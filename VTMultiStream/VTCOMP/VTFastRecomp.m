//
//  VTFastRecomp.m
//  UView
//
//  Created by dli on 3/12/16.
//  Copyright © 2016 YesView. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "VTFastRecomp.h"

////C函数的声明和实现放在类外面
void eachSampleBufferCallbackOfFastCompProcess(void *outputCallbackRefCon,void *sourceFrameRefCon,OSStatus status,VTEncodeInfoFlags infoFlags,CMSampleBufferRef sampleBuffer);
void eachFrameCallbackOfFastDecompProgress(void *decompressionOutputRefCon,void *sourceFrameRefCon,OSStatus status,VTDecodeInfoFlags infoFlags,CVImageBufferRef imageBuffer,CMTime presentationTimeStamp,CMTime duration);

//// compress process each samplebuffer callback
void eachSampleBufferCallbackOfFastCompProcess(void *outputCallbackRefCon,void *sourceFrameRefCon,OSStatus status,VTEncodeInfoFlags infoFlags,CMSampleBufferRef sampleBuffer)
{
    @autoreleasepool {
        if (status != 0) {
            return;
        }
        if (!CMSampleBufferDataIsReady(sampleBuffer))
        {
            ////NSLog(@"VTCompressEachFrameCallback data is not ready ");
            return;
        }
        
        ////printVTEncodeInfoFlags(infoFlags);
        
        VTFastRecomp * encoder;
        if(outputCallbackRefCon){
            encoder = (__bridge VTFastRecomp*)outputCallbackRefCon;
            
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
                    encoder.endSessionAtSourceTime = CMTimeAdd(pInfo[i].presentationTimeStamp,pInfo[i].duration);
                }
                CMSampleBufferRef sout;
                CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, sampleBuffer, count, pInfo, &sout);
                free(pInfo);
                [encoder.writerInput appendSampleBuffer:sout];
                CFRelease(sampleBuffer);
                CFRelease(sout);
            }
            
            encoder.compressionSourceSeq = encoder.compressionSourceSeq +1;
            
            ////we should not release sampleBuffer here;
            
            

            
            
        } else {
            return;
        }
        
    }
}
//// decompress process each frame call back,cacheAlreadyFilledCount+1
void eachFrameCallbackOfFastDecompProgress(void *decompressionOutputRefCon,void *sourceFrameRefCon,OSStatus status,VTDecodeInfoFlags infoFlags,CVImageBufferRef imageBuffer,CMTime presentationTimeStamp,CMTime duration)
{
    @autoreleasepool {
        VTFastRecomp *decoder = (__bridge VTFastRecomp *)decompressionOutputRefCon;
        
        /* 用于将来扩展
         if (sourceFrameRefCon)
         {
         NSNumber * isKeyFrame;
         isKeyFrame = (__bridge NSNumber *)sourceFrameRefCon;
         NSLog(@"isKeyFrame of the 0st frame in this dataBuffer:%d",[isKeyFrame intValue]);
         isKeyFrame = NULL;
         }
         
         GPUImage:
         if (sourceFrameRefCon == 1)
         {
         调用1号滤镜,，函数由用户输入
         }
         
         
         */

        sourceFrameRefCon = NULL;

        
        ////CVImageBufferRef imageBufferForApplyFilter;
        
        if (decoder.enableProgressIndication) {
            decoder.currentIndication = presentationTimeStamp.value * 1.0f / presentationTimeStamp.timescale;
            decoder.progressIndication = decoder.currentIndication / decoder.totalIndication;
            
        }
        
        
        
        
        ////decoder.eachExtractedCVImage 存储原始的被video tool box callback owner的imageBuffer
        
        if (decoder.applyFilter) {
            decoder.CVPBRefInput.newInputCVPixelBufferRef = NULL;
            decoder.CVPBRefInput.newInputCVPixelBufferRef = imageBuffer;
            
            
            if ([decoder.initedFilter.filterName isEqualToString:@"Sticking"]) {
                if (decoder.enablePreviousResultsBuffers) {
                    int newest = (int)decoder.previousResultsBuffers.count - 1;
                    if (newest >= 0) {
                        decoder.CVPBRefInputAux1.newInputCVPixelBufferRef = NULL;
                        decoder.CVPBRefInputAux1.newInputCVPixelBufferRef = (__bridge CVPixelBufferRef)(decoder.previousResultsBuffers[newest]);
                        [decoder.CVPBRefInputAux1 startProcessing];
                    } else {
                        decoder.CVPBRefInputAux1.newInputCVPixelBufferRef = NULL;
                        decoder.CVPBRefInputAux1.newInputCVPixelBufferRef = imageBuffer;
                        [decoder.CVPBRefInputAux1 startProcessing];
                    }
                }
            }
            
            
           if ([decoder.initedFilter.filterName isEqualToString:@"Julia"]) {
               GPUImageJulia * filter= (GPUImageJulia *)decoder.initedFilter;
               float step = (filter.endRadius - filter.startRadius) /decoder.estimatedSourceTotalFramesCount;
               NSLog(@"radius step = %f",step);
               
               float radius = filter.startRadius + step * decoder.goodSamCounts;
               [filter setRadius:radius];
               int r = arc4random_uniform(1000000);
               float y = (float)r / (float)1000000;
               [filter setTimeSeed:y];
           }
            
            if ([decoder.initedFilter.filterName isEqualToString:@"ZW"]) {
                GPUImageZW * filter= (GPUImageZW *)decoder.initedFilter;
                float step = (filter.maxScale - filter.minScale) /filter.frameNumsInterval;
                ////decoder.estimatedSourceTotalFramesCount
                ////decoder.goodSamCounts
                int q = decoder.goodSamCounts / filter.frameNumsInterval;
                if (q%2==0) {
                    filter.currScale = filter.currScale + step;
                } else {
                    filter.currScale = filter.currScale - step;
                }
                
                NSLog(@"curr scale = %f,increasing step = %f",filter.currScale,step);
                [filter setTimeSeed:filter.currScale];
            }
            
            if ([decoder.initedFilter.filterName isEqualToString:@"3D"]) {
                GPUImage3D * filter= (GPUImage3D *)decoder.initedFilter;
                int r = arc4random_uniform(1000000);
                float y = (float)r / (float)1000000;
                [filter setTimeSeed:y];
                [filter setTime:[[NSDate date] timeIntervalSince1970]];
            }
            
            
            [decoder.CVPBRefInput startProcessing];
            decoder.eachExtractedCVImage = decoder.CVPBRefOutput.outputPixelBufferRef;

        } else {
            decoder.eachExtractedCVImage  = imageBuffer;
        }
        
        if (status != noErr)
        {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Decompressed error: %@", error);
        } else {
            if (decoder.removeNegativeCMTime == YES) {
                if (presentationTimeStamp.value < 0 || presentationTimeStamp.timescale < 0 ) {
                    return;
                }
                if (duration.value < 0 || duration.timescale < 0) {
                    return;
                }
            } else {
                
            }
            CVPixelBufferLockBaseAddress(decoder.eachExtractedCVImage,0);
            if (decoder.useCacheArray) {
                if (decoder.parallelArray.count  == decoder.cacheArraySize) {
                    ////如果排序缓存已满
                    [decoder.parallelArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
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
                    ////从FIFO对列中挤出第一个 赋给 decoder.eachModifiedCVImage
                    decoder.eachModifiedCVImage = (__bridge CVImageBufferRef)[decoder.parallelArray[0] valueForKey:@"CVImage"];
                    CMTime thisPresentation = [[decoder.parallelArray[0] valueForKey:@"presentationTimeStamp"] CMTimeValue];
                    CMTime thisDuration = [[decoder.parallelArray[0] valueForKey:@"duration"] CMTimeValue];
                    VTEncodeInfoFlags flags;
                    OSStatus statusCode;
                    ////把decoder.eachModifiedCVImage 交给 压缩进程
                    if (decoder.useOnlyDurations) {
                        statusCode = VTCompressionSessionEncodeFrame(decoder.compressionSession,decoder.eachModifiedCVImage,decoder.currCacheStartPresentation,thisDuration,NULL, NULL, &flags);
                        decoder.currCacheStartPresentation = CMTimeAdd(decoder.currCacheStartPresentation,thisDuration);
                    } else {
                        statusCode = VTCompressionSessionEncodeFrame(decoder.compressionSession,decoder.eachModifiedCVImage,thisPresentation,thisDuration,NULL, NULL, &flags);
                    }

                    
                    
                    if (statusCode != noErr) {
                        NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                        VTCompressionSessionInvalidate(decoder.compressionSession);
                        CFRelease(decoder.compressionSession);
                        decoder.compressionSession = NULL;
                        return;
                    }
                    
                    
                    ////根据需要保留一份缓存,因为有multi Round Filter可能会使用到上次的结果
                    if (decoder.applyFilter) {
                        if (decoder.enablePreviousResultsBuffers) {
                            if (decoder.previousResultsBuffers.count == decoder.previousResultsBuffersCapacity) {
                                CVPixelBufferRelease((__bridge CVPixelBufferRef)(decoder.previousResultsBuffers[0]));
                                decoder.previousResultsBuffers[0] =[NSNull null];
                                [decoder.previousResultsBuffers removeObjectAtIndex:0];
                                CVPixelBufferPoolFlush(decoder.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                            } else {
                                CVPixelBufferRef tempCVPixelBuff;
                                tempCVPixelBuff = copyCVPixelBufferToBufferPoolGeneratedBuffer(decoder.eachModifiedCVImage, decoder.pixelBufferPool);
                                [decoder.previousResultsBuffers addObject:(__bridge id)(tempCVPixelBuff)];
                                tempCVPixelBuff = NULL;
                            }
                        }
                    }

                    
                    
                    
                    
                    decoder.parallelArray[0] = [NSNull null];
                    [decoder.parallelArray removeObjectAtIndex:0];
                    
                    ////从排序队列中移除，然后
                    ////释放 decoder.eachModifiedCVImage
                    ////如果应用过filter那么 必须真正释放 因为 filter会复制一份原始的被video tool box callback owner的imageBuffer
                    ////被复制出来的 需要我们自己释放CVPixelBufferRelease(decoder.eachModifiedCVImage);
                    ////we should not release CVImageBufferRef imageBuffer here when without applyFilter,
                    ////because when without applyFilter, the imageBuffer did not get copyed by us,
                    ////it is ownered by video tool box  callback
                    if (decoder.applyFilter) {
                        CVPixelBufferRelease(decoder.eachModifiedCVImage);
                        decoder.eachModifiedCVImage = NULL;
                        decoder.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                        decoder.CVPBRefOutput.outputPixelBufferRef = NULL;
                        CVPixelBufferPoolFlush(decoder.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                        
                    } else {
                        decoder.eachModifiedCVImage = NULL;
                    }
                    
                    
                    ////把刚解压得到的decoder.eachExtractedCVImage 存入FIFO 排序缓存
                    NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                    [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                    [parallel setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
                    [parallel setValue:(__bridge id)decoder.eachExtractedCVImage forKey:@"CVImage"];
                    [decoder.parallelArray addObject:parallel];
                    
                    
                    ////--同时
                    
                    ////--
                    
                } else {
                    ////排序缓存未满时候不会发生 递交给 压缩进程的动作
                    ////把刚解压得到的decoder.eachExtractedCVImage 存入FIFO 排序缓存
                    NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                    [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                    [parallel setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
                    [parallel setValue:(__bridge id)decoder.eachExtractedCVImage forKey:@"CVImage"];
                    [decoder.parallelArray addObject:parallel];
                }

            } else {
                //// 这里直接把imageBuffer传给comp,不使用排序缓存
                //// presentationTimeStamp 不使用
                //// 使用duration 计算新的　presentationTimeStamp
                //// 注意在外面的Flag设置
                VTEncodeInfoFlags flags;
                OSStatus statusCode;
                if (decoder.useOnlyDurations) {
                    statusCode = VTCompressionSessionEncodeFrame(decoder.compressionSession,decoder.eachExtractedCVImage,decoder.currCacheStartPresentation,duration,NULL, NULL, &flags);
                    decoder.currCacheStartPresentation = CMTimeAdd(decoder.currCacheStartPresentation,duration);
                } else {
                    statusCode = VTCompressionSessionEncodeFrame(decoder.compressionSession,decoder.eachExtractedCVImage,presentationTimeStamp,duration,NULL, NULL, &flags);
                }
                
                
                
                
                ////根据需要保留一份缓存,因为有multi Round Filter可能会使用到上次的结果
                if (decoder.applyFilter) {
                    if (decoder.enablePreviousResultsBuffers) {
                        if (decoder.previousResultsBuffers.count == decoder.previousResultsBuffersCapacity) {
                            CVPixelBufferRelease((__bridge CVPixelBufferRef)(decoder.previousResultsBuffers[0]));
                            decoder.previousResultsBuffers[0] =[NSNull null];
                            [decoder.previousResultsBuffers removeObjectAtIndex:0];
                            CVPixelBufferPoolFlush(decoder.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                        } else {
                            CVPixelBufferRef tempCVPixelBuff;
                            tempCVPixelBuff = copyCVPixelBufferToBufferPoolGeneratedBuffer(decoder.eachExtractedCVImage, decoder.pixelBufferPool);
                            [decoder.previousResultsBuffers addObject:(__bridge id)(tempCVPixelBuff)];
                            tempCVPixelBuff = NULL;
                        }
                    }
                }

                
                
                
                
                ////we should not release CVImageBufferRef imageBuffer here when without applyFilter,
                ////because when without applyFilter, the imageBuffer did not get copyed by us,
                ////it is ownered by video tool box  callback
                if (decoder.applyFilter) {
                    CVPixelBufferRelease(decoder.eachExtractedCVImage);
                    decoder.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                    decoder.CVPBRefOutput.outputPixelBufferRef = NULL;
                    CVPixelBufferPoolFlush(decoder.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);

                
                
                } else {
                    
                }
                
                
                if (statusCode != noErr) {
                    NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                    VTCompressionSessionInvalidate(decoder.compressionSession);
                    CFRelease(decoder.compressionSession);
                    decoder.compressionSession = NULL;
                    return;
                }
                
            }
            
            CVPixelBufferUnlockBaseAddress(decoder.eachExtractedCVImage, 0);
            decoder.goodSamCounts ++;
            decoder.origGoodSamCounts ++;
            
            
            
            
        }

        ////
        decoder.eachExtractedCVImage = NULL;
        decoder.eachModifiedCVImage = NULL;
        ////
    }
}


@implementation VTFastRecomp
//// p4sed
-(void) readMe
{
    NSLog(@"=====part1:how to use:=====");
    NSString * part1 = @"    VTFastRecomp * vtfrc = [[VTFastRecomp alloc] init];\
    [vtfrc resetParameters];\
    vtfrc.sourceVideoURL = self.multiMovieURLs[0];\
    vtfrc.writerOutputRelativeDirPath = @'VTFRCOUTPUT';\
    vtfrc.writerOutputFileName = @'recomp.mov';\
    vtfrc.writerOutputFileType = AVFileTypeQuickTimeMovie;\
    vtfrc.compressionSessionPropertiesConstructFromKeyValue =YES;\
    vtfrc.compressionCodecType = kCMVideoCodecType_H264;\
    vtfrc.compressionAverageBitRate = 1280000;\
    vtfrc.deleteOutputDirBeforeWrite = YES;\
    vtfrc.useOnlyDurations = NO;\
    vtfrc.applyOOBPT = NO;\
    vtfrc.applyOOBPTQuick = YES;\
    vtfrc.useCacheArray = YES;\
    vtfrc.cacheArraySize = 2;\
    vtfrc.writerShouldOptimizeForNetworkUse = YES;\
    vtfrc.constructDestinationImageBufferAttributesFromKeyValue =YES;\
    vtfrc.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;\
    [vtfrc makeRecomp];\
    ";
    NSLog(@"%@",part1);
    NSLog(@"=====part1:how to use:=====");
}
//// p4sed
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
    self.writerShouldOptimizeForNetworkUse = NO;
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
    self.readerOutputAlwaysCopiesSampleData = NO;
    ////使用一个类似FIFO的队列,对列满了以后每次弹出一个
    self.useCacheArray = YES;
    self.cacheArraySize = 15;
    self.eachExtractedCVImage = NULL;
    self.eachModifiedCVImage = NULL;
    self.applyFilter = NO;
    self.filterNumber = 0;
    self.pixelBufferPool = NULL;
    self.minimumBufferCount = 1;
    self.maximumBufferAge = 10;
    self.pixelBufferFormatType = kCVPixelFormatType_32BGRA;
    ////this format is necessary for using openGL
    self.CVPBRefInput = NULL;
    self.CVPBRefInputAux1 = NULL;
    self.initedFilter = NULL;
    self.terminatedFilter = NULL;
    self.CVPBRefOutput = NULL;
    self.frameFilterDelegate = NULL;
    self.enablePreviousResultsBuffers = NO;
    self.previousResultsBuffersCapacity = 0;
    self.previousResultsBuffers = NULL;
    self.parallelArray = NULL;
    
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
    self.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_32BGRA;
    //// kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    self.constructDecompressionDecodeSpecificationFromKeyValue = NO;
    self.decompressionDecodeSpecification = NULL;
    ////
    self.compSessionWidth = -1;
    self.compSessionHeight = -1;
    self.recompressionStartTime = NULL;
    self.currKeyFrameIndicator = NO;
    self.newSessionEachKeyFrame = NO;
    ////
    self.sortImagesAfterDecompression = YES;
    self.currCacheStartPresentation=kCMTimeZero;
    self.useOnlyDurations = YES;
    self.decompressionFinished =NO;
    ////
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
    self.compressionExpectedFrameRate = 0;
    ////
    self.keepKeyFrameSigns = NO;
    self.endSessionAtSourceTime = kCMTimeZero;
    ////
    self.applyOOBPT = NO;
    self.applyOOBPTQuick = YES;
    self.recompressionEndTime = NULL;
    self.compressionFinished = NO;
    self.deleteOutputFileInSandboxAfterCopyToAlbum = NO;
    self.writeToAlbum = NO;
    self.SYNC = NO;
    ////
    self.enableProgressIndication = NO;
    self.progressIndicationTimerInterval = 1.0;
    self.progressIndication = 0.0;
    self.totalIndication = 0.0;
    self.currentIndication = 0.0;
    
}
//// p4sed
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
//// p4sed
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
            temp = NULL;
            [FileUitl deleteTmpFile:self.writerOutputPath];
            self.writerOutputURL=[NSURL fileURLWithPath:self.writerOutputPath];
        }
        self.writer = NULL;
        self.writerInput = NULL;
        NSError * error;
        self.writer= [[AVAssetWriter alloc] initWithURL:self.writerOutputURL
                                               fileType:self.writerOutputFileType
                                                  error:&error];
        error = NULL;
        self.writer.shouldOptimizeForNetworkUse = self.writerShouldOptimizeForNetworkUse;
        self.writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:nil];
        
        if (self.applyOOBPTQuick) {
            self.writerInput.transform = self.preferedTransform;
        }
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
//// p4sed
-(void) makeReaderReadyAndStart
{
    @autoreleasepool {
        if (self.applyOOBPT) {
            self.applyOOBPTQuick = NO;
            if (self.readerAsset == NULL) {
                self.readerAsset = [AVAsset assetWithURL:self.sourceVideoURL];
                NSError * error ;
                self.reader = [[AVAssetReader alloc] initWithAsset:self.readerAsset error:&error];
                self.sourceVideoTrack = [selectAllVideoTracksFromAVAssetNoCopyItem(self.readerAsset) objectAtIndex:self.whichTrack];
                self.preferedTransform = [self.sourceVideoTrack preferredTransform];
                NSString * tmpPath = self.sourceVideoPath;
                tmpPath = [tmpPath stringByAppendingString:@".replace"];
                NSURL * replace = [NSURL fileURLWithPath:tmpPath];
                [FileUitl deleteTmpFile:tmpPath];
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                ptVideoFromSourceURLSema(self.sourceVideoURL, 0, replace, sema, 0, self.preferedTransform);
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                [FileUitl deleteTmpFile:self.sourceVideoPath];
                [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:self.sourceVideoPath error:nil];
                self.readerAsset = NULL;
            } else {
                self.sourceVideoTrack = [selectAllVideoTracksFromAVAssetNoCopyItem(self.readerAsset) objectAtIndex:self.whichTrack];
                self.preferedTransform = [self.sourceVideoTrack preferredTransform];
                NSString * tmpPath = self.sourceVideoPath;
                tmpPath = [tmpPath stringByAppendingString:@".replace"];
                NSURL * replace = [NSURL fileURLWithPath:tmpPath];
                [FileUitl deleteTmpFile:tmpPath];
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                ptVideoFromSourceURLSema(self.sourceVideoURL, 0, replace, sema, 0, self.preferedTransform);
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                [FileUitl deleteTmpFile:self.sourceVideoPath];
                [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:self.sourceVideoPath error:nil];
                self.readerAsset = NULL;
            }
            
        }
        if (self.readerAsset == NULL) {
            self.readerAsset = [AVAsset assetWithURL:self.sourceVideoURL];
        } else {
        }
        NSError * error ;
        self.reader = [[AVAssetReader alloc] initWithAsset:self.readerAsset error:&error];
        error = NULL;
        self.sourceVideoTrack = [selectAllVideoTracksFromAVAssetNoCopyItem(self.readerAsset) objectAtIndex:self.whichTrack];
        
        if (self.enableProgressIndication) {
            self.totalIndication  = self.readerAsset.duration.value * 1.0f / self.readerAsset.duration.timescale;
        }
        
        self.preferedTransform = [self.sourceVideoTrack preferredTransform];
        self.width = self.sourceVideoTrack.naturalSize.width;
        self.height = self.sourceVideoTrack.naturalSize.height;
        
        ////AVAssetReaderOutput with outputSettings 可以直接copy出CVImageBufferRef
        ////比当前所用的AVAssetReaderTrackOutput nil方便
        ////参考GPUImageMovie.m中的用法
        ////
        
        self.readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:self.sourceVideoTrack outputSettings:nil];
        self.readerOutput.alwaysCopiesSampleData = self.readerOutputAlwaysCopiesSampleData;
        ////randomAccess
        ////resetForReadingTimeRanges:
        [self.readerOutput markConfigurationAsFinal];
        [self.reader addOutput:self.readerOutput];
        [self.reader startReading];
    }
}
//// p4sed
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
            float CVPwidth = ((self.compSessionWidth>0)? self.compSessionWidth:self.width);
            float CVPheight = ((self.compSessionHeight>0)? self.compSessionHeight:self.height);
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
        self.compressionEachSampleBufferCallback = eachSampleBufferCallbackOfFastCompProcess;
        ////NSLog(@"self.compressionEncoderSpecification:%@",self.compressionEncoderSpecification);
        ////printVTEncoderList(NULL);
        OSStatus status = VTCompressionSessionCreate(NULL,
                                                     ((self.compSessionWidth>0)? self.compSessionWidth:self.width),
                                                     ((self.compSessionHeight>0)? self.compSessionHeight:self.height),
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
            if (ct) {
                CFRelease(ct);
                ct = NULL;
            }
            
            return ;
        } else {
            ////NSLog(@"VTCompressionSessionCreated");
        }
        
        if (self.compressionEncoderSpecificationConstructFromKeyValue == YES) {
            
            if (self.compressionEncoderSpecification == NULL) {
                
            } else {
                CFRelease(self.compressionEncoderSpecification);
                
                self.compressionEncoderSpecification = NULL;
            }
            
            if (ct != NULL) {
                CFRelease(ct);
                ct = NULL;
            }
            
        } else {
            if (self.compressionEncoderSpecification == NULL) {
                
            } else {
                CFRelease(self.compressionEncoderSpecification);
                
                self.compressionEncoderSpecification = NULL;
            }
        }

        if (self.compressionSourceImageBufferAttributesConstructFromKeyValue == YES) {
            if (self.compressionSourceImageBufferAttributes == NULL) {
                
            } else {
                CFRelease(self.compressionSourceImageBufferAttributes);
                self.compressionSourceImageBufferAttributes = NULL;
            }
            
            if (ct != NULL) {
                CFRelease(ct);
                ct = NULL;
            }
            if (CFEmptyDict != NULL) {
                CFRelease(CFEmptyDict);
                CFEmptyDict = NULL;
            }
            
            CFRelease(compressionCVPixelFormatType);
            CFRelease(CFWidth);
            CFRelease(CFHeight);
            CFRelease(CFBOOLYES);

        } else {
            if (self.compressionSourceImageBufferAttributes == NULL) {
                
            } else {
                CFRelease(self.compressionSourceImageBufferAttributes);
                self.compressionSourceImageBufferAttributes = NULL;
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
            VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(self.compressionAverageBitRate));
            
            if (self.compressionExpectedFrameRate!=0) {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)@(self.compressionExpectedFrameRate));
                
            }
            
            
            
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
        ////OSStatus staus =
        VTCompressionSessionPrepareToEncodeFrames(self.compressionSession);
        ////NSLog(@"VTCompressionSessionPrepareToEncodeFrames:%d:self.compressionSession:%@",staus,self.compressionSession);
        
    }
    
}
//// makeVTDecompressionSession
-(void) makeVTDecompressionSession
{
    @autoreleasepool {
        self.decompressionSession = NULL;
        self.decompressionEachFrameCallback = eachFrameCallbackOfFastDecompProgress;
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = self.decompressionEachFrameCallback;
        callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
        CFNumberRef cfn1 = NULL;
        if (self.constructDestinationImageBufferAttributesFromKeyValue) {
            
            if (self.destinationImageBufferAttributes != NULL) {
                
            } else {
                self.destinationImageBufferAttributes = NULL;
                const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
                uint32_t v = self.destinationImageBufferKCVPixelFormatType;
                cfn1 = CFNumberCreate(NULL, kCFNumberSInt32Type, &v);
                const void *values[] = { cfn1 };
                self.destinationImageBufferAttributes = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            }

        } else {
            self.destinationImageBufferAttributes = NULL;
           
        }
        ////self.decompressionDecodeSpecification should be inited here
        ////kVTDecompressionProperty_DeinterlaceMode_Temporal
        if (self.constructDecompressionDecodeSpecificationFromKeyValue) {
            CFRelease(self.decompressionDecodeSpecification);
            self.decompressionDecodeSpecification = NULL;
        } else {
            if (self.decompressionDecodeSpecification != NULL) {
                
            } else {
                self.decompressionDecodeSpecification = NULL;
                
            }
        }
        ////self.decompressionDecodeSpecification should be inited here
        ////VT 无法找到prores 4444 的decoder
        ////NSLog(@"self.decompressionVideoFormatDescription:%@",self.decompressionVideoFormatDescription);
        ////NSLog(@"self.decompressionDecodeSpecification:%@",self.decompressionDecodeSpecification);
        ////NSLog(@"self.destinationImageBufferAttributes:%@",self.destinationImageBufferAttributes);
        
        OSStatus status =  VTDecompressionSessionCreate(kCFAllocatorDefault,self.decompressionVideoFormatDescription,self.decompressionDecodeSpecification,self.destinationImageBufferAttributes,&callBackRecord,&_decompressionSession);
        NSLog(@"Video Decompression Session Create: \t %@", (status == noErr) ? @"successful!" : @"failed...");
        
        callBackRecord.decompressionOutputCallback = NULL;
        callBackRecord.decompressionOutputRefCon = NULL;
        
        
        if(status != noErr) {
            printVTError(status);
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
            CFRelease(cfn1);
            cfn1 = NULL;
        } else {
            if (self.destinationImageBufferAttributes != NULL) {
                CFRelease(self.destinationImageBufferAttributes);
                self.destinationImageBufferAttributes = NULL;
                CFRelease(cfn1);
                cfn1 = NULL;
            } else {
                
            }
        }
        
        if (cfn1 == NULL) {
            
        } else {
            CFRelease(cfn1);
            cfn1 = NULL;
        }
        
        if (self.destinationImageBufferAttributes) {
            CFRelease(self.destinationImageBufferAttributes);
            self.destinationImageBufferAttributes = NULL;
        }
        
        
        self.decompressionVideoFormatDescription = NULL;
        
        
    }
}
//// decompress process while circle
-(void) makeDecomp
{
    BOOL done = NO;
    self.goodSamCounts = 0;
    self.origGoodSamCounts = 0;
    BOOL firstGoodIFrame = NO;
    if (self.useCacheArray) {
        self.parallelArray = [[NSMutableArray  alloc] init];
    }
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
                    ////The client is responsible for calling CFRelease on the
                    ////returned CMSampleBuffer object when finished with it.
                    ////This method will return NULL if there are no more sample buffers available
                    ////for the receiver within the time range specified by its AVAssetReader's timeRange property,
                    ////or if there is an error that prevents the AVAssetReader from reading more media data.
                    ////When this method returns NULL, clients should check the value of the associated
                    ////AVAssetReader's status property to determine why no more samples could be read.
                    CFRelease(sampleBuffer);
                    sampleBuffer = NULL;
                } else {
                    blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
                    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                    if (imageBuffer == NULL && blockBuffer == NULL) {
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
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
                        
                        if (self.applyFilter) {
                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                            self.CVPBRefInput.newInputCVPixelBufferRef = imageBuffer;
                            
                            
                            if ([self.initedFilter.filterName isEqualToString:@"Sticking"]) {
                                if (self.enablePreviousResultsBuffers) {
                                    int newest = (int)self.previousResultsBuffers.count - 1;
                                    if (newest >= 0) {
                                        self.CVPBRefInputAux1.newInputCVPixelBufferRef = NULL;
                                        self.CVPBRefInputAux1.newInputCVPixelBufferRef = (__bridge CVPixelBufferRef)(self.previousResultsBuffers[newest]);
                                        [self.CVPBRefInputAux1 startProcessing];
                                    } else {
                                        self.CVPBRefInputAux1.newInputCVPixelBufferRef = NULL;
                                        self.CVPBRefInputAux1.newInputCVPixelBufferRef = imageBuffer;
                                        [self.CVPBRefInputAux1 startProcessing];
                                    }
                                }
                            }
                            
                            
                            
                            
                            
                            
                            [self.CVPBRefInput startProcessing];
                            self.eachExtractedCVImage = self.CVPBRefOutput.outputPixelBufferRef;
                            
                            


                            
                            
                            
                        } else {
                            self.eachExtractedCVImage  = imageBuffer;
                        }
                        
                        ////
                        for (int ki=0; ki < (int)numOfsamplesInSampleBuffer; ki++) {
                            if (isH264IFrame(sampleBuffer, ki)) {
                                self.currKeyFrameIndicator = YES;
                                if (self.useCacheArray) {
                                    if (self.parallelArray.count  == self.cacheArraySize) {
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
                                        self.eachExtractedCVImage = (__bridge CVImageBufferRef)[self.parallelArray[0] valueForKey:@"CVImage"];
                                        CMTime thisPresentation = [[self.parallelArray[0] valueForKey:@"presentationTimeStamp"] CMTimeValue];
                                        CMTime thisDuration = [[self.parallelArray[0] valueForKey:@"duration"] CMTimeValue];
                                        VTEncodeInfoFlags flags;
                                        OSStatus statusCode;
                                        //////////////////
                                        if (self.useOnlyDurations) {
                                            if (!self.keepKeyFrameSigns) {
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,thisDuration,NULL, NULL, &flags);
                                            } else {
                                                CFDictionaryRef frameProperties= NULL;
                                                const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                                const void *values[1] = { kCFBooleanTrue };
                                                frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                             self.eachExtractedCVImage,
                                                                                             self.currCacheStartPresentation,
                                                                                             thisDuration,
                                                                                             frameProperties, NULL, &flags);
                                                CFRelease(frameProperties);
                                            }
                                            if (statusCode != noErr) {
                                                NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                                VTCompressionSessionInvalidate(self.compressionSession);
                                                CFRelease(self.compressionSession);
                                                self.compressionSession = NULL;
                                                return;
                                            }
                                            
                                            if (self.applyFilter) {
                                                CVPixelBufferRelease(self.eachExtractedCVImage);
                                                self.eachExtractedCVImage = NULL;
                                                self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                                self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                                CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                                
                                            } else {
                                                self.eachExtractedCVImage = NULL;
                                            }
                                            
                                            self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                                        } else {
                                            if (!self.keepKeyFrameSigns) {
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                             self.eachExtractedCVImage,
                                                                                             thisPresentation,
                                                                                             thisDuration,
                                                                                             NULL, NULL, &flags);
                                            } else {
                                                CFDictionaryRef frameProperties= NULL;
                                                const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                                const void *values[1] = { kCFBooleanTrue };
                                                frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                             self.eachExtractedCVImage,
                                                                                             thisPresentation,
                                                                                             thisDuration,
                                                                                             frameProperties, NULL, &flags);
                                                CFRelease(frameProperties);
                                            }
                                            
                                            
                                            
                                            
                                            ////根据需要保留一份缓存,因为有multi Round Filter可能会使用到上次的结果
                                            if (self.applyFilter) {
                                                if (self.enablePreviousResultsBuffers) {
                                                    if (self.previousResultsBuffers.count == self.previousResultsBuffersCapacity) {
                                                        CVPixelBufferRelease((__bridge CVPixelBufferRef)(self.previousResultsBuffers[0]));
                                                        self.previousResultsBuffers[0] =[NSNull null];
                                                        [self.previousResultsBuffers removeObjectAtIndex:0];
                                                        CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                                    } else {
                                                        CVPixelBufferRef tempCVPixelBuff;
                                                        tempCVPixelBuff = copyCVPixelBufferToBufferPoolGeneratedBuffer(self.eachExtractedCVImage, self.pixelBufferPool);
                                                        [self.previousResultsBuffers addObject:(__bridge id)(tempCVPixelBuff)];
                                                        tempCVPixelBuff = NULL;
                                                    }
                                                }
                                            }
                                            
                                            
                                            
                                            
                                            
                                            
                                            if (self.applyFilter) {
                                                CVPixelBufferRelease(self.eachExtractedCVImage);
                                                self.eachExtractedCVImage = NULL;
                                                self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                                self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                                CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                                
                                            } else {
                                                self.eachExtractedCVImage = NULL;
                                            }
                                            
                                            
                                            
                                            if (statusCode != noErr) {
                                                NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                                VTCompressionSessionInvalidate(self.compressionSession);
                                                CFRelease(self.compressionSession);
                                                self.compressionSession = NULL;
                                                return;
                                            }
                                        }
                                        //////////////////
                                        self.parallelArray[0] = [NSNull null];
                                        [self.parallelArray removeObjectAtIndex:0];
                                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                                        [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                        [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                        [parallel setValue:(__bridge id)imageBuffer forKey:@"CVImage"];
                                        [self.parallelArray addObject:parallel];
                                        
                                    } else {
                                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                                        [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                        [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                        [parallel setValue:(__bridge id)imageBuffer forKey:@"CVImage"];
                                        [self.parallelArray addObject:parallel];
                                    }
                                    
                                } else {
                                    
                                    //// 这里直接把imageBuffer传给comp
                                    //// presentationTimeStamp 不使用
                                    //// 使用duration 计算新的　presentationTimeStamp
                                    //// 注意在外面的Flag设置
                                    VTEncodeInfoFlags flags;
                                    OSStatus statusCode;
                                    if (self.useOnlyDurations) {
                                        if (!self.keepKeyFrameSigns) {
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,frameDuration,NULL, NULL, &flags);
                                            
                                        } else {
                                            CFDictionaryRef frameProperties= NULL;
                                            const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                            const void *values[1] = { kCFBooleanTrue };
                                            frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                         self.eachExtractedCVImage,
                                                                                         self.currCacheStartPresentation,
                                                                                         frameDuration,
                                                                                         frameProperties, NULL, &flags);
                                            CFRelease(frameProperties);
                                        }
                                        
                                        
                                        ////根据需要保留一份缓存,因为有multi Round Filter可能会使用到上次的结果
                                        if (self.applyFilter) {
                                            if (self.enablePreviousResultsBuffers) {
                                                if (self.previousResultsBuffers.count == self.previousResultsBuffersCapacity) {
                                                    CVPixelBufferRelease((__bridge CVPixelBufferRef)(self.previousResultsBuffers[0]));
                                                    self.previousResultsBuffers[0] =[NSNull null];
                                                    [self.previousResultsBuffers removeObjectAtIndex:0];
                                                    CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                                } else {
                                                    CVPixelBufferRef tempCVPixelBuff;
                                                    tempCVPixelBuff = copyCVPixelBufferToBufferPoolGeneratedBuffer(self.eachExtractedCVImage, self.pixelBufferPool);
                                                    [self.previousResultsBuffers addObject:(__bridge id)(tempCVPixelBuff)];
                                                    tempCVPixelBuff = NULL;
                                                }
                                            }
                                        }

                                        
                                        
                                        
                                        
                                        
                                        
                                        if (self.applyFilter) {
                                            CVPixelBufferRelease(self.eachExtractedCVImage);
                                            self.eachExtractedCVImage = NULL;
                                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                            self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                            CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                            
                                        } else {
                                            self.eachExtractedCVImage = NULL;
                                        }
                                        
                                        if (statusCode != noErr) {
                                            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                            VTCompressionSessionInvalidate(self.compressionSession);
                                            CFRelease(self.compressionSession);
                                            self.compressionSession = NULL;
                                            return;
                                        }
                                        
                                        self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,frameDuration);
                                    } else {
                                        
                                        if (!self.keepKeyFrameSigns) {
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                         self.eachExtractedCVImage,
                                                                                         presentationTimeStamp,
                                                                                         frameDuration,
                                                                                         NULL, NULL, &flags);
                                        } else {
                                            CFDictionaryRef frameProperties= NULL;
                                            const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                            const void *values[1] = { kCFBooleanTrue };
                                            frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                         self.eachExtractedCVImage,
                                                                                         presentationTimeStamp,
                                                                                         frameDuration,
                                                                                         frameProperties, NULL, &flags);
                                            CFRelease(frameProperties);
                                        }
                                        
                                        if (self.applyFilter) {
                                            CVPixelBufferRelease(self.eachExtractedCVImage);
                                            self.eachExtractedCVImage = NULL;
                                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                            self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                            CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                            
                                        } else {
                                            self.eachExtractedCVImage = NULL;
                                        }
                                        
                                        
                                        if (statusCode != noErr) {
                                            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                            VTCompressionSessionInvalidate(self.compressionSession);
                                            CFRelease(self.compressionSession);
                                            self.compressionSession = NULL;
                                            return;
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
                            } else {
                                self.currKeyFrameIndicator = NO;
                                if (ki==0) {
                                    ////第一frame  必须是IFRAME
                                    continue;
                                } else {
                                    ////
                                    if (self.useCacheArray) {
                                        if (self.parallelArray.count  == self.cacheArraySize) {
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
                                            self.eachExtractedCVImage = (__bridge CVImageBufferRef)[self.parallelArray[0] valueForKey:@"CVImage"];
                                            CMTime thisPresentation = [[self.parallelArray[0] valueForKey:@"presentationTimeStamp"] CMTimeValue];
                                            CMTime thisDuration = [[self.parallelArray[0] valueForKey:@"duration"] CMTimeValue];
                                            VTEncodeInfoFlags flags;
                                            OSStatus statusCode;
                                            if (self.useOnlyDurations) {
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,thisDuration,NULL, NULL, &flags);
                                                self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                                            } else {
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,thisPresentation,thisDuration,NULL, NULL, &flags);
                                            }
                                            if (statusCode != noErr) {
                                                NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                                VTCompressionSessionInvalidate(self.compressionSession);
                                                CFRelease(self.compressionSession);
                                                self.compressionSession = NULL;
                                                return;
                                            }
                                            
                                            
                                            if (self.applyFilter) {
                                                CVPixelBufferRelease(self.eachExtractedCVImage);
                                                self.eachExtractedCVImage = NULL;
                                                self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                                self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                                CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                                
                                            } else {
                                                self.eachExtractedCVImage = NULL;
                                            }
                                            
                                            self.parallelArray[0] = [NSNull null];
                                            
                                            
                                            
                                            
                                            [self.parallelArray removeObjectAtIndex:0];
                                            NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                                            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                            [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                            [parallel setValue:(__bridge id)imageBuffer forKey:@"CVImage"];
                                            [self.parallelArray addObject:parallel];
                                            
                                        } else {
                                            NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                                            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                            [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                            [parallel setValue:(__bridge id)imageBuffer forKey:@"CVImage"];
                                            [self.parallelArray addObject:parallel];
                                        }
                                    } else {
                                        //// 这里直接把imageBuffer传给comp
                                        //// presentationTimeStamp 不使用
                                        //// 使用duration 计算新的　presentationTimeStamp
                                        //// 注意在外面的Flag设置
                                        VTEncodeInfoFlags flags;
                                        OSStatus statusCode;
                                        if (self.useOnlyDurations) {
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,frameDuration,NULL, NULL, &flags);
                                            self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,frameDuration);
                                        } else {
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,presentationTimeStamp,frameDuration,NULL, NULL, &flags);
                                        }
                                        
                                        
                                        
                                        if (self.applyFilter) {
                                            CVPixelBufferRelease(self.eachExtractedCVImage);
                                            self.eachExtractedCVImage = NULL;
                                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                            self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                            CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                            
                                        } else {
                                            self.eachExtractedCVImage = NULL;
                                        } 
                                        
                                        if (statusCode != noErr) {
                                            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                            VTCompressionSessionInvalidate(self.compressionSession);
                                            CFRelease(self.compressionSession);
                                            self.compressionSession = NULL;
                                            return;
                                        }
                                        
                                    }
                                    ////
                                }
                            }
                        }
                        ////
                        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                        //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        //because used CFRetain before
                        CFRelease(imageBuffer);
                        imageBuffer = NULL;
                        self.eachExtractedCVImage = NULL;
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
                        ////VTDecodeInfoFlags flagOut = 0;
                        ////NSNumber * KF = [NSNumber numberWithBool:isIFrame];
                        ////
                        ////void * sourceFrameRefCon = (__bridge void*)KF;
                        
                        if (isIFrame) {
                            self.currKeyFrameIndicator = YES;
                            self.decompressionVideoFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                            VTDecompressionSessionFinishDelayedFrames(self.decompressionSession);
                            VTDecompressionSessionWaitForAsynchronousFrames(self.decompressionSession);
                            VTDecompressionSessionInvalidate(self.decompressionSession);
                            if (self.decompressionSession) {
                                CFRelease(self.decompressionSession);
                                self.decompressionSession = NULL;
                            }
                            [self makeVTDecompressionSession];
                        }
                        ////
                        for (int ki=0; ki < (int)numOfsamplesInSampleBuffer; ki++) {
                            if (isH264IFrame(sampleBuffer, ki)) {
                                self.currKeyFrameIndicator = YES;
                            } else {
                                self.currKeyFrameIndicator = NO;
                                if (ki==0) {
                                    ////第一frame  必须是IFRAME
                                    continue;
                                } else {
                                }
                            }
                        }
                        ////
                        OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(self.decompressionSession,
                                                                                  sampleBuffer,
                                                                                  flags,
                                                                                  NULL,////sourceFrameRefCon,
                                                                                  NULL////&flagOut
                                                                                  );

                        
                        
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
                    done = YES;
                    if (sampleBuffer) {
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                    }
                    [self.reader cancelReading];
                    break;
                }
                else
                {
                    done = YES;
                    if (sampleBuffer) {
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                    }
                    [self.reader cancelReading];
                    break;
                }
            }
            
        }
    }
    
    while (!done)
    {
        
        
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
                    CFRelease(sampleBuffer);
                    sampleBuffer = NULL;
                } else {
                    blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
                    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                    if (imageBuffer == NULL && blockBuffer == NULL) {
                        ////either imageBuffer or blockBuffer
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
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
                        
                        ////CVImageBufferRef imageBufferForApplyFilter;
                        
                        if (self.enableProgressIndication) {
                            self.currentIndication = presentationTimeStamp.value * 1.0f / presentationTimeStamp.timescale;
                            self.progressIndication = self.currentIndication / self.totalIndication;
                            
                        }
                        
                        
                        
                        
                        ////decoder.eachExtractedCVImage 存储原始的被video tool box callback owner的imageBuffer
                        
                        if (self.applyFilter) {
                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                            self.CVPBRefInput.newInputCVPixelBufferRef = imageBuffer;
                            [self.CVPBRefInput startProcessing];
                            self.eachExtractedCVImage = self.CVPBRefOutput.outputPixelBufferRef;
                            
                            
                            
                            if ([self.initedFilter.filterName isEqualToString:@"Sticking"]) {
                                if (self.enablePreviousResultsBuffers) {
                                    int newest = (int)self.previousResultsBuffers.count - 1;
                                    if (newest >= 0) {
                                        self.CVPBRefInputAux1.newInputCVPixelBufferRef = NULL;
                                        self.CVPBRefInputAux1.newInputCVPixelBufferRef = (__bridge CVPixelBufferRef)(self.previousResultsBuffers[newest]);
                                        [self.CVPBRefInputAux1 startProcessing];
                                    } else {
                                        self.CVPBRefInputAux1.newInputCVPixelBufferRef = NULL;
                                        self.CVPBRefInputAux1.newInputCVPixelBufferRef = imageBuffer;
                                        [self.CVPBRefInputAux1 startProcessing];
                                    }
                                }
                            }
                            
                            
                            
                        } else {
                            self.eachExtractedCVImage  = imageBuffer;
                        }
                        

                        
                        ////
                        for (int ki=0; ki < (int)numOfsamplesInSampleBuffer; ki++) {
                            if (isH264IFrame(sampleBuffer, ki)) {
                                self.currKeyFrameIndicator = YES;
                                if (self.useCacheArray) {
                                    if (self.parallelArray.count  == self.cacheArraySize) {
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
                                        self.eachExtractedCVImage = (__bridge CVImageBufferRef)[self.parallelArray[0] valueForKey:@"CVImage"];
                                        CMTime thisPresentation = [[self.parallelArray[0] valueForKey:@"presentationTimeStamp"] CMTimeValue];
                                        CMTime thisDuration = [[self.parallelArray[0] valueForKey:@"duration"] CMTimeValue];
                                        VTEncodeInfoFlags flags;
                                        OSStatus statusCode;
                                        //////////////////
                                        if (self.useOnlyDurations) {
                                            if (!self.keepKeyFrameSigns) {
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,thisDuration,NULL, NULL, &flags);
                                            } else {
                                                CFDictionaryRef frameProperties= NULL;
                                                const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                                const void *values[1] = { kCFBooleanTrue };
                                                frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                             self.eachExtractedCVImage,
                                                                                             self.currCacheStartPresentation,
                                                                                             thisDuration,
                                                                                             frameProperties, NULL, &flags);
                                                CFRelease(frameProperties);
                                            }
                                            
                                            
                                            
                                            
                                            if (statusCode != noErr) {
                                                
                                                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                                CFRelease(sampleBuffer);
                                                sampleBuffer = NULL;
                                                //because used CFRetain before
                                                CFRelease(imageBuffer);
                                                imageBuffer = NULL;
                                                self.eachExtractedCVImage = NULL;
                                                
                                                
                                                NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                                VTCompressionSessionInvalidate(self.compressionSession);
                                                CFRelease(self.compressionSession);
                                                self.compressionSession = NULL;
                                                return;
                                            }
                                            self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                                        } else {
                                            if (!self.keepKeyFrameSigns) {
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                             self.eachExtractedCVImage,
                                                                                             thisPresentation,
                                                                                             thisDuration,
                                                                                             NULL, NULL, &flags);
                                            } else {
                                                CFDictionaryRef frameProperties= NULL;
                                                const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                                const void *values[1] = { kCFBooleanTrue };
                                                frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                             self.eachExtractedCVImage,
                                                                                             thisPresentation,
                                                                                             thisDuration,
                                                                                             frameProperties, NULL, &flags);
                                                CFRelease(frameProperties);
                                            }
                                            
                                            
                                            
                                            ////根据需要保留一份缓存,因为有multi Round Filter可能会使用到上次的结果
                                            if (self.applyFilter) {
                                                if (self.enablePreviousResultsBuffers) {
                                                    if (self.previousResultsBuffers.count == self.previousResultsBuffersCapacity) {
                                                        CVPixelBufferRelease((__bridge CVPixelBufferRef)(self.previousResultsBuffers[0]));
                                                        self.previousResultsBuffers[0] =[NSNull null];
                                                        [self.previousResultsBuffers removeObjectAtIndex:0];
                                                        CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                                    } else {
                                                        CVPixelBufferRef tempCVPixelBuff;
                                                        tempCVPixelBuff = copyCVPixelBufferToBufferPoolGeneratedBuffer(self.eachExtractedCVImage, self.pixelBufferPool);
                                                        [self.previousResultsBuffers addObject:(__bridge id)(tempCVPixelBuff)];
                                                        tempCVPixelBuff = NULL;
                                                    }
                                                }
                                            }
                                            
                                            
                                            
                                            if (statusCode != noErr) {
                                                
                                                
                                                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                                CFRelease(sampleBuffer);
                                                sampleBuffer = NULL;
                                                //because used CFRetain before
                                                CFRelease(imageBuffer);
                                                imageBuffer = NULL;
                                                self.eachExtractedCVImage = NULL;
                                                
                                                
                                                NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                                VTCompressionSessionInvalidate(self.compressionSession);
                                                CFRelease(self.compressionSession);
                                                self.compressionSession = NULL;
                                                return;
                                            }
                                        }
                                        //////////////////
                                        
                                        
                                       
                                        
                                        ////从排序队列中移除，然后
                                        ////释放 decoder.eachModifiedCVImage
                                        ////如果应用过filter那么 必须真正释放 因为 filter会复制一份原始的被video tool box callback owner的imageBuffer
                                        ////被复制出来的 需要我们自己释放CVPixelBufferRelease(decoder.eachModifiedCVImage);
                                        ////we should not release CVImageBufferRef imageBuffer here when without applyFilter,
                                        ////because when without applyFilter, the imageBuffer did not get copyed by us,
                                        ////it is ownered by video tool box  callback
                                        if (self.applyFilter) {
                                            CVPixelBufferRelease(self.eachExtractedCVImage);
                                            self.eachExtractedCVImage = NULL;
                                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                            self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                            CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                            
                                        } else {
                                            self.eachExtractedCVImage = NULL;
                                        }
                                        
                                        self.parallelArray[0] = [NSNull null];
                                        [self.parallelArray removeObjectAtIndex:0];
                                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                                        [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                        [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                        [parallel setValue:(__bridge id)imageBuffer forKey:@"CVImage"];
                                        [self.parallelArray addObject:parallel];
                                        
                                        
                                        
                                        
                                    } else {
                                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                                        [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                        [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                        [parallel setValue:(__bridge id)imageBuffer forKey:@"CVImage"];
                                        [self.parallelArray addObject:parallel];
                                    }
                                    
                                } else {
                                    
                                    //// 这里直接把imageBuffer传给comp
                                    //// presentationTimeStamp 不使用
                                    //// 使用duration 计算新的　presentationTimeStamp
                                    //// 注意在外面的Flag设置
                                    VTEncodeInfoFlags flags;
                                    OSStatus statusCode;
                                    if (self.useOnlyDurations) {
                                        if (!self.keepKeyFrameSigns) {
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,frameDuration,NULL, NULL, &flags);
                                            
                                        } else {
                                            CFDictionaryRef frameProperties= NULL;
                                            const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                            const void *values[1] = { kCFBooleanTrue };
                                            frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                         self.eachExtractedCVImage,
                                                                                         self.currCacheStartPresentation,
                                                                                         frameDuration,
                                                                                         frameProperties, NULL, &flags);
                                            CFRelease(frameProperties);
                                        }
                                        
                                        
                                        ////根据需要保留一份缓存,因为有multi Round Filter可能会使用到上次的结果
                                        if (self.applyFilter) {
                                            if (self.enablePreviousResultsBuffers) {
                                                if (self.previousResultsBuffers.count == self.previousResultsBuffersCapacity) {
                                                    CVPixelBufferRelease((__bridge CVPixelBufferRef)(self.previousResultsBuffers[0]));
                                                    self.previousResultsBuffers[0] =[NSNull null];
                                                    [self.previousResultsBuffers removeObjectAtIndex:0];
                                                    CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                                } else {
                                                    CVPixelBufferRef tempCVPixelBuff;
                                                    tempCVPixelBuff = copyCVPixelBufferToBufferPoolGeneratedBuffer(self.eachExtractedCVImage, self.pixelBufferPool);
                                                    [self.previousResultsBuffers addObject:(__bridge id)(tempCVPixelBuff)];
                                                    tempCVPixelBuff = NULL;
                                                }
                                            }
                                        }
                                        
                                        
                                        
                                        
                                        if (self.applyFilter) {
                                            CVPixelBufferRelease(self.eachExtractedCVImage);
                                            self.eachExtractedCVImage = NULL;
                                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                            self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                            CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                            
                                        } else {
                                            self.eachExtractedCVImage = NULL;
                                        }
                                        
                                        
                                        if (statusCode != noErr) {
                                            
                                            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                                            //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                            CFRelease(sampleBuffer);
                                            sampleBuffer = NULL;
                                            //because used CFRetain before
                                            CFRelease(imageBuffer);
                                            imageBuffer = NULL;
                                            self.eachExtractedCVImage = NULL;
                                            
                                            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                            VTCompressionSessionInvalidate(self.compressionSession);
                                            CFRelease(self.compressionSession);
                                            self.compressionSession = NULL;
                                            return;
                                        }
                                        self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,frameDuration);
                                    } else {
                                        
                                        if (!self.keepKeyFrameSigns) {
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                         self.eachExtractedCVImage,
                                                                                         presentationTimeStamp,
                                                                                         frameDuration,
                                                                                         NULL, NULL, &flags);
                                        } else {
                                            CFDictionaryRef frameProperties= NULL;
                                            const void *keys[1] = { kVTEncodeFrameOptionKey_ForceKeyFrame };
                                            const void *values[1] = { kCFBooleanTrue };
                                            frameProperties = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                                         self.eachExtractedCVImage,
                                                                                         presentationTimeStamp,
                                                                                         frameDuration,
                                                                                         frameProperties, NULL, &flags);
                                            CFRelease(frameProperties);
                                        }
                                        
                                        if (self.applyFilter) {
                                            CVPixelBufferRelease(self.eachExtractedCVImage);
                                            self.eachExtractedCVImage = NULL;
                                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                            self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                            CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                            
                                        } else {
                                            self.eachExtractedCVImage = NULL;
                                        }
                                        
                                        if (statusCode != noErr) {
                                            
                                            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                                            //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                            CFRelease(sampleBuffer);
                                            sampleBuffer = NULL;
                                            //because used CFRetain before
                                            CFRelease(imageBuffer);
                                            imageBuffer = NULL;
                                            self.eachExtractedCVImage = NULL;
                                            
                                            
                                            
                                            
                                            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                            VTCompressionSessionInvalidate(self.compressionSession);
                                            CFRelease(self.compressionSession);
                                            self.compressionSession = NULL;
                                            return;
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
                            } else {
                                self.currKeyFrameIndicator = NO;
                                if (ki==0) {
                                    ////第一frame  必须是IFRAME
                                    continue;
                                } else {
                                    ////
                                    if (self.useCacheArray) {
                                        if (self.parallelArray.count  == self.cacheArraySize) {
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
                                            self.eachExtractedCVImage = (__bridge CVImageBufferRef)[self.parallelArray[0] valueForKey:@"CVImage"];
                                            CMTime thisPresentation = [[self.parallelArray[0] valueForKey:@"presentationTimeStamp"] CMTimeValue];
                                            CMTime thisDuration = [[self.parallelArray[0] valueForKey:@"duration"] CMTimeValue];
                                            VTEncodeInfoFlags flags;
                                            OSStatus statusCode;
                                            if (self.useOnlyDurations) {
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,thisDuration,NULL, NULL, &flags);
                                                self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                                            } else {
                                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,thisPresentation,thisDuration,NULL, NULL, &flags);
                                            }
                                            if (statusCode != noErr) {
                                                
                                                
                                                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                                                //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                                CFRelease(sampleBuffer);
                                                sampleBuffer = NULL;
                                                //because used CFRetain before
                                                CFRelease(imageBuffer);
                                                imageBuffer = NULL;
                                                self.eachExtractedCVImage = NULL;
                                                
                                                
                                                
                                                NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                                VTCompressionSessionInvalidate(self.compressionSession);
                                                CFRelease(self.compressionSession);
                                                self.compressionSession = NULL;
                                                return;
                                            }
                                            
                                            
                                            if (self.applyFilter) {
                                                CVPixelBufferRelease(self.eachExtractedCVImage);
                                                self.eachExtractedCVImage = NULL;
                                                self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                                self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                                CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                                
                                            } else {
                                                self.eachExtractedCVImage = NULL;
                                            }
                                            
                                            self.parallelArray[0] = [NSNull null];
                                            
                                            [self.parallelArray removeObjectAtIndex:0];
                                            NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                                            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                            [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                            [parallel setValue:(__bridge id)imageBuffer forKey:@"CVImage"];
                                            [self.parallelArray addObject:parallel];
                                            
                                        } else {
                                            NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                                            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                            [parallel setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                            [parallel setValue:(__bridge id)imageBuffer forKey:@"CVImage"];
                                            [self.parallelArray addObject:parallel];
                                        }
                                    } else {
                                        //// 这里直接把imageBuffer传给comp
                                        //// presentationTimeStamp 不使用
                                        //// 使用duration 计算新的　presentationTimeStamp
                                        //// 注意在外面的Flag设置
                                        VTEncodeInfoFlags flags;
                                        OSStatus statusCode;
                                        if (self.useOnlyDurations) {
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,frameDuration,NULL, NULL, &flags);
                                            self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,frameDuration);
                                        } else {
                                            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,presentationTimeStamp,frameDuration,NULL, NULL, &flags);
                                        }
                                        if (statusCode != noErr) {

                                            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                                            //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                                            CFRelease(sampleBuffer);
                                            sampleBuffer = NULL;
                                            //because used CFRetain before
                                            CFRelease(imageBuffer);
                                            imageBuffer = NULL;
                                            self.eachExtractedCVImage = NULL;
                                            
                                            NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                                            VTCompressionSessionInvalidate(self.compressionSession);
                                            CFRelease(self.compressionSession);
                                            
                                            
                                            self.compressionSession = NULL;
                                            
                                            return;
                                        }
                                        
                                        
                                        if (self.applyFilter) {
                                            CVPixelBufferRelease(self.eachExtractedCVImage);
                                            self.eachExtractedCVImage = NULL;
                                            self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                                            self.CVPBRefOutput.outputPixelBufferRef = NULL;
                                            CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                                            
                                        } else {
                                            self.eachExtractedCVImage = NULL;
                                        }
                                        
                                    }
                                    ////
                                }
                            }
                        }
                        ////
                        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                        //The client is responsible for calling CFRelease on the returned CMSampleBuffer object
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        //because used CFRetain before
                        CFRelease(imageBuffer);
                        imageBuffer = NULL;
                        self.eachExtractedCVImage = NULL;
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
                        ////VTDecodeInfoFlags flagOut = 0;
                        ////NSNumber * KF = [NSNumber numberWithBool:isIFrame];
                        ////void * sourceFrameRefCon = (__bridge void*)KF;
                        if (isIFrame) {
                            self.currKeyFrameIndicator = YES;
                            if (self.newSessionEachKeyFrame) {
                                self.decompressionVideoFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                                VTDecompressionSessionFinishDelayedFrames(self.decompressionSession);
                                VTDecompressionSessionWaitForAsynchronousFrames(self.decompressionSession);
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
                        for (int ki=0; ki < (int)numOfsamplesInSampleBuffer; ki++) {
                            if (isH264IFrame(sampleBuffer, ki)) {
                                self.currKeyFrameIndicator = YES;
                            } else {
                                self.currKeyFrameIndicator = NO;
                            }
                        }
                        ////
                        OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(self.decompressionSession,
                                                                                  sampleBuffer,
                                                                                  flags,
                                                                                  NULL,////sourceFrameRefCon,
                                                                                  NULL////&flagOut
                                                                                  );
                        
                        

                        
                        
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
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        //because used CFRetain before
                        NSLog(@"impossible!!!!");
                    }
                    
                }
            } else {
                if (self.reader.status == AVAssetReaderStatusFailed)
                {
                    NSError *failureError = self.reader.error;
                    NSLog(@"failureError:%@",failureError.description);
                    if (sampleBuffer) {
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                    }
                    [self.reader cancelReading];
                    break;
                }
                else
                {
                    done = YES;
                    if (sampleBuffer) {
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                    }
                    [self.reader cancelReading];
                    NSLog(@"reader ended:");
                    break;
                }
            }
            
        }
        
    }
    ////处理VT 队列中的剩余
    @autoreleasepool {
        VTDecompressionSessionFinishDelayedFrames(self.decompressionSession);
        VTDecompressionSessionWaitForAsynchronousFrames(self.decompressionSession);
        VTDecompressionSessionInvalidate(self.decompressionSession);
        if (self.decompressionSession) {
            NSLog(@"self.decompressionSession:%@",self.decompressionSession);
            /* Block until our callback has been called with the last frame. */
            CFRelease(self.decompressionSession);
            self.decompressionSession = NULL;
        }
        
        
        
        self.readerOutput = NULL;
        self.readerAsset = NULL;
        self.reader = NULL;
        
        
        NSLog(@"self.parallelArray = %@",self.parallelArray);
        
        if (self.useCacheArray) {
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
            ////处理排序缓存的尾剩余
            for (int i =0; i<self.parallelArray.count; i++) {
                
                
                self.eachExtractedCVImage = (__bridge CVImageBufferRef)[self.parallelArray[i] valueForKey:@"CVImage"];
                CMTime thisPresentation = [[self.parallelArray[i] valueForKey:@"presentationTimeStamp"] CMTimeValue];
                CMTime thisDuration = [[self.parallelArray[i] valueForKey:@"duration"] CMTimeValue];
                VTEncodeInfoFlags flags;
                OSStatus statusCode;
                if (self.useOnlyDurations) {
                    statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,self.currCacheStartPresentation,thisDuration,NULL, NULL, &flags);
                    self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                } else {
                    
                    statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,self.eachExtractedCVImage,thisPresentation,thisDuration,NULL, NULL, &flags);
                }
                
                
                
                ////we should not release CVImageBufferRef imageBuffer here when without applyFilter,
                ////because when without applyFilter, the imageBuffer did not get copyed by us,
                ////it is ownered by video tool box  callback
                if (self.applyFilter) {
                    CVPixelBufferRelease(self.eachExtractedCVImage);
                    self.eachExtractedCVImage = NULL;
                    self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                    self.CVPBRefOutput.outputPixelBufferRef = NULL;
                    CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                    self.parallelArray[i] = [NSNull null];
                } else {
                    self.eachExtractedCVImage = NULL;
                    self.parallelArray[i] = [NSNull null];
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
    ////清除self.previousResultsBuffers
    if (self.applyFilter) {
        if (self.enablePreviousResultsBuffers) {
            for (int i = 0; i < self.previousResultsBuffers.count; i++) {
                if (self.previousResultsBuffers[i]) {
                    CVPixelBufferRelease((__bridge CVPixelBufferRef)(self.previousResultsBuffers[i]));
                    self.previousResultsBuffers[i] = [NSNull null];
                }
            }
            self.previousResultsBuffers = NULL;
        }
        
    }
    

    
    self.parallelArray = NULL;
    self.decompressionFinished =YES;
    
}
////checked
-(void) makeFinalOutputFile
{
    @autoreleasepool {
        while (!self.decompressionFinished) {
            NSLog(@"self.decompressionFinished:%d",self.decompressionFinished);
            NSLog(@"self.compressionSourceSeq:%d",self.compressionSourceSeq);
            NSLog(@"self.goodSamCounts:%d",self.goodSamCounts);
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        if (self.decompressionFinished) {
            VTCompressionSessionCompleteFrames(self.compressionSession, kCMTimeInvalid);
            VTCompressionSessionInvalidate(self.compressionSession);
            CFRelease(self.compressionSession);
            
            
            
            
            self.compressionSession = NULL;
            [self.writerInput markAsFinished];
            [self.writer endSessionAtSourceTime:self.endSessionAtSourceTime];
            self.endSessionAtSourceTime = kCMTimeZero;
            
            
            
            
        }
        
        
        __block dispatch_semaphore_t semaCanReturn = dispatch_semaphore_create(0);

        
        
        
        
        
        [self.writer finishWritingWithCompletionHandler:^{
            @autoreleasepool {
                self.writerInput =NULL;
                self.writer = NULL;
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
                if (self.enableProgressIndication) {
                    self.progressIndication = 1.0;
                }
                
                self.recompressionStartTime = NULL;
                self.recompressionEndTime = NULL;
                self.compressionFinished = YES;
                
                if (self.applyFilter) {
                    

                    
                    CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
                    CVPixelBufferPoolRelease(self.pixelBufferPool);
                    self.pixelBufferPool = NULL;
                    self.CVPBRefInput.newInputCVPixelBufferRef = NULL;
                    self.CVPBRefOutput.outputPixelBufferRef = NULL;
                    self.CVPBRefInput = NULL;
                    self.CVPBRefInputAux1 = NULL;
                    self.initedFilter = NULL;
                    self.terminatedFilter = NULL;
                    self.CVPBRefOutput = NULL;

                    
                }

                
            }
            
            if (self.SYNC) {
                dispatch_semaphore_signal(semaCanReturn);
            }
            
        }];
        
        if (self.SYNC) {
            while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            
        }
        
    }

}


////
-(void)makeRecomp
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long int date = (long long int)time;
    self.recompressionStartTime = [NSDate dateWithTimeIntervalSince1970:date];
    
    
    [self makeSourceVideoPathsAndURLsReady];
    
    [self makeReaderReadyAndStart];
    [self makeWriterReadyAndStart];
    
    if (self.applyFilter) {
        
        ////
        if (self.terminatedFilter) {
            
        } else {
            self.terminatedFilter = self.initedFilter;
        }
        
        if (self.enablePreviousResultsBuffers) {
            self.previousResultsBuffers = [[NSMutableArray alloc] init];
        }
        
        
        
        self.pixelBufferPool = makeCVPixelBufferPool(self.minimumBufferCount, self.maximumBufferAge, self.pixelBufferFormatType, self.sourceVideoTrack.naturalSize.width, self.sourceVideoTrack.naturalSize.height);
        
        self.CVPBRefInput = [[GPUImageCVPixelBufferRefInput alloc] init];
        
        if ([self.initedFilter.filterName isEqualToString:@"Sticking"]) {
            self.CVPBRefInputAux1 = [[GPUImageCVPixelBufferRefInput alloc] init];
            [self.CVPBRefInputAux1 addTarget:self.initedFilter atTextureLocation:1];
        }
        
        if ([self.initedFilter.filterName isEqualToString:@"Julia"]) {
            self.estimatedSourceTotalFramesCount = self.sourceVideoTrack.nominalFrameRate * self.readerAsset.duration.value / self.readerAsset.duration.timescale;
        }
        
        if ([self.initedFilter.filterName isEqualToString:@"ZW"]) {
            self.estimatedSourceTotalFramesCount = self.sourceVideoTrack.nominalFrameRate * self.readerAsset.duration.value / self.readerAsset.duration.timescale;
        }
        
        [self.CVPBRefInput addTarget:self.initedFilter atTextureLocation:0];
        self.CVPBRefOutput = [[GPUImageCVPixelBufferRefOutput alloc] initWithSize:self.sourceVideoTrack.naturalSize];
        self.CVPBRefOutput.pixelBufferPool = self.pixelBufferPool;
        [self.terminatedFilter addTarget:self.CVPBRefOutput];
    }
    
    
    
    [self makeVTCompressionSession];
    [self makeVTSessionPropertiesReadyAndStart];
    [self makeDecomp];
    [self makeFinalOutputFile];
    
    
    
}




@end