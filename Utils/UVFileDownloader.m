//
//  UVFileDownloader.m
//  UView
//
//  Created by JinHao on 9/26/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import "UVFileDownloader.h"
#import <TCBlobDownload.h>
#import <FCFileManager.h>

@interface UVFileDownloaderProgressState : NSObject

@property (nonatomic, assign) uint64_t receivedLength;
@property (nonatomic, assign) uint64_t totalLength;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, assign) BOOL finished;

@end

@implementation UVFileDownloaderProgressState

@end

@interface UVFileDownloader () <TCBlobDownloaderDelegate>

@property (nonatomic, strong) TCBlobDownloadManager *manager;
@property (nonatomic, strong) NSArray *downloaders;
@property (nonatomic, strong) NSArray *downloaderProgressStates;

@property (nonatomic, copy) UVFileDownloadProgressUpdateBlock progressUpdate;
@property (nonatomic, copy) UVFileDownloadCompletionBlock completion;
@property (nonatomic, copy) UVFileDownloadFailedBlock failed;

@end

@implementation UVFileDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[TCBlobDownloadManager alloc] init];
        [_manager setMaxConcurrentDownloads:3];
    }
    return self;
}

- (void)downloadFileFromURLs:(NSArray *)urls
              progressUpdate:(UVFileDownloadProgressUpdateBlock)progressUpdate
                  completion:(UVFileDownloadCompletionBlock)completion
                       error:(UVFileDownloadFailedBlock)failed
{
    [self invalidate];

    self.progressUpdate = progressUpdate;
    self.completion = completion;
    self.failed = failed;

    self.downloaderProgressStates = [urls bk_map: ^id (NSURL *url) {
        UVFileDownloaderProgressState *state = [[UVFileDownloaderProgressState alloc] init];
        state.url = url;
        
        NSString *filePath = [self cachedResourcePathForURL:url];
        if ([self fileExistAtPath:filePath]) {
            state.finished = YES;
            state.filePath = filePath;
            state.totalLength = 1;
            state.receivedLength = 1;
        }
        
        return state;
    }];
    
    self.downloaders = [self.downloaderProgressStates bk_map: ^id (UVFileDownloaderProgressState *state) {
        return state.finished ? [NSNull null] : [self createDownloaderForURL:state.url];
    }];
    
    if ([self.downloaders bk_all:^BOOL(id obj) {
        return [obj isKindOfClass:[NSNull class]];
    }]) {
        
        [self updateProgress];
        [self checkIfComplete];
        
    } else {
        [[self.downloaders bk_select:^BOOL(id obj) {
            return [obj isKindOfClass:[TCBlobDownloader class]];
        }] bk_each: ^(id downloader) {
            [self.manager startDownload:downloader];
        }];
    }
}

- (TCBlobDownloader *)createDownloaderForURL:(NSURL *)url {
    TCBlobDownloader *downloader = [[TCBlobDownloader alloc] initWithURL:url
                                                            downloadPath:[self downloadPath]
                                                                delegate:self];
    
    downloader.fileName = [self fileNameForURL:url];
    return downloader;
}

- (void)cancelDownload
{
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
}

- (void)invalidate
{
    [self cancelDownload];
}

- (UVFileDownloaderProgressState *)stateForDownloader:(TCBlobDownloader *)downloader
{
    return self.downloaderProgressStates[[self.downloaders indexOfObject:downloader]];
}

- (void)updateProgress
{
    uint64_t totalLength = [[self.downloaderProgressStates bk_reduce:@(0) withBlock: ^id (NSNumber *sum, UVFileDownloaderProgressState *state) {
        return @(sum.longLongValue + state.totalLength);
    }] longLongValue];

    uint64_t receivedLength = [[self.downloaderProgressStates bk_reduce:@(0) withBlock: ^id (NSNumber *sum, UVFileDownloaderProgressState *state) {
        return @(sum.longLongValue + state.receivedLength);
    }] longLongValue];
    
    if (self.progressUpdate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressUpdate([self progressWithTotal:(double)totalLength progressValue:(double)receivedLength]);
        });
    }
}

- (void)checkIfComplete {
    if ([self.downloaderProgressStates bk_all: ^BOOL (UVFileDownloaderProgressState *state) {
        return state.finished;
    }]) {
        if (self.completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completion([self.downloaderProgressStates bk_map:^id(UVFileDownloaderProgressState *state) {
                    return state.filePath;
                }]);
            });
        }
    }
}

- (double)progressWithTotal:(double)totalValue progressValue:(double)progressValue {
    return (totalValue == 0) ? 0 : progressValue / totalValue;
}

- (void)moveFileToCachedResourcePath:(NSString *)filePath {
    NSString *destPath = [self cachedResourcePathForFileName:filePath.lastPathComponent];
    [FCFileManager removeItemAtPath:destPath];
    [FCFileManager moveItemAtPath:filePath toPath:destPath];
}

#pragma mark - Paths

- (NSString *)downloadPath
{
    return [FCFileManager pathForCachesDirectory];
}

- (NSString *)cachedResourcePathForFileName:(NSString *)fileName {
    return [[FCFileManager pathForCachesDirectoryWithPath:@"Resources"] stringByAppendingPathComponent:fileName];
}

- (NSString *)cachedResourcePathForURL:(NSURL *)url {
    return [self cachedResourcePathForFileName:[self fileNameForURL:url]];
}

- (NSString *)fileNameForURL:(NSURL *)url
{
    return [url.absoluteString.md5 stringByAppendingPathExtension:url.pathExtension];
}

- (BOOL)fileExistAtPath:(NSString *)path {
    return [FCFileManager isFileItemAtPath:path];
}

#pragma mark - Downloader Delegate

- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    UVFileDownloaderProgressState *state = [self stateForDownloader:blobDownload];
    [self moveFileToCachedResourcePath:pathToFile];
    state.filePath = [self cachedResourcePathForFileName:pathToFile.lastPathComponent];
    state.finished = downloadFinished;
    [self checkIfComplete];
}

- (void)  download:(TCBlobDownloader *)blobDownload
    didReceiveData:(uint64_t)receivedLength
           onTotal:(uint64_t)totalLength
          progress:(float)progress
{
    UVFileDownloaderProgressState *state = [self stateForDownloader:blobDownload];
    state.receivedLength = receivedLength;
    state.totalLength = totalLength;
    [self updateProgress];
}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    [self cancelDownload];

    if (self.failed) {
        self.failed();
    }
}

@end
