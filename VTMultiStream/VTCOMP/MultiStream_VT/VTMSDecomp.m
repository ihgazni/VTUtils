//
//  VTMSDecomp.m
//
//  Created by dli on 3/12/16.
//  Copyright © 2016 YesView. All rights reserved.
//




#import "VTMSDecomp.h"

////C函数的声明和实现放在类外面
void eachFrameCallbackOfMSDecomp(void *decompressionOutputRefCon,void *sourceFrameRefCon,OSStatus status,VTDecodeInfoFlags infoFlags,CVImageBufferRef imageBuffer,CMTime presentationTimeStamp,CMTime duration);
//// decompress process each frame call back,cacheAlreadyFilledCount+1
void eachFrameCallbackOfMSDecomp(void *decompressionOutputRefCon,void *sourceFrameRefCon,OSStatus status,VTDecodeInfoFlags infoFlags,CVImageBufferRef imageBuffer,CMTime presentationTimeStamp,CMTime duration)
{
    @autoreleasepool {
        ////指的是VTMSDecomp本身
        VTMSDecomp *decoder = (__bridge VTMSDecomp *)decompressionOutputRefCon;
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
        ////当前版本不使用传入的sourceFrameRefCon
        sourceFrameRefCon = NULL;
        ////CVImageBufferRef imageBufferForApplyFilter;
        ////进度指示器
        if (decoder.enableProgressIndication) {
            decoder.currentIndication = presentationTimeStamp.value * 1.0f / presentationTimeStamp.timescale;
            decoder.progressIndication = decoder.currentIndication / decoder.totalIndication;
            
        }
        ////decoder.eachExtractedCVImage 存储原始的被video tool box callback owner的imageBuffer
        ////针对每条流的filter
        if (decoder.applyFilter) {
            decoder.CVPBRefInput.newInputCVPixelBufferRef = NULL;
            decoder.CVPBRefInput.newInputCVPixelBufferRef = imageBuffer;
            ////Sticking
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
           ////Julia
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
           ////ZW
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
            ////3D
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
        ////status
        if (status != noErr)
        {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Decompressed error: %@", error);
        } else {
            ////如何处理负的 CMTime
            if (decoder.removeNegativeCMTime == YES) {
                if (presentationTimeStamp.value < 0 || presentationTimeStamp.timescale < 0 ) {
                    return;
                }
                if (duration.value < 0 || duration.timescale < 0) {
                    return;
                }
            } else {
                
            }
            ////
            CVPixelBufferLockBaseAddress(decoder.eachExtractedCVImage,0);
            ////使用针对单流的排序缓存
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
                    ////把decoder.eachModifiedCVImage相关信息 交给 MSBuffer
                    NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                    ////不使用presentation
                    if (decoder.useOnlyDurations) {
                        ////{
                        ////    imageBuffer : decoder.eachModifiedCVImage
                        ////    presentationTimeStamp : decoder.currCacheStartPresentation
                        ////    duration : thisDuration
                        ////}
                        [frameInStream setValue:(__bridge id)decoder.eachModifiedCVImage forKey:@"imageBuffer"];
                        [frameInStream setValue:[NSValue valueWithCMTime:decoder.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                        [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                        [decoder.MSBuffers[decoder.streamNumber] addObject:frameInStream];
                        ////dispatch_semaphore_signal(decoder.MSCanCompSema);
                        decoder.currCacheStartPresentation = CMTimeAdd(decoder.currCacheStartPresentation,thisDuration);
                    } else {
                        ////{
                        ////    imageBuffer : decoder.eachModifiedCVImage
                        ////    presentationTimeStamp : thisPresentation
                        ////    duration : thisDuration
                        ////}
                        [frameInStream setValue:(__bridge id)decoder.eachModifiedCVImage forKey:@"imageBuffer"];
                        [frameInStream setValue:[NSValue valueWithCMTime:thisPresentation] forKey:@"presentationTimeStamp"];
                        [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                        [decoder.MSBuffers[decoder.streamNumber] addObject:frameInStream];
                        ////dispatch_semaphore_signal(decoder.MSCanCompSema);
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
                    ////针对单流的FIFO队列移除第一个
                    decoder.parallelArray[0] = [NSNull null];
                    [decoder.parallelArray removeObjectAtIndex:0];
                    ////从排序队列中移除，然后
                    ////释放 decoder.eachModifiedCVImage
                    ////如果应用过filter那么 必须真正释放 因为 filter会复制一份原始的
                    ////被video tool box callback owner的imageBuffer
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
                NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                if (decoder.useOnlyDurations) {
                    ////{
                    ////    imageBuffer : decoder.eachExtractedCVImage
                    ////    presentationTimeStamp : decoder.currCacheStartPresentation
                    ////    duration : duration
                    ////}
                    [frameInStream setValue:(__bridge id)decoder.eachExtractedCVImage forKey:@"imageBuffer"];
                    [frameInStream setValue:[NSValue valueWithCMTime:decoder.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                    [frameInStream setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
                    [decoder.MSBuffers[decoder.streamNumber] addObject:frameInStream];
                    ////dispatch_semaphore_signal(decoder.MSCanCompSema);
                    decoder.currCacheStartPresentation = CMTimeAdd(decoder.currCacheStartPresentation,duration);
                } else {
                    ////{
                    ////    imageBuffer : decoder.eachExtractedCVImage
                    ////    presentationTimeStamp : presentationTimeStamp
                    ////    duration : duration
                    ////}
                    [frameInStream setValue:(__bridge id)decoder.eachExtractedCVImage forKey:@"imageBuffer"];
                    [frameInStream setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                    [frameInStream setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
                    [decoder.MSBuffers[decoder.streamNumber] addObject:frameInStream];
                    ////dispatch_semaphore_signal(decoder.MSCanCompSema);
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


/////----------

@implementation VTMSDecomp
//// p4sed
-(void) readMe
{
    NSLog(@"=====part1:how to use:=====");
    NSString * part1 = @"\
    VTMSDecomp  * stream1 = [[VTMSDecomp alloc] init];\
    {\
        [stream1 resetParameters];\
        stream1.sourceVideoURL = videoOverlaySrcURL1;\
        stream1.useOnlyDurations = NO;\
        stream1.useCacheArray = YES;\
        stream1.cacheArraySize = 2;\
        stream1.constructDestinationImageBufferAttributesFromKeyValue = YES;\
        stream1.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_32BGRA;\
    }\
    ";
    NSLog(@"%@",part1);
    NSLog(@"=====part1:how to use:=====");
}
//// p4sed
-(void) resetParameters
{
    ////
    self.MSCanDecompSema =NULL;
    self.maxFramesNumberOfEachStream = 6;
    
    ////初始化源视频文件的路径 URL 等参数
    self.sourceVideoURL = NULL;
    self.sourceVideoPath = NULL;
    self.sourceVideoFilename = NULL;
    self.sourceVideoRelativeDir = NULL;
    ////初始化reader并开始，存储width height preferedTransform给完成重压缩后的最后阶段使用
    self.reader = NULL;
    self.readerAsset = NULL;
    self.whichTrack = 0;
    self.sourceVideoTrack = NULL;
    self.estimatedSourceTotalFramesCount = 0.0;
    self.preferedTransform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    self.width = 0.0;
    self.height = 0.0;
    self.applyOOBPT = NO;
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

    self.currKeyFrameIndicator = NO;
    self.newSessionEachKeyFrame = NO;
    ////
    self.sortImagesAfterDecompression = YES;
    self.currCacheStartPresentation=kCMTimeZero;
    self.useOnlyDurations = YES;
    self.decompressionStarted = NO;
    self.decompressionFinished = NO;
    ////

   

    ////
    self.keepKeyFrameSigns = NO;
    ////
    self.enableProgressIndication = NO;
    self.progressIndicationTimerInterval = 1.0;
    self.progressIndication = 0.0;
    self.totalIndication = 0.0;
    self.currentIndication = 0.0;
    
}
////
-(void)makeMSSemaReady
{
    self.MSCanDecompSema =  dispatch_semaphore_create(self.maxFramesNumberOfEachStream);
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
-(void) makeReaderReadyAndStart
{
    @autoreleasepool {
        if (self.applyOOBPT) {
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
        self.readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:self.sourceVideoTrack outputSettings:nil];
        self.readerOutput.alwaysCopiesSampleData = self.readerOutputAlwaysCopiesSampleData;
        ////randomAccess
        ////resetForReadingTimeRanges:
        [self.readerOutput markConfigurationAsFinal];
        [self.reader addOutput:self.readerOutput];
        [self.reader startReading];
    }
}
//// makeVTDecompressionSession
-(void) makeVTDecompressionSession
{
    @autoreleasepool {
        self.decompressionSession = NULL;
        self.decompressionEachFrameCallback = eachFrameCallbackOfMSDecomp;
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = self.decompressionEachFrameCallback;
        callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
        CFNumberRef cfn1 = NULL;
        if (self.constructDestinationImageBufferAttributesFromKeyValue) {
            self.destinationImageBufferAttributes = NULL;
            const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
            uint32_t v = self.destinationImageBufferKCVPixelFormatType;
            cfn1 = CFNumberCreate(NULL, kCFNumberSInt32Type, &v);
            const void *values[] = { cfn1 };
            self.destinationImageBufferAttributes = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        } else {
            if (self.destinationImageBufferAttributes != NULL) {
            } else {
                self.destinationImageBufferAttributes = NULL;
                const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
                uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
                cfn1 = CFNumberCreate(NULL, kCFNumberSInt32Type, &v);
                const void *values[] = { cfn1 };
                self.destinationImageBufferAttributes = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            }
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
        OSStatus status =  VTDecompressionSessionCreate(kCFAllocatorDefault,self.decompressionVideoFormatDescription,self.decompressionDecodeSpecification,self.destinationImageBufferAttributes,&callBackRecord,&_decompressionSession);
        NSLog(@"Video Decompression Session Create: \t %@", (status == noErr) ? @"successful!" : @"failed...");
        
        callBackRecord.decompressionOutputCallback = NULL;
        callBackRecord.decompressionOutputRefCon = NULL;
        
        
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
////
-(void)streamReady
{
    [self makeMSSemaReady];
    [self makeSourceVideoPathsAndURLsReady];
    [self makeReaderReadyAndStart];

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
    
    
}

//// decompress process while circle
-(void) makeDecomp
{
    self.decompressionStarted = YES;
    BOOL done = NO;
    self.goodSamCounts = 0;
    self.origGoodSamCounts = 0;
    BOOL firstGoodIFrame = NO;
    if (self.useCacheArray) {
        self.parallelArray = [[NSMutableArray  alloc] init];
    }
    
    
    
    ////这个流程繁杂，但是第一Frame的正确性又是必须的，所以以后再简化
    while (!firstGoodIFrame) {
        
        
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 1000000);
        dispatch_semaphore_wait(self.MSCanDecompSema,timeout);
        
        
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
                                        NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                                        if (self.useOnlyDurations) {
                                            [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                                            [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                            ////dispatch_semaphore_signal(self.MSCanCompSema);
                                            
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
                                            
                                            [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:thisPresentation] forKey:@"presentationTimeStamp"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                                            [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                            ////dispatch_semaphore_signal(self.MSCanCompSema);
                                            
                                            
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
                                    NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                                    if (self.useOnlyDurations) {
                                        
                                        [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                        [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                                        [frameInStream setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                        [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                        ////dispatch_semaphore_signal(self.MSCanCompSema);
                                        
                                        
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
                                        
                                        
                                        
                                        self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,frameDuration);
                                    } else {
                                        [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                        [frameInStream setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                        [frameInStream setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                        [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                        ////dispatch_semaphore_signal(self.MSCanCompSema);
                                        
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
                                            
                                            NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                                            if (self.useOnlyDurations) {
                                                [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                                [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                                                [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                                                [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                                ////dispatch_semaphore_signal(self.MSCanCompSema);
                                                self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                                            } else {
                                                [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                                [frameInStream setValue:[NSValue valueWithCMTime:thisPresentation] forKey:@"presentationTimeStamp"];
                                                [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                                                [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                                ////dispatch_semaphore_signal(self.MSCanCompSema);
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
                                        NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                                        if (self.useOnlyDurations) {
                                            [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                            [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                            ////dispatch_semaphore_signal(self.MSCanCompSema);
                                            self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,frameDuration);
                                        } else {
                                            [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                            [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                            ////dispatch_semaphore_signal(self.MSCanCompSema);
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
    ////
    while (!done)
    {
        
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 10*1000*1000*1000);
        dispatch_semaphore_wait(self.MSCanDecompSema,timeout);
        ////

        
        
        
        @autoreleasepool {
            /////NSLog(@"decompress 开始处理缓存");
            CMSampleBufferRef sampleBuffer = [self.readerOutput copyNextSampleBuffer];
            NSLog(@"copy one in %@!!!!!",self);
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
                                        //////////////////
                                        NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                                        if (self.useOnlyDurations) {
                                            [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                                            [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                            ////dispatch_semaphore_signal(self.MSCanCompSema);
                                            self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                                        } else {
                                            [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:thisPresentation] forKey:@"presentationTimeStamp"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                                            [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                            ////dispatch_semaphore_signal(self.MSCanCompSema);
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
                                    NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                                    if (self.useOnlyDurations) {
                                        [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                        [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                                        [frameInStream setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                        [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                        ////dispatch_semaphore_signal(self.MSCanCompSema);
                                        
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
                                        
                                        self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,frameDuration);
                                    } else {
                                        [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                        [frameInStream setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                        [frameInStream setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                        [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                        ////dispatch_semaphore_signal(self.MSCanCompSema);
                                        
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
                                            
                                            NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                                            if (self.useOnlyDurations) {
                                                [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                                [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                                                [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                                                [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                                ////dispatch_semaphore_signal(self.MSCanCompSema);
                                                self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                                            } else {
                                                [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                                [frameInStream setValue:[NSValue valueWithCMTime:thisPresentation] forKey:@"presentationTimeStamp"];
                                                [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                                                [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                                ////dispatch_semaphore_signal(self.MSCanCompSema);
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
                                        ////
                                        NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                                        if (self.useOnlyDurations) {
                                            [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                            [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                            ////dispatch_semaphore_signal(self.MSCanCompSema);
                                            self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,frameDuration);
                                        } else {
                                            [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
                                            [frameInStream setValue:[NSValue valueWithCMTime:frameDuration] forKey:@"duration"];
                                            [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                                            ////dispatch_semaphore_signal(self.MSCanCompSema);
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
            
            
            
            
            
            for (int i =0; i<self.parallelArray.count; i++) {
                
                
                self.eachExtractedCVImage = (__bridge CVImageBufferRef)[self.parallelArray[i] valueForKey:@"CVImage"];
                CMTime thisPresentation = [[self.parallelArray[i] valueForKey:@"presentationTimeStamp"] CMTimeValue];
                CMTime thisDuration = [[self.parallelArray[i] valueForKey:@"duration"] CMTimeValue];
                ////
                NSMutableDictionary * frameInStream = [[NSMutableDictionary alloc] init];
                if (self.useOnlyDurations) {
                    [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                    [frameInStream setValue:[NSValue valueWithCMTime:self.currCacheStartPresentation] forKey:@"presentationTimeStamp"];
                    [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                    [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                    ////dispatch_semaphore_signal(self.MSCanCompSema);
                    self.currCacheStartPresentation = CMTimeAdd(self.currCacheStartPresentation,thisDuration);
                } else {
                    [frameInStream setValue:(__bridge id)self.eachExtractedCVImage forKey:@"imageBuffer"];
                    [frameInStream setValue:[NSValue valueWithCMTime:thisPresentation] forKey:@"presentationTimeStamp"];
                    [frameInStream setValue:[NSValue valueWithCMTime:thisDuration] forKey:@"duration"];
                    [self.MSBuffers[self.streamNumber] addObject:frameInStream];
                    ////dispatch_semaphore_signal(self.MSCanCompSema);
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
                
                
            }
            
        }
    }
    
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
    ////针对单独流的滤镜清理工作
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
    
    self.decompressionFinished =YES;
    
}



@end