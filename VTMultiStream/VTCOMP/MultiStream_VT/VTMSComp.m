//
//  VTMSComp.m
//  UView
//
//  Created by dli on 3/12/16.
//  Copyright © 2016 YesView. All rights reserved.
//




#import "VTMSComp.h"

////C函数的声明和实现放在类外面
void eachSampleBufferCallbackOfMSComp(void *outputCallbackRefCon,void *sourceFrameRefCon,OSStatus status,VTEncodeInfoFlags infoFlags,CMSampleBufferRef sampleBuffer);
//// compress process each samplebuffer callback
void eachSampleBufferCallbackOfMSComp(void *outputCallbackRefCon,void *sourceFrameRefCon,OSStatus status,VTEncodeInfoFlags infoFlags,CMSampleBufferRef sampleBuffer)
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
        
        VTMSComp * encoder;
        if(outputCallbackRefCon){
            encoder = (__bridge VTMSComp*)outputCallbackRefCon;
            
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
                    
                    
                    ////进度指示器
                    if (encoder.enableProgressIndication) {
                        encoder.currentIndication = pInfo[i].presentationTimeStamp.value * 1.0f / pInfo[i].presentationTimeStamp.timescale;
                        encoder.progressIndication = encoder.currentIndication / encoder.totalIndication;
                        
                    }
                    
                    
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


@implementation VTMSComp
//// p4sed
-(void) readMe
{
    NSLog(@"=====part1:how to use:=====");
    NSString * part1 = @"\
    VTMSComp * vtmsc = [[VTMSComp alloc] init];\
    {\
        [vtmsc resetParameters];\
        vtmsc.writerOutputURL = writerOutputURL;\
        vtmsc.writerOutputFileType = AVFileTypeQuickTimeMovie;\
        vtmsc.compressionSessionPropertiesConstructFromKeyValue =YES;\
        vtmsc.compressionAverageBitRate = 1280000;\
        vtmsc.deleteOutputDirBeforeWrite = YES;\
        vtmsc.writerShouldOptimizeForNetworkUse = YES;\
        vtmsc.compSessionWidth = 1280.0;\
        vtmsc.compSessionHeight = 720.0;\
        GPUImageMSAdd * MSAdd = [[GPUImageMSAdd  alloc] init];\
        vtmsc.initedFilter = MSAdd;\
        vtmsc.applyFilter  = YES;\
        vtmsc.SYNC = YES;\
        [vtmsc makeMSinit];\
        [vtmsc addDecompStream:stream1];\
        [vtmsc addDecompStream:stream2];\
        [vtmsc makeRecomp];\
    }\
    ";
    NSLog(@"%@",part1);
    NSLog(@"=====part1:how to use:=====");
}
//// p4sed
-(void) resetParameters
{

    
    ////
    self.maxStreamOfMSBuffers = 5;
    self.MSBuffers = NULL;
    self.streams = NULL;
    self.MSCanCompSema = NULL;
    self.VTRecompressProcessingConcurrentQueue = NULL;
    self.framesOfThisRound = NULL;
    ////
    
    
    
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
    
    ////
    self.compPresentationTimeStamp = kCMTimeZero;
    self.compDuration = kCMTimeZero;
    
    ////filter
    self.applyFilter = YES;
    self.filterNumber = 0;
    self.pixelBufferPool = NULL;
    self.minimumBufferCount = 1;
    self.maximumBufferAge = 10;
    self.pixelBufferFormatType = kCVPixelFormatType_32BGRA;
    ////this format is necessary for using openGL
    self.CVPBRefInputs = NULL;
    self.initedFilter = NULL;
    self.terminatedFilter = NULL;
    self.CVPBRefOutput = NULL;
    self.MSFilterDelegate = NULL;
    self.enablePreviousResultsBuffers = NO;
    self.previousResultsBuffersCapacity = 0;
    self.previousResultsBuffers = NULL;
    ////

    ////
    self.compSessionWidth = -1;
    self.compSessionHeight = -1;
    self.recompressionStartTime = NULL;
    ////

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
-(void)makeMSinit
{
    self.MSBuffers = [[NSMutableArray alloc] init];
    self.streams = [[NSMutableArray alloc] init];
    self.CVPBRefInputs = [[NSMutableArray alloc] init];
    self.MSCanCompSema = dispatch_semaphore_create(0);
    self.framesOfThisRound = [[NSMutableDictionary alloc] init];
    self.VTRecompressProcessingConcurrentQueue = dispatch_queue_create("VTRecompressProcessingConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
}
////


-(void)addDecompStream:(VTMSDecomp*)stream
{
    int currStreamCount = (int)self.MSBuffers.count;
    if (currStreamCount < self.maxStreamOfMSBuffers) {
        NSMutableArray * buffForEachStream = [[NSMutableArray alloc] init];
        stream.streamNumber = currStreamCount;
        stream.MSBuffers = self.MSBuffers;
        [self.streams addObject:stream];
        [self.MSBuffers addObject:buffForEachStream];
        [self.framesOfThisRound setValue:[NSNull null] forKey:[NSString stringWithFormat:@"%d",currStreamCount]];
        ////isKindOfClass:[NSNull class]
    } else {
        NSLog(@"maxStreamOfMSBuffers reached!!! cant be added");
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
            float CVPwidth = ((self.compSessionWidth>0)? self.compSessionWidth:1280.0);
            float CVPheight = ((self.compSessionHeight>0)? self.compSessionHeight:720.0);
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
        self.compressionEachSampleBufferCallback = eachSampleBufferCallbackOfMSComp;
        ////NSLog(@"self.compressionEncoderSpecification:%@",self.compressionEncoderSpecification);
        ////printVTEncoderList(NULL);
        OSStatus status = VTCompressionSessionCreate(NULL,
                                                     ((self.compSessionWidth>0)? self.compSessionWidth:1280.0),
                                                     ((self.compSessionHeight>0)? self.compSessionHeight:720.0),
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



////checked
-(void) makeFinalOutputFile
{
    
    @autoreleasepool {
        ////当所有流的解压确认已经完成,等待compressSession中残留的frame被压缩
        ////然后关闭compressSession
        {
            VTCompressionSessionCompleteFrames(self.compressionSession, kCMTimeInvalid);
            VTCompressionSessionInvalidate(self.compressionSession);
            CFRelease(self.compressionSession);

            self.compressionSession = NULL;
            [self.writerInput markAsFinished];
            [self.writer endSessionAtSourceTime:self.endSessionAtSourceTime];
            self.endSessionAtSourceTime = kCMTimeZero;
   
        }
        ////----------------dli-----------------
        ////接下来要完成的工作是清理整体滤镜
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
                    for (int i = 0; i<self.CVPBRefInputs.count; i++) {
                        GPUImageCVPixelBufferRefInput * CVPBRefInput = (GPUImageCVPixelBufferRefInput *)self.CVPBRefInputs[i];
                        CVPBRefInput.newInputCVPixelBufferRef = NULL;
                        self.CVPBRefInputs[i] = [NSNull null];
                    }
                    self.CVPBRefOutput.outputPixelBufferRef = NULL;
                    self.CVPBRefInputs = NULL;
                    self.initedFilter = NULL;
                    self.terminatedFilter = NULL;
                    self.CVPBRefOutput = NULL;

                    
                }
                
                BOOL sync = self.SYNC;

                for (int i = 0; i<self.streams.count; i++) {
                    VTMSDecomp * stream = (VTMSDecomp *)self.streams[i];
                    [stream resetParameters];
                }

                [self resetParameters];
                
                self.SYNC = sync;
                
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


////求所有stream的平均estimatedSourceTotalFramesCount
-(float) averageEstimatedSourceTotalFramesCount
{
    ////
    float total = 0.0;
    for (int i = 0; i<self.streams.count; i++) {
        VTMSDecomp * stream = (VTMSDecomp *)self.streams[i];
        float nominalFrameRate = stream.sourceVideoTrack.nominalFrameRate;
        float duration = stream.readerAsset.duration.value;
        float timescale = stream.readerAsset.duration.timescale;
        float estimatedSourceTotalFramesCount = nominalFrameRate * duration /timescale;
        total = total + estimatedSourceTotalFramesCount;
    }
    return(total/self.streams.count);
    
}


////求所有stream的平均frameDuration
-(CMTime) averageFrameDuration
{
    ////
    float total = 0.0;
    float totalTimeScale = 0.0;
    for (int i = 0; i<self.streams.count; i++) {
        VTMSDecomp * stream = (VTMSDecomp *)self.streams[i];
        float nominalFrameRate = stream.sourceVideoTrack.nominalFrameRate;
        float frameDuration = 1.0 / nominalFrameRate;
        total = total + frameDuration;
        totalTimeScale = totalTimeScale + stream.sourceVideoTrack.timeRange.duration.timescale;
    }
    CMTime rslt = CMTimeMakeWithSeconds(total/self.streams.count, (int)(totalTimeScale/self.streams.count));
    return(rslt);
    
}




////初始化整体滤镜,作用于所有流，用来合成流与流的
-(void) makeMSFilterReady
{
    ////初始化整体滤镜
    if (self.applyFilter) {
        ////
        if (self.terminatedFilter) {
            
        } else {
            self.terminatedFilter = self.initedFilter;
        }
        if (self.enablePreviousResultsBuffers) {
            self.previousResultsBuffers = [[NSMutableArray alloc] init];
        }
        self.pixelBufferPool = makeCVPixelBufferPool(self.minimumBufferCount, self.maximumBufferAge, self.pixelBufferFormatType, self.compSessionWidth, self.compSessionHeight);
        
        
        
        for (int i = 0; i<self.streams.count; i++) {
            GPUImageCVPixelBufferRefInput * CVPBRefInput = [[GPUImageCVPixelBufferRefInput alloc] init];
            [self.CVPBRefInputs addObject:CVPBRefInput];
        }
        
        if ([self.initedFilter.filterName isEqualToString:@"Sticking"]) {
            GPUImageCVPixelBufferRefInput * CVPBRefInputAux1 = (GPUImageCVPixelBufferRefInput *)self.CVPBRefInputs[1];
            [CVPBRefInputAux1 addTarget:self.initedFilter atTextureLocation:1];
        }
        
        if ([self.initedFilter.filterName isEqualToString:@"Julia"]) {
            self.estimatedSourceTotalFramesCount = [self averageEstimatedSourceTotalFramesCount];
        }
        
        if ([self.initedFilter.filterName isEqualToString:@"ZW"]) {
            self.estimatedSourceTotalFramesCount = [self averageEstimatedSourceTotalFramesCount];
        }
        
        
        for (int i = 0; i<self.streams.count; i++) {
            [(GPUImageCVPixelBufferRefInput *)self.CVPBRefInputs[i] addTarget:self.initedFilter atTextureLocation:i];
        }
        
        
        self.CVPBRefOutput = [[GPUImageCVPixelBufferRefOutput alloc] initWithSize:CGSizeMake(self.compSessionWidth, self.compSessionHeight)];
        self.CVPBRefOutput.pixelBufferPool = self.pixelBufferPool;
        [self.terminatedFilter addTarget:self.CVPBRefOutput];
    }
}


////是否所有流的解压已经完成
-(BOOL)allDecompStreamsFinished
{
    BOOL allFinished = YES;
    for (int i = 0; i<self.streams.count; i++) {
        VTMSDecomp * stream = (VTMSDecomp *)self.streams[i];
        if(stream.decompressionFinished){
            
        } else {
            allFinished = NO;
            break;
        }
        
    }
    return(allFinished);
}

-(BOOL)FIFOReadyForDraw
{
    BOOL allFinished = YES;
    for (int i = 0; i<self.MSBuffers.count; i++) {
        VTMSDecomp * stream = (VTMSDecomp *)self.streams[i];
        if(stream.decompressionFinished){
            
        } else {
            NSMutableArray * buffForEachStream = self.MSBuffers[i];
            int count = (int)buffForEachStream.count;
            if (count <=0) {
                allFinished = NO;
                break;
            }
        }
        
    }
    return(allFinished);
}

////从缓存中提取frame,合成，并处理处理压缩流程,
-(void) makeComp
{
    

    self.compDuration = [self averageFrameDuration];
    ////全部结束意味着所有Decomp已经完成
    ////还需要处理的frames都已经在MSBuffer里面了
    BOOL allDecompOK = [self allDecompStreamsFinished];
    ////如果没有全部结束
    while (!allDecompOK) {
        ////NSLog(@"self.MSBuffers:%@",self.MSBuffers);
        ////因为解压过程比这个过程快到大约 10 倍 ，所以应该从这个发signal
        /*
        while (dispatch_semaphore_wait(self.MSSema, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
        }
        //////
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 1000000);
        dispatch_semaphore_wait(self.MSSema,timeout);
        */
        

        
        ////收到一次信号,检查是否所有未完成流的第一列frame全部就位
        BOOL readyForDraw = [self FIFOReadyForDraw];
        if (readyForDraw) {
            CVPixelBufferRef eachExtractedCVImage = NULL;
            ////从MSBuffer中取出第一列，然后从MSBuffer中删除取出的
            if (self.applyFilter) {
                
                ////NSLog(@"self.CVPBRefInputs.count:%lu",(unsigned long)self.CVPBRefInputs.count);
                
                for (int i = 0; i<self.CVPBRefInputs.count; i++) {
                    GPUImageCVPixelBufferRefInput * CVPBRefInput = (GPUImageCVPixelBufferRefInput *)self.CVPBRefInputs[i];
                    CVPBRefInput.newInputCVPixelBufferRef = NULL;
                    NSMutableArray * buffForEachStream = self.MSBuffers[i];
                    
                    ////NSLog(@"buffForEachStream:%@ in stream:%d",buffForEachStream,i);
                    
                    if (buffForEachStream.count > 0) {
                        NSMutableDictionary * frameInStream = (NSMutableDictionary * )buffForEachStream[0];
                        ////NSLog(@"frameInStream:%@",frameInStream);
                        ////这里必须__bridge_retained 把所有权拿过来，否则CVPBRefInput.newInputCVPixelBufferRef
                        ////无法保证能HOLD住imageBuffer
                        CVPixelBufferRef imageBuffer = (__bridge_retained  CVPixelBufferRef)([frameInStream valueForKey:@"imageBuffer"]);
                        
                        CVPBRefInput.newInputCVPixelBufferRef = imageBuffer;
                        
                        self.MSBuffers[i][0] = [NSNull null];
                        [self.MSBuffers[i] removeObjectAtIndex:0];
                        ////NSLog(@"CVPBRefInput.newInputCVPixelBufferRef:%@",CVPBRefInput.newInputCVPixelBufferRef);
                    } else {
                        
                    }
                }
                
                
                ////NSLog(@"self.MSBuffers:%@",self.MSBuffers);

                
                ////特殊处理的滤镜添加到这里
         
                ////特殊处理的滤镜添加到这里
                
                for (int i = 0; i< self.CVPBRefInputs.count; i++) {
                    unsigned long  index = self.CVPBRefInputs.count - i -1;
                    GPUImageCVPixelBufferRefInput * CVPBRefInput = (GPUImageCVPixelBufferRefInput *)self.CVPBRefInputs[index];
                    [CVPBRefInput startProcessing];
                    
                   
                    
                }


                eachExtractedCVImage = self.CVPBRefOutput.outputPixelBufferRef;
                
                NSLog(@"eachExtractedCVImage:%@",eachExtractedCVImage);
                
            } else {
                ////多流无滤镜仅仅为了测试
                for (int i =0; i<self.MSBuffers.count; i++) {
                    NSMutableArray * buffForEachStream = self.MSBuffers[i];
                    if (buffForEachStream.count > 0) {
                        NSMutableDictionary * frameInStream = (NSMutableDictionary * )buffForEachStream[0];
                        eachExtractedCVImage = (__bridge CVPixelBufferRef)([frameInStream valueForKey:@"imageBuffer"]);
                        self.MSBuffers[i][0] = [NSNull null];
                        [self.MSBuffers[i] removeObjectAtIndex:0];
                    }
                }
                
                
                
            }
            
            

            
            ////VTencode Here
            CVPixelBufferLockBaseAddress(eachExtractedCVImage,0);
            VTEncodeInfoFlags flags;
            OSStatus statusCode;
            statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,eachExtractedCVImage,self.compPresentationTimeStamp,self.compDuration,NULL, NULL, &flags);
            if (statusCode != noErr) {
                NSLog(@"encoder VTCompressionSessionEncodeFrame failed %d", (int)statusCode);
                ////VTCompressionSessionInvalidate(self.compressionSession);
                ////CFRelease(self.compressionSession);
                ////self.compressionSession = NULL;
                ////return;
            }
            
            
            for (int i = 0; i<self.streams.count; i++) {
                NSMutableArray * buffForEachStream = self.MSBuffers[i];
                VTMSDecomp * stream = (VTMSDecomp *)self.streams[i];
                if (buffForEachStream.count < stream.maxFramesNumberOfEachStream) {
                    if (stream.decompressionStarted && stream.goodSamCounts>0) {
                        ////必须retain 否则会出现dispatch_semaphore_dispose问题,
                        ////原因不明
                        NSLog(@"%@you can decomp one:",stream.MSCanDecompSema);
                        CFRetain((__bridge CFTypeRef)(stream.MSCanDecompSema));
                        dispatch_semaphore_signal(stream.MSCanDecompSema);

                    }
                    
                }
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
                        tempCVPixelBuff = copyCVPixelBufferToBufferPoolGeneratedBuffer(eachExtractedCVImage, self.pixelBufferPool);
                        [self.previousResultsBuffers addObject:(__bridge id)(tempCVPixelBuff)];
                        tempCVPixelBuff = NULL;
                    }
                }
            }
            
            
            CVPixelBufferUnlockBaseAddress(eachExtractedCVImage, 0);
            
            ////
            ////we should not release CVImageBufferRef imageBuffer here when without applyFilter,
            ////because when without applyFilter, the imageBuffer did not get copyed by us,
            ////it is ownered by video tool box  callback
            if (self.applyFilter) {
               
                CVPixelBufferRelease(eachExtractedCVImage);
                for (int i = 0; i<self.CVPBRefInputs.count; i++) {
                    GPUImageCVPixelBufferRefInput * CVPBRefInput = (GPUImageCVPixelBufferRefInput *)self.CVPBRefInputs[i];
                    ////对应上面的__bridge_retain
                    CVPixelBufferRelease(CVPBRefInput.newInputCVPixelBufferRef);
                    ////下面这个原因不明，有时需要释放两次
                    ////if(CVPBRefInput.newInputCVPixelBufferRef){
                    ////    CVPixelBufferRelease(CVPBRefInput.newInputCVPixelBufferRef);
                    ////}
                    CVPBRefInput.newInputCVPixelBufferRef = NULL;
                }
                self.CVPBRefOutput.outputPixelBufferRef = NULL;
                CVPixelBufferPoolFlush(self.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);

            } else {
                
            }
            
            eachExtractedCVImage = NULL;
            ////VTencode Here
            self.compPresentationTimeStamp = CMTimeAdd(self.compPresentationTimeStamp,self.compDuration);
        } else {
            
        }
        allDecompOK = [self allDecompStreamsFinished];

    }
    
    [self makeFinalOutputFile];

    
    
}
////每条流进入ready状态
-(void) makeAllStreamReady
{
    float maxTotalIndication = 0.0;
    for (int i = 0; i<self.streams.count; i++) {
        VTMSDecomp * eachStream = (VTMSDecomp *)self.streams[i];
        [eachStream streamReady];
        if (self.enableProgressIndication) {
            float totalIndication  = eachStream.readerAsset.duration.value * 1.0f / eachStream.readerAsset.duration.timescale;
            maxTotalIndication = MAX(totalIndication, totalIndication);
        }
    }
    if (self.enableProgressIndication) {
        self.totalIndication = maxTotalIndication;
    }
    
}

////
-(void)makeRecomp
{
    
    ////整个过程开始的时间
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long int date = (long long int)time;
    self.recompressionStartTime = [NSDate dateWithTimeIntervalSince1970:date];
    ////初始化整体滤镜
    [self makeMSFilterReady];
    ////开启writer
    [self makeWriterReadyAndStart];
    ////每条流进入ready状态
    [self makeAllStreamReady];
    ////comp会话Ready
    [self makeVTCompressionSession];
    [self makeVTSessionPropertiesReadyAndStart];

    
    
    for (int i = 0; i<self.streams.count; i++) {
        VTMSDecomp * eachStream = (VTMSDecomp *)self.streams[i];
        dispatch_async(self.VTRecompressProcessingConcurrentQueue, ^{
            [eachStream makeDecomp];
        });
    }
    
    
    ////开始comp线程与所有流线程
    [self makeComp];
    

}





@end