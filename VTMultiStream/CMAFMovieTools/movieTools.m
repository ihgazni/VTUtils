//
//  movieTools.m
//  UView
//
//  Created by dli on 1/13/16.
//  Copyright © 2016 YesView. All rights reserved.
//



#import "movieTools.h"



@implementation movieTools



@end

////<info>
float getTotalLengthOfMovieFromAsset(AVAsset *someAsset, int whichTrack,NSString*mediaType)
{
    NSError *outError;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:someAsset error:&outError];
    
    NSArray * audioTracks = [assetReader.asset tracksWithMediaType:AVMediaTypeAudio];
    NSArray * videoTracks = [assetReader.asset tracksWithMediaType:AVMediaTypeVideo];
    
    
    CMTime start;
    CMTime duration;
    CMTime length;
    
    if ([mediaType isEqualToString:@"audio"]) {
        AVAssetTrack * at = (AVAssetTrack *) audioTracks[whichTrack];
        start = at.timeRange.start;
        duration = at.timeRange.duration;
    } else {
        AVAssetTrack * vt = (AVAssetTrack *) videoTracks[whichTrack];
        start = vt.timeRange.start;
        duration = vt.timeRange.duration;
    }
    
    length = CMTimeAdd(start, duration);
    float rslt = ((float)length.value)/((float)length.timescale);
    return(rslt);
    
    
}
int getTimeScaleFromAsset(AVAsset *someAsset, int whichTrack,NSString*mediaType)
{
    NSError *outError;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:someAsset error:&outError];
    
    NSArray * audioTracks = [assetReader.asset tracksWithMediaType:AVMediaTypeAudio];
    NSArray * videoTracks = [assetReader.asset tracksWithMediaType:AVMediaTypeVideo];
    

    CMTime start;
    CMTime duration;

    if ([mediaType isEqualToString:@"audio"]) {
        AVAssetTrack * at = (AVAssetTrack *) audioTracks[whichTrack];
        start = at.timeRange.start;
        duration = at.timeRange.duration;
        
    } else {
        AVAssetTrack * vt = (AVAssetTrack *) videoTracks[whichTrack];
        start = vt.timeRange.start;
        duration = vt.timeRange.duration;
    }
    
    
    return(start.timescale);
    
}
////</info>



////<tracks>
////<tracks><elegir>
NSMutableArray * elegirAllAudioTracksFromAVAsset(AVAsset* asset,BOOL COPYITEM)
{
    NSMutableArray * audioTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeAudio] copyItems:COPYITEM];
    return(audioTracks);
    
}
NSMutableArray * elegirAllVideoTracksFromAVAsset(AVAsset* asset,BOOL COPYITEM)
{
    NSMutableArray * videoTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeVideo] copyItems:COPYITEM];
    return(videoTracks);
}
////<tracks></elegir>
////<tracks><array>
NSMutableArray * putAllAudioTracksToArrayFromAVAssets(NSMutableArray * assets,BOOL COPYITEM)
{
    NSMutableArray * audioTracks = [[NSMutableArray alloc] init];
    for (int i =0; i<assets.count; i++) {
        AVAsset* asset = assets[i];
        NSMutableArray * tempAudioTracks = elegirAllAudioTracksFromAVAsset(asset,COPYITEM);
        for (int j =0; j< tempAudioTracks.count; j++) {
            [audioTracks addObject:tempAudioTracks[j]];
        }
    }
    return(audioTracks);
}
NSMutableArray * putAllVideoTracksToArrayFromAVAssets(NSMutableArray * assets,BOOL COPYITEM)
{
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    for (int i =0; i<assets.count; i++) {
        AVAsset* asset = assets[i];
        NSMutableArray * tempVideoTracks = elegirAllVideoTracksFromAVAsset(asset,COPYITEM);
        for (int j =0; j< tempVideoTracks.count; j++) {
            [videoTracks addObject:tempVideoTracks[j]];
        }
    }
    return(videoTracks);
}
////<tracks></array>
////</tracks>

////---save to file
void saveWithExportSession(AVAssetExportSession* assetExport,BOOL SYNC,BOOL SAVETOALBUM)
{

    __block dispatch_semaphore_t semaCanReturn;
    
    if (SYNC) {
        semaCanReturn = dispatch_semaphore_create(0);
    } else {
        
    }
    
    [assetExport exportAsynchronouslyWithCompletionHandler:^{

        
        switch (assetExport.status)
        {
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"AVAssetExportSessionStatusCancelled");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"AVAssetExportSessionStatusExporting");
                break;
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"AVAssetExportSessionStatusUnknown");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"AVAssetExportSessionStatusWaiting");
                break;
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"Export Failed with error.userInfo: %@", assetExport.error.userInfo);
                NSLog(@"Export Failed with error: %@", assetExport.error);
                NSLog(@"Export Failed with error.description: %@", assetExport.error.description);
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                if (SAVETOALBUM) {
                    [FileUitl writeVideoToPhotoLibrary:assetExport.outputURL];
                }
                break;
            }
            
        }
        
        
        if (SYNC) {
            dispatch_semaphore_signal(semaCanReturn);
        }
    }];
    
    ////The NSRunLoop class is generally not considered to be thread-safe
    ////and its methods should only be called within the context of the current thread.
    ////You should never try to call the methods of an NSRunLoop object running in a
    ////different thread, as doing so might cause unexpected results.
    
    
    if (SYNC) {
        while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    } else {
        
    }
    
}

////---remove video PT
AVMutableVideoComposition * getVideoCompositionForRemovingPT(AVAssetTrack * videoTrack,AVMutableCompositionTrack *compositionVideoTrack)
{
    CGAffineTransform t2 = [videoTrack preferredTransform];
    
    

    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, compositionVideoTrack.timeRange.duration);
    
    
    
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    [layerInstruction setTransform:t2 atTime:kCMTimeZero];
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [compositionVideoTrack nominalFrameRate]);
    
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        mainVideoComp.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        mainVideoComp.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
    } else {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    }
    
    return(mainVideoComp);
   
}


////----把track保存成file
void saveAudioTrackToFile(AVAssetTrack * audioTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM)
{

   
    ////对于同一条audioTrack
    ////如果直接使用 AVAssetExportPresetHighestQuality + AVFileTypeQuickTimeMovie
    ////来输出不带视频的纯音频movie,那么编码是AAC + mono
    ////如果直接使用 AVAssetExportPresetAppleM4A + AVFileTypeAppleM4A
    ////来输出不带视频的纯音频movie,那么编码是AAC + stero(L R)
    ////声道对应channel ,一个audioTrack可以包含多个channel
    ////在channel层面处理audio
    ////参阅https://developer.apple.com/library/ios/samplecode/AudioTapProcessor/Listings/AudioTapProcessor_MYAudioTapProcessor_h.html#//apple_ref/doc/uid/DTS40012324-AudioTapProcessor_MYAudioTapProcessor_h-DontLinkElementID_5
    
    
    if (preset) {
        
    } else {
        preset = AVAssetExportPresetAppleM4A;
    }
    if (outputFileType) {
        
    } else {
        outputFileType = AVFileTypeAppleM4A;
    }
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:preset];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
    ////M4A 必须setVolume 否则 －12780 error
    [audioInputParams setVolume:1.0 atTime:kCMTimeZero];
    audioMix.inputParameters = [NSArray arrayWithObject:audioInputParams];

    assetExport.timeRange = audioTrack.timeRange;
    assetExport.outputFileType = outputFileType;
    assetExport.audioMix = audioMix;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;

    
    saveWithExportSession(assetExport, SYNC,SAVETOALBUM);

    
}
void saveVideoTrackToFile(AVAssetTrack * videoTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM)
{
    
    if (preset) {
        
    } else {
        preset = AVAssetExportPresetHighestQuality;
    }
    if (outputFileType) {
        
    } else {
        outputFileType = AVFileTypeQuickTimeMovie;
    }
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:preset];
    
    AVMutableVideoComposition *mainVideoComp = getVideoCompositionForRemovingPT(videoTrack, compositionVideoTrack);
    
    assetExport.videoComposition = mainVideoComp;
    assetExport.outputFileType = outputFileType;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
    
}


void trimAudioTrackToFile(CMTime trimTo,AVAssetTrack * audioTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM)
{
    
    
    ////对于同一条audioTrack
    ////如果直接使用 AVAssetExportPresetHighestQuality + AVFileTypeQuickTimeMovie
    ////来输出不带视频的纯音频movie,那么编码是AAC + mono
    ////如果直接使用 AVAssetExportPresetAppleM4A + AVFileTypeAppleM4A
    ////来输出不带视频的纯音频movie,那么编码是AAC + stero(L R)
    ////声道对应channel ,一个audioTrack可以包含多个channel
    ////在channel层面处理audio
    ////参阅https://developer.apple.com/library/ios/samplecode/AudioTapProcessor/Listings/AudioTapProcessor_MYAudioTapProcessor_h.html#//apple_ref/doc/uid/DTS40012324-AudioTapProcessor_MYAudioTapProcessor_h-DontLinkElementID_5
    
    
    if (preset) {
        
    } else {
        preset = AVAssetExportPresetAppleM4A;
    }
    if (outputFileType) {
        
    } else {
        outputFileType = AVFileTypeAppleM4A;
    }


    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    if (CMTimeCompare(trimTo, CMTimeAdd(audioTrack.timeRange.start, audioTrack.timeRange.duration)) >= 0) {
        [compositionAudioTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    } else {
        CMTimeRange newTimeRangeForInsert =   CMTimeRangeMake(audioTrack.timeRange.start, CMTimeSubtract(trimTo, audioTrack.timeRange.start));
        [compositionAudioTrack insertTimeRange:newTimeRangeForInsert ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    }

    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:preset];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
    ////M4A 必须setVolume 否则 －12780 error
    [audioInputParams setVolume:1.0 atTime:kCMTimeZero];
    audioMix.inputParameters = [NSArray arrayWithObject:audioInputParams];
    
    assetExport.timeRange = audioTrack.timeRange;
    assetExport.outputFileType = outputFileType;
    assetExport.audioMix = audioMix;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    saveWithExportSession(assetExport, SYNC,SAVETOALBUM);
    
    
}
void trimVideoTrackToFile(CMTime trimTo,AVAssetTrack * videoTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM)
{
    
    if (preset) {
        
    } else {
        preset = AVAssetExportPresetHighestQuality;
    }
    if (outputFileType) {
        
    } else {
        outputFileType = AVFileTypeQuickTimeMovie;
    }
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    if (CMTimeCompare(trimTo, CMTimeAdd(videoTrack.timeRange.start, videoTrack.timeRange.duration)) >= 0) {
        [compositionVideoTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    } else {
        CMTimeRange newTimeRangeForInsert =   CMTimeRangeMake(videoTrack.timeRange.start, CMTimeSubtract(trimTo, videoTrack.timeRange.start));
        [compositionVideoTrack insertTimeRange:newTimeRangeForInsert ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    }
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:preset];
    
    AVMutableVideoComposition *mainVideoComp = getVideoCompositionForRemovingPT(videoTrack, compositionVideoTrack);
    
    assetExport.videoComposition = mainVideoComp;
    assetExport.outputFileType = outputFileType;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
    
}


void rangeAudioTrackToFile(CMTime trimFrom,CMTime trimTo,AVAssetTrack * audioTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM)
{
    
    
    ////对于同一条audioTrack
    ////如果直接使用 AVAssetExportPresetHighestQuality + AVFileTypeQuickTimeMovie
    ////来输出不带视频的纯音频movie,那么编码是AAC + mono
    ////如果直接使用 AVAssetExportPresetAppleM4A + AVFileTypeAppleM4A
    ////来输出不带视频的纯音频movie,那么编码是AAC + stero(L R)
    ////声道对应channel ,一个audioTrack可以包含多个channel
    ////在channel层面处理audio
    ////参阅https://developer.apple.com/library/ios/samplecode/AudioTapProcessor/Listings/AudioTapProcessor_MYAudioTapProcessor_h.html#//apple_ref/doc/uid/DTS40012324-AudioTapProcessor_MYAudioTapProcessor_h-DontLinkElementID_5
    
    
    if (preset) {
        
    } else {
        preset = AVAssetExportPresetAppleM4A;
    }
    if (outputFileType) {
        
    } else {
        outputFileType = AVFileTypeAppleM4A;
    }
    
    
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    


    
    if (CMTimeCompare(trimFrom,audioTrack.timeRange.start) < 0 ) {
        trimFrom = audioTrack.timeRange.start ;
    }
    if (CMTimeCompare(trimTo, CMTimeAdd(audioTrack.timeRange.start, audioTrack.timeRange.duration)) >= 0) {
        trimTo = CMTimeAdd(audioTrack.timeRange.start, audioTrack.timeRange.duration);
    }
    
    CMTimeRange newTimeRangeForInsert =   CMTimeRangeMake(trimFrom, CMTimeSubtract(trimTo, trimFrom));
    [compositionAudioTrack insertTimeRange:newTimeRangeForInsert ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    
    
    
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:preset];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
    ////M4A 必须setVolume 否则 －12780 error
    [audioInputParams setVolume:1.0 atTime:kCMTimeZero];
    audioMix.inputParameters = [NSArray arrayWithObject:audioInputParams];
    
    assetExport.timeRange = audioTrack.timeRange;
    assetExport.outputFileType = outputFileType;
    assetExport.audioMix = audioMix;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    saveWithExportSession(assetExport, SYNC,SAVETOALBUM);
    
    
}
void rangeVideoTrackToFile(CMTime trimFrom,CMTime trimTo,AVAssetTrack * videoTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM)
{
    
    if (preset) {
        
    } else {
        preset = AVAssetExportPresetHighestQuality;
    }
    if (outputFileType) {
        
    } else {
        outputFileType = AVFileTypeQuickTimeMovie;
    }
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    if (CMTimeCompare(trimFrom,videoTrack.timeRange.start) < 0 ) {
        trimFrom = videoTrack.timeRange.start ;
    }
    if (CMTimeCompare(trimTo, CMTimeAdd(videoTrack.timeRange.start, videoTrack.timeRange.duration)) >= 0) {
        trimTo = CMTimeAdd(videoTrack.timeRange.start, videoTrack.timeRange.duration);
    }
    
    CMTimeRange newTimeRangeForInsert =   CMTimeRangeMake(trimFrom, CMTimeSubtract(trimTo, trimFrom));
    [compositionVideoTrack insertTimeRange:newTimeRangeForInsert ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:preset];
    
    AVMutableVideoComposition *mainVideoComp = getVideoCompositionForRemovingPT(videoTrack, compositionVideoTrack);
    
    assetExport.videoComposition = mainVideoComp;
    assetExport.outputFileType = outputFileType;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
    
}


void repeatAudioTrackToFile(float times,AVAssetTrack * audioTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM)
{
    
    if (preset) {
        
    } else {
        preset = AVAssetExportPresetAppleM4A;
    }
    if (outputFileType) {
        
    } else {
        outputFileType = AVFileTypeAppleM4A;
    }
    
    CMTime curr = audioTrack.timeRange.start;
    
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    int completeRounds = floorf(times);
    for (int i = 0; i< times; i++) {
        [compositionAudioTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTrack atTime:curr error:nil];
        curr = CMTimeAdd(curr, audioTrack.timeRange.duration);
    }

    float lefted = times - completeRounds;
    CMTime lastDu = CMTimeMultiplyByFloat64(audioTrack.timeRange.duration, lefted);
    CMTimeRange lastTr = CMTimeRangeMake(curr, lastDu);
    [compositionAudioTrack insertTimeRange:lastTr ofTrack:audioTrack atTime:curr error:nil];
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:preset];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
    ////M4A 必须setVolume 否则 －12780 error
    [audioInputParams setVolume:1.0 atTime:kCMTimeZero];
    audioMix.inputParameters = [NSArray arrayWithObject:audioInputParams];
    
    assetExport.timeRange = audioTrack.timeRange;
    assetExport.outputFileType = outputFileType;
    assetExport.audioMix = audioMix;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    saveWithExportSession(assetExport, SYNC,SAVETOALBUM);
    
}
void repeatVideoTrackToFile(float times,AVAssetTrack * videoTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM)
{
    if (preset) {
        
    } else {
        preset = AVAssetExportPresetHighestQuality;
    }
    if (outputFileType) {
        
    } else {
        outputFileType = AVFileTypeQuickTimeMovie;
    }
    
    CMTime curr = videoTrack.timeRange.start;
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    int completeRounds = floorf(times);
    for (int i = 0; i< completeRounds; i++) {
        [compositionVideoTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTrack atTime:curr error:nil];
        curr = CMTimeAdd(curr, videoTrack.timeRange.duration);

    }


    float lefted = times - completeRounds;
    CMTime lastDu = CMTimeMultiplyByFloat64(videoTrack.timeRange.duration, lefted);
    lastDu = CMTimeConvertScale(lastDu, videoTrack.timeRange.duration.timescale, kCMTimeRoundingMethod_QuickTime);
    CMTimeRange lastTr = CMTimeRangeMake(kCMTimeZero, lastDu);
    
    
    [compositionVideoTrack insertTimeRange:lastTr ofTrack:videoTrack atTime:curr error:nil];
    
    
    curr = CMTimeAdd(curr, lastDu);
    
    
 
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:preset];
    

    AVMutableVideoComposition *mainVideoComp = getVideoCompositionForRemovingPT(videoTrack, compositionVideoTrack);
    
    
    
    
    assetExport.videoComposition = mainVideoComp;
    assetExport.outputFileType = outputFileType;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
}




////----trim
void trimSingleTrackAudioToFileFromURL(NSURL*sourceAudioURL,NSURL*destAudioURL,CMTime trimTo,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM)
{
    
    AVAsset * asset = [AVAsset assetWithURL:sourceAudioURL];
    NSMutableArray * audioTracks = elegirAllAudioTracksFromAVAsset(asset,NO);
    AVAssetTrack * audioTrack = audioTracks[whichTrack];
    trimAudioTrackToFile(trimTo,audioTrack,SYNC,AVAssetExportPresetHighestQuality,destAudioURL,AVFileTypeQuickTimeMovie,SAVETOALBUM);
    
}
void trimSingleTrackVideoToFileFromURL(NSURL*sourceVideoURL,NSURL*destVideoURL,CMTime trimTo,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM)
{
    
    AVAsset * asset = [AVAsset assetWithURL:sourceVideoURL];
    NSMutableArray * videoTracks = elegirAllVideoTracksFromAVAsset(asset,NO);
    AVAssetTrack * videoTrack = videoTracks[whichTrack];
    trimVideoTrackToFile(trimTo,videoTrack,SYNC,AVAssetExportPresetHighestQuality,destVideoURL,AVFileTypeQuickTimeMovie,SAVETOALBUM);
    
}
void rangeSingleTrackAudioToFileFromURL(NSURL*sourceAudioURL,NSURL*destAudioURL,CMTime trimFrom,CMTime trimTo,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM)
{
    
    AVAsset * asset = [AVAsset assetWithURL:sourceAudioURL];
    NSMutableArray * audioTracks = elegirAllAudioTracksFromAVAsset(asset,NO);
    AVAssetTrack * audioTrack = audioTracks[whichTrack];
    rangeAudioTrackToFile(trimFrom,trimTo,audioTrack,SYNC,AVAssetExportPresetHighestQuality,destAudioURL,AVFileTypeQuickTimeMovie,SAVETOALBUM);
    
}
void rangeSingleTrackVideoToFileFromURL(NSURL*sourceVideoURL,NSURL*destVideoURL,CMTime trimFrom,CMTime trimTo,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM)
{
    
    AVAsset * asset = [AVAsset assetWithURL:sourceVideoURL];
    NSMutableArray * videoTracks = elegirAllVideoTracksFromAVAsset(asset,NO);
    AVAssetTrack * videoTrack = videoTracks[whichTrack];
    rangeVideoTrackToFile(trimFrom,trimTo,videoTrack,SYNC,AVAssetExportPresetHighestQuality,destVideoURL,AVFileTypeQuickTimeMovie,SAVETOALBUM);
    
}


////----trim


////----repeat
void repeatSingleTrackVideoToFileFromURL(NSURL*sourceVideoURL,NSURL*destVideoURL,float times,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM)
{
    
    AVAsset * asset = [AVAsset assetWithURL:sourceVideoURL];
    NSMutableArray * videoTracks = elegirAllVideoTracksFromAVAsset(asset,NO);
    AVAssetTrack * videoTrack = videoTracks[whichTrack];
    repeatVideoTrackToFile(times,videoTrack,SYNC,AVAssetExportPresetHighestQuality,destVideoURL,AVFileTypeQuickTimeMovie,SAVETOALBUM);
    
}
////----repeat



////----split
////----把movie 按照音轨 视轨 彻底分解,并存储
NSMutableDictionary * splitMovieToFilesByTracksFromURL(NSURL*sourceMovieURL,NSURL*destAudioDirURL,NSURL*destVideoDirURL,BOOL SYNC,BOOL SAVETOALBUM)
{
    NSString * path = [sourceMovieURL path];
    NSString * movieName = [path lastPathComponent];
    NSString * movieNameWithoutSuffix = [movieName stringByDeletingPathExtension];
    AVAsset * asset = [AVAsset assetWithURL:sourceMovieURL];
    
    ////NSLog(@"asset:%@",asset);
    ////NSLog(@"asset.tracks:%@",asset.tracks);
    
    NSMutableArray * audioTracks = elegirAllAudioTracksFromAVAsset(asset,NO);
    NSMutableArray * videoTracks = elegirAllVideoTracksFromAVAsset(asset,NO);
    NSMutableArray * destAudioURLs = [[NSMutableArray alloc] init];
    NSMutableArray * destVideoURLs = [[NSMutableArray alloc] init];
    
    NSLog(@"audioTracks.count:%lu",(unsigned long)audioTracks.count);
    NSLog(@"videoTracks.count:%lu",(unsigned long)videoTracks.count);

    for (int i = 0; i<audioTracks.count; i++) {
        NSString * destAudioDirPath = [destAudioDirURL path];
        NSString * destAudioPath = [destAudioDirPath stringByAppendingPathComponent:movieNameWithoutSuffix];
        destAudioPath = [destAudioPath stringByAppendingFormat:@"_%d.m4a",i];
        NSURL * destAudioURL = [NSURL fileURLWithPath:destAudioPath];
        
        NSLog(@"destAudioURL:%@",destAudioURL);
        
        [destAudioURLs addObject:destAudioURL];
        saveAudioTrackToFile(audioTracks[i],SYNC,AVAssetExportPresetAppleM4A,destAudioURL,AVFileTypeAppleM4A,SAVETOALBUM);
        
    }
    
    
    for (int i = 0; i<videoTracks.count; i++) {
        NSString * destVideoDirPath = [destVideoDirURL path];
        NSString * destVideoPath = [destVideoDirPath stringByAppendingPathComponent:movieNameWithoutSuffix];
        destVideoPath = [destVideoPath stringByAppendingFormat:@"_%d.mov",i];
        NSURL * destVideoURL = [NSURL fileURLWithPath:destVideoPath];
        
        NSLog(@"destVideoURL:%@",destVideoURL);
        
        [destVideoURLs addObject:destVideoURL];
        saveVideoTrackToFile(videoTracks[i],SYNC,AVAssetExportPresetHighestQuality,destVideoURL,AVFileTypeQuickTimeMovie,SAVETOALBUM);
        
    }
    

    NSMutableDictionary * rslt = [[NSMutableDictionary alloc] init];
    [rslt setValue:destAudioURLs forKey:@"audio"];
    [rslt setValue:destVideoURLs forKey:@"video"];
    /*
    if (SYNC) {
        asset = NULL;
        audioTracks = NULL;
        videoTracks = NULL;
    }
    */
    return(rslt);
  
}


////----把audioTrack中的多个channel分离成多个mono channel track,并存储成多个文件
NSMutableArray * splitAudioChannelsInSingleTrackToMultiMonoTrackFiles(NSURL*sourceAudioURL,NSURL*destAudioDirURL,BOOL SYNC,BOOL SAVETOALBUM)
{
    ////一个reader 是可以有多个 readerOutput
    ////SND_PCM_ACCESS_RW_INTERLEAVED
    ////交错访问。在缓冲区的每个 PCM 帧都包含所有设置的声道的连续的采样数据。
    ////比如声卡要播放采样长度是 16-bit 的 PCM 立体声数据，表示每个 PCM 帧中有 16-bit 的左声道数据，
    ////然后是 16-bit 右声道数据。
    ////SND_PCM_ACCESS_RW_NONINTERLEAVED
    ////非交错访问。每个 PCM 帧只是一个声道需要的数据，如果使用多个声道，那么第一帧是第一个声道的数据，
    ////第二帧是第二个声道的数据，依此类推。
    ////
    NSString * path = [sourceAudioURL path];
    NSString * movieName = [path lastPathComponent];
    NSString * movieNameWithoutSuffix = [movieName stringByDeletingPathExtension];
    NSMutableArray * destAudioURLs = [[NSMutableArray alloc] init];
    AVAsset * asset = [AVAsset assetWithURL:sourceAudioURL];
    AVAssetTrack * audioTrack = asset.tracks[0];
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:nil];
    CMAudioFormatDescriptionRef fDesc = (__bridge CMAudioFormatDescriptionRef)(audioTrack.formatDescriptions[0]);
    NSMutableDictionary * audioReaderOutputSettings = getAudioReaderOutputSettingsFromCMAudioFormatDescription(fDesc,16);
    size_t formatListSize = 0;
    const AudioFormatListItem *formatList = CMAudioFormatDescriptionGetFormatList(fDesc, &formatListSize);
    AudioFormatListItem fl = (*formatList);
    AudioStreamBasicDescription mASBD = fl.mASBD;
    int count =1;
    if (mASBD.mChannelsPerFrame <=1) {
        count = 1;
    } else {
        count = mASBD.mChannelsPerFrame;
    }
    int stride = 0;
    int channelByte =0;
    {
        int bitDepth = mASBD.mBitsPerChannel;
        int channels = mASBD.mChannelsPerFrame;
        if (bitDepth ==0) {
            bitDepth = 16;
        }
        if (channels <=1) {
            channels = 1;
        }
        
        stride = bitDepth * channels /8 ;
        channelByte = bitDepth /8;
        
    }
    

    
    NSMutableArray * trackOutputs = [[NSMutableArray alloc] init];
    NSMutableArray * writerInputs = [[NSMutableArray alloc] init];
    NSMutableArray * writers = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *audioWriterInputOutputSettings = creatMonoAudioWriterInputOutputSettingsFromCMAudioFormatDescription(fDesc,24);
    
    for (int i = 0; i<count; i++) {
        NSString * destAudioDirPath = [destAudioDirURL path];
        NSString * destAudioPath = [destAudioDirPath stringByAppendingPathComponent:movieNameWithoutSuffix];
        destAudioPath = [destAudioPath stringByAppendingFormat:@"_%d.m4a",i];
        NSURL * destAudioURL = [NSURL fileURLWithPath:destAudioPath];
        [destAudioURLs addObject:destAudioURL];
        AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:destAudioURL  fileType:AVFileTypeAppleM4A error:nil];
        [writers addObject:assetWriter];
        AVAssetWriterInput *input;
        input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioWriterInputOutputSettings];
        input.expectsMediaDataInRealTime = NO;
        [writerInputs addObject:input];
        [assetWriter addInput:input];
        [assetWriter startWriting];
        [assetWriter startSessionAtSourceTime:kCMTimeZero];
        
        AVAssetReaderTrackOutput *trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioReaderOutputSettings];
        [assetReader addOutput:trackOutput];
        [trackOutputs addObject:trackOutput];
    }
    
    [assetReader startReading];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t dispatchQueue = dispatch_queue_create("QUEUE", DISPATCH_QUEUE_CONCURRENT);

    for (int i = 0; i<count; i++) {
        
        dispatch_group_async(dispatchGroup, dispatchQueue, ^{
            CMTime endSessionAtSourceTime = kCMTimeZero;
            AVAssetReaderTrackOutput *trackOutput = trackOutputs[i];
            AVAssetWriterInput *input = writerInputs[i];
            AVAssetWriter * assetWriter = writers[i];
            BOOL done = NO;
            while (!done)
            {
                while (![input isReadyForMoreMediaData]) {
                    [NSThread sleepForTimeInterval:0.001f];
                }
                CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
                if (sampleBuffer)
                {
                    NSMutableData * bufferMono = [NSMutableData new];
                    AudioBufferList  audioBufferList;
                    CMBlockBufferRef blockBuffer;
                    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
                    CMItemCount count;
                    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
                    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
                    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, count, pInfo, &count);
                    for (CMItemCount i = 0; i < count; i++)
                    {
                        pInfo[i].decodeTimeStamp = pInfo[i].presentationTimeStamp;
                        endSessionAtSourceTime = CMTimeAdd(pInfo[i].presentationTimeStamp,pInfo[i].duration);
                    }
                    for (int y=0; y<audioBufferList.mNumberBuffers; y++)
                    {
                        AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
                        //Append mono of channel i  buffer data
                        for (int z=i; z<audioBuffer.mDataByteSize; z= z+stride) {
                            [bufferMono appendBytes:(audioBuffer.mData+z) length:channelByte];
                        }
                        
                    }
                    Byte * byteData = [FileUitl copyNSDataToByteData:bufferMono];
                    bufferMono = NULL;
                    long numSamples = CMSampleBufferGetNumSamples(sampleBuffer);
                    CMFormatDescriptionRef format = creatMonoAudioFormatDescFromOrigLinePCMSampleBuffer(sampleBuffer, 16);
                    CMSampleBufferRef newSampleBuffer = NULL;
                    OSStatus status = CMSampleBufferCreate(kCFAllocatorDefault, NULL, false, NULL, NULL, format, numSamples, 1, pInfo, 0, NULL, &newSampleBuffer);
                    CFRelease(format);
                    format = NULL;
                    free(pInfo);
                    CFRelease(sampleBuffer);
                    if (status != noErr) {
                        NSLog(@"Failed to create sample buffer");
                        break;
                    }
                    
                    AudioBufferList * newAudioBufferList;
                    newAudioBufferList = allocateNewAudioBufferList(1, 1, 16, NO, (UInt32)numSamples);
                    free(newAudioBufferList->mBuffers[0].mData);
                    newAudioBufferList->mBuffers[0].mData = byteData;
                    status = CMSampleBufferSetDataBufferFromAudioBufferList(newSampleBuffer,
                                                                            kCFAllocatorDefault,
                                                                            kCFAllocatorDefault,
                                                                            0,
                                                                            newAudioBufferList);
                    if (status != noErr) {
                        NSLog(@"Failed to add samples to sample buffer:%d",status);
                        CFRelease(newSampleBuffer);
                        freeAudioBufferList(newAudioBufferList);
                        break;
                    }
                    [input appendSampleBuffer:newSampleBuffer];
                    CFRelease(newSampleBuffer);
                    freeAudioBufferList(newAudioBufferList);
                    
                    
                    
                }
                else
                {
                    [input markAsFinished];
                    if (assetReader.status == AVAssetReaderStatusFailed){
                        NSLog(@"the reader failed: %@", assetReader.error);
                        break;
                    }
                    [assetWriter endSessionAtSourceTime:endSessionAtSourceTime];
                    [assetWriter finishWritingWithCompletionHandler:^{
                        NSLog(@"finished");
                        if (SAVETOALBUM) {
                            [FileUitl writeVideoToPhotoLibrary:destAudioURLs[i]];
                        }
                    }];
                    done = YES;
                    break;
                    
                }
            }
           });
        
    }
    
    
    __block dispatch_semaphore_t semaCanReturn;
    if (SYNC) {
        semaCanReturn = dispatch_semaphore_create(0);
    } else {
        
    }
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        if (SYNC) {
            dispatch_semaphore_signal(semaCanReturn);
        } else {
            
        }
    });
    
    if (SYNC) {
        while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
    } else {
        
    }
    
    
    return(NULL);
}


////----combine
////----把多个音频audioTracks合并到一个track的不同channel上
void combineAudioFilesToMultiChannelAudioFile(NSMutableArray*sourceAudioURLs,NSURL * destAudioURL, BOOL SYNC,BOOL SAVETOALBUM)
{
    
}

////----把多个音频文件合成一个音频文件的多条track
void combineAudioFilesToMultiTracksAudioFile(NSMutableArray*sourceAudioURLs,NSURL * destAudioURL, BOOL SYNC,BOOL SAVETOALBUM)
{
    NSMutableArray * assets = [[NSMutableArray alloc] init];
    NSMutableArray * readers = [[NSMutableArray alloc] init];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:destAudioURL  fileType:AVFileTypeAppleM4A error:nil];
    
    
    for (int i = 0; i<sourceAudioURLs.count; i++) {
        AVAsset * asset = [AVAsset assetWithURL:sourceAudioURLs[i]];
        [assets addObject:asset];
        AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:nil];
        [readers addObject:assetReader];
    }
    NSMutableArray * audioTracks = putAllAudioTracksToArrayFromAVAssets(assets, NO);
    CMTime mergedAudioDuration = getMaxCMTDurationTrackFromTracksArray(audioTracks).timeRange.duration;
    
    
    NSMutableArray * readerOutputs = [[NSMutableArray alloc] init];
    NSMutableArray * writerInputs = [[NSMutableArray alloc] init];
    
   
    

    for (int i = 0; i<audioTracks.count; i++) {
        AVAssetTrack * audioTrack = audioTracks[i];
        ////暂时没有遇到一个audioTrack过多个formatDescription的情况
        CMAudioFormatDescriptionRef fDesc = (__bridge CMAudioFormatDescriptionRef)(audioTrack.formatDescriptions[0]);
        ////readerOutput时使用16
        ////writerInput时苹果用的默认是 24 位深 当mBitsPerChannel = 0 时表示24, 大多软件用16
        NSMutableDictionary * audioReaderOutputSettings = getAudioReaderOutputSettingsFromCMAudioFormatDescription(fDesc,16);
        NSMutableDictionary *audioWriterInputOutputSettings = getAudioWriterInputOutputSettingsFromCMAudioFormatDescription(fDesc,24);

        
        AVAssetReaderTrackOutput *trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioReaderOutputSettings];
        

        AVAssetReader *assetReader = readers[i];
        [assetReader addOutput:trackOutput];
        AVAssetWriterInput *input;
        input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioWriterInputOutputSettings];
        input.expectsMediaDataInRealTime = NO;
        AVAssetWriterInputGroup * inputGroup;
        NSMutableArray * inputs = [[NSMutableArray alloc] init];
        [inputs addObject:input];
        inputGroup = [AVAssetWriterInputGroup assetWriterInputGroupWithInputs:inputs defaultInput:input];
        if ([assetWriter canAddInput:input] && [assetWriter canAddInputGroup:inputGroup])
        {
            [assetWriter addInput:input];
            [assetWriter addInputGroup:inputGroup];
            [readerOutputs addObject: trackOutput];
            [writerInputs addObject:input];
        }
        else
        {
            NSLog(@"skipping input because it cannot be added to the asset writer");
        }
    }
    
    [assetWriter startWriting];
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t dispatchQueue = dispatch_queue_create("QUEUE", DISPATCH_QUEUE_CONCURRENT);
    
    
    for (int i = 0; i<audioTracks.count; i++) {
        AVAssetReader *assetReader = readers[i];
        [assetReader startReading];
    }
    __block CMTime endSessionAtSourceTime = kCMTimeZero;
    
    for (int i = 0; i<audioTracks.count; i++) {
        
        dispatch_group_async(dispatchGroup, dispatchQueue, ^{
            AVAssetReaderTrackOutput *trackOutput = readerOutputs[i];
            AVAssetWriterInput *input = writerInputs[i];
            AVAssetReader *assetReader = readers[i];
            BOOL done = NO;
            while (!done)
            {
                
                while (![input isReadyForMoreMediaData]) {
                    [NSThread sleepForTimeInterval:0.001f];
                }
                
                CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
                
                if (sampleBuffer)
                {

                    CMItemCount count;
                    
                    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
                    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
                    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, count, pInfo, &count);
                    for (CMItemCount i = 0; i < count; i++)
                    {
                        pInfo[i].decodeTimeStamp = pInfo[i].presentationTimeStamp;
                        endSessionAtSourceTime = CMTimeAdd(pInfo[i].presentationTimeStamp,pInfo[i].duration);
                    }
                    free(pInfo);
                    [input appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                }
                else
                {
                    [input markAsFinished];
                    if (assetReader.status == AVAssetReaderStatusFailed){
                        NSLog(@"the reader failed: %@", assetReader.error);
                        break;
                    }
                    done = YES;
                    break;
                    
                }
                
                
            }
        });
    }
    
    __block dispatch_semaphore_t semaCanReturn;
    if (SYNC) {
        semaCanReturn = dispatch_semaphore_create(0);
    } else {
        
    }
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        [assetWriter endSessionAtSourceTime:mergedAudioDuration];
        [assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"finished");
            if (SYNC) {
                dispatch_semaphore_signal(semaCanReturn);
            }
            if (SAVETOALBUM) {
                [FileUitl writeVideoToPhotoLibrary:destAudioURL];
            }
        }];
    });
    
    if (SYNC) {
        while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
    } else {
        
    }

    
}
////----把多个视频文件removePT合成一个视频文件的多条track,apple  not support write multiTracks to a file
////----to implement this  you must  use trackGroup  per track/per trackgroup
////----AVAssetTrackGroup是一组track，同时只能播放其中一条track，但是不同的AVAssetTrackGroup中的track可以同时播放
void combineVideoFilesToMultiTracksVideoFile(NSMutableArray*sourceVideoURLs,NSURL * destVideoURL, BOOL SYNC,BOOL SAVETOALBUM)
{
    NSMutableArray * assets = [[NSMutableArray alloc] init];
    NSMutableArray * readers = [[NSMutableArray alloc] init];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:destVideoURL fileType:AVFileTypeQuickTimeMovie error:nil];
    
    
    for (int i = 0; i<sourceVideoURLs.count; i++) {
        AVAsset * asset = [AVAsset assetWithURL:sourceVideoURLs[i]];
        [assets addObject:asset];
        AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:nil];
        [readers addObject:assetReader];
    }
    NSMutableArray * videoTracks = putAllVideoTracksToArrayFromAVAssets(assets, NO);
    CMTime mergedVideoDuration = getMaxCMTDurationTrackFromTracksArray(videoTracks).timeRange.duration;
   
    NSMutableArray * readerOutputs = [[NSMutableArray alloc] init];
    NSMutableArray * writerInputs = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i<videoTracks.count; i++) {
        AVAssetTrack * videoTrack = videoTracks[i];
        AVAssetReaderTrackOutput *trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:nil];
        AVAssetReader *assetReader = readers[i];
        [assetReader addOutput:trackOutput];
        AVAssetWriterInput *input;
        input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:nil];
        AVAssetWriterInputGroup * inputGroup;
        NSMutableArray * inputs = [[NSMutableArray alloc] init];
        [inputs addObject:input];
        inputGroup = [AVAssetWriterInputGroup assetWriterInputGroupWithInputs:inputs defaultInput:input];
        if ([assetWriter canAddInput:input] && [assetWriter canAddInputGroup:inputGroup])
        {
            [assetWriter addInput:input];
            [assetWriter addInputGroup:inputGroup];
            [readerOutputs addObject: trackOutput];
            [writerInputs addObject:input];
        }
        else
        {
            NSLog(@"skipping input because it cannot be added to the asset writer");
        }
    }
 
    [assetWriter startWriting];
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t dispatchQueue = dispatch_queue_create("QUEUE", DISPATCH_QUEUE_CONCURRENT);
    
    
    for (int i = 0; i<videoTracks.count; i++) {
        AVAssetReader *assetReader = readers[i];
        [assetReader startReading];
    }
    __block CMTime endSessionAtSourceTime = kCMTimeZero;

    for (int i = 0; i<videoTracks.count; i++) {
        
        dispatch_group_async(dispatchGroup, dispatchQueue, ^{
            AVAssetReaderTrackOutput *trackOutput = readerOutputs[i];
            AVAssetWriterInput *input = writerInputs[i];
            AVAssetReader *assetReader = readers[i];
            BOOL done = NO;
            while (!done)
            {
                CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
                
                if (sampleBuffer)
                {
                    
                    while (![input isReadyForMoreMediaData]) {
                        [NSThread sleepForTimeInterval:0.001f];
                    }
                    
                    CMItemCount count;
                    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
                    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
                    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, count, pInfo, &count);
                    for (CMItemCount i = 0; i < count; i++)
                    {
                        pInfo[i].decodeTimeStamp = pInfo[i].presentationTimeStamp;
                        endSessionAtSourceTime = CMTimeAdd(pInfo[i].presentationTimeStamp,pInfo[i].duration);
                    }
                    free(pInfo);
                    [input appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                }
                else
                {
                    [input markAsFinished];
                    if (assetReader.status == AVAssetReaderStatusFailed){
                        NSLog(@"the reader failed: %@", assetReader.error);
                        break;
                    }
                    done = YES;
                    break;
                    
                }
            }
        });
    }
    
    __block dispatch_semaphore_t semaCanReturn;
    if (SYNC) {
        semaCanReturn = dispatch_semaphore_create(0);
    } else {
        
    }
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        [assetWriter endSessionAtSourceTime:mergedVideoDuration];
        [assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"finished");
            if (SYNC) {
                dispatch_semaphore_signal(semaCanReturn);
            }
            if (SAVETOALBUM) {
                [FileUitl writeVideoToPhotoLibrary:destVideoURL];
            }
        }];
    });
    
    if (SYNC) {
        while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
    } else {
        
    }
    
  
}
////----把1个声音文件和1个所有tracks都removePT的视频文件合并成一个movie
void combineAudioFileAndVideoFileToMovieFile(NSURL*sourceAudioURL,NSURL*sourceVideoURL,NSURL*destMovieURL,BOOL SYNC,BOOL SAVETOALBUM)
{
    
    
    AVAsset * audioAsset = [AVAsset assetWithURL:sourceAudioURL];
    NSMutableArray * audioTracks = elegirAllAudioTracksFromAVAsset(audioAsset,NO);
    AVAsset * videoAsset = [AVAsset assetWithURL:sourceVideoURL];
    NSMutableArray * videoTracks = elegirAllVideoTracksFromAVAsset(videoAsset,NO);
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];

    for (int i = 0; i < audioTracks.count; i++) {
        AVAssetTrack * audioTrack = (AVAssetTrack *)audioTracks[i];
        AVMutableCompositionTrack *audioCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTracks[i] atTime:kCMTimeZero error:nil];
    }
    for (int i = 0; i < videoTracks.count; i++) {
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        AVMutableCompositionTrack *videoCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoCompTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTracks[i] atTime:kCMTimeZero error:nil];
    }
    
    ////使用AVAssetExportSession 只能有两个tracks videoTrack:1 audioTrack:2
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeMPEG4;
    ////AVFileTypeQuickTimeMovie;
    assetExport.outputURL = destMovieURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
    
}
////----把多个单轨声音文件和多个removePT的单轨视频文件合并成一个movie
void combineMultiSingleTrackAudioFilesAndMultiSingleTrackVideoFilesToMovieFile(NSMutableArray*sourceAudioURLs,NSMutableArray*sourceVideoURLs,NSURL*destMovieURL,BOOL SYNC,BOOL SAVETOALBUM)
{
   
    
    
    NSMutableArray * audioTracks = [[NSMutableArray alloc] init];
    NSMutableArray * audioAssets = [[NSMutableArray alloc] init];
    ////为了避免释放asset的情况 应该是 AVF的BUG -11820
    
    for (int i = 0; i<sourceAudioURLs.count; i++) {
        AVAsset * audioAsset = [AVAsset assetWithURL:sourceAudioURLs[i]];
        [audioAssets addObject:audioAsset];
        AVAssetTrack * at = audioAsset.tracks[0];
        [audioTracks addObject:at];
    }
    
    
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    NSMutableArray * videoAssets = [[NSMutableArray alloc] init];
    ////为了避免释放asset的情况 应该是 AVF的BUG -11820
    for (int i = 0; i<sourceVideoURLs.count; i++) {
        AVAsset * videoAsset = [AVAsset assetWithURL:sourceVideoURLs[i]];
        [videoAssets addObject:videoAsset];
        AVAssetTrack * vt = videoAsset.tracks[0];
        [videoTracks addObject:vt];

    }
    
    
    

    
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    for (int i = 0; i < audioTracks.count; i++) {
        AVAssetTrack * audioTrack = (AVAssetTrack *)audioTracks[i];
        AVMutableCompositionTrack *audioCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTracks[i] atTime:kCMTimeZero error:nil];
    }
    for (int i = 0; i < videoTracks.count; i++) {
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        AVMutableCompositionTrack *videoCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoCompTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTracks[i] atTime:kCMTimeZero error:nil];
    }
    
    ////使用AVAssetExportSession 只能有两个tracks videoTrack:1 audioTrack:2
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeMPEG4;
    assetExport.outputURL = destMovieURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
    audioTracks = NULL;
    videoTracks = NULL;
    audioAssets = NULL;
    videoAssets = NULL;
  
}


void creatEmptyAudioFileViaCMTimeRange(CMTimeRange range,NSURL*destAudioURL,BOOL SYNC,BOOL SAVETOALBUM)
{
    
    
    NSString * refTrackPath = [[NSBundle mainBundle] pathForResource:@"empty_audio" ofType:@"m4a"];
    NSURL * refTrackURL = [NSURL fileURLWithPath:refTrackPath];
    AVAsset * asset = [AVAsset assetWithURL:refTrackURL];
    AVAssetTrack * at = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    
    
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *audioCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    ////这是一个trick ,同一个atTime点insert的empty 会把non-empty的track往后推
    ////|----empty----|---non-empty|
    ////达到上述效果，语句上insertEmptyTimeRange 必须放在 insertTimeRange 后面
    [audioCompTrack insertTimeRange:range ofTrack:at atTime:kCMTimeZero error:nil];
    [audioCompTrack insertEmptyTimeRange:range];
    
    
   AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];

    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompTrack ];
    ////M4A 必须setVolume 否则 －12780 error
    [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
    audioMix.inputParameters = [NSArray arrayWithObject:audioInputParams];
    
    CMTime newStart = range.start;
    CMTime newExt = CMTimeMakeWithSeconds(0.01, at.timeRange.duration.timescale);
    CMTime newDura = CMTimeAdd(range.duration,newExt);
    CMTimeRange newRange = CMTimeRangeMake(newStart, newDura);
    
    assetExport.timeRange = newRange;
    assetExport.outputFileType = AVFileTypeAppleM4A;
    assetExport.audioMix = audioMix;
    assetExport.outputURL = destAudioURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    saveWithExportSession(assetExport, SYNC,SAVETOALBUM);
}
void creatEmptyVideoFileViaCMTimeRange(CGSize renderSize,CMTimeRange range,NSURL*destVideoURL,BOOL SYNC,BOOL SAVETOALBUM)
{



    NSString * refTrackPath = [[NSBundle mainBundle] pathForResource:@"empty_video" ofType:@"mov"];
    NSURL * refTrackURL = [NSURL fileURLWithPath:refTrackPath];
    AVAsset * asset = [AVAsset assetWithURL:refTrackURL];
    AVAssetTrack * videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    



    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    ////这是一个trick ,同一个atTime点insert的empty 会把non-empty的track往后推
    ////|----empty----|---non-empty|
    ////达到上述效果，语句上insertEmptyTimeRange 必须放在 insertTimeRange 后面
    [compositionVideoTrack insertTimeRange:range ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    [compositionVideoTrack insertEmptyTimeRange:range];
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    

    ////如果使用mainVideoComp  那么构造videoComp时候的参数 timerange
    ////必须和assetExport的一致
    
    CMTime newStart = range.start;
    CMTime newExt = CMTimeMakeWithSeconds(0.01, videoTrack.timeRange.duration.timescale);
    CMTime newDura = CMTimeAdd(range.duration,newExt);
    CMTimeRange newRange = CMTimeRangeMake(newStart, newDura);
    
    assetExport.timeRange = newRange;
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = destVideoURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
    
}

void addEmptyAudioRangeToVideoFileToMakeMovieFile(NSURL*sourceVideoURL,NSURL*destMovieURL)
{
    
}
void addEmptyVideoRangeToAudioFileToMakeMovieFile(NSURL*sourceAudioURL,NSURL*destMovieURL)
{
    
}





////<merge>
////直接把多条compTracks 压到一起的结果是混音，并不是多条音轨
void mergeAudioFilesToSingleTrackAudioFile(NSMutableArray*sourceAudioURLs,NSURL * destAudioURL, BOOL SYNC,BOOL SAVETOALBUM)
{
    NSMutableArray * assets = [[NSMutableArray alloc] init];
    for (int i = 0; i<sourceAudioURLs.count; i++) {
        AVAsset * asset = [AVAsset assetWithURL:sourceAudioURLs[i]];
        [assets addObject:asset];
    }
    NSMutableArray * AudioTracks = putAllAudioTracksToArrayFromAVAssets(assets, NO);
    CMTime mergedAudioDuration = getMaxCMTDurationTrackFromTracksArray(AudioTracks).timeRange.duration;
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    for (int i = 0; i < AudioTracks.count; i++) {
        AVAssetTrack * AudioTrack = (AVAssetTrack *)AudioTracks[i];
        AVMutableCompositionTrack *AudioCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [AudioCompTrack insertTimeRange:AudioTrack.timeRange ofTrack:AudioTracks[i] atTime:kCMTimeZero error:nil];
        CMTime substract = CMTimeSubtract(mergedAudioDuration, AudioTrack.timeRange.duration);
        substract = CMTimeConvertScale(substract,mergedAudioDuration.timescale,kCMTimeRoundingMethod_QuickTime);
        [AudioCompTrack insertEmptyTimeRange:CMTimeRangeMake(AudioTrack.timeRange.duration, substract)];
    }
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
    assetExport.outputFileType = AVFileTypeAppleM4A;
    assetExport.outputURL = destAudioURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
}
////结果是按opacity比例调整，这个以后要换成GPUImage来做
void mergeVideoFilesToSingleTrackVideoFile(NSMutableArray*sourceVideoURLs,NSMutableArray * opacities,NSURL * destVideoURL, BOOL SYNC,BOOL SAVETOALBUM)
{

    NSMutableArray * assets = [[NSMutableArray alloc] init];
    for (int i = 0; i<sourceVideoURLs.count; i++) {
        AVAsset * asset = [AVAsset assetWithURL:sourceVideoURLs[i]];
        [assets addObject:asset];
    }
    
    NSMutableArray * videoTracks = putAllVideoTracksToArrayFromAVAssets(assets, NO);
    

    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    CMTime mergedVideoDuration = getMaxCMTDurationTrackFromTracksArray(videoTracks).timeRange.duration;
    NSMutableArray * compositionTracks = [[NSMutableArray alloc] init];
    int count = (int)videoTracks.count;
    AVAssetTrack * originalTrack;
    AVMutableCompositionTrack * compositionTrack;
    // 为每段视频生成compositionTrack
    for (int i = 0; i < count; i++) {
        originalTrack = (AVAssetTrack *)videoTracks[i];
        compositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionTracks addObject:compositionTrack];
    }
    // 给每段视频填充空白padding
    for (int i = 0; i < count; i++) {
        originalTrack = (AVAssetTrack *)videoTracks[i];
        compositionTrack =  (AVMutableCompositionTrack * )compositionTracks[i];
        [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, originalTrack.timeRange.duration) ofTrack:originalTrack atTime:kCMTimeZero error:nil];
        CMTime substract = CMTimeSubtract(mergedVideoDuration, originalTrack.timeRange.duration);
        substract = CMTimeConvertScale(substract,mergedVideoDuration.timescale,kCMTimeRoundingMethod_QuickTime);
        [compositionTrack insertEmptyTimeRange:CMTimeRangeMake(originalTrack.timeRange.duration, substract)];
    }

    //创建main instruction layer
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mergedVideoDuration);
    AVMutableVideoCompositionLayerInstruction *layerInstruction;
    // 每个 compositionTrack 创建 layer,并且不显示空白段padding视频
    // 进行这一步的原因是：
    // 假如视频总时长是 10， 原始视频时长只有8 ，那么需要插入时长为2的空白视频
    // 此时在原始视频播放完毕之后视频将会永远显示 原始视频的最后一副画面
    NSMutableArray * layerInstructions = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        originalTrack = (AVAssetTrack *)videoTracks[i];
        compositionTrack =  (AVMutableCompositionTrack * )compositionTracks[i];
        layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack];
        CMTime substract = CMTimeSubtract(mergedVideoDuration, originalTrack.timeRange.duration);
        substract = CMTimeConvertScale(substract,mergedVideoDuration.timescale,kCMTimeRoundingMethod_QuickTime);
        ////写1.0会覆盖
        float opacity = [opacities[i] floatValue];
        [layerInstruction setOpacity:opacity atTime:kCMTimeZero];
        [layerInstruction setOpacity:0.0 atTime:originalTrack.timeRange.duration];
        [layerInstructions addObject:layerInstruction];
    }
    

    mainInstruction.layerInstructions = layerInstructions;
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    mainComposition.frameDuration = CMTimeMake(1, [videoTracks[0] nominalFrameRate]);
    mainComposition.renderSize = [videoTracks[0] naturalSize];
    
    

    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.videoComposition = mainComposition;
    assetExport.outputFileType =  AVFileTypeQuickTimeMovie;
    assetExport.outputURL = destVideoURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
    
    
}

/////-----下面这个等于自己生成动画
////------layerInstruction是UIKit坐标系， Y轴向下的
////------所以要先转换CGPoints
NSMutableArray * creatAnimationTimeRangesAndTranslationsFromPathPoints(CMTime start,CMTime end,NSMutableArray * pathPoints,float backGroundHeight,float selfHeight)
{
    NSMutableArray * rslt = [[NSMutableArray alloc] init];
    unsigned long count = pathPoints.count;
    NSMutableArray * layerInstructionPathPoints = [[NSMutableArray alloc] init];
    float origX;
    float origY;
    float newX;
    float newY;
    for (int i = 0; i<count; i++) {
        CGPoint xy = [pathPoints[i] CGPointValue];
        origX = xy.x;
        origY = xy.y;
        newX = origX;
        newY = backGroundHeight - origY - selfHeight;
        xy = CGPointMake(newX, newY);
        [layerInstructionPathPoints addObject:[NSValue valueWithCGPoint:xy]];
    }
    CMTime duration = CMTimeSubtract(end, start);
    CMTime step = CMTimeMultiplyByRatio(duration, 1, (int)(count-1));
    CMTime curr = start;
    for (int i = 0; i<count-1; i++) {
        NSMutableDictionary * each = [[NSMutableDictionary alloc] init];
        CGPoint xyStart = [layerInstructionPathPoints[i] CGPointValue];
        CGPoint xyEnd = [layerInstructionPathPoints[i+1] CGPointValue];
        CGAffineTransform startTransform = CGAffineTransformMakeTranslation(xyStart.x,xyStart.y);
        CGAffineTransform endTransform = CGAffineTransformMakeTranslation(xyEnd.x,xyEnd.y);
        [each setValue:[NSValue valueWithCGAffineTransform:startTransform] forKey:@"startTransform"];
        [each setValue:[NSValue valueWithCGAffineTransform:endTransform] forKey:@"endTransform"];
        CMTimeRange animationTimeRange = CMTimeRangeMake(curr, step);
        [each setValue:[NSValue valueWithCMTimeRange:animationTimeRange] forKey:@"timeRange"];
        curr = CMTimeAdd(curr, step);
        [rslt addObject:each];
    }

    return(rslt);
}

////pathPointsArray 每条track 一组pathPoints
////可以为[NSNull null]，为[NSNull null]表示没有animation
////每一组pathPoints 由一系列CGPoints点构成
////即使只是静止的叠加，那么上面的track(在前面的track)参数也要指定一个最微小的移动，例如0.1,否则
////最后一个track的会覆盖前面所有track

void overlayVideoFilesToSingleTrackVideoFile(NSMutableArray*sourceVideoURLs,NSMutableArray * pathPointsArray,NSMutableArray * atTimes,NSURL * destVideoURL, BOOL SYNC,BOOL SAVETOALBUM)
{
    
    NSMutableArray * assets = [[NSMutableArray alloc] init];
    for (int i = 0; i<sourceVideoURLs.count; i++) {
        AVAsset * asset = [AVAsset assetWithURL:sourceVideoURLs[i]];
        [assets addObject:asset];
    }
    NSMutableArray * videoTracks = putAllVideoTracksToArrayFromAVAssets(assets, NO);
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    ////-11841出现的原因多数是mainInstruction.timeRange不对
    NSMutableArray * plusAtTimeDurations = [[NSMutableArray alloc] init];
    for (int i = 0; i<sourceVideoURLs.count; i++) {
        AVAssetTrack * vt = (AVAssetTrack *)videoTracks[i];
        CMTime atTime = CMTimeMakeWithSeconds([atTimes[i] floatValue], vt.timeRange.duration.timescale);
        CMTime plusAtTimeDuration = CMTimeAdd(atTime, vt.timeRange.duration);
        [plusAtTimeDurations addObject:[NSValue valueWithCMTime:plusAtTimeDuration]];
    }
    CMTime mergedVideoDuration = getMaxCMTDurationCMTFromArray(plusAtTimeDurations);
    
    ////CMTimeShow(mergedVideoDuration);

    NSMutableArray * compositionTracks = [[NSMutableArray alloc] init];
    int count = (int)videoTracks.count;
    AVAssetTrack * originalTrack;
    AVMutableCompositionTrack * compositionTrack;
    // 为每段视频生成compositionTrack
    for (int i = 0; i < count; i++) {
        originalTrack = (AVAssetTrack *)videoTracks[i];
        compositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionTracks addObject:compositionTrack];
    }
    CMTime atTime;
    // 给每段视频填充空白padding
    for (int i = 0; i < count; i++) {
        originalTrack = (AVAssetTrack *)videoTracks[i];
        atTime = CMTimeMakeWithSeconds([atTimes[i] floatValue], mergedVideoDuration.timescale);
        compositionTrack =  (AVMutableCompositionTrack * )compositionTracks[i];
        
        CMTimeRange prefixEmptyTimeRange = CMTimeRangeMake(kCMTimeZero, atTime);
        [compositionTrack insertEmptyTimeRange:prefixEmptyTimeRange];
        
        CMTimeRange ofTrackTimeRange = CMTimeRangeMake(kCMTimeZero, originalTrack.timeRange.duration);
        [compositionTrack insertTimeRange:ofTrackTimeRange ofTrack:originalTrack atTime:atTime error:nil];
        
        CMTime substract = CMTimeSubtract(mergedVideoDuration, originalTrack.timeRange.duration);
        substract = CMTimeSubtract(substract, atTime);
        substract = CMTimeConvertScale(substract,mergedVideoDuration.timescale,kCMTimeRoundingMethod_QuickTime);
        CMTimeRange suffixEmptyTimeRange;
        if (CMTimeCompare(substract, kCMTimeZero)>=0) {
            suffixEmptyTimeRange = CMTimeRangeMake(CMTimeAdd(atTime,originalTrack.timeRange.duration), CMTimeSubtract(substract, atTime));
        } else {
            suffixEmptyTimeRange = CMTimeRangeMake(CMTimeAdd(atTime,originalTrack.timeRange.duration), kCMTimeZero);
        }
        [compositionTrack insertEmptyTimeRange:suffixEmptyTimeRange];
        
    }
    ////以最后一段视频的size为最终renderSize
    CGSize renderSize = originalTrack.naturalSize;
    float height = renderSize.height;
    //创建main instruction layer
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mergedVideoDuration);
    
    CMTimeRangeShow(mainInstruction.timeRange);
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction;
    // 每个 compositionTrack 创建 layer,并且不显示空白段padding视频
    // 进行这一步的原因是：
    // 假如视频总时长是 10， 原始视频时长只有8 ，那么需要插入时长为2的空白视频
    // 此时在原始视频播放完毕之后视频将会永远显示 原始视频的最后一副画面
    NSMutableArray * layerInstructions = [[NSMutableArray alloc] init];
    
  
    
    for (int i = 0; i < count; i++) {
        
        originalTrack = (AVAssetTrack *)videoTracks[i];
        atTime = CMTimeMakeWithSeconds([atTimes[i] floatValue], mergedVideoDuration.timescale);
        float selfHeight = originalTrack.naturalSize.height;
        compositionTrack =  (AVMutableCompositionTrack * )compositionTracks[i];
         
        
        layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack];
        

        NSMutableArray * pathPoints =pathPointsArray[i];
        
        
        if ([pathPoints isKindOfClass:[NSNull class]]) {

        } else {

            
            CMTime start = atTime;
            CMTime end = CMTimeAdd(atTime, originalTrack.timeRange.duration);
            
            ////CMTimeShow(start);
            ////CMTimeShow(end);
            ////NSLog(@"pathPoints:%@",pathPoints);
            ////NSLog(@"height:%f",height);
            ////NSLog(@"selfHeight:%f",selfHeight);
            
            
            NSMutableArray * animationParameters = creatAnimationTimeRangesAndTranslationsFromPathPoints(start, end, pathPoints, height,selfHeight);
            
            
            
            
            for (int j = 0; j<animationParameters.count; j++) {
                
                ////NSLog(@"animationParameters[%d]:%@",j,animationParameters[j]);
                
                CGAffineTransform startTransform = [[animationParameters[j] valueForKey:@"startTransform"] CGAffineTransformValue];
                CGAffineTransform endTransform = [[animationParameters[j] valueForKey:@"endTransform"] CGAffineTransformValue];
                CMTimeRange transformTR = [[animationParameters[j] valueForKey:@"timeRange"] CMTimeRangeValue];
                
                [layerInstruction setTransformRampFromStartTransform:startTransform toEndTransform:endTransform timeRange:transformTR];
            }
        }
        

        ////这一步时必须的，否则suffix empty会显示黑色,而不是显示下面的track
        CMTime opacityZeroAtTime = CMTimeAdd(atTime,originalTrack.timeRange.duration);
        [layerInstruction setOpacity:0.0 atTime:opacityZeroAtTime];
        [layerInstructions addObject:layerInstruction];
        
        
        
    }
    
    ////NSLog(@"layerInstructions:%@",layerInstructions);
    
    mainInstruction.layerInstructions = layerInstructions;
    
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    
    mainComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    
    
    mainComposition.frameDuration = CMTimeMake(1, [videoTracks[0] nominalFrameRate]);
    
    mainComposition.renderSize = renderSize;
    
    CMTimeShow(mainComposition.frameDuration);
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.videoComposition = mainComposition;
    assetExport.outputFileType =  AVFileTypeQuickTimeMovie;
    assetExport.outputURL = destVideoURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
}
void overlayVideoFilesWithMSAddModeSYNC(NSURL * videoSrcURL,NSURL * videoOverlaySrcURL,NSURL*writerOutputURL,float compWidth,float compHeight,int compAverageBitRate)
{
    VTMSDecomp  * stream1 = [[VTMSDecomp alloc] init];
    {
        [stream1 resetParameters];
        stream1.sourceVideoURL = videoSrcURL;
        stream1.useOnlyDurations = NO;
        stream1.useCacheArray = YES;
        stream1.cacheArraySize = 2;
        stream1.constructDestinationImageBufferAttributesFromKeyValue = YES;
        stream1.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_32BGRA;
    }
    
    VTMSDecomp  * stream2 = [[VTMSDecomp alloc] init];
    {
        [stream2 resetParameters];
        stream2.sourceVideoURL = videoOverlaySrcURL;
        stream2.useOnlyDurations = NO;
        stream2.useCacheArray = YES;
        stream2.cacheArraySize = 2;
        stream2.constructDestinationImageBufferAttributesFromKeyValue = YES;
        stream2.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_32BGRA;
    }
    
    VTMSComp * vtmsc = [[VTMSComp alloc] init];
    {
        [vtmsc resetParameters];
        vtmsc.writerOutputURL = writerOutputURL;
        vtmsc.writerOutputFileType = AVFileTypeQuickTimeMovie;
        vtmsc.compressionSessionPropertiesConstructFromKeyValue =YES;
        vtmsc.compressionAverageBitRate = compAverageBitRate;
        vtmsc.deleteOutputDirBeforeWrite = YES;
        vtmsc.writerShouldOptimizeForNetworkUse = YES;
        vtmsc.compSessionWidth = compWidth;
        vtmsc.compSessionHeight = compHeight;
        GPUImageMSAdd * MSAdd = [[GPUImageMSAdd  alloc] init];
        vtmsc.initedFilter = MSAdd;
        vtmsc.applyFilter  = YES;
        vtmsc.SYNC = YES;
        [vtmsc makeMSinit];
        [vtmsc addDecompStream:stream1];
        [vtmsc addDecompStream:stream2];
        [vtmsc makeRecomp];
        
    }
}

/////-----

////</merge>




////----<scale>
void resizeVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,CGSize size,BOOL SYNC,BOOL SAVETOALBUM)
{
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    CGAffineTransform t2 = [videoTrack preferredTransform];
    //// if use back camera  , rotate degree is clock wise when using settransform
    //// if use front camera , rotate degree is clock wise when using settransform
    float widthScale;
    float heightScale;
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        widthScale = size.width / videoTrack.naturalSize.height;
        heightScale = size.height / videoTrack.naturalSize.width;
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        widthScale = size.width / videoTrack.naturalSize.width;
        heightScale = size.height / videoTrack.naturalSize.height;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        widthScale = size.width / videoTrack.naturalSize.width;
        heightScale = size.height / videoTrack.naturalSize.height;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        widthScale = size.width / videoTrack.naturalSize.height;
        heightScale = size.height / videoTrack.naturalSize.width;
    } else {
        widthScale = size.width / videoTrack.naturalSize.width;
        heightScale = size.height / videoTrack.naturalSize.height;
    }
    CGAffineTransform scale = CGAffineTransformMakeScale(widthScale,heightScale);
    [layerInstruction setTransform:CGAffineTransformConcat(t2, scale)  atTime:kCMTimeZero];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    mainVideoComp.renderSize = size;
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.videoComposition = mainVideoComp;
    assetExport.outputFileType =  AVFileTypeQuickTimeMovie;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
    
}
void resizeVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,CGSize size,BOOL SYNC,BOOL SAVETOALBUM)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    return(resizeVideoFromSourceAsset(asset,whichTrack,destinationURL,size,SYNC,SAVETOALBUM));
}
////----</scale>

////-<crop>
void cropAndRangeVideoFromSourceAsset(AVAsset*asset,int whichTrack,CMTimeRange timeRange,NSURL*destinationURL,CGSize size,CGPoint topLeftPosition,BOOL SYNC,BOOL SAVETOALBUM)
{
    
    ////左上topLeft 值得是x向上 y向上的 坐标系的左上
    ////但在layerInstruction中 坐标系y轴向下的
    ////所以具体数值时在layerInstruction坐标系中的数值
    
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];

    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = timeRange;
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    CGAffineTransform t2 = [videoTrack preferredTransform];
    //// if use back camera  , rotate degree is clock wise when using settransform
    //// if use front camera , rotate degree is clock wise when using settransform

    float coodOrigXshift ;
    float coodOrigYshift ;
    
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
        
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
        
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
        
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
        
    } else {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
    }
    
    CGAffineTransform move = CGAffineTransformMakeTranslation(coodOrigXshift,coodOrigYshift);
    [layerInstruction setTransform:CGAffineTransformConcat(t2, move) atTime:kCMTimeZero];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    mainVideoComp.renderSize = size;
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    assetExport.videoComposition = mainVideoComp;
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);

}
void cropAndRangeVideoFromSourceURL(NSURL*sourceURL,int whichTrack,CMTimeRange timeRange,NSURL*destinationURL,CGSize size,CGPoint topLeftPosition,BOOL SYNC,BOOL SAVETOALBUM)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    cropAndRangeVideoFromSourceAsset(asset,whichTrack,timeRange,destinationURL,size,topLeftPosition,SYNC,SAVETOALBUM);
}
////-</crop>






////-------CGPath---------
void movingVideoOnBackGroundFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,CGPoint anchorCoodZ,CGSize BGSize,NSMutableArray*pathPoints,NSMutableArray*keyTimes,NSMutableArray*timingFunctions,BOOL SYNC,BOOL SAVETOALBUM)
{
    ////8.3 have a blackframe BUG
    ////使用SYNC时候exportSession
    ////如果+[CATransaction synchronize] called within transaction
    ////那么需要把这个放到非main_Q上，因为
    ////This happens when more than one animation are taking place on main thread
    
    ////need_to_be_displayed_as ----preferedTransform---->landscapup(home button at right)
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];
    
    
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = videoTrack.timeRange;
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    
    
    ////因为在内部存储时总是landscape ,所以 origWidth 总是 长 的 边
    float origWidth = videoTrack.naturalSize.width;
    float origHeight = videoTrack.naturalSize.height;
    
    //输入的anchor是针对pt还原之后的矩形的
    float x = anchorCoodZ.x;
    float y = anchorCoodZ.y;
    
    
    
    CGAffineTransform pt = [videoTrack preferredTransform];
    if (pt.a==0.0 && pt.b==1.0 && pt.c==-1.0 && pt.d == 0.0) {
        origWidth = videoTrack.naturalSize.height;
        origHeight = videoTrack.naturalSize.width;
    } else if (pt.a==1.0 && pt.b==0.0 && pt.c==0.0 && pt.d == 1.0) {
        
    } else if (pt.a==-1.0 && pt.b==0.0 && pt.c==0.0 && pt.d == -1.0) {
        
    } else if (pt.a==0.0 && pt.b==-1.0 && pt.c==1.0 && pt.d == 0.0) {
        origWidth = videoTrack.naturalSize.height;
        origHeight = videoTrack.naturalSize.width;
    } else {
        
    }
    
    
    //
    float widthBG = BGSize.width;
    float heightBG = BGSize.height;
    
    
    ////--- this step is necessary if the output is not the original
    ////--- when the videoLayer frame is small than renderSize
    ////--- the real video will be shrinked  in videoLayer corresponding  to the ratio  of  (videoLayer frame) / (renderSize)
    ////---
    float widthScale = widthBG / origWidth;
    float heightScale = heightBG / origHeight;
    CGAffineTransform st = CGAffineTransformMakeScale(widthScale,heightScale);
    CGAffineTransform ptst = CGAffineTransformConcat(pt,st);
    
    
    //pt 还原为所见即所得
    [layerInstruction setTransform:ptst atTime:kCMTimeZero];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, widthBG, heightBG);
    parentLayer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]);
    ////parentLayer.backgroundColor = [[UIColor clearColor] CGColor];
    ////这里使用clearColor或blackColor  在输出的video里面都是 0 0 0 255,
    ///clearColor应该是0,0,0,0 但是视频H.264无法携带alpha通道
    //parentLayer所处的坐标系是 标准坐标系 parentFrame的左下角是原点 x向右是正 y向上为正
    [parentLayer setMasksToBounds:YES];
    
    ////default anchor point  is at 0.5,0.5
    ////so the position  is at center
    ////position is the absolute cood  of anchor
    ////anchorPoint is the relative ratio of anchor
    ////frame is the absolute coord
    ////bounds is the relative of self
    
    //videoLayer所处的坐标系是 标准坐标系 video的左下角是原点 x向右是正 y向上为正
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0,0 ,origWidth,origHeight);
    ////videoLayer.anchorPoint = CGPointMake(0.0, 0.0);
    ////translate CGPath 上点的坐标是针对anchorPoint的
    ////因为坐标系变换, render 的坐标系的Y轴时向下的
    ////平移时不需要这个 y = origHeight - y ; 因为CA animation针对的坐标系不是render UIKit坐标系，不需要自己变
    videoLayer.anchorPoint =  CGPointMake(x/origWidth, y/origHeight);

    
    /*
     ////CAKeyframeAnimation则可以支持任意多个关键帧,关键帧有两种方式来指定,
     ////使用path或者使用values,path是一个CGPathRef的值,且path只能对CALayer的 anchorPoint 和
     ////position 属性起作用,且设置了path之后values就不再起效了.
     
     CGMutablePathRef path = CGPathCreateMutable();
     CGPathMoveToPoint(path,NULL,50.0,120.0);
     CGPathAddCurveToPoint(path,NULL,50.0,275.0,150.0,275.0,150.0,120.0);
     CGPathAddCurveToPoint(path,NULL,150.0,275.0,250.0,275.0,250.0,120.0);
     CGPathAddCurveToPoint(path,NULL,250.0,275.0,350.0,275.0,350.0,120.0);
     CGPathAddCurveToPoint(path,NULL,350.0,275.0,450.0,275.0,450.0,120.0);
     [animation setPath:path];
     animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
     CFRelease(path);
     */
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    ////而values则更加灵活. keyTimes这个可选参数可以为对应的关键帧指定对应的时间点,
    ////其取值范围为0到1.0,keyTimes中的每一个时间值都对应values中的每一帧.
    ////当keyTimes没有设置的时候,各个关键帧的时间是平分的.
    [animation setValues:pathPoints];
    /* An optional array of `NSNumber' objects defining the pacing of the
     * animation. Each time corresponds to one value in the `values' array,
     * and defines when the value should be used in the animation function.
     * Each value in the array is a floating point number in the range
     * [0,1].
     */
    if (keyTimes) {
        [animation setKeyTimes:keyTimes];
    }
    
    ////在关键帧动画中还有一个非常重要的参数,那便是calculationMode,
    ////计算模式.其主要针对的是每一帧的内容为一个座标点的情况,
    ////也就是对anchorPoint 和 position 进行的动画.当在平面座标系中有多个离散的点的时候,
    ////可以是离散的,也可以直线相连后进行插值计算,也可以使用圆滑的曲线将他们相连后进行插值计算.
    ////calculationMode目前提供如下几种模式
    ////kCAAnimationLinear
    ////kCAAnimationDiscrete
    ////kCAAnimationPaced
    ////kCAAnimationCubic
    ////kCAAnimationCubicPaced
    ////kCAAnimationLinear calculationMode的默认值,表示当关键帧为座标点的时候,
    ////关键帧之间直接直线相连进行插值计算;
    ////kCAAnimationDiscrete 离散的,就是不进行插值计算,所有关键帧直接逐个进行显示;
    ////kCAAnimationPaced 使得动画均匀进行,而不是按keyTimes设置的或者按关键帧平分时间,
    ////此时keyTimes和timingFunctions无效;
    ////kCAAnimationCubic 对关键帧为座标点的关键帧进行圆滑曲线相连后插值计算,
    ////对于曲线的形状还可以通过tensionValues,continuityValues,biasValues来进行调整自定义,
    ////这里的数学原理是Kochanek–Bartels spline,这里的主要目的是使得运行的轨迹变得圆滑;
    ////kCAAnimationCubicPaced 看这个名字就知道和kCAAnimationCubic有一定联系,
    ////其实就是在kCAAnimationCubic的基础上使得动画运行变得均匀,就是系统时间内运动的距离相同,
    ////此时keyTimes以及timingFunctions也是无效的.
    
    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
    animation.duration = CMTimeGetSeconds(compTrack.timeRange.duration);
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    
    /*
     ////还可以通过设置可选参数timingFunctions
     ////(CAKeyframeAnimation中timingFunction是无效的)
     ////为关键帧之间的过渡设置timingFunction,如果values有n个元素,
     ////那么timingFunctions则应该有n-1个.但很多时候并不需要timingFunctions,
     ////因为已经设置了够多的关键帧了,比如没1/60秒就设置了一个关键帧,那么帧率将达到60FPS,
     ////完全不需要相邻两帧的过渡效果（当然也有可能某两帧 值相距较大,
     ////可以使用均匀变化或者增加帧率,比如每0.01秒设置一个关键帧）.
     
     NSArray * functions =      [NSArray arrayWithObjects:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
     nil];
     NSMutableArray * timingFunctions =  [[NSMutableArray alloc] initWithArray:functions];
     */
    if (timingFunctions) {
        animation.timingFunctions = timingFunctions;
    }
    
    [videoLayer addAnimation:animation forKey:@"movingPathAnimation"];
    [parentLayer addSublayer:videoLayer];
    
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    mainVideoComp.renderSize = CGSizeMake(widthBG,heightBG);
    mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = destinationURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    assetExport.videoComposition = mainVideoComp;
    saveWithExportSession(assetExport, SYNC, SAVETOALBUM);
      
    
}
void movingVideoOnBackGroundFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,CGPoint anchorCoodZ,CGSize BGSize,NSMutableArray*pathPoints,NSMutableArray*keyTimes,NSMutableArray*timingFunctions,BOOL SYNC,BOOL SAVETOALBUM)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];
    
    movingVideoOnBackGroundFromSourceAsset(asset,whichTrack,destinationURL,anchorCoodZ,BGSize,pathPoints,keyTimes,timingFunctions,SYNC,SAVETOALBUM);
    
}
////-------CGPath--------


////---<get single frame>
void getSingleImageFromVideoURLWithCMTUnitIntervalAndSaveToURL(NSURL * videoURL ,CMTime atTime,NSURL * destURL)
{
    ////--dont USE this directly in viewDidLoad
    AVAsset * asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    NSError *err = NULL;
    CGImageRef oneRef = [generator copyCGImageAtTime:atTime actualTime:NULL error:&err];
    UIImage * img = [[UIImage alloc] initWithCGImage:oneRef];
    CGImageRelease(oneRef);
    [img saveToURL:destURL];
}
////---<get single frame>

