//
//  VTRecomp.m
//  UView
//
//  Created by dli on 3/8/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTRecomp.h"

@implementation VTRecomp
-(void)readMe
{
    
}

-(void)printAndCheckParameters
{
    
}

-(void) resetParameters
{
    ////初始化源视频文件的路径 URL 等参数
    self.sourceVideoURL = NULL;
    self.sourceVideoPath = NULL;
    self.sourceVideoFilename = NULL;
    self.sourceVideoRelativeDir = NULL;
    ////初始化writer并开始,先开始writer再开始reader,避免错过开始的frame
    self.writerOutputFileType = NULL;
    self.writer = NULL;
    self.writerInput = NULL;
    self.writerPixelBufferAdaptor = NULL;
    self.deleteOutputDirBeforeWrite = NULL;
    self.writerOutputFileName = NULL;
    self.writerOutputRelativeDirPath = NULL;
    self.writerOutputPath = NULL;
    self.writerOutputURL = NULL;
    ////初始化reader并开始，存储width height preferedTransform给完成重压缩后的最后阶段使用
    self.reader = NULL;
    self.readerAsset = NULL;
    self.whichTrack = 0;
    self.sourceVideoTrack = NULL;
    self.preferedTransform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    self.width = 0.0;
    self.height = 0.0;
    self.readerOutput = NULL;
    ////初始化cache ,队列, 信号量， 建立缓存机制, 如果不是reOrder不起作用，是不需要这样做的，当前因为需要重排序，所以必须这样
    self.VTRecompressProcessingSerialQueue = NULL;
    self.VTRecompressProcessingConcurrentQueue = NULL;
    self.useCacheArray = YES;
    self.cacheArraySize = 30;
    self.cacheAlreadyFilledCount = 0;
    self.cacheAlreadyHandledCount = 0;
    self.cacheLock = NULL;
    self.bufferFilledSema = NULL;
    self.bufferHandledSema = NULL;
    self.eachExtractedCVImage = NULL;
    self.parallelArray = NULL;
    self.extractedCVImageRefs = NULL;
    self.presentationTimeStamps = NULL;
    self.decodeTimeStamps = NULL;
    self.durations = NULL;
    self.keyFrameSigns = NULL;
    ////
    self.goodSamCounts = 0;
    self.origGoodSamCounts = 0;
    self.removeNegativeCMTime = YES;
    ////
    self.decompressionSession = NULL;
    self.decompressionEachFrameCallback = NULL;
    self.decompressionVideoFormatDescription = NULL;
    self.constructDestinationImageBufferAttributesFromKeyValue = NO;
    self.destinationImageBufferAttributes = NULL;
    self.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    self.constructDecompressionDecodeSpecificationFromKeyValue = NO;
    self.decompressionDecodeSpecification = NULL;
    ////
    self.recompressionStartTime = NULL;
    self.currKeyFrameIndicator = NO;
    self.newSessionEachKeyFrame = NO;
    ////
    self.sortImagesAfterDecompression = YES;
    self.reducedFrameNumerator = 0 ;
    self.reducedFrameDenominator = 0;
    self.currCacheStartPresentation=kCMTimeZero;
    self.useOnlyDurations = NO;
    self.useOnlyPresentations = NO;
    self.doneDoneDone = NO;
    self.decompressionFinished =NO;
    ////
    self.compressionMultiPassEnabled = NO;
    self.multiPassStorageCMTimeRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
    self.deleteSourceOneByOneAfterAppendSinglePass = NO;
    self.deleteSourceOneByOneAfterAppendMultiPass = NO;
    self.nextPassStartSeqs = NULL;
    self.nextPassEndSeqs = NULL;
    self.nextIgnoreStartSeqs = NULL;
    self.nextIgnoreEndSeqs = NULL;
    self.compressionSourcesCount = 0;
    self.compressionSourceSeq = 0;
    /////
    self.compressionCodecType = kCMVideoCodecType_H264;
    self.compressionEncoderSpecification = NULL;
    self.compressionEncoderSpecificationConstructFromKeyValue =NO;
    self.encoderID = @"";
    self.CodecName = @"";
    self.CodecType = kCMVideoCodecType_H264;
    self.DisplayName = @"";
    self.EncoderName = @"";
    self.compressionSourceImageBufferAttributes = NULL;
    self.compressionSourceImageBufferAttributesConstructFromKeyValue = NO;
    self.compressionCVPixelFormatTypeValue = kCVPixelFormatType_32BGRA;
    self.compressionSession = NULL;
    self.compressionEachSampleBufferCallback = NULL;
    ////
    self.multiPassStorageOut = NULL;
    self.multiPassStorageCreationOption_DoNotDelete =NO;
    self.siloOut = NULL;
    self.compressionSessionProperties = NULL;
    self.compressionSessionPropertiesConstructFromKeyValue = NO;
    self.compressionAllowFrameReordering = NO;
    self.compressionAllowTemporalCompression = YES;
    self.compressionCleanAperture = NULL;
    self.compressionCleanApertureConstructFromKeyValue = NO;
    self.cleanApertureWidth = 0;
    self.cleanApertureHeight = 0;
    self.cleanApertureHorizontalOffset = 0;
    self.cleanApertureVerticalOffset = 0;
    self.compressionAverageBitRate = 1280000;
    self.compressionColorPrimaries = NULL;
    self.compressionFieldCount = 0;
    self.compressionFieldDetail = kCMFormatDescriptionFieldDetail_TemporalBottomFirst;
    self.compressionH264EntropyMode = kVTH264EntropyMode_CABAC;
    self.compressionMaxFrameDelayCount = kVTUnlimitedFrameDelayCount;
    self.compressionMaxKeyFrameInterval = 0;
    self.compressionMaxKeyFrameIntervalDuration = 0;
    self.compressionPixelAspectRatioConstructFromKeyValue = NO;
    self.compressionPixelAspectRatio = NULL;
    self.pixelAspectRatioHorizontalSpacing = 1;
    self.pixelAspectRatioVerticalSpacing = 1;
    self.compressionProfilelevel = kVTProfileLevel_H264_High_AutoLevel;
    self.compressionRealTime = NO;
    self.compressionYCbCrMatrix = kCMFormatDescriptionYCbCrMatrix_ITU_R_709_2;
    self.compressionTransferFunction = kCMFormatDescriptionTransferFunction_ITU_R_709_2;
    ////
    self.keepKeyFrameSigns = NO;
    self.endSessionAtSourceTime = kCMTimeZero;
    ////
    self.howManyPasses = 0 ;
    self.currPassRound = 0 ;
    self.furtherPass = NO;
    ////
    self.applyOOBPT = YES;
    self.recompressionEndTime = NULL;
    self.compressionFinished = NO;
    self.deleteOutputFileInSandboxAfterCopyToAlbum = NO;
    self.writeToAlbum = NO;
    self.SYNC = NO;
}
////
-(void) makeSourceVideoPathsAndURLsReady
{
    @autoreleasepool {
        if (self.sourceVideoURL != NULL) {
            self.sourceVideoPath = [self.sourceVideoURL path];
            self.sourceVideoFilename = [self.sourceVideoPath lastPathComponent];
            self.sourceVideoRelativeDir = [self.sourceVideoPath stringByDeletingLastPathComponent].lastPathComponent;
        } else if (self.sourceVideoPath != NULL) {
            self.sourceVideoURL = [NSURL fileURLWithPath:self.sourceVideoPath];
            self.sourceVideoPath = [self.sourceVideoURL path];
            self.sourceVideoFilename = [self.sourceVideoPath lastPathComponent];
            self.sourceVideoRelativeDir = [self.sourceVideoPath stringByDeletingLastPathComponent].lastPathComponent;
        } else {
            self.sourceVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.sourceVideoRelativeDir];
            self.sourceVideoPath = [self.sourceVideoPath stringByAppendingPathComponent:self.sourceVideoFilename];
            self.sourceVideoURL = [NSURL fileURLWithPath:self.sourceVideoPath];
        }
    }
}
////
-(void) makeWriterReadyAndStart
{
    
    @autoreleasepool {
        
        if (self.writerOutputURL != NULL) {
            self.writerOutputPath = [self.writerOutputURL path];
            self.writerOutputFileName = self.writerOutputPath.lastPathComponent;
            self.writerOutputRelativeDirPath = [self.writerOutputPath stringByDeletingLastPathComponent].lastPathComponent;
        } else if (self.writerOutputPath != NULL) {
            self.writerOutputURL = [NSURL fileURLWithPath:self.writerOutputPath];
            self.writerOutputFileName = self.writerOutputPath.lastPathComponent;
            self.writerOutputRelativeDirPath = [self.writerOutputPath stringByDeletingLastPathComponent].lastPathComponent;
        } else {
            if (self.deleteOutputDirBeforeWrite) {
                [FileUitl deleteSubDirOfTmp:self.writerOutputRelativeDirPath];
            }
            [FileUitl creatSubDirOfTmp:self.writerOutputRelativeDirPath];
            NSString * temp = [self.writerOutputRelativeDirPath stringByAppendingPathComponent:self.writerOutputFileName];
            self.writerOutputPath=[FileUitl getFullPathOfTmp:temp];
            [FileUitl deleteTmpFile:self.writerOutputPath];
            self.writerOutputURL=[NSURL fileURLWithPath:self.writerOutputPath];
        }
        self.writer = NULL;
        self.writerInput = NULL;
        NSError * error;
        self.writer= [[AVAssetWriter alloc] initWithURL:self.writerOutputURL
                                               fileType:self.writerOutputFileType
                                                  error:&error];
        self.writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:nil];
        [self.writerInput setExpectsMediaDataInRealTime:NO];
        if([self.writer canAddInput:self.writerInput])
        {
            [self.writer addInput:self.writerInput];
        } else {
            NSLog(@"writer cant add input");
            return;
        }
        [self.writer startWriting];
        [self.writer startSessionAtSourceTime:kCMTimeZero];
    }
}
////
-(void) makeReaderReadyAndStart
{
    @autoreleasepool {
        if (self.readerAsset == NULL) {
            self.readerAsset = [AVAsset assetWithURL:self.sourceVideoURL];
        } else {
            
        }
        NSError * error ;
        self.reader = [[AVAssetReader alloc] initWithAsset:self.readerAsset error:&error];
        self.sourceVideoTrack = [selectAllVideoTracksFromAVAsset(self.readerAsset) objectAtIndex:self.whichTrack];
        self.preferedTransform = [self.sourceVideoTrack preferredTransform];
        self.width = self.sourceVideoTrack.naturalSize.width;
        self.height = self.sourceVideoTrack.naturalSize.height;
        self.readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:self.sourceVideoTrack outputSettings:nil];
        [self.reader addOutput:self.readerOutput];
        [self.reader startReading];
    }
}
////
-(void) makeCacheQueueSemaReady
{
    self.VTRecompressProcessingConcurrentQueue = dispatch_queue_create("VTRecompressProcessingConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    self.VTRecompressProcessingSerialQueue = dispatch_queue_create("VTRecompressProcessingSerialQueue", DISPATCH_QUEUE_SERIAL);
    self.keyFrameSigns = [[NSMutableArray  alloc] init];
    self.presentationTimeStamps = [[NSMutableArray alloc] init];
    self.durations  = [[NSMutableArray alloc] init];
    self.decodeTimeStamps = [[NSMutableArray alloc] init];
    self.parallelArray = [[NSMutableArray  alloc] init];
    self.cacheAlreadyFilledCount = 0;
    self.cacheAlreadyHandledCount = self.cacheArraySize ;
    self.bufferFilledSema = dispatch_semaphore_create(0);
    self.bufferHandledSema = dispatch_semaphore_create(0);
    self.cacheLock = [[NSLock alloc] init];
}
//// decompress process each frame call back,cacheAlreadyFilledCount+1
void eachFrameCallbackOfDecompProgress(void *decompressionOutputRefCon,void *sourceFrameRefCon,OSStatus status,VTDecodeInfoFlags infoFlags,CVImageBufferRef imageBuffer,CMTime presentationTimeStamp,CMTime duration)
{
    @autoreleasepool {
        VTRecomp *decoder = (__bridge VTRecomp *)decompressionOutputRefCon;
        if (status != noErr)
        {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Decompressed error: %@", error);
        }
        else
        {
            if (decoder.removeNegativeCMTime == YES) {
                if (presentationTimeStamp.value < 0 || presentationTimeStamp.timescale < 0 ) {
                    return;
                }
                if (duration.value < 0 || duration.timescale < 0) {
                    return;
                }
            } else {
                
            }
            CVPixelBufferLockBaseAddress(imageBuffer,0);
            decoder.eachExtractedCVImage = imageBuffer;
            NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"decodeTimeStamp"];
            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
            [parallel setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
            ////decoder.currKeyFrameIndicator的更新和此处不同步，所以这里先用NO 占位
            [parallel setValue:[NSNumber numberWithBool:NO] forKey:@"isKeyFrame"];
            [parallel setValue:[NSNumber numberWithInt:decoder.goodSamCounts] forKey:@"origSeq"];
            [parallel setValue:(__bridge id)decoder.eachExtractedCVImage forKey:@"CVImage"];
            [decoder.parallelArray addObject:parallel];
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
            decoder.cacheAlreadyFilledCount = decoder.cacheAlreadyFilledCount + 1;
            decoder.goodSamCounts ++;
            decoder.origGoodSamCounts ++;
        }
        ////we should not release CVImageBufferRef imageBuffer here
    }
}
//// makeVTDecompressionSession
-(void) makeVTDecompressionSession
{
    @autoreleasepool {
        self.decompressionSession = NULL;
        self.decompressionEachFrameCallback = eachFrameCallbackOfDecompProgress;
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = self.decompressionEachFrameCallback;
        callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
        if (self.constructDestinationImageBufferAttributesFromKeyValue) {
            self.destinationImageBufferAttributes = NULL;
            const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
            uint32_t v = self.destinationImageBufferKCVPixelFormatType;
            const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
            self.destinationImageBufferAttributes = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        } else {
            if (self.destinationImageBufferAttributes != NULL) {
            } else {
                self.destinationImageBufferAttributes = NULL;
                const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
                uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
                const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
                self.destinationImageBufferAttributes = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            }
        }
        ////self.decompressionDecodeSpecification should be inited here
        ////kVTDecompressionProperty_DeinterlaceMode_Temporal
        if (self.constructDecompressionDecodeSpecificationFromKeyValue) {
            self.decompressionDecodeSpecification = NULL;
        } else {
            if (self.decompressionDecodeSpecification != NULL) {
                
            } else {
                self.decompressionDecodeSpecification = NULL;
                
            }
        }
        ////self.decompressionDecodeSpecification should be inited here
        OSStatus status =  VTDecompressionSessionCreate(kCFAllocatorDefault,self.decompressionVideoFormatDescription,self.decompressionDecodeSpecification,self.destinationImageBufferAttributes,&callBackRecord,&_decompressionSession);
        NSLog(@"Video Decompression Session Create: \t %@", (status == noErr) ? @"successful!" : @"failed...");
        if(status != noErr) {
            NSLog(@"\t\t VTD ERROR type: %d", (int)status);
        }
        if (self.constructDecompressionDecodeSpecificationFromKeyValue == YES) {
            CFRelease(self.decompressionDecodeSpecification);
            self.decompressionDecodeSpecification = NULL;
        } else {
            if (self.decompressionDecodeSpecification == NULL) {
                
            } else {
                CFRelease(self.decompressionDecodeSpecification);
                self.decompressionDecodeSpecification = NULL;
            }
        }
        if (self.constructDestinationImageBufferAttributesFromKeyValue) {
            CFRelease(self.destinationImageBufferAttributes);
            self.destinationImageBufferAttributes = NULL;
        } else {
            if (self.destinationImageBufferAttributes != NULL) {
                CFRelease(self.destinationImageBufferAttributes);
                self.destinationImageBufferAttributes = NULL;
            } else {
                
            }
        }
    }
}
////
-(void) makeParallelArrayReadyAfterCacheFilled
{
    
    ////decompressionOutputCallback 是异步的
    if (self.removeNegativeCMTime) {
        for (int i = 0; i< self.keyFrameSigns.count; i++) {
            [self.parallelArray[i] setValue:self.keyFrameSigns[i] forKey:@"isKeyFrame"];
        }
    } else {
        for (int i = 0; i< self.keyFrameSigns.count; i++) {
            [self.parallelArray[i] setValue:self.keyFrameSigns[i] forKey:@"isKeyFrame"];
        }
    }
    if (self.sortImagesAfterDecompression) {
        [self.parallelArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            NSDictionary * o1 = (NSDictionary *) obj1;
            NSDictionary * o2 = (NSDictionary *) obj2;
            CMTime pt1 = [[o1 valueForKey:@"presentationTimeStamp"] CMTimeValue];
            CMTime pt2 = [[o2 valueForKey:@"presentationTimeStamp"] CMTimeValue];
            if (pt1.value <= pt2.value) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (pt1.value > pt2.value) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    ////-----人工剔除frame
    if((self.reducedFrameNumerator > 0) && (self.reducedFrameDenominator > 0) && (self.reducedFrameNumerator < self.reducedFrameDenominator)) {
        
        NSMutableArray * bakParallelArray = [[NSMutableArray alloc] init];
        for (int i = 0; i< self.parallelArray.count; i++) {
            int r = i % self.reducedFrameDenominator;
            int s = self.reducedFrameDenominator - r ;
            if (s <= self.reducedFrameNumerator) {
                [bakParallelArray addObject:self.parallelArray[i]];
            }
        }
        self.parallelArray = NULL;
        self.parallelArray = bakParallelArray;
        bakParallelArray = NULL;
    }
    ////----如果人工降低frame rate 需要调整duration Time
    if((self.reducedFrameNumerator > 0) && (self.reducedFrameDenominator > 0) && (self.reducedFrameNumerator < self.reducedFrameDenominator)) {
        for (int i = 0; i< self.parallelArray.count - 1; i++) {
            NSMutableDictionary * parallela = [[NSMutableDictionary alloc] init];
            parallela = self.parallelArray[i];
            CMTime pa = [[parallela valueForKey:@"presentationTimeStamp"] CMTimeValue];
            NSMutableDictionary * parallelb = [[NSMutableDictionary alloc] init];
            parallelb = self.parallelArray[i+1];
            CMTime pb = [[parallelb valueForKey:@"presentationTimeStamp"] CMTimeValue];
            CMTime d = CMTimeSubtract(pb, pa);
            [parallela setValue:[NSValue valueWithCMTime:d] forKey:@"duration"];
            self.parallelArray[i] = parallela;
        }
    }
    self.extractedCVImageRefs = CFArrayCreateMutable(NULL,  (CFIndex)self.parallelArray.count, &kCFTypeArrayCallBacks);
    int paCount;
    if (self.cacheArraySize <= self.parallelArray.count) {
        paCount = self.cacheArraySize;
    } else {
        paCount = (int)self.parallelArray.count;
    }
    for (int i = 0; i< paCount; i++) {
        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
        parallel = self.parallelArray[i];
        self.presentationTimeStamps[i] = [parallel valueForKey:@"presentationTimeStamp"];
        self.durations[i] = [parallel valueForKey:@"duration"];
        self.decodeTimeStamps[i] = [parallel valueForKey:@"decodeTimeStamp"];
        self.keyFrameSigns[i] = [parallel valueForKey:@"isKeyFrame"];
        CFArrayAppendValue(self.extractedCVImageRefs, (__bridge CGImageRef)([parallel valueForKey:@"CVImage"]));
    }
    if (self.useOnlyDurations && !self.useOnlyPresentations) {
        CMTime currP = self.currCacheStartPresentation;
        for (int i = 0; i < self.durations.count; i++) {
            self.presentationTimeStamps[i]=[NSValue valueWithCMTime:currP];
            currP = CMTimeAdd(currP, [self.durations[i] CMTimeValue]);
        }
        self.currCacheStartPresentation = currP;
    } else if (!self.useOnlyDurations && self.useOnlyPresentations) {
        for (int i = 0; i < self.durations.count - 1; i++) {
            CMTime currP = [self.presentationTimeStamps[i] CMTimeValue];
            CMTime nextP = [self.presentationTimeStamps[i+1] CMTimeValue];
            self.durations[i] = [NSValue valueWithCMTime:CMTimeSubtract(nextP, currP)];
        }
        ////最后一个维持原有的duration 为了实现上的方便
    } else {
        /////////
    }
    if (self.compressionMultiPassEnabled) {
        CMTime si = [self.presentationTimeStamps[0] CMTimeValue];
        CMTime eip = [self.presentationTimeStamps[self.presentationTimeStamps.count-1] CMTimeValue];
        CMTime eid = [self.durations[self.durations.count-1] CMTimeValue];
        CMTime ei = CMTimeAdd(eip, eid);
        self.multiPassStorageCMTimeRange = CMTimeRangeMake(si, ei);
    }
    for (int i = self.cacheArraySize; i<self.parallelArray.count ; i++) {
        self.parallelArray[i - self.cacheArraySize] = self.parallelArray[i];
    }
    for (int i = self.cacheArraySize; i<self.parallelArray.count ; i++) {
        [self.parallelArray removeObjectAtIndex:self.cacheArraySize];
    }
    
    
    /*
    NSLog(@"------dli---makeParallelArrayReadyAfterCacheFilled------");
    NSLog(@"self.extractedCVImageRefs:%@",self.extractedCVImageRefs);
    NSLog(@"------dli---makeParallelArrayReadyAfterCacheFilled------");
    */
    
    
    
}
//// decompress process while circle
-(void) makeDecomp
{
    BOOL done = NO;
    self.goodSamCounts = 0;
    self.origGoodSamCounts = 0;
    BOOL firstGoodIFrame = NO;
    ////dispatch_time_t semaWaitDelay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 100);
    
    [self.cacheLock lock];
    while (!firstGoodIFrame) {
        @autoreleasepool {
            CMSampleBufferRef sampleBuffer = [self.readerOutput copyNextSampleBuffer];
            CMBlockBufferRef blockBuffer = NULL;
            CVImageBufferRef imageBuffer = NULL;
            if (sampleBuffer)
            {
                CMItemCount numOfsamplesInSampleBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
                if ((int)numOfsamplesInSampleBuffer == 0) {
                    ////ignore bad sampleBuffer with no samples
                } else {
                    blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
                    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                    if (imageBuffer == NULL && blockBuffer == NULL) {
                        ////either imageBuffer or blockBuffer
                    } else if ( blockBuffer == NULL) {
                        //The caller does not own the returned dataBuffer, and must retain it explicitly
                        CFRetain(imageBuffer);
                        CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                        CMTime decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer);
                        CMTime frameDuration = CMSampleBufferGetDuration(sampleBuffer);
                        if (self.removeNegativeCMTime == YES) {
                            if (presentationTimeStamp.value < 0 || presentationTimeStamp.timescale < 0 ) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(imageBuffer);
                                imageBuffer = NULL;
                                continue;
                            }
                            if (decodeTimeStamp.value < 0 || decodeTimeStamp.timescale < 0) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(imageBuffer);
                                imageBuffer = NULL;
                                continue;
                            }
                            if (frameDuration.value < 0 || frameDuration.timescale < 0) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(imageBuffer);
                                imageBuffer = NULL;
                                continue;
                            }
                        } else {
                        }
                        CVPixelBufferLockBaseAddress(imageBuffer,0);
                        self.eachExtractedCVImage = imageBuffer;
                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                        [parallel setValue:[NSValue valueWithCMTime:decodeTimeStamp] forKey:@"decodeTimeStamp"];
                        [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                        [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                        ////
                        for (int ki; ki < (int)numOfsamplesInSampleBuffer; ki++) {
                            if (isH264IFrame(sampleBuffer, ki)) {
                                self.currKeyFrameIndicator = YES;
                                [self.keyFrameSigns addObject:[NSNumber numberWithBool:YES]];
                            } else {
                                self.currKeyFrameIndicator = NO;
                                if (ki==0) {
                                    ////第一frame  必须是IFRAME
                                    continue;
                                } else {
                                    [self.keyFrameSigns addObject:[NSNumber numberWithBool:NO]];
                                }
                            }
                        }
                        ////
                        [parallel setValue:[NSNumber numberWithInt:self.goodSamCounts] forKey:@"origSeq"];
                        [parallel setValue:(__bridge id)self.eachExtractedCVImage forKey:@"CVImage"];
                        [self.parallelArray addObject:parallel];
                        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                        //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        //because used CFRetain before
                        CFRelease(imageBuffer);
                        imageBuffer = NULL;
                        self.goodSamCounts ++;
                        self.origGoodSamCounts = self.origGoodSamCounts +1;
                        firstGoodIFrame = YES;
                    } else if ( imageBuffer == NULL) {
                        //The caller does not own the returned dataBuffer, and must retain it explicitly
                        CFRetain(blockBuffer);
                        if (self.removeNegativeCMTime == YES) {
                            CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                            CMTime decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer);
                            CMTime frameDuration = CMSampleBufferGetDuration(sampleBuffer);
                            if (presentationTimeStamp.value < 0 || presentationTimeStamp.timescale < 0 ) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                ////----because used CFRetain before
                                CFRelease(blockBuffer);
                                blockBuffer = NULL;
                                continue;
                            }
                            if (decodeTimeStamp.value < 0 || decodeTimeStamp.timescale < 0) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                ////----because used CFRetain before
                                CFRelease(blockBuffer);
                                blockBuffer = NULL;
                                continue;
                            }
                            if (frameDuration.value < 0 || frameDuration.timescale < 0) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                ////----because used CFRetain before
                                CFRelease(blockBuffer);
                                blockBuffer = NULL;
                                continue;
                            }
                        } else {
                        }
                        ////////////////============dli================
                        BOOL isIFrame = isH264IFrame(sampleBuffer,0);
                        //
                        VTDecodeFrameFlags flags = kVTDecodeFrame_EnableTemporalProcessing|kVTDecodeFrame_EnableAsynchronousDecompression ;
                        VTDecodeInfoFlags flagOut = 0;
                        void * sourceFrameRefCon = NULL;
                        if (isIFrame) {
                            self.currKeyFrameIndicator = YES;
                            self.decompressionVideoFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                            VTDecompressionSessionWaitForAsynchronousFrames(self.decompressionSession);
                            VTDecompressionSessionInvalidate(self.decompressionSession);
                            if (self.decompressionSession) {
                                CFRelease(self.decompressionSession);
                                self.decompressionSession = NULL;
                            }
                            [self makeVTDecompressionSession];
                        }
                        ////
                        for (int ki; ki < (int)numOfsamplesInSampleBuffer; ki++) {
                            if (isH264IFrame(sampleBuffer, ki)) {
                                self.currKeyFrameIndicator = YES;
                                [self.keyFrameSigns addObject:[NSNumber numberWithBool:YES]];
                            } else {
                                self.currKeyFrameIndicator = NO;
                                if (ki==0) {
                                    ////第一frame  必须是IFRAME
                                    continue;
                                } else {
                                    [self.keyFrameSigns addObject:[NSNumber numberWithBool:NO]];
                                }
                            }
                        }
                        ////
                        OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(self.decompressionSession,
                                                                                  sampleBuffer,
                                                                                  flags,
                                                                                  &sourceFrameRefCon,
                                                                                  &flagOut);
                        if(decodeStatus == kVTInvalidSessionErr) {
                            NSLog(@"IOS8VT: Invalid session, reset decoder session");
                        } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                            NSLog(@"IOS8VT: decode failed status=%d(Bad data)", (int)decodeStatus);
                        } else if(decodeStatus != noErr) {
                            NSLog(@"IOS8VT: decode failed status=%d", (int)decodeStatus);
                        }
                        //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        ////----because used CFRetain before
                        CFRelease(blockBuffer);
                        blockBuffer = NULL;
                        firstGoodIFrame = YES;
                    }  else {
                        NSLog(@"impossible!!!!");
                    }
                }
            } else {
                if (self.reader.status == AVAssetReaderStatusFailed)
                {
                    NSError *failureError = self.reader.error;
                    NSLog(@"failureError:%@",failureError.description);
                    [self.reader cancelReading];
                    break;
                }
                else
                {
                    done = YES;
                    [self.reader cancelReading];
                    break;
                }
            }
        }
    }
    while (self.cacheAlreadyFilledCount == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    self.cacheAlreadyFilledCount = 0;
    [self.cacheLock unlock];
    
    
    
    while (!done)
    {
        ////
        ////NSLog(@"decompress 开始处理后续");
        if (self.cacheAlreadyHandledCount < self.cacheArraySize) {
            ////NSLog(@"self.goodSamCounts:%d",self.goodSamCounts);
            ////NSLog(@"    压缩过程尚未填充满buff,等待compress,self.cacheAlreadyHandledCount:%d",self.cacheAlreadyHandledCount);
            if( dispatch_semaphore_wait(self.bufferHandledSema,DISPATCH_TIME_NOW)){
               ////non-zero if the timeout occurred
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
               ////NSLog(@"        semaWaitDelay时间内未收到压缩完成填充buffer的信号bufferHandledSema, 继续等待compress");
               continue;
            } else {
               ////zero 继续执行
                ////NSLog(@"        semaWaitDelay时间内收到压缩完成填充buffer的信号bufferHandledSema,开始继续解压");
            }
        }
        if (self.cacheAlreadyFilledCount == 0) {
            ////NSLog(@"     decompress处理buffer前要确保self.cacheAlreadyFilledCount为0，这个动作是compress过程收尾时完成的，已经为0");
        } else {
            ////NSLog(@"     decompress正在填充中，currently=%d",self.cacheAlreadyFilledCount);
        }
        ////
        @autoreleasepool {
            /////NSLog(@"decompress 开始处理缓存");
            CMSampleBufferRef sampleBuffer = [self.readerOutput copyNextSampleBuffer];
            CMBlockBufferRef blockBuffer = NULL;
            CVImageBufferRef imageBuffer = NULL;
            if (sampleBuffer)
            {
                CMItemCount numOfsamplesInSampleBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
                if ((int)numOfsamplesInSampleBuffer == 0) {
                    ////ignore bad sampleBuffer with no samples
                } else {
                    blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
                    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                    if (imageBuffer == NULL && blockBuffer == NULL) {
                        ////either imageBuffer or blockBuffer
                    } else if ( blockBuffer == NULL) {
                        //The caller does not own the returned dataBuffer, and must retain it explicitly
                        CFRetain(imageBuffer);
                        CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                        CMTime decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer);
                        CMTime frameDuration = CMSampleBufferGetDuration(sampleBuffer);
                        if (self.removeNegativeCMTime == YES) {
                            if (presentationTimeStamp.value < 0 || presentationTimeStamp.timescale < 0 ) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(imageBuffer);
                                imageBuffer = NULL;
                                continue;
                            }
                            if (decodeTimeStamp.value < 0 || decodeTimeStamp.timescale < 0) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(imageBuffer);
                                imageBuffer = NULL;
                                continue;
                            }
                            if (frameDuration.value < 0 || frameDuration.timescale < 0) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(imageBuffer);
                                imageBuffer = NULL;
                                continue;
                            }
                        } else {
                            
                        }
                        CVPixelBufferLockBaseAddress(imageBuffer,0);
                        ////if typeForBuffer = @"CVImage"  and  storeInDick == NO, will never applyCIPT
                        self.eachExtractedCVImage = imageBuffer;
                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                        [parallel setValue:[NSValue valueWithCMTime:decodeTimeStamp] forKey:@"decodeTimeStamp"];
                        [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                        [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                        ////
                        for (int ki; ki < (int)numOfsamplesInSampleBuffer; ki++) {
                            if (isH264IFrame(sampleBuffer, ki)) {
                                self.currKeyFrameIndicator = YES;
                                [self.keyFrameSigns addObject:[NSNumber numberWithBool:YES]];
                            } else {
                                
                                self.currKeyFrameIndicator = NO;
                                if (ki==0) {
                                    ////第一frame  必须是IFRAME
                                    continue;
                                } else {
                                    [self.keyFrameSigns addObject:[NSNumber numberWithBool:NO]];
                                }
                            }
                        }
                        ////
                        [parallel setValue:[NSNumber numberWithInt:self.goodSamCounts] forKey:@"origSeq"];
                        [parallel setValue:(__bridge id)self.eachExtractedCVImage forKey:@"CVImage"];
                        [self.parallelArray addObject:parallel];
                        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                        //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        //because used CFRetain before
                        CFRelease(imageBuffer);
                        imageBuffer = NULL;
                        self.origGoodSamCounts ++;
                        self.goodSamCounts ++;
                    } else if ( imageBuffer == NULL) {
                        //The caller does not own the returned dataBuffer, and must retain it explicitly
                        CFRetain(blockBuffer);
                        if (self.removeNegativeCMTime == YES) {
                            CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                            CMTime decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer);
                            CMTime frameDuration = CMSampleBufferGetDuration(sampleBuffer);
                            if (presentationTimeStamp.value < 0 || presentationTimeStamp.timescale < 0 ) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(blockBuffer);
                                blockBuffer = NULL;
                                continue;
                                
                            }
                            if (decodeTimeStamp.value < 0 || decodeTimeStamp.timescale < 0) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(blockBuffer);
                                blockBuffer = NULL;
                                continue;
                            }
                            if (frameDuration.value < 0 || frameDuration.timescale < 0) {
                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                CFRelease(sampleBuffer);
                                sampleBuffer = NULL;
                                //because used CFRetain before
                                CFRelease(blockBuffer);
                                blockBuffer = NULL;
                                continue;
                            }
                        } else {
                            
                        }
                        ////////////////============dli================
                        BOOL isIFrame = isH264IFrame(sampleBuffer,0);
                        //
                        VTDecodeFrameFlags flags = kVTDecodeFrame_EnableTemporalProcessing|kVTDecodeFrame_EnableAsynchronousDecompression ;
                        VTDecodeInfoFlags flagOut = 0;
                        void * sourceFrameRefCon = NULL;
                        if (isIFrame) {
                            self.currKeyFrameIndicator = YES;
                            if (self.newSessionEachKeyFrame) {
                                self.decompressionVideoFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);                            VTDecompressionSessionWaitForAsynchronousFrames(self.decompressionSession);
                                VTDecompressionSessionInvalidate(self.decompressionSession);
                                if (self.decompressionSession) {
                                    CFRelease(self.decompressionSession);
                                    self.decompressionSession = NULL;
                                }
                                [self makeVTDecompressionSession];
                            }
                        } else {
                            
                        }
                        ////
                        for (int ki; ki < (int)numOfsamplesInSampleBuffer; ki++) {
                            if (isH264IFrame(sampleBuffer, ki)) {
                                self.currKeyFrameIndicator = YES;
                                [self.keyFrameSigns addObject:[NSNumber numberWithBool:YES]];
                            } else {
                                
                                self.currKeyFrameIndicator = NO;
                                [self.keyFrameSigns addObject:[NSNumber numberWithBool:NO]];
                            }
                        }
                        ////
                        OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(self.decompressionSession,
                                                                                  sampleBuffer,
                                                                                  flags,
                                                                                  &sourceFrameRefCon,
                                                                                  &flagOut);
                        if(decodeStatus == kVTInvalidSessionErr) {
                            NSLog(@"IOS8VT: Invalid session, reset decoder session");
                        } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                            NSLog(@"IOS8VT: decode failed status=%d(Bad data)", (int)decodeStatus);
                        } else if(decodeStatus != noErr) {
                            NSLog(@"IOS8VT: decode failed status=%d", (int)decodeStatus);
                        }
                        
                        
                        //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        
                        ////----because used CFRetain before
                        CFRelease(blockBuffer);
                        blockBuffer = NULL;
                        
                    }  else {
                        NSLog(@"impossible!!!!");
                    }
                    
                }
            } else {
                if (self.reader.status == AVAssetReaderStatusFailed)
                {
                    NSError *failureError = self.reader.error;
                    NSLog(@"failureError:%@",failureError.description);
                    [self.reader cancelReading];
                    break;
                }
                else
                {
                    done = YES;
                    VTDecompressionSessionWaitForAsynchronousFrames(self.decompressionSession);
                    [self makeParallelArrayReadyAfterCacheFilled];
                    self.cacheAlreadyFilledCount = self.cacheArraySize;
                    ////----for test
                    NSLog(@"cachesize:%d<> parrallel array:%ld",self.cacheArraySize,self.parallelArray.count);
                    ////----for test
                    ////把剩余的frames全部刷出来
                    ////此时不再copySampleBuffer出来
                    ////等待comp 线程处理
                    ////为了防止自己释放的锁马上又被自己得到
                    self.cacheAlreadyHandledCount = 0;
                    
                    NSLog(@"---dli----done---self.bufferFilledSema");
                    NSLog(@"---dli----done---self.bufferFilledSema");
                    
                    self.doneDoneDone = YES;
                    dispatch_semaphore_signal(self.bufferFilledSema);
                    [self.reader cancelReading];
                    break;
                }
            }
            
            if(self.cacheAlreadyFilledCount < self.cacheArraySize) {
            } else {
                VTDecompressionSessionWaitForAsynchronousFrames(self.decompressionSession);
                [self makeParallelArrayReadyAfterCacheFilled];
                self.cacheAlreadyFilledCount = self.cacheArraySize;
                ////把剩余的frames全部刷出来
                ////此时不再copySampleBuffer出来
                ////等待comp 线程处理
                ////为了防止自己释放的锁马上又被自己得到
                self.cacheAlreadyHandledCount = 0;
                
                NSLog(@"---dli----not done but cache full---self.bufferFilledSema");
                NSLog(@"---dli----not done but cache full---self.bufferFilledSema");
                
                dispatch_semaphore_signal(self.bufferFilledSema);
            }
        }
        
    }
    
    @autoreleasepool {
        VTDecompressionSessionWaitForAsynchronousFrames(self.decompressionSession);
        VTDecompressionSessionInvalidate(self.decompressionSession);
        if (self.decompressionSession) {
            /* Block until our callback has been called with the last frame. */
            CFRelease(self.decompressionSession);
            self.decompressionSession = NULL;
        }
    }
    self.decompressionFinished =YES;
    
}
//// compress process each samplebuffer callback
void eachSampleBufferCallbackOfCompProcess(void *outputCallbackRefCon,void *sourceFrameRefCon,OSStatus status,VTEncodeInfoFlags infoFlags,CMSampleBufferRef sampleBuffer)
{
    @autoreleasepool {
        if (status != 0) {
            return;
        }
        if (sourceFrameRefCon)
        {
            CVPixelBufferRef pixelbuffer = sourceFrameRefCon;
            CVPixelBufferRelease(pixelbuffer);
        }
        if (!CMSampleBufferDataIsReady(sampleBuffer))
        {
            ////NSLog(@"VTCompressEachFrameCallback data is not ready ");
            return;
        }
        VTRecomp * encoder = (__bridge VTRecomp*)outputCallbackRefCon;
        while (!encoder.writerInput.readyForMoreMediaData) {
            ////NSLog(@"start wait");
            [NSThread sleepForTimeInterval:0.001f];
            ////NSLog(@"did wait");
        }
        CFRetain(sampleBuffer);
        {
            CMItemCount count;
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
            if (encoder.compressionMultiPassEnabled) {
                ////OSStatus siloStatus =
                VTFrameSiloAddSampleBuffer(encoder.siloOut, sout);
            } else {
                [encoder.writerInput appendSampleBuffer:sout];
            }
            CFRelease(sampleBuffer);
            CFRelease(sout);
            if (encoder.compressionMultiPassEnabled) {
                ////multipass must delete via next Start Seq And next End Seq
                for (int d =0; d<encoder.nextIgnoreStartSeqs.count; d++) {
                    int si = [encoder.nextIgnoreStartSeqs[d] intValue];
                    int ei = [encoder.nextIgnoreEndSeqs[d] intValue];
                    for (int i = si; i<=ei; i++) {
                        if (encoder.deleteSourceOneByOneAfterAppendMultiPass) {
                            if (encoder.extractedCVImageRefs != NULL) {
                                CVImageBufferRef imgBuffer = (CVImageBufferRef)CFArrayGetValueAtIndex(encoder.extractedCVImageRefs, i);
                                CFRelease(imgBuffer);
                                CFArraySetValueAtIndex(encoder.extractedCVImageRefs, i, NULL);
                            }  else {
                            }
                        } else {
                           ////
                        }
                    }
                }
            } else {
                if (encoder.deleteSourceOneByOneAfterAppendSinglePass) {
                    if (encoder.extractedCVImageRefs != NULL) {
                        CVImageBufferRef imgBuffer = (CVImageBufferRef)CFArrayGetValueAtIndex(encoder.extractedCVImageRefs, encoder.compressionSourceSeq);
                        CFRelease(imgBuffer);
                        CFArraySetValueAtIndex(encoder.extractedCVImageRefs, encoder.compressionSourceSeq, NULL);
                        if (encoder.compressionSourceSeq == encoder.compressionSourcesCount - 1) {
                            CFRelease(encoder.extractedCVImageRefs);
                        }
                    } else {
                    }
                } else {
                }
            }
        }
        if (encoder.compressionMultiPassEnabled) {
        } else {
            encoder.compressionSourceSeq = encoder.compressionSourceSeq +1;
        }
        
    }
}
////
-(void) makeVTCompressionSession
{
    @autoreleasepool {
        CFNumberRef ct=NULL;
        if (self.compressionEncoderSpecificationConstructFromKeyValue == YES) {
            int seq  = printVTEncoderList(NULL) + 1;
            self.CodecType = self.compressionCodecType;//kCMVideoCodecType_H264
            self.CodecName = kCMVideoCodecTypeToString(self.compressionCodecType);//"avc1"
            self.DisplayName = self.CodecName;//"avc1"
            self.encoderID = [NSString stringWithFormat:@"anon-%d",seq];//"anon-1"
            self.EncoderName = [NSString stringWithFormat:@"Manually Registered %@ Video Encoder",self.CodecName];//"Dynamically Registered avc1 Video Encoder"
            self.compressionEncoderSpecification = NULL;
            self.compressionEncoderSpecification = CFDictionaryCreateMutable(kCFAllocatorDefault,5,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
            /*
             //kVTVideoEncoderSpecification_EncoderID same as kVTVideoEncoderList_EncoderID
             NSLog(@"kVTVideoEncoderSpecification_EncoderID:%@",kVTVideoEncoderSpecification_EncoderID);
             NSLog(@"kVTVideoEncoderList_CodecType:%@",kVTVideoEncoderList_CodecType); // CFNumber for four-char-code (eg, 'avc1')
             NSLog(@"kVTVideoEncoderList_EncoderID:%@",kVTVideoEncoderList_EncoderID);  // CFString, reverse-DNS-style unique identifier for this encoder; may be passed as kVTVideoEncoderSpecification_EncoderID
             NSLog(@"kVTVideoEncoderList_CodecName:%@",kVTVideoEncoderList_CodecName);  // CFString, for display to user (eg, "H.264")
             NSLog(@"kVTVideoEncoderList_EncoderName:%@",kVTVideoEncoderList_EncoderName);  // CFString, for display to user (eg, "Apple H.264")
             NSLog(@"kVTVideoEncoderList_DisplayName:%@",kVTVideoEncoderList_DisplayName);  // CFString (same as CodecName if there is only one encoder for that format, otherwise same as EncoderName)
             */
            ct = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(_CodecType)));
            CFDictionaryAddValue(self.compressionEncoderSpecification, kVTVideoEncoderSpecification_EncoderID, (__bridge CFStringRef)self.encoderID);//"anon-1"
            CFDictionaryAddValue(self.compressionEncoderSpecification, kVTVideoEncoderList_CodecType, ct);
            CFDictionaryAddValue(self.compressionEncoderSpecification, kVTVideoEncoderList_CodecName, (__bridge CFStringRef)self.CodecName);
            CFDictionaryAddValue(self.compressionEncoderSpecification, kVTVideoEncoderList_DisplayName, (__bridge CFStringRef)self.DisplayName);
            CFDictionaryAddValue(self.compressionEncoderSpecification, kVTVideoEncoderList_EncoderName, (__bridge CFStringRef)self.EncoderName);
            ////NSLog(@"self.compressionEncoderSpecification:%@",self.compressionEncoderSpecification);
            ////printVTEncoderList(NULL);
        } else {
            if (self.compressionEncoderSpecification == NULL) {
                ////
            } else {
                ////
            }
        }
        CFDictionaryRef CFEmptyDict = NULL;
        CFNumberRef compressionCVPixelFormatType = NULL;
        CFNumberRef CFWidth = NULL;
        CFNumberRef CFHeight = NULL;
        CFNumberRef CFBOOLYES = NULL;
        if (self.compressionSourceImageBufferAttributesConstructFromKeyValue == YES) {
            self.compressionSourceImageBufferAttributes = NULL;
            SInt32 compressionCVPixelFormatTypeValue = self.compressionCVPixelFormatTypeValue;
            SInt8  CFBOOLYESValue = 0xFF;
            float CVPwidth = self.width;
            float CVPheight = self.height;
            CFEmptyDict = CFDictionaryCreate(kCFAllocatorDefault, nil, nil, 0, nil, nil);
            compressionCVPixelFormatType = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(compressionCVPixelFormatTypeValue)));
            CFWidth = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(CVPwidth)));
            CFHeight = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(CVPheight)));
            CFBOOLYES = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, (const void*)(&(CFBOOLYESValue)));
            const void *pixelBufferOptionsDictKeys[] = {
                kCVPixelBufferPixelFormatTypeKey,
                kCVPixelBufferWidthKey,
                kCVPixelBufferHeightKey,
                kCVPixelBufferOpenGLESCompatibilityKey,
                kCVPixelBufferIOSurfacePropertiesKey
            };
            const void *pixelBufferOptionsDictValues[] = {
                compressionCVPixelFormatType,
                CFWidth,
                CFHeight,
                CFBOOLYES,
                CFEmptyDict
            };
            self.compressionSourceImageBufferAttributes = CFDictionaryCreate(kCFAllocatorDefault, pixelBufferOptionsDictKeys, pixelBufferOptionsDictValues, 5, nil, nil);
        } else {
            if (self.compressionSourceImageBufferAttributes == NULL) {
                ////
            } else {
                ////
            }
        }
        self.compressionEachSampleBufferCallback = eachSampleBufferCallbackOfCompProcess;
        ////NSLog(@"self.compressionEncoderSpecification:%@",self.compressionEncoderSpecification);
        ////printVTEncoderList(NULL);
        OSStatus status = VTCompressionSessionCreate(NULL,
                                                     self.width,
                                                     self.height,
                                                     self.compressionCodecType,
                                                     self.compressionEncoderSpecification,
                                                     self.compressionSourceImageBufferAttributes,
                                                     NULL,
                                                     self.compressionEachSampleBufferCallback,
                                                     (__bridge void *)(self),
                                                     &_compressionSession);
        if (status != 0)
        {
            printVTError(status);
            return ;
        } else {
            ////NSLog(@"VTCompressionSessionCreated");
        }
        if (self.compressionEncoderSpecificationConstructFromKeyValue == YES) {
            CFRelease(ct);
            ct = NULL;
        }
        if (self.compressionEncoderSpecification == NULL) {
            
        } else {
            CFRelease(self.compressionEncoderSpecification);
        }
        if (self.compressionSourceImageBufferAttributesConstructFromKeyValue == YES) {
            CFRelease(CFEmptyDict);
            CFRelease(compressionCVPixelFormatType);
            CFRelease(CFWidth);
            CFRelease(CFHeight);
            CFRelease(CFBOOLYES);
            CFRelease(self.compressionSourceImageBufferAttributes);
        } else {
            if (self.compressionSourceImageBufferAttributes == NULL) {
                
            } else {
                CFRelease(self.compressionSourceImageBufferAttributes);
            }
        }
    }
}
////
-(void) makeVTSessionPropertiesReadyAndStart
{
    @autoreleasepool {
        if (self.compressionSessionPropertiesConstructFromKeyValue == YES) {
            if (self.compressionCodecType == kCMVideoCodecType_H264) {
                if (self.compressionAllowFrameReordering!=NO) {
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanTrue);
                } else {
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
                }
                if (self.compressionAllowTemporalCompression!=NO) {
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AllowTemporalCompression, kCFBooleanTrue);
                } else {
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AllowTemporalCompression, kCFBooleanFalse);
                }
            }
            if (self.compressionCleanApertureConstructFromKeyValue != NO){
                VTSessionSetCleanApertureFromValues(self.compressionSession,self.cleanApertureWidth,self.cleanApertureHeight,self.cleanApertureHorizontalOffset,self.cleanApertureVerticalOffset);
            } else {
                if (self.compressionCleanAperture != NULL) {
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_CleanAperture, self.compressionCleanAperture);
                    CFRelease(self.compressionCleanAperture);
                } else {
                    
                }
                
            }
            
            NSLog(@"---yika-----");
            VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(self.compressionAverageBitRate));
            
            if (self.compressionColorPrimaries != NULL) {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_ColorPrimaries,self.compressionColorPrimaries);
            } else {
                
            }
            if (self.compressionFieldCount == 1) {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_FieldCount, (__bridge CFTypeRef)@(1));
            } else if (self.compressionFieldCount == 2) {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_FieldCount, (__bridge CFTypeRef)@(2));
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_FieldDetail, self.compressionFieldDetail);
            } else {
                
            }
            if (self.compressionCodecType == kCMVideoCodecType_H264) {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_H264EntropyMode, self.compressionH264EntropyMode);
            }
            if(self.compressionMaxFrameDelayCount ==kVTUnlimitedFrameDelayCount) {
                
            } else {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_MaxFrameDelayCount, (__bridge CFTypeRef)@(self.compressionMaxFrameDelayCount));
            }
            if(self.compressionMaxKeyFrameInterval ==0) {
                
            } else {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)@(self.compressionMaxKeyFrameInterval));
            }
            if(self.compressionMaxKeyFrameIntervalDuration ==0) {
                
            } else {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, (__bridge CFTypeRef)@(self.compressionMaxKeyFrameIntervalDuration));
            }
            if (self.compressionPixelAspectRatioConstructFromKeyValue == NO) {
                if (self.compressionPixelAspectRatio != NULL) {
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_PixelAspectRatio, self.compressionPixelAspectRatio);
                } else {
                    CFNumberRef CFHorizontalSpacing = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(_pixelAspectRatioHorizontalSpacing)));
                    CFNumberRef CFVerticalSpacing = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(_pixelAspectRatioVerticalSpacing)));
                    CFDictionaryRef compressionPixelAspectRatio = NULL;
                    
                    const void *pixelAspectRatioDictKeys[] = {
                        kCMFormatDescriptionKey_PixelAspectRatioHorizontalSpacing,
                        kCMFormatDescriptionKey_PixelAspectRatioVerticalSpacing
                    };
                    const void *pixelAspectRatioDictValues[] = {
                        CFHorizontalSpacing,
                        CFVerticalSpacing
                    };
                    compressionPixelAspectRatio = CFDictionaryCreate(kCFAllocatorDefault, pixelAspectRatioDictKeys, pixelAspectRatioDictValues, 2, nil, nil);
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_PixelAspectRatio, compressionPixelAspectRatio);
                    CFRelease(CFHorizontalSpacing);
                    CFRelease(CFVerticalSpacing);
                    CFRelease(compressionPixelAspectRatio);
                    
                }
            } else {
                
            }
            if (self.compressionCodecType == kCMVideoCodecType_H264) {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_ProfileLevel, self.compressionProfilelevel);
            }
            if (self.compressionRealTime == NO) {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanFalse);
            } else {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
            }
            if (self.compressionTransferFunction == NULL) {
                
            } else {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_TransferFunction, self.compressionTransferFunction);
            }
            if (self.compressionYCbCrMatrix == NULL) {
                
            } else {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_YCbCrMatrix, self.compressionYCbCrMatrix);
            }
        } else {
            if (self.compressionSessionProperties != NULL) {
                VTSessionSetProperties(self.compressionSession, self.compressionSessionProperties);
                CFRelease(self.compressionSessionProperties);
            } else {
                if (self.compressionCodecType == kCMVideoCodecType_H264) {
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_H264EntropyMode,kVTH264EntropyMode_CABAC);
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_AutoLevel);
                    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(1280000));
                }
                
            }
        }
        if (self.compressionMultiPassEnabled) {
            self.multiPassStorageOut = NULL;
            if (self.multiPassStorageCreationOption_DoNotDelete) {
                CFMutableDictionaryRef MPOptions =  CFDictionaryCreateMutable(kCFAllocatorDefault,1,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
                CFDictionaryAddValue(MPOptions, kVTMultiPassStorageCreationOption_DoNotDelete, kCFBooleanTrue);
                OSStatus status = VTMultiPassStorageCreate(NULL, NULL, self.multiPassStorageCMTimeRange, MPOptions, &_multiPassStorageOut);
                if (status == 0) {
                    
                } else {
                    ////NSLog(@"VTMultiPassStorageCreate fail:%d",status);
                }
                CFRelease(MPOptions);
            } else {
                OSStatus status = VTMultiPassStorageCreate(NULL, NULL, self.multiPassStorageCMTimeRange, NULL, &_multiPassStorageOut);
                if (status == 0) {
                    
                } else {
                    ////NSLog(@"VTMultiPassStorageCreate fail:%d",status);
                }
                
            }
            OSStatus status = VTSessionSetProperty(self.compressionSession,kVTCompressionPropertyKey_MultiPassStorage,self.multiPassStorageOut);
            if (status == 0) {
                
            } else {
                ////NSLog(@"kVTCompressionPropertyKey_MultiPassStorage fail:%d",status);
            }
            self.siloOut = NULL;
            status = VTFrameSiloCreate(NULL, NULL, self.multiPassStorageCMTimeRange, NULL, &_siloOut);
            if (status == 0) {
                
            } else {
                ////NSLog(@"VTFrameSiloCreate fail:%d",status);
            }
            
        }
        ////NSLog(@"self.compressionSession:%@",self.compressionSession);
        ////OSStatus staus =
        VTCompressionSessionPrepareToEncodeFrames(self.compressionSession);
        ////NSLog(@"VTCompressionSessionPrepareToEncodeFrames:%d:self.compressionSession:%@",staus,self.compressionSession);
        
    }
  
}
////
-(void) makeVTencodeEachFrameSinglePass
{
    ////dispatch_time_t semaWaitDelay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC*100);
    while (!self.doneDoneDone) {
        ////NSLog(@"新一轮compress处理:");
        if (self.cacheAlreadyFilledCount < self.cacheArraySize) {
            ////NSLog(@"    解压过程尚未填充满buff,等待decompress");
            if(dispatch_semaphore_wait(self.bufferFilledSema,DISPATCH_TIME_NOW)){
                ////non-zero if the timeout occurred
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                ////NSLog(@"        semaWaitDelay时间内未收到解压完成填充buffer的信号bufferFilledSema, 继续等待decompress");
                continue;
            } else {
                ////NSLog(@"        semaWaitDelay时间内收到解压完成填充buffer的信号bufferFilledSema,开始处理buffer");
            }
        }
        
         ////NSLog(@"compress处理buffer前self.cacheAlreadyFilledCount:%d",self.cacheAlreadyFilledCount);
         ////NSLog(@"compress处理buffer前self.cacheAlreadyHandledCount:%d",self.cacheAlreadyHandledCount);
         ////NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
        
        if (self.cacheAlreadyHandledCount == 0) {
            //////NSLog(@"    compress处理buffer前要确保self.cacheAlreadyHandledCount为0，这个动作是decompress过程收尾时完成的，已经为0");
        } else {
            //////NSLog(@"    compress处理buffer前要确保self.cacheAlreadyHandledCount为0，这个动作是decompress过程收尾时完成的，尚未为0");
            continue;
        }

        if (self.extractedCVImageRefs != NULL) {
            //////NSLog(@"    compress开始处理缓存");
            self.compressionSourcesCount = (int)CFArrayGetCount(self.extractedCVImageRefs);
            ////NSLog(@"self.compressionSourcesCount:%d",self.compressionSourcesCount);
            
            ////NSLog(@"whywhywhy  :%d",self.cacheAlreadyHandledCount);
            
            ////NSLog(@"最后一轮处理");
            ////NSLog(@"self.doneDoneDone:%d",self.doneDoneDone);
            ////NSLog(@"self.extractedCVImageRefs count:%ld",CFArrayGetCount(self.extractedCVImageRefs));
            ////NSLog(@"self.presentationTimeStamps:%@",self.presentationTimeStamps);
            ////NSLog(@"self.durations:%@",self.durations);
            ////NSLog(@"self.cacheAlreadyHandledCount:%d",self.cacheAlreadyHandledCount);
            ////NSLog(@"self.cacheAlreadyFilledCount:%d",self.cacheAlreadyFilledCount);
            
            
            
            
            for (int i = 0; i < self.compressionSourcesCount; i++) {
                @autoreleasepool {
                    CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                    CMTime newDuration = [self.durations[i] CMTimeValue];
                    CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.extractedCVImageRefs, i);
                    ////creat  or copy   need CFRelease
                    VTEncodeInfoFlags flags;
                    OSStatus statusCode;
                    if (self.keepKeyFrameSigns) {
                        statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                     imgBUffer,
                                                                     presentationTimeStamp,
                                                                     newDuration,
                                                                     NULL, NULL, &flags);
                    } else {
                        int sign = (int)[self.keyFrameSigns[i] integerValue];
                        if (sign == 1) {
                            CFDictionaryRef frameProperties= NULL;
                            const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                            const void *values[1] = { kCFBooleanTrue };
                            frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                         imgBUffer,
                                                                         presentationTimeStamp,
                                                                         newDuration,
                                                                         frameProperties, NULL, &flags);
                            CFRelease(frameProperties);
                        } else {
                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                         imgBUffer,
                                                                         presentationTimeStamp,
                                                                         newDuration,
                                                                         NULL, NULL, &flags);
                        }
                        
                    }
                    if (statusCode != noErr) {
                        NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                        VTCompressionSessionInvalidate(self.compressionSession);
                        CFRelease(self.compressionSession);
                        self.compressionSession = NULL;
                        return;
                    }
                }
                self.cacheAlreadyHandledCount = self.cacheArraySize;                
            }
            
            ////NSLog(@"whywhywhy  :%d",self.cacheAlreadyHandledCount);
            
            
            self.endSessionAtSourceTime = CMTimeAdd([self.presentationTimeStamps[self.presentationTimeStamps.count -1] CMTimeValue],[self.durations[self.durations.count - 1] CMTimeValue]);
            
            
        }
        
        /*
        while (self.cacheAlreadyHandledCount < self.cacheArraySize) {
            NSLog(@"    self.cacheAlreadyHandledCount:%d ,compress等待处理缓存完毕 in while",self.cacheAlreadyHandledCount);
            if (!self.doneDoneDone) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
            }
            
        }
        */
        
        //////NSLog(@"    self.cacheAlreadyHandledCount:%d,self.cacheAlreadyFilledCount:%d",self.cacheAlreadyHandledCount,self.cacheAlreadyFilledCount);
        NSLog(@"    compress即将self.cacheAlreadyHandledCount = self.cacheArraySize,清空缓存,self.cacheAlreadyFilledCount = 0,发送信号self.bufferHandledSema,释放锁");
        CFRelease(self.extractedCVImageRefs);
        self.extractedCVImageRefs = NULL;
        self.presentationTimeStamps = NULL;
        self.decodeTimeStamps = NULL;
        self.durations = NULL;
        self.keyFrameSigns = NULL;
        self.cacheAlreadyFilledCount = 0;
        //////NSLog(@"    self.cacheAlreadyHandledCount:%d,self.cacheAlreadyFilledCount:%d",self.cacheAlreadyHandledCount,self.cacheAlreadyFilledCount);
        dispatch_semaphore_signal(self.bufferHandledSema);
        NSLog(@"    compress已经self.cacheAlreadyHandledCount = self.cacheArraySize,清空缓存,self.cacheAlreadyFilledCount = 0,发送信号self.bufferHandledSema,释放锁");
        
        
    }
    
    
    
    
    
    
    
    @autoreleasepool {
        
        while (!self.doneDoneDone) {
            if(dispatch_semaphore_wait(self.bufferFilledSema,DISPATCH_TIME_NOW)){
                ////non-zero if the timeout occurred
                //////NSLog(@"        semaWaitDelay时间内未收到解压完成填充buffer的信号bufferFilledSema, 继续等待decompress");
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                continue;
            } else {
                //////NSLog(@"        semaWaitDelay时间内收到解压完成填充buffer的信号bufferFilledSema,开始处理buffer");
            }
        }

        if (self.extractedCVImageRefs != NULL) {
            ////NSLog(@"最后一轮处理");
            ////NSLog(@"self.doneDoneDone:%d",self.doneDoneDone);
            ////NSLog(@"self.extractedCVImageRefs count:%ld",CFArrayGetCount(self.extractedCVImageRefs));
            ////NSLog(@"self.presentationTimeStamps:%@",self.presentationTimeStamps);
            ///NSLog(@"self.durations:%@",self.durations);
            ////NSLog(@"self.cacheAlreadyHandledCount:%d",self.cacheAlreadyHandledCount);
            ////NSLog(@"self.cacheAlreadyFilledCount:%d",self.cacheAlreadyFilledCount);
        }
        

        
        if (self.extractedCVImageRefs != NULL) {
            self.compressionSourcesCount = (int)CFArrayGetCount(self.extractedCVImageRefs);
            for (int i = 0; i < self.compressionSourcesCount; i++) {
                @autoreleasepool {
                    CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                    CMTime newDuration = [self.durations[i] CMTimeValue];
                    CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.extractedCVImageRefs, i);
                    ////creat  or copy   need CFRelease
                    VTEncodeInfoFlags flags;
                    OSStatus statusCode;
                    if (self.keepKeyFrameSigns) {
                        statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                     imgBUffer,
                                                                     presentationTimeStamp,
                                                                     newDuration,
                                                                     NULL, NULL, &flags);
                    } else {
                        int sign = (int)[self.keyFrameSigns[i] integerValue];
                        if (sign == 1) {
                            CFDictionaryRef frameProperties= NULL;
                            const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                            const void *values[1] = { kCFBooleanTrue };
                            frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                         imgBUffer,
                                                                         presentationTimeStamp,
                                                                         newDuration,
                                                                         frameProperties, NULL, &flags);
                            CFRelease(frameProperties);
                        } else {
                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                         imgBUffer,
                                                                         presentationTimeStamp,
                                                                         newDuration,
                                                                         NULL, NULL, &flags);
                        }
                        
                    }
                    if (statusCode != noErr) {
                        ////NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                        VTCompressionSessionInvalidate(self.compressionSession);
                        CFRelease(self.compressionSession);
                        self.compressionSession = NULL;
                        return;
                    }
                }
                
            }
            
        }
   
        self.cacheAlreadyHandledCount = self.cacheArraySize;
        self.cacheAlreadyFilledCount = 0;
        dispatch_semaphore_signal(self.bufferHandledSema);
        
        
        if (self.extractedCVImageRefs != NULL) {
            
            self.cacheAlreadyHandledCount = (int)CFArrayGetCount(self.extractedCVImageRefs);
            self.endSessionAtSourceTime = CMTimeAdd([self.presentationTimeStamps[self.presentationTimeStamps.count -1] CMTimeValue],[self.durations[self.durations.count - 1] CMTimeValue]);
            CFRelease(self.extractedCVImageRefs);
            self.extractedCVImageRefs = NULL;
            self.presentationTimeStamps = NULL;
            self.decodeTimeStamps = NULL;
            self.durations = NULL;
            self.keyFrameSigns = NULL;
            self.cacheAlreadyFilledCount = 0;
        }

    }

    @autoreleasepool {
        VTCompressionSessionCompleteFrames(self.compressionSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(self.compressionSession);
        CFRelease(self.compressionSession);
        self.compressionSession = NULL;
        checkAVAssetWriterStatus(self.writer);
        [self.writerInput markAsFinished];
        ////this is necessary to make sure the finishWritingWithCompletionHandler be excuted
        NSLog(@"sheck self.endSessionAtSourceTime");
        CMTimeShow(self.endSessionAtSourceTime);
        NSLog(@"sheck self.endSessionAtSourceTime");
        
        [self.writer endSessionAtSourceTime:self.endSessionAtSourceTime];
        checkAVAssetWriterStatus(self.writer);
        if ((!self.deleteSourceOneByOneAfterAppendSinglePass) && (!self.deleteSourceOneByOneAfterAppendMultiPass)) {
            if (self.extractedCVImageRefs != NULL) {
                CFRelease(self.extractedCVImageRefs);
                self.extractedCVImageRefs = NULL;
            }
        }
    }
  
}
////
-(void) makeVTencodeEachFrameMultiPass
{
    CMTime cursor = kCMTimeZero;
    ////dispatch_time_t semaWaitDelay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC);
    
    while (!self.doneDoneDone) {
        if (self.cacheAlreadyFilledCount < self.cacheArraySize) {
            if( dispatch_semaphore_wait(self.bufferFilledSema,DISPATCH_TIME_NOW)){
                ////non-zero if the timeout occurred
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                continue;
            } else {
                ////zero 继续执行
            }
        }
        if (self.cacheAlreadyHandledCount == 0) {

        } else {
            continue;
        }
        self.currPassRound = 1;
        ////---first round
        {
            VTCompressionSessionBeginPass(self.compressionSession, 0, NULL);
            if (self.extractedCVImageRefs != NULL) {
                self.compressionSourcesCount = (int)CFArrayGetCount(self.extractedCVImageRefs);
                for (int i = 0; i < self.compressionSourcesCount; i++) {
                    @autoreleasepool {
                        CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                        CMTime newDuration = [self.durations[i] CMTimeValue];
                        CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.extractedCVImageRefs, i);
                        ////creat  or copy   need CFRelease
                        VTEncodeInfoFlags flags;
                        OSStatus statusCode;
                        if (self.keepKeyFrameSigns) {
                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                         imgBUffer,
                                                                         presentationTimeStamp,
                                                                         newDuration,
                                                                         NULL, NULL, &flags);
                        } else {
                            int sign = (int)[self.keyFrameSigns[i] integerValue];
                            if (sign == 1) {
                                CFDictionaryRef frameProperties= NULL;
                                const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                const void *values[1] = { kCFBooleanTrue };
                                frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                             imgBUffer,
                                                                             presentationTimeStamp,
                                                                             newDuration,
                                                                             frameProperties, NULL, &flags);
                                CFRelease(frameProperties);
                            } else {
                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                             imgBUffer,
                                                                             presentationTimeStamp,
                                                                             newDuration,
                                                                             NULL, NULL, &flags);
                            }
                        }
                        if (statusCode != noErr) {
                            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                            VTCompressionSessionInvalidate(self.compressionSession);
                            CFRelease(self.compressionSession);
                            self.compressionSession = NULL;
                            return;
                        }
                        cursor = CMTimeAdd(cursor, presentationTimeStamp);
                    }
                }
                CMTime lastNewDuration = [self.durations[self.compressionSourcesCount-1] CMTimeValue];
                cursor =CMTimeAdd(cursor, lastNewDuration);
            }
            
            @autoreleasepool {
                Boolean furtherPassesRequestedOut;
                OSStatus status = VTCompressionSessionEndPass(self.compressionSession, &furtherPassesRequestedOut, NULL);
                if (furtherPassesRequestedOut) {
                    self.furtherPass =YES;
                    NSLog(@"further Pass");
                    ////ready for further pass
                    NSLog(@"-----get ready for folowwing rounds");
                    CMItemCount timeRangeCountOut;
                    const CMTimeRange *  timeRangeArrayOut;
                    status = VTCompressionSessionGetTimeRangesForNextPass(self.compressionSession, &timeRangeCountOut, &timeRangeArrayOut);
                    NSLog(@"timeRangeCountOut:%ld",timeRangeCountOut);
                    self.nextPassStartSeqs = [[NSMutableArray alloc] init];
                    self.nextPassEndSeqs = [[NSMutableArray alloc] init];
                    self.nextPassStartSeqs = [[NSMutableArray alloc] init];
                    self.nextPassEndSeqs = [[NSMutableArray alloc] init];
                    NSLog(@"---release in round 1");
                    for (int j = 0; j< timeRangeCountOut; j++) {
                        CMTimeRangeShow(timeRangeArrayOut[j]);
                        CMTime nextStart = timeRangeArrayOut[j].start;
                        CMTime nextEnd = CMTimeRangeGetEnd(timeRangeArrayOut[j]);
                        CMTimeShow(nextStart);
                        CMTimeShow(nextEnd);
                        int nsq = selectNearestFromCMTimeArray(nextStart,self.presentationTimeStamps, self.durations);
                        int neq = selectNearestFromCMTimeArray(nextEnd,self.presentationTimeStamps, self.durations);
                        NSLog(@"nextStart Seq %d",nsq);
                        NSLog(@"nextEnd Seq %d",neq);
                        [self. nextPassStartSeqs addObject:[NSNumber numberWithInt:nsq]];
                        [self. nextPassEndSeqs addObject:[NSNumber numberWithInt:neq]];
                        ////CFRelease(timeRangeArrayOut);dont do this here , bad access
                    }
                    NSLog(@"---release in round 1");
                    ////----排序
                    [self. nextPassStartSeqs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                        NSNumber * o1 = (NSNumber *) obj1;
                        NSNumber * o2 = (NSNumber *) obj2;
                        
                        int  pt1 = [o1 intValue] ;
                        int  pt2 = [o2 intValue] ;
                        
                        if (pt1 <= pt2) {
                            return(NSOrderedAscending);
                        } else {
                            return(NSOrderedDescending);
                        }
                    }];
                    [self. nextPassEndSeqs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                        NSNumber * o1 = (NSNumber *) obj1;
                        NSNumber * o2 = (NSNumber *) obj2;
                        
                        int  pt1 = [o1 intValue] ;
                        int  pt2 = [o2 intValue] ;
                        
                        if (pt1 <= pt2) {
                            return(NSOrderedAscending);
                        } else {
                            return(NSOrderedDescending);
                        }
                    }];
                    ////----排序
                    [self.nextIgnoreStartSeqs addObject:[NSNumber numberWithInt:0]];
                    for (int j = 0; j< timeRangeCountOut; j++) {
                        int nsq = [self.nextPassStartSeqs[j] intValue];
                        int neq = [self.nextPassEndSeqs[j] intValue];
                        
                        [self.nextIgnoreStartSeqs addObject:[NSNumber numberWithInt:(neq+1)]];
                        [self.nextIgnoreEndSeqs addObject:[NSNumber numberWithInt:(nsq -1)]];
                    }
                    [self.nextIgnoreEndSeqs addObject:[NSNumber numberWithInt:(self.compressionSourcesCount -1)]];
                    self.currPassRound  = self.currPassRound +1;
                    ////ready for further pass
                    NSLog(@"-----get ready for folowwing rounds");
                } else {
                    self.furtherPass = NO;
                    NSLog(@"no further Pass");
                }
            }
        }
        ////----first Round
        ////----next rounds
        while (self.furtherPass) {
            NSLog(@"-----rounds---------%d",self.currPassRound);
            if (self.currPassRound > self.howManyPasses) {
                if (self.howManyPasses == 0 ) {
                    
                } else {
                    break;
                }
                
            } else {
                if (self.currPassRound == self.howManyPasses) {
                    VTCompressionSessionBeginPass(self.compressionSession, kVTCompressionSessionBeginFinalPass, NULL);
                } else {
                    VTCompressionSessionBeginPass(self.compressionSession, 0, NULL);
                }
                
                int sectionsCount = (int)self.nextPassStartSeqs.count;
                
                for (int l = 0; l< sectionsCount; l++) {////---for
                    int si = (int)self.nextPassStartSeqs[l];
                    int ei = (int)self.nextPassEndSeqs[l];
                    if (self.extractedCVImageRefs != NULL) {
                        for (int i = si; i <= ei; i++) {
                            @autoreleasepool {
                                CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                                CMTime newDuration = [self.durations[i] CMTimeValue];
                                CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.extractedCVImageRefs, i);
                                ////creat  or copy   need CFRelease
                                VTEncodeInfoFlags flags;
                                OSStatus statusCode;
                                if (self.keepKeyFrameSigns) {
                                    statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                 imgBUffer,
                                                                                 presentationTimeStamp,
                                                                                 newDuration,
                                                                                 NULL, NULL, &flags);
                                } else {
                                    int sign = (int)[self.keyFrameSigns[i] integerValue];
                                    if (sign == 1) {
                                        CFDictionaryRef frameProperties= NULL;
                                        const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                        const void *values[1] = { kCFBooleanTrue };
                                        frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                        statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                     imgBUffer,
                                                                                     presentationTimeStamp,
                                                                                     newDuration,
                                                                                     frameProperties, NULL, &flags);
                                        CFRelease(frameProperties);
                                    } else {
                                        statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                     imgBUffer,
                                                                                     presentationTimeStamp,
                                                                                     newDuration,
                                                                                     NULL, NULL, &flags);
                                    }
                                }
                                if (statusCode != noErr) {
                                    NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                    VTCompressionSessionInvalidate(self.compressionSession);
                                    CFRelease(self.compressionSession);
                                    self.compressionSession = NULL;
                                    return;
                                }
                                
                            }
                            
                            
                        }
                    }
                }
                
            }////-else
            
            @autoreleasepool {
                Boolean furtherPassesRequestedOut;
                OSStatus status = VTCompressionSessionEndPass(self.compressionSession, &furtherPassesRequestedOut, NULL);
                
                if (furtherPassesRequestedOut) {
                    self.furtherPass =YES;
                    NSLog(@"further Pass");
                    NSLog(@"-----rounds---------%d",self.currPassRound);
                } else {
                    self.furtherPass = NO;
                    NSLog(@"no further Pass");
                    NSLog(@"-----rounds---------%d",self.currPassRound);
                    break;
                }
                
                NSLog(@"-----ready for next ---------%d",(self.currPassRound + 1));
                CMItemCount timeRangeCountOut;
                const CMTimeRange *  timeRangeArrayOut;
                status = VTCompressionSessionGetTimeRangesForNextPass(self.compressionSession, &timeRangeCountOut, &timeRangeArrayOut);
                
                NSLog(@"timeRangeCountOut:%ld",timeRangeCountOut);
                
                self.nextPassStartSeqs = [[NSMutableArray alloc] init];
                self.nextPassEndSeqs = [[NSMutableArray alloc] init];
                self.nextPassStartSeqs = [[NSMutableArray alloc] init];
                self.nextPassEndSeqs = [[NSMutableArray alloc] init];
                
                for (int j = 0; j< timeRangeCountOut; j++) {
                    CMTimeRangeShow(timeRangeArrayOut[j]);
                    CMTime nextStart = timeRangeArrayOut[j].start;
                    CMTime nextEnd = CMTimeRangeGetEnd(timeRangeArrayOut[j]);
                    CMTimeShow(nextStart);
                    CMTimeShow(nextEnd);
                    int nsq = selectNearestFromCMTimeArray(nextStart,self.presentationTimeStamps, self.durations);
                    int neq = selectNearestFromCMTimeArray(nextEnd,self.presentationTimeStamps, self.durations);
                    NSLog(@"nextStart Seq %d",nsq);
                    NSLog(@"nextEnd Seq %d",neq);
                    [self. nextPassStartSeqs addObject:[NSNumber numberWithInt:nsq]];
                    [self. nextPassEndSeqs addObject:[NSNumber numberWithInt:neq]];
                    CFRelease(timeRangeArrayOut);
                }
                
                ////----排序
                [self. nextPassStartSeqs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                    NSNumber * o1 = (NSNumber *) obj1;
                    NSNumber * o2 = (NSNumber *) obj2;
                    
                    int  pt1 = [o1 intValue] ;
                    int  pt2 = [o2 intValue] ;
                    
                    if (pt1 <= pt2) {
                        return(NSOrderedAscending);
                    } else {
                        return(NSOrderedDescending);
                    }
                }];
                [self. nextPassEndSeqs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                    NSNumber * o1 = (NSNumber *) obj1;
                    NSNumber * o2 = (NSNumber *) obj2;
                    
                    int  pt1 = [o1 intValue] ;
                    int  pt2 = [o2 intValue] ;
                    
                    if (pt1 <= pt2) {
                        return(NSOrderedAscending);
                    } else {
                        return(NSOrderedDescending);
                    }
                }];
                ////----排序
                
                
                [self.nextIgnoreStartSeqs addObject:[NSNumber numberWithInt:0]];
                
                for (int j = 0; j< timeRangeCountOut; j++) {
                    int nsq = [self.nextPassStartSeqs[j] intValue];
                    int neq = [self.nextPassEndSeqs[j] intValue];
                    
                    [self.nextIgnoreStartSeqs addObject:[NSNumber numberWithInt:(neq+1)]];
                    [self.nextIgnoreEndSeqs addObject:[NSNumber numberWithInt:(nsq -1)]];
                }
                
                [self.nextIgnoreEndSeqs addObject:[NSNumber numberWithInt:(self.compressionSourcesCount -1)]];
                
                NSLog(@"-----ready for next ---------%d",(self.currPassRound + 1));
                self.currPassRound  = self.currPassRound +1;
                
                
            }
            
        }////--while
        ////----next rounds
        
        if(self.cacheAlreadyHandledCount < self.cacheArraySize) {
        } else {
            self.cacheAlreadyHandledCount = self.cacheArraySize;
            CFRelease(self.extractedCVImageRefs);
            self.extractedCVImageRefs = NULL;
            self.presentationTimeStamps = NULL;
            self.decodeTimeStamps = NULL;
            self.durations = NULL;
            self.keyFrameSigns = NULL;
            self.cacheAlreadyFilledCount = 0;
            dispatch_semaphore_signal(self.bufferHandledSema);
            
        }
    }
    @autoreleasepool {
        CMTime cursor = kCMTimeZero;
        self.currPassRound = 1;
        ////---first round
        {
            VTCompressionSessionBeginPass(self.compressionSession, 0, NULL);
            if (self.extractedCVImageRefs != NULL) {
                self.compressionSourcesCount = (int)CFArrayGetCount(self.extractedCVImageRefs);
                for (int i = 0; i < self.compressionSourcesCount; i++) {
                    @autoreleasepool {
                        CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                        CMTime newDuration = [self.durations[i] CMTimeValue];
                        CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.extractedCVImageRefs, i);
                        ////creat  or copy   need CFRelease
                        VTEncodeInfoFlags flags;
                        OSStatus statusCode;
                        if (self.keepKeyFrameSigns) {
                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                         imgBUffer,
                                                                         presentationTimeStamp,
                                                                         newDuration,
                                                                         NULL, NULL, &flags);
                        } else {
                            int sign = (int)[self.keyFrameSigns[i] integerValue];
                            if (sign == 1) {
                                CFDictionaryRef frameProperties= NULL;
                                const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                const void *values[1] = { kCFBooleanTrue };
                                frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                             imgBUffer,
                                                                             presentationTimeStamp,
                                                                             newDuration,
                                                                             frameProperties, NULL, &flags);
                                CFRelease(frameProperties);
                            } else {
                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                             imgBUffer,
                                                                             presentationTimeStamp,
                                                                             newDuration,
                                                                             NULL, NULL, &flags);
                            }
                        }
                        if (statusCode != noErr) {
                            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                            VTCompressionSessionInvalidate(self.compressionSession);
                            CFRelease(self.compressionSession);
                            self.compressionSession = NULL;
                            return;
                        }
                        cursor = CMTimeAdd(cursor, presentationTimeStamp);
                    }
                }
                CMTime lastNewDuration = [self.durations[self.compressionSourcesCount-1] CMTimeValue];
                cursor =CMTimeAdd(cursor, lastNewDuration);
            }
            
            @autoreleasepool {
                Boolean furtherPassesRequestedOut;
                OSStatus status = VTCompressionSessionEndPass(self.compressionSession, &furtherPassesRequestedOut, NULL);
                if (furtherPassesRequestedOut) {
                    self.furtherPass =YES;
                    NSLog(@"further Pass");
                    ////ready for further pass
                    NSLog(@"-----get ready for folowwing rounds");
                    CMItemCount timeRangeCountOut;
                    const CMTimeRange *  timeRangeArrayOut;
                    status = VTCompressionSessionGetTimeRangesForNextPass(self.compressionSession, &timeRangeCountOut, &timeRangeArrayOut);
                    NSLog(@"timeRangeCountOut:%ld",timeRangeCountOut);
                    self.nextPassStartSeqs = [[NSMutableArray alloc] init];
                    self.nextPassEndSeqs = [[NSMutableArray alloc] init];
                    self.nextPassStartSeqs = [[NSMutableArray alloc] init];
                    self.nextPassEndSeqs = [[NSMutableArray alloc] init];
                    NSLog(@"---release in round 1");
                    for (int j = 0; j< timeRangeCountOut; j++) {
                        CMTimeRangeShow(timeRangeArrayOut[j]);
                        CMTime nextStart = timeRangeArrayOut[j].start;
                        CMTime nextEnd = CMTimeRangeGetEnd(timeRangeArrayOut[j]);
                        CMTimeShow(nextStart);
                        CMTimeShow(nextEnd);
                        int nsq = selectNearestFromCMTimeArray(nextStart,self.presentationTimeStamps, self.durations);
                        int neq = selectNearestFromCMTimeArray(nextEnd,self.presentationTimeStamps, self.durations);
                        NSLog(@"nextStart Seq %d",nsq);
                        NSLog(@"nextEnd Seq %d",neq);
                        [self. nextPassStartSeqs addObject:[NSNumber numberWithInt:nsq]];
                        [self. nextPassEndSeqs addObject:[NSNumber numberWithInt:neq]];
                        ////CFRelease(timeRangeArrayOut);dont do this here , bad access
                    }
                    NSLog(@"---release in round 1");
                    ////----排序
                    [self. nextPassStartSeqs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                        NSNumber * o1 = (NSNumber *) obj1;
                        NSNumber * o2 = (NSNumber *) obj2;
                        
                        int  pt1 = [o1 intValue] ;
                        int  pt2 = [o2 intValue] ;
                        
                        if (pt1 <= pt2) {
                            return(NSOrderedAscending);
                        } else {
                            return(NSOrderedDescending);
                        }
                    }];
                    [self. nextPassEndSeqs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                        NSNumber * o1 = (NSNumber *) obj1;
                        NSNumber * o2 = (NSNumber *) obj2;
                        
                        int  pt1 = [o1 intValue] ;
                        int  pt2 = [o2 intValue] ;
                        
                        if (pt1 <= pt2) {
                            return(NSOrderedAscending);
                        } else {
                            return(NSOrderedDescending);
                        }
                    }];
                    ////----排序
                    [self.nextIgnoreStartSeqs addObject:[NSNumber numberWithInt:0]];
                    for (int j = 0; j< timeRangeCountOut; j++) {
                        int nsq = [self.nextPassStartSeqs[j] intValue];
                        int neq = [self.nextPassEndSeqs[j] intValue];
                        
                        [self.nextIgnoreStartSeqs addObject:[NSNumber numberWithInt:(neq+1)]];
                        [self.nextIgnoreEndSeqs addObject:[NSNumber numberWithInt:(nsq -1)]];
                    }
                    [self.nextIgnoreEndSeqs addObject:[NSNumber numberWithInt:(self.compressionSourcesCount -1)]];
                    self.currPassRound  = self.currPassRound +1;
                    ////ready for further pass
                    NSLog(@"-----get ready for folowwing rounds");
                } else {
                    self.furtherPass = NO;
                    NSLog(@"no further Pass");
                }
            }
        }
        ////----first Round
        ////----next rounds
        while (self.furtherPass) {
            NSLog(@"-----rounds---------%d",self.currPassRound);
            if (self.currPassRound > self.howManyPasses) {
                if (self.howManyPasses == 0 ) {
                    
                } else {
                    break;
                }
                
            } else {
                if (self.currPassRound == self.howManyPasses) {
                    VTCompressionSessionBeginPass(self.compressionSession, kVTCompressionSessionBeginFinalPass, NULL);
                } else {
                    VTCompressionSessionBeginPass(self.compressionSession, 0, NULL);
                }
                
                int sectionsCount = (int)self.nextPassStartSeqs.count;
                
                for (int l = 0; l< sectionsCount; l++) {////---for
                    int si = (int)self.nextPassStartSeqs[l];
                    int ei = (int)self.nextPassEndSeqs[l];
                    if (self.extractedCVImageRefs != NULL) {
                        for (int i = si; i <= ei; i++) {
                            @autoreleasepool {
                                CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                                CMTime newDuration = [self.durations[i] CMTimeValue];
                                CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.extractedCVImageRefs, i);
                                ////creat  or copy   need CFRelease
                                VTEncodeInfoFlags flags;
                                OSStatus statusCode;
                                if (self.keepKeyFrameSigns) {
                                    statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                 imgBUffer,
                                                                                 presentationTimeStamp,
                                                                                 newDuration,
                                                                                 NULL, NULL, &flags);
                                } else {
                                    int sign = (int)[self.keyFrameSigns[i] integerValue];
                                    if (sign == 1) {
                                        CFDictionaryRef frameProperties= NULL;
                                        const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                        const void *values[1] = { kCFBooleanTrue };
                                        frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                        statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                     imgBUffer,
                                                                                     presentationTimeStamp,
                                                                                     newDuration,
                                                                                     frameProperties, NULL, &flags);
                                        CFRelease(frameProperties);
                                    } else {
                                        statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                     imgBUffer,
                                                                                     presentationTimeStamp,
                                                                                     newDuration,
                                                                                     NULL, NULL, &flags);
                                    }
                                }
                                if (statusCode != noErr) {
                                    NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                    VTCompressionSessionInvalidate(self.compressionSession);
                                    CFRelease(self.compressionSession);
                                    self.compressionSession = NULL;
                                    return;
                                }
                                
                            }
                            
                            
                        }
                    }
                }
                
            }////-else
            
            @autoreleasepool {
                Boolean furtherPassesRequestedOut;
                OSStatus status = VTCompressionSessionEndPass(self.compressionSession, &furtherPassesRequestedOut, NULL);
                
                if (furtherPassesRequestedOut) {
                    self.furtherPass =YES;
                    NSLog(@"further Pass");
                    NSLog(@"-----rounds---------%d",self.currPassRound);
                } else {
                    self.furtherPass = NO;
                    NSLog(@"no further Pass");
                    NSLog(@"-----rounds---------%d",self.currPassRound);
                    break;
                }
                
                NSLog(@"-----ready for next ---------%d",(self.currPassRound + 1));
                CMItemCount timeRangeCountOut;
                const CMTimeRange *  timeRangeArrayOut;
                status = VTCompressionSessionGetTimeRangesForNextPass(self.compressionSession, &timeRangeCountOut, &timeRangeArrayOut);
                
                NSLog(@"timeRangeCountOut:%ld",timeRangeCountOut);
                
                self.nextPassStartSeqs = [[NSMutableArray alloc] init];
                self.nextPassEndSeqs = [[NSMutableArray alloc] init];
                self.nextPassStartSeqs = [[NSMutableArray alloc] init];
                self.nextPassEndSeqs = [[NSMutableArray alloc] init];
                
                for (int j = 0; j< timeRangeCountOut; j++) {
                    CMTimeRangeShow(timeRangeArrayOut[j]);
                    CMTime nextStart = timeRangeArrayOut[j].start;
                    CMTime nextEnd = CMTimeRangeGetEnd(timeRangeArrayOut[j]);
                    CMTimeShow(nextStart);
                    CMTimeShow(nextEnd);
                    int nsq = selectNearestFromCMTimeArray(nextStart,self.presentationTimeStamps, self.durations);
                    int neq = selectNearestFromCMTimeArray(nextEnd,self.presentationTimeStamps, self.durations);
                    NSLog(@"nextStart Seq %d",nsq);
                    NSLog(@"nextEnd Seq %d",neq);
                    [self. nextPassStartSeqs addObject:[NSNumber numberWithInt:nsq]];
                    [self. nextPassEndSeqs addObject:[NSNumber numberWithInt:neq]];
                    CFRelease(timeRangeArrayOut);
                }
                
                ////----排序
                [self. nextPassStartSeqs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                    NSNumber * o1 = (NSNumber *) obj1;
                    NSNumber * o2 = (NSNumber *) obj2;
                    
                    int  pt1 = [o1 intValue] ;
                    int  pt2 = [o2 intValue] ;
                    
                    if (pt1 <= pt2) {
                        return(NSOrderedAscending);
                    } else {
                        return(NSOrderedDescending);
                    }
                }];
                [self. nextPassEndSeqs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                    NSNumber * o1 = (NSNumber *) obj1;
                    NSNumber * o2 = (NSNumber *) obj2;
                    
                    int  pt1 = [o1 intValue] ;
                    int  pt2 = [o2 intValue] ;
                    
                    if (pt1 <= pt2) {
                        return(NSOrderedAscending);
                    } else {
                        return(NSOrderedDescending);
                    }
                }];
                ////----排序
                
                
                [self.nextIgnoreStartSeqs addObject:[NSNumber numberWithInt:0]];
                
                for (int j = 0; j< timeRangeCountOut; j++) {
                    int nsq = [self.nextPassStartSeqs[j] intValue];
                    int neq = [self.nextPassEndSeqs[j] intValue];
                    
                    [self.nextIgnoreStartSeqs addObject:[NSNumber numberWithInt:(neq+1)]];
                    [self.nextIgnoreEndSeqs addObject:[NSNumber numberWithInt:(nsq -1)]];
                }
                
                [self.nextIgnoreEndSeqs addObject:[NSNumber numberWithInt:(self.compressionSourcesCount -1)]];
                
                NSLog(@"-----ready for next ---------%d",(self.currPassRound + 1));
                self.currPassRound  = self.currPassRound +1;
                
                
            }
            
        }////--while
        ////----next rounds
        self.cacheAlreadyHandledCount = (int)CFArrayGetCount(self.extractedCVImageRefs);
        self.endSessionAtSourceTime = CMTimeAdd([self.presentationTimeStamps[self.presentationTimeStamps.count -1] CMTimeValue],[self.durations[self.durations.count - 1] CMTimeValue]);
        CFRelease(self.extractedCVImageRefs);
        self.extractedCVImageRefs = NULL;
        self.presentationTimeStamps = NULL;
        self.decodeTimeStamps = NULL;
        self.durations = NULL;
        self.keyFrameSigns = NULL;
        self.cacheAlreadyFilledCount = 0;
    }
    @autoreleasepool {
        OSStatus status = VTFrameSiloCallBlockForEachSampleBuffer(self.siloOut, self.multiPassStorageCMTimeRange, ^OSStatus(CMSampleBufferRef  _Nonnull sampleBuffer) {
            BOOL succ = [self.writerInput appendSampleBuffer:sampleBuffer];
            if (succ) {
                return(0);
            } else {
                return(1);
            }
        });
        NSLog(@"VTFrameSiloCallBlockForEachSampleBuffer status :%d",(int)status);
        ////
        VTMultiPassStorageClose(self.multiPassStorageOut);
        CFRelease(self.multiPassStorageOut);
        CFRelease(self.siloOut);
        ////
        if ((!self.deleteSourceOneByOneAfterAppendSinglePass) && (!self.deleteSourceOneByOneAfterAppendMultiPass)) {
            if (self.extractedCVImageRefs != NULL) {
                CFRelease(self.extractedCVImageRefs);
                self.extractedCVImageRefs = NULL;
            }
        }
        ////
        if (self.deleteSourceOneByOneAfterAppendMultiPass) {
            if (self.extractedCVImageRefs != NULL) {
                CFRelease(self.extractedCVImageRefs);
                self.extractedCVImageRefs = NULL;
            }
        }
        ////
        VTCompressionSessionCompleteFrames(self.compressionSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(self.compressionSession);
        CFRelease(self.compressionSession);
        self.compressionSession = NULL;
        checkAVAssetWriterStatus(self.writer);
        [self.writerInput markAsFinished];
        ////this is necessary to make sure the finishWritingWithCompletionHandler be excuted
        [self.writer endSessionAtSourceTime:self.endSessionAtSourceTime];
        checkAVAssetWriterStatus(self.writer);
    }
}
////
-(void) makeFinalOutputFile
{
    
    __block dispatch_semaphore_t semaCanReturn = dispatch_semaphore_create(0);    
    
    [self.writer finishWritingWithCompletionHandler:^{
        @autoreleasepool {
            self.writerInput =NULL;
            self.writer = NULL;
            checkAVAssetWriterStatus(self.writer);
            if (self.applyOOBPT) {
                NSString * tmpPath = self.writerOutputPath;
                tmpPath = [tmpPath stringByAppendingString:@".replace"];
                NSURL * replace = [NSURL fileURLWithPath:tmpPath];
                [FileUitl deleteTmpFile:tmpPath];
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                ptVideoFromSourceURLSema(self.writerOutputURL, 0, replace, sema, 0, self.preferedTransform);
                [FileUitl deleteTmpFile:self.writerOutputPath];
                [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:self.writerOutputPath error:nil];
                
            }
            if (self.writeToAlbum) {
                NSLog(@"begin Export!");
                [FileUitl writeVideoToPhotoLibrary:self.writerOutputURL];
                NSLog(@"Export complete!");
            }
            if (self.writeToAlbum && self.deleteOutputFileInSandboxAfterCopyToAlbum){
                [FileUitl deleteTmpFile:self.writerOutputPath];
            }
            NSTimeInterval tempTime = [[NSDate date] timeIntervalSince1970];
            long long int tempDate = (long long int)tempTime;
            self.recompressionEndTime = [NSDate dateWithTimeIntervalSince1970:tempDate];
            NSTimeInterval costedTime = [self.recompressionEndTime timeIntervalSinceDate:self.recompressionStartTime];
            NSLog(@"costed time :%f",costedTime);
            self.compressionFinished = YES;
            if (self.SYNC) {
                dispatch_semaphore_signal(semaCanReturn);
            } else {
                [self resetParameters];
            }
            
        }
        
    }];
    
    if (self.SYNC) {
        while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        [self resetParameters];
    }
    
    
}
////
-(void) makeComp
{
    @autoreleasepool {
        [self makeVTCompressionSession];
        [self makeVTSessionPropertiesReadyAndStart];
        
        printVTCompressionSessionPropertyValue(self.compressionSession, kVTCompressionPropertyKey_AverageBitRate);
        
        if (self.compressionMultiPassEnabled==YES) {
            [self makeVTencodeEachFrameMultiPass];
        } else {
            [self makeVTencodeEachFrameSinglePass];
        }
        [self makeFinalOutputFile];
    }
    
}
////
-(void)makeRecomp
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long int date = (long long int)time;
    self.recompressionStartTime = [NSDate dateWithTimeIntervalSince1970:date];

    [self makeSourceVideoPathsAndURLsReady];
    [self makeWriterReadyAndStart];
    [self makeReaderReadyAndStart];
    [self makeCacheQueueSemaReady];
    
    dispatch_async(self.VTRecompressProcessingConcurrentQueue, ^{
        [self makeDecomp];
        NSLog(@"%d",self.compressionAverageBitRate);
    });
    
    dispatch_async(self.VTRecompressProcessingConcurrentQueue, ^{
        [self makeComp];
        NSLog(@"%d",self.compressionAverageBitRate);
    });
    
    
}



@end