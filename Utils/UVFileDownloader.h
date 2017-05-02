//
//  UVFileDownloader.h
//  UView
//
//  Created by JinHao on 9/26/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UVFileDownloadProgressUpdateBlock)(double progress);
typedef void (^UVFileDownloadCompletionBlock)(NSArray *filePaths);
typedef void (^UVFileDownloadFailedBlock)();

@interface UVFileDownloader : NSObject

- (void)downloadFileFromURLs:(NSArray *)urls
              progressUpdate:(UVFileDownloadProgressUpdateBlock)progressUpdate
                  completion:(UVFileDownloadCompletionBlock)completion
                       error:(UVFileDownloadFailedBlock)failed;

- (void)cancelDownload;

@end
