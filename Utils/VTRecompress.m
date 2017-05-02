//
//  VTRecompress.m
//  UView
//
//  Created by dli on 12/28/15.
//  Copyright © 2015 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "VTRecompress.h"


#import "GMImagePickerController.h"
#import "HighlightsCreator.h"
#import "UVAdPlayerView.h"
#import <RDVTabBarController/RDVTabBarController.h>
#import "VTSPlayerViewController.h"
#import "UVMusicSelectViewController.h"
#import "UVVideoOutputLengthSelectionTableViewCell.h"
#import "UVVideoLengthPresetTableViewController.h"
#import "UVGroupModel.h"
#import "UVParticipateContentViewController.h"
#import "UVScriptContentViewController.h"
#import "UVScriptModel.h"
#import "FCFileManager.h"
#import "MJExtension.h"
#import "UVSmartVideoCreator.h"
#import "UVSmartVideoJob.h"
#import "AVOSCloud.h"
#import "UVTask.h"
#import "UVPartner.h"
#import "UVUser.h"
#import "UVAppState.h"
#import "UVHighlightManager.h"
#import "MBProgressHUD+MJ.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "UVResource.h"
#import "UVVideoHelper.h"
#import <UIImageView+WebCache.h>
#import "UVFileDownloader.h"

#include <VideoToolbox/VideoToolbox.h>


#import "NSString+Utils.h"
#import "FileUtil.h"
#import "coreMediaPrint.h"


@implementation VTRecompress






////-dli-
//// self.reader
//// self.readerAsset

- (id)initReaderWithAsset:(AVAsset *)asset
{
    if ((self = [super init]))
    {
        self.readerAsset = asset;
        NSError *error;
        self.reader = [AVAssetReader assetReaderWithAsset:self.readerAsset error:&error];
        if (error)
        {
            return(nil);
        }
    } else {
        return(nil);
    }
    return self;
}

////-dli-
//// self.reader
//// self.readerAsset
//// self.readerInputURL
- (id)initReaderWithURL:(NSURL *)url
{
    if ((self = [super init]))
    {
        self.readerInputURL = url;
        self.readerAsset = [AVAsset assetWithURL:url];
        NSError *error;
        self.reader = [AVAssetReader assetReaderWithAsset:self.readerAsset error:&error];
        if (error)
        {
            return(nil);
        }
    } else {
        return(nil);
    }
    
    return self;
}


////-dli-
//// self.reader
//// self.readerAsset
//// self.readerInputURL
//// self.readerInputPath
- (id)initReaderWithPath:(NSString *)path
{
    if ((self = [super init]))
    {
        self.readerInputPath = path;
        NSURL * url = [[NSURL alloc] initFileURLWithPath:path];
        self.readerInputURL = url;
        self.readerAsset = [AVAsset assetWithURL:url];
        NSError *error;
        self.reader = [AVAssetReader assetReaderWithAsset:self.readerAsset error:&error];
        if (error)
        {
            return(nil);
        }
    } else {
        return(nil);
    }
    return self;
}



////-dli

- (void)initReaderVideoCompositionOutput
{
    NSArray *videoTracks = [self.readerAsset tracksWithMediaType:AVMediaTypeVideo];
    
    if (videoTracks.count > 0) {
        self.readerVideoCompositionOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:nil];
        self.readerVideoCompositionOutput.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.readerAsset];

        if ([self.reader canAddOutput:self.readerVideoCompositionOutput])
        {
            [self.reader addOutput:self.readerVideoCompositionOutput];
        }
        
    } else {
        self.readerVideoCompositionOutput = nil;
    }
    
    
}

- (void)initReaderAudioMixOutput

{
    NSArray *audioTracks = [self.readerAsset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count > 0) {
        self.readerAudioMixOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks audioSettings:nil];
        self.readerAudioMixOutput.alwaysCopiesSampleData = NO;
        self.readerAudioMixOutput.audioMix = self.readerAudioOutputMix;
        if ([self.reader canAddOutput:self.readerAudioMixOutput])
        {
            [self.reader addOutput:self.readerAudioMixOutput];
        }
    } else {
        self.readerAudioMixOutput = nil;
    }
}


- (void)initReaderVideoOutputSpecificTrack:(NSInteger)i
{
    NSArray *videoTracks = [self.readerAsset tracksWithMediaType:AVMediaTypeVideo];
    
    if (videoTracks.count > 0) {


        self.readerVideoOutputSpecificTrack = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTracks[i] outputSettings:nil];
        
        if ([self.reader canAddOutput:self.readerVideoOutputSpecificTrack])
        {
            [self.reader addOutput:self.readerVideoOutputSpecificTrack];
        }
        
    } else {
        self.readerVideoOutputSpecificTrack = nil;
    }
    
    
}


- (void)initReaderAudioOutputSpecificTrack:(NSInteger)i
{
    NSArray *audioTracks = [self.readerAsset tracksWithMediaType:AVMediaTypeAudio];
    
    if (audioTracks.count > 0) {
        
        
        self.readerAudioOutputSpecificTrack = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTracks[i] outputSettings:nil];
        
        if ([self.reader canAddOutput:self.readerAudioOutputSpecificTrack])
        {
            [self.reader addOutput:self.readerAudioOutputSpecificTrack];
        }
        
    } else {
        self.readerAudioOutputSpecificTrack = nil;
    }
    
    
}




- (void)initMixAudioComposition
{
    self.mixAudioComposition = [[AVMutableComposition alloc] init];;
}

- (void)initMixVideoComposition
{
    self.mixVideoComposition = [[AVMutableComposition alloc] init];;
}

- (void)initMixAudioAndVideoComposition
{
    self.mixAudioAndVideoComposition = [[AVMutableComposition alloc] init];;
}



- (void)initReaderVideoOutputWithTrackSelection:(NSMutableArray *)indexes mixComposition:(AVMutableComposition *)mixComposition
{
    NSMutableArray *videoTracks = [[NSMutableArray alloc ] initWithArray:[self.readerAsset tracksWithMediaType:AVMediaTypeVideo] copyItems:YES];
    
    
    if (videoTracks.count > 0) {
        
        
        self.readerVideoOutputWithTrackSelection = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:creatConcatedVideoCompTrackWithTracksSelection(videoTracks, indexes,mixComposition) outputSettings:nil];
        
        if ([self.reader canAddOutput:self.readerVideoOutputWithTrackSelection])
        {
            [self.reader addOutput:self.readerVideoOutputWithTrackSelection];
        }
        
    } else {
        self.readerVideoOutputWithTrackSelection = nil;
    }
    
    
}


- (void)initReaderAudioOutputWithTrackSelection:(NSMutableArray *)indexes mixComposition:(AVMutableComposition *)mixComposition
{
    NSMutableArray *audioTracks = [[NSMutableArray alloc] initWithArray:[self.readerAsset tracksWithMediaType:AVMediaTypeAudio] copyItems:YES];
       
    if (audioTracks.count > 0) {
        
        
        self.readerAudioOutputWithTrackSelection = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:creatConcatedVideoCompTrackWithTracksSelection(audioTracks, indexes,mixComposition) outputSettings:nil];
        
        if ([self.reader canAddOutput:self.readerAudioOutputWithTrackSelection])
        {
            [self.reader addOutput:self.readerAudioOutputWithTrackSelection];
        }
        
    } else {
        self.readerAudioOutputWithTrackSelection = nil;
    }
    
    
}



- (void)initReaderVideoOutputWithAllTracks:(AVMutableComposition *)mixComposition
{
    NSMutableArray *videoTracks = [[NSMutableArray alloc] initWithArray:[self.readerAsset tracksWithMediaType:AVMediaTypeVideo] copyItems:YES];

   
    
    if (videoTracks.count > 0) {
        
        
        self.readerVideoOutputWithAllTracks = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:creatConcatedVideoCompTrackWithAllTracks(videoTracks,mixComposition) outputSettings:nil];
        
        if ([self.reader canAddOutput:self.readerVideoOutputWithAllTracks])
        {
            [self.reader addOutput:self.readerVideoOutputWithAllTracks];
        }
        
    } else {
        self.readerVideoOutputWithAllTracks = nil;
    }
    
    
}


- (void)initReaderAudioOutputWithAllTracks:(AVMutableComposition *)mixComposition
{
    NSMutableArray *audioTracks = [[NSMutableArray alloc] initWithArray:[self.readerAsset tracksWithMediaType:AVMediaTypeAudio] copyItems:YES];;
    
    if (audioTracks.count > 0) {
        
        
        self.readerAudioOutputWithTrackSelection = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:creatConcatedAudioCompTrackWithAllTracks(audioTracks,mixComposition) outputSettings:nil];
        
        if ([self.reader canAddOutput:self.readerAudioOutputWithAllTracks])
        {
            [self.reader addOutput:self.readerAudioOutputWithAllTracks];
        }
        
    } else {
        self.readerAudioOutputWithAllTracks = nil;
    }
    
    
}






////-dli-
//// self.writer
//// self.writerOutputURL
//// self.writerOutputFileType

- (id)initWriterWithURL:(NSURL *)url writeOutputFileType:(NSString*)fileType
{
    if ((self = [super init]))
    {
        self.writerOutputURL = url;
        
        self.writerOutputFileType = fileType;
        
        NSError *error;
        self.writer = [AVAssetWriter assetWriterWithURL:url fileType:fileType error:&error];
        if (error)
        {
            return(nil);
        }
    } else {
        return(nil);
    }
    
    return self;
}




////-dli-
//// self.writer
//// self.writerOutputURL
//// self.writerOutputFileType
//// self.writerOutputPath

- (id)initWriterWithPath:(NSString *)path writeOutputFileType:(NSString*)fileType
{
    if ((self = [super init]))
    {
        self.writerOutputPath = path;
        NSURL * url = [[NSURL alloc] initFileURLWithPath:path];
        
        self.writerOutputURL = url;
        
        self.writerOutputFileType = fileType;
        
        NSError *error;
        self.writer = [AVAssetWriter assetWriterWithURL:url fileType:fileType error:&error];
        if (error)
        {
            return(nil);
        }
    } else {
        return(nil);
    }
    
    return self;
}



- (id)initAudioWriterInput
{
      self.writerAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
      if ([self.writer canAddInput:self.writerAudioInput])
      {
          [self.writer addInput:self.writerAudioInput];
      }
    return(self);
}

- (id)initVideoWriterInput
{
    self.writerVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:nil];
    if ([self.writer canAddInput:self.writerVideoInput])
    {
        [self.writer addInput:self.writerVideoInput];
    }
    return(self);
}


- (id)initVideoWriterInputWithAdapter:(CGFloat)width height:(CGFloat)height
{
    self.writerVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:nil];
    if ([self.writer canAddInput:self.writerVideoInput])
    {
        [self.writer addInput:self.writerVideoInput];
    }
    
    NSDictionary *pixelBufferAttributes = @
    {
        (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
        (id)kCVPixelBufferWidthKey: @(width),
        (id)kCVPixelBufferHeightKey: @(height),
        @"IOSurfaceOpenGLESTextureCompatibility": @YES,
        @"IOSurfaceOpenGLESFBOCompatibility": @YES,
    };
    
    self.writerVideoPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.writerVideoInput sourcePixelBufferAttributes:pixelBufferAttributes];
    
    
    return(self);
}






- (void) initQueue
{
    self.VTDecompressAsyncProcessingConcurrentQueue = dispatch_queue_create("VTDecompressAsyncProcessingConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);;
    self.VTCompressAsyncProcessingConcurrentQueue = dispatch_queue_create("VTCompressAsyncProcessingConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);;
}


- (void) initSema
{
    self.semaCanWriteReCompressBuffer = dispatch_semaphore_create(1);
    self.semaCanReadReCompressBuffer = dispatch_semaphore_create(0);
}


- (void)start
{
    [self.writer startWriting];
    [self.reader startReading];
    
    NSArray * audioTracks = selectAllAudioTracksFromAVAsset(self.readerAsset);
    NSArray * videoTracks = selectAllVideoTracksFromAVAsset(self.readerAsset);
    
    if (videoTracks.count > 0)
        [self.writer startSessionAtSourceTime:CMTimeMake(0, ((AVAssetTrack *)videoTracks[0]).naturalTimeScale)];
    else
        [self.writer startSessionAtSourceTime:CMTimeMake(0, ((AVAssetTrack *)audioTracks[0]).naturalTimeScale)];
}



////----------------------




void writeEachFrameIntoReCompressImageBufferCallback(void *decompressionOutputRefCon,
                                                     void *sourceFrameRefCon,
                                                     OSStatus status,
                                                     VTDecodeInfoFlags infoFlags,
                                                     CVImageBufferRef imageBuffer,
                                                     CMTime presentationTimeStamp,
                                                     CMTime presentationDuration)
{
    VTRecompress *streamManager = (__bridge VTRecompress *)decompressionOutputRefCon;
    
    if (status != noErr)
    {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Decompressed error: %@", error);
    }
    else
    {
        dispatch_semaphore_wait(streamManager.semaCanWriteReCompressBuffer, DISPATCH_TIME_FOREVER);
        streamManager.reCompressImageBuffer = imageBuffer;
        streamManager.reCompressPresentationTimeStamp = presentationTimeStamp;
        streamManager.reCompressDurationTimeStamp = presentationDuration;
        dispatch_semaphore_signal(streamManager.semaCanReadReCompressBuffer);
    }
    
    
}





-(void) createDeCompressSessionOfReCompress:(VTDecompressionOutputCallback)decompressionSessionDecodeFrameCallback
{
    // make sure to destroy the old VTD session
    _decompressionSession = NULL;
    VTDecompressionOutputCallbackRecord callBackRecord;
    callBackRecord.decompressionOutputCallback = decompressionSessionDecodeFrameCallback;

    // this is necessary if you need to make calls to Objective C "self" from within in the callback method.
    callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
    
    // you can set some desired attributes for the destination pixel buffer.  I didn't use this but you may
    // if you need to set some attributes, be sure to uncomment the dictionary in VTDecompressionSessionCreate
    
    /*
     NSDictionary *destinationImageBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithBool:YES],
     (id)kCVPixelBufferOpenGLESCompatibilityKey,
     nil];
     
     */
    
    
    CFDictionaryRef attrs = NULL;
    const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
    //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
    //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
    uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
    attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    
    ////attrs
    ////(__bridge CFDictionaryRef)(destinationImageBufferAttributes)
    ////NULL
    
    
    OSStatus status =  VTDecompressionSessionCreate(kCFAllocatorDefault,
                                                    _formatDescOfDecompress,
                                                    NULL,
                                                    attrs,
                                                    &callBackRecord,
                                                    &_decompressionSession);
    
    NSLog(@"Video Decompression Session Create: \t %@", (status == noErr) ? @"successful!" : @"failed...");
    
    if(status != noErr) {
        NSLog(@"\t\t VTD ERROR type: %d", (int)status);
    }
}





-(void) decodeAllFramesFromReaderOutputOneByOne:(AVAssetReaderTrackOutput*)readerOutput decompressionSessionDecodeFrameCallback:(VTDecompressionOutputCallback)decompressionSessionDecodeFrameCallback
{
    
    _decompressFrameLabel= 0;
    
    
    BOOL done = NO;
    int samCounts = 0;
    while (!done)
    {
        
        
        ////NSLog(@"samCounts: %d",samCounts);
        
        CMSampleBufferRef sampleBuffer = [readerOutput copyNextSampleBuffer];
        CMBlockBufferRef blockBuffer = NULL;
        CVImageBufferRef imageBuffer = NULL;
        
        
        if (sampleBuffer)
        {
            blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
            imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            
            if (imageBuffer == NULL && blockBuffer == NULL) {
                ////NSLog(@"both null skip");
            } else if ( blockBuffer == NULL) {
                
                // Do something with sampleBuffer here.
                // Lock the image buffer
                ////CVPixelBufferLockBaseAddress(imageBuffer,0);
                
                // Get information of the image
                ////uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
                ////size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
                ////size_t width = CVPixelBufferGetWidth(imageBuffer);
                ////size_t height = CVPixelBufferGetHeight(imageBuffer);
                
                //
                //  Here's where you can process the buffer!
                //  (your code goes here)
                //
                //  Finish processing the buffer!
                //
                
                // Unlock the image buffer
                ////CVPixelBufferUnlockBaseAddress(imageBuffer,0);
                NSLog(@"sampleBuffer:%@",sampleBuffer);
                CFRelease(sampleBuffer);
                ////NSLog(@"only image buff");
                ////CFRelease(imageBuffer);
                sampleBuffer = NULL;
                imageBuffer = NULL;
                
            } else if ( imageBuffer == NULL) {
                
                /*
                 The function CMBlockBufferGetDataPointer gives you access to all the data you need,
                 but there are a few not very obvious things you need to do to convert it to an elementary stream.
                 Multiple NAL units in a single CMBlockBuffer
                 The next not very obvious thing is that a single CMBlockBuffer w
                 ill sometimes contain multiple NAL units. Apple seems to add an additional NAL unit (SEI)
                 containing metadata to every I-Frame NAL unit (also called IDR). This is probably why
                 you are seeing multiple buffers in a single CMBlockBuffer object. However,
                 the CMBlockBufferGetDataPointer function gives you a single pointer with access to all the data.
                 That being said, the presence of multiple NAL units complicates the conversion of the AVCC headers.
                 Now you actually have to read the length value contained in the AVCC header to find the next NAL unit,
                 and continue converting headers until you have reached the end of the buffer.
                 */
                
                ////printParameterSets(sampleBuffer);
                
                
                
                BOOL isIFrame = isH264IFrame(sampleBuffer);
                
                
                ////----decode  samplebuffer
                
                ////flags 用0 表示使用同步解码
                VTDecodeFrameFlags flags = kVTDecodeFrame_EnableTemporalProcessing | kVTDecodeFrame_EnableAsynchronousDecompression;
                //kVTDecodeFrame_EnableAsynchronousDecompression;
                //0;
                //kVTDecodeFrame_EnableTemporalProcessing | kVTDecodeFrame_EnableAsynchronousDecompression;
                
                VTDecodeInfoFlags flagOut = 0;
                CVPixelBufferRef outputPixelBuffer = NULL;
                
                self.formatDescOfDecompress = CMSampleBufferGetFormatDescription(sampleBuffer);
                
                if (isIFrame) {
                    VTDecompressionSessionInvalidate(self.decompressionSession);
                    [self createDeCompressSessionOfReCompress:decompressionSessionDecodeFrameCallback];
                    NSLog(@"iframe:%d",samCounts);
                }
                
                
                //&outputPixelBuffer  this is not good
                
                OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(self.decompressionSession,
                                                                          sampleBuffer,
                                                                          flags,
                                                                          &outputPixelBuffer,
                                                                          &flagOut);
                
                
                
                if(decodeStatus == kVTInvalidSessionErr) {
                    NSLog(@"IOS8VT: Invalid session, reset decoder session");
                } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                    NSLog(@"IOS8VT: decode failed status=%d(Bad data)", decodeStatus);
                } else if(decodeStatus != noErr) {
                    NSLog(@"IOS8VT: decode failed status=%d", decodeStatus);
                }
                
                
                
                CFRelease(sampleBuffer);
                ////NSLog(@"==========================================================");
                ////NSLog(@"blockBuffer:%@",blockBuffer);
                ////NSLog(@"only block buff");
                ////CFRelease(blockBuffer);
                
                
                
                sampleBuffer = NULL;
                blockBuffer = NULL;
                
                
                
            }  else {
                NSLog(@"impossible!!!!");
            }
            // Do something with sampleBuffer here.
            
            
            
            samCounts ++;
            
            
        }
        else
        {
            // Find out why the asset reader output couldn't copy another sample buffer.
            if (self.reader.status == AVAssetReaderStatusFailed)
            {
                NSError *failureError = self.reader.error;
                // Handle the error here.
                NSLog(@"failureError:%@",failureError.description);
            }
            else
            {
                // The asset reader output has read all of its samples.
                done = YES;
            }
        }
       
        
    }
    
    ////-dli-
    if (self.decompressionSession) {
        VTDecompressionSessionInvalidate(self.decompressionSession);
    }
    ////-dli-
    
    self.deCompressFinished = true;
}




////-------------------





void appendEachSampleBufferToWriterAfterCompress(void *outputCallbackRefCon,
                     void *sourceFrameRefCon,
                     OSStatus status,
                     VTEncodeInfoFlags infoFlags,
                     CMSampleBufferRef sampleBuffer)
{
    
    
    NSLog(@"didCompressH264 called with status %d infoFlags %d", (int)status, (int)infoFlags);
    if (status != 0) return;
    
    if (!CMSampleBufferDataIsReady(sampleBuffer))
    {
        NSLog(@"didCompressH264 data is not ready ");
        return;
    }
    
    
    VTRecompress * encoder = (__bridge VTRecompress*)outputCallbackRefCon;
    
    
    ////-dli-
    
    if (encoder.compressFrameLabel == 0) {
        encoder.startSessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    }
    
    
    AVAssetWriterInput * currentWriteInput;
    
    ////[encoder->videoWriterInput requestMediaDataWhenReadyOnQueue:encoder.inputQueue usingBlock:^{
    
    ////[encoder->myCondition lock];
    
    CMFormatDescriptionRef fdr = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    
    if (CMFormatDescriptionGetMediaType(fdr) == kCMMediaType_Audio) {
        
        currentWriteInput = encoder.writerAudioInput;
        
    } else if(CMFormatDescriptionGetMediaType(fdr) == kCMMediaType_Video) {
        
        currentWriteInput = encoder.writerVideoInput;
    }
    
    
    while (!currentWriteInput.readyForMoreMediaData) {
        NSLog(@"start wait");
        ////[encoder->myCondition wait];
        [NSThread sleepForTimeInterval:0.1f];
        NSLog(@"did wait");
    }
    
    ////------------------------------------------------------------------------->
    ////CMSampleBufferRef  tempSam ;
    ////CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &tempSam);
    ////NSLog(@"readyForMoreMediaData:%@",tempSam);
    
    CFRetain(sampleBuffer);
    

        
        CMItemCount count;
        ////CMTime newTimeStamp = CMTimeMake(YOURTIME_GOES_HERE);
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
        CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, count, pInfo, &count);
        for (CMItemCount i = 0; i < count; i++)
        {
            pInfo[i].decodeTimeStamp = pInfo[i].presentationTimeStamp;
            //// kCMTimeInvalid if in sequence
        }
        CMSampleBufferRef sout;
        CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, sampleBuffer, count, pInfo, &sout);
        free(pInfo);
        
        ////NSLog(@"encoder->videoWriterInput:%@",encoder->videoWriterInput.description);
        NSLog(@"readyForMoreMediaData:%@",sout);
        BOOL appendSamRslt = [currentWriteInput appendSampleBuffer:sout];
        ////CFRelease(sampleBuffer);
        ////CFRelease(sout);
        
        NSLog(@"sampleReferenceBaseURL:%@",currentWriteInput.sampleReferenceBaseURL);
        
        NSLog(@"appendSamRslt:%d",appendSamRslt);
        
        
        checkAVAssetWriterStatus(encoder.writer);
        
        NSLog(@"encoder->videoWriter.error:%@",encoder.writer.error);
        NSLog(@"encoder->videoWriter.error.description:%@",encoder.writer.error.description);
        
    
    
}





-(void) createCompressSessionOfReCompress:(VTCompressionOutputCallback )appendEachSampleBufferToWriterAfterCompress
{
    
    
    // make sure to destroy the old VTD session
    _compressionSession = NULL;
    

    
    
    float width = getNaturalSize(self.readerAsset, 0).width;
    float height = getNaturalSize(self.readerAsset, 0).height;
    
    
    
    
    
    
    
    //---------saved as mp4 to file
    
    
    
    
    self.reCompressedMP4File = [FileUitl documentsPath:@"reCompressed.mp4"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:self.reCompressedMP4File error:nil];
    
    
    
    ////That was right. Probably the file had been already created and so the assetWriter couldn't write the frames.
    ////[fileMgr createFileAtPath:self->reCompressedMP4File contents:nil attributes:nil];
    ////self->reCompressedMP4FileHandle = [NSFileHandle fileHandleForWritingAtPath:self->reCompressedMP4File];
    
    
    
    ////self->videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self->reCompressedMP4File] fileType:AVFileTypeQuickTimeMovie error:nil];
    
    self.writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:self.reCompressedMP4File] fileType:AVFileTypeQuickTimeMovie error:nil];
    
    
    ////NSParameterAssert(self->videoWriter);
    
    
    CMFormatDescriptionRef videoDesc;
    CMFormatDescriptionCreate(kCFAllocatorDefault, kCMMediaType_Video, 'avc1', NULL, &videoDesc);
    
    
    
    

    
    
    
    
    //---------saved as h264 elementary stream to file
    self.reCompressedFile = [FileUitl documentsPath:@"reCompressed.264"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.reCompressedFile error:nil];
    [fileManager createFileAtPath:self.reCompressedFile contents:nil attributes:nil];
    self.reCompressedFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.reCompressedFile];
    //---------saved as h264 elementary stream to file
    
    
    
    
    /*
     NSDictionary *encoderSpec = @{
     (id)kVTVideoEncoderSpecification_EnableHardwareAcceleratedVideoEncoder : @(YES),
     (id)kVTVideoEncoderSpecification_RequireHardwareAcceleratedVideoEncoder : @(YES),
     };
     */
    

    
    OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, appendEachSampleBufferToWriterAfterCompress, (__bridge void *)(self),  &_compressionSession);
    NSLog(@"encoder VTCompressionSessionCreate %d", (int)status);
    
    if (status != 0)
    {
        NSLog(@"encoder Unable to create a H264 session");
        return ;
        
    }
    
    
    ////VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
    ////VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, 240);
    
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_H264EntropyMode,kVTH264EntropyMode_CABAC);
    
    
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_AutoLevel);
    
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(1280000));
    
    VTCompressionSessionPrepareToEncodeFrames(_compressionSession);
    
    
    

    
}


////-------------------------------------------------



- (void) compressAllFramesOneByOne
{
    ////
    int i =0;
    ////
    while(!self.deCompressFinished) {
        
        dispatch_semaphore_wait(self.semaCanReadReCompressBuffer, DISPATCH_TIME_FOREVER);
        
        self.compressFrameLabel = i;
        
        
        CVImageBufferRef imgBUffer = self.reCompressImageBuffer;
        
        
        
        CMTime presentationTimeStamp = self.reCompressPresentationTimeStamp;
        CMTime newDuration = self.reCompressDurationTimeStamp;
        VTEncodeInfoFlags flags;
        
        
        
        
        
        
        
        OSStatus statusCode = VTCompressionSessionEncodeFrame(_compressionSession,
                                                              imgBUffer,
                                                              presentationTimeStamp,
                                                              newDuration,
                                                              NULL, NULL, &flags);
        
        
        
        
        
        
        
        
        if (statusCode != noErr) {
            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
            
            VTCompressionSessionInvalidate(_compressionSession);
            CFRelease(_compressionSession);
            _compressionSession = NULL;
            return;
        }
        
        CFRelease(imgBUffer);
        
        NSLog(@"encoder VTCompressionSessionEncodeFrame Success");
        
        
        dispatch_semaphore_signal(self.semaCanWriteReCompressBuffer);
        
        
        NSLog(@"--------------%d--------------",i);
        
        i = i+ 1;
    }
    
    
    
    VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);
    
    VTCompressionSessionInvalidate(_compressionSession);
    CFRelease(_compressionSession);
    _compressionSession = NULL;
    
    
    
    
    
    
    
    
    [self.reCompressedFileHandle  closeFile];
    self.reCompressedFileHandle = NULL;
    
    
    
    ////[self->videoWriterInput markAsFinished];
    
    
    
    
    
    
    
    
    
    
    
    
    [self.writer finishWritingWithCompletionHandler:^{
        
        NSLog(@"-------||||||-------sync or not -----||||||--------");
        self.writerVideoInput =nil;
        self.writer = nil;
        [self.reCompressedMP4FileHandle  closeFile];
        
        self.reCompressedMP4FileHandle = NULL;
        
        ////[self UVVideoUploadViaLocalUrl:[NSURL fileURLWithPath:self->reCompressedMP4File] AVFileName:@"reCompressed.mp4"];
        
    }];
}










-(void) VTReCompress
{
    
    self.deCompressFinished = false;
    [self createDeCompressSessionOfReCompress:writeEachFrameIntoReCompressImageBufferCallback];
    
    [self createCompressSessionOfReCompress:appendEachSampleBufferToWriterAfterCompress];
    
    dispatch_async(self.VTDecompressAsyncProcessingConcurrentQueue, ^(void){
        ////[self decodeFromReaderOutput:self.readerAudioOutputWithAllTracks decompressionSessionDecodeFrameCallback:writeEachFrameIntoReCompressImageBufferCallback];
        [self decodeAllFramesFromReaderOutputOneByOne:self.readerVideoOutputWithAllTracks decompressionSessionDecodeFrameCallback:writeEachFrameIntoReCompressImageBufferCallback];
    });
    
    dispatch_async(self.VTCompressAsyncProcessingConcurrentQueue, ^(void){
        [self compressAllFramesOneByOne];
    });
    
    
    
}



/*
 
 {
 'individualSettings': {
 'materialsArray': [],
 'specificFiltersArray': []
 },
 'overallScript': {
 'header': {},
 'scenes': {
 
 '0': {
 'text': {
 'duration': {},
 'startTime': {},
 'position': {
 'y': {},
 'x': {}
 },
 'color': {
 'r': {},
 'b': {},
 'g': {}
 },
 'text': {},
 'animationMode': {},
 'font': {},
 'size': {
 'width': {},
 'height': {}
 }
 },
 'background': {
 'image': {
 'URL': {},
 'position': {
 'y': {},
 'x': {}
 },
 'size': {
 'width': {},
 'height': {}
 }
 },
 'description': {
 'color': {
 'r': {},
 'b': {},
 'g': {}
 },
 'startTime': {},
 'text': {},
 'duration': {},
 'position': {
 'y': {},
 'x': {}
 },
 'animationMode': {},
 'font': {},
 'size': {
 'width': {},
 'height': {}
 }
 }
 },
 'overlay': {
 'durationArray': [],
 'URLArray': [],
 'mode': {},
 'startTime': {},
 'position': {
 'y': {},
 'x': {}
 },
 'type': {},
 'size': {
 'width': {},
 'height': {}
 }
 },
 'sceneFilter':{}
 },
 
 
 '1': {
 'text': {
 'duration': {},
 'startTime': {},
 'position': {
 'y': {},
 'x': {}
 },
 'color': {
 'r': {},
 'b': {},
 'g': {}
 },
 'text': {},
 'animationMode': {},
 'font': {},
 'size': {
 'width': {},
 'height': {}
 }
 },
 'background': {
 'image': {
 'URL': {},
 'position': {
 'y': {},
 'x': {}
 },
 'size': {
 'width': {},
 'height': {}
 }
 },
 'description': {
 'color': {
 'r': {},
 'b': {},
 'g': {}
 },
 'startTime': {},
 'text': {},
 'duration': {},
 'position': {
 'y': {},
 'x': {}
 },
 'animationMode': {},
 'font': {},
 'size': {
 'width': {},
 'height': {}
 }
 }
 },
 'overlay': {
 'durationArray': [],
 'URLArray': [],
 'mode': {},
 'startTime': {},
 'position': {
 'y': {},
 'x': {}
 },
 'type': {},
 'size': {
 'width': {},
 'height': {}
 }
 },
 'sceneFilter':{}
 
 }
 
 
 },
 
 'tailer': {}
 }
 }
 
 */





@end


