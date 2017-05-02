//
//  VTGIFToVideo.m
//  UView
//
//  Created by dli on 2/5/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "VTGIFToVideo.h"


@implementation VTGIFToVideo

-(void)readMe
{
    NSLog(@"=====part1:how to use single Pass:=====");
    NSString * part1 = @"\
    VTGIFToVideo * vtg2v =[[VTGIFToVideo alloc] init];\
    [vtg2v resetParameters];\
    vtg2v.compressionSessionPropertiesConstructFromKeyValue =YES;\
    vtg2v.compressionAverageBitRate = 1280000;\
    vtg2v.sourceGIFPath = @'.........';\
    vtg2v.deleteOutputDirBeforeWrite = YES;\
    vtg2v.writerOutputURL = @'imagesToVideo.mov';\
    vtg2v.writerOutputFileType = AVFileTypeQuickTimeMovie;\
    [vtg2v makeCompress];\
    ";
    NSLog(@"%@",part1);
    NSLog(@"=====part1:how to use single Pass:=====");
    
    
}






-(void) resetParameters
{
    self.presentationTimeStamps = NULL;
    self.useOnlyDurations = NO;
    self.useOnlyPresentations = NO;
    self.durations = NULL;
    self.sourceGIFURL = NULL;
    self.sourceGIFPath = NULL;
    self.GIFData = NULL;
    self.GIFCGImageSource = NULL;
    self.GIFImageSourceCount = 0;
    self.forceKeyFrameSigns = NULL;
    self.applyCIPT = NO;
    self.CIPT = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    self.widthCIPT = 0.0;
    self.heightCIPT = 0.0;
    
    self.applyOOBPT = NO;
    self.preferedTransform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    self.width = 0.0;
    self.height = 0.0;
    ////
    self.writerOutputFileType = NULL;
    self.writer = NULL;
    self.writerInput = NULL;
    self.writerPixelBufferAdaptor = NULL;
    self.writerInputSerialQueue = NULL;
    self.writerInputConcurrentQueue = NULL;
    self.deleteOutputDirBeforeWrite = NULL;
    self.writerOutputFileName = NULL;
    self.writerOutputRelativeDirPath = NULL;
    self.writerOutputPath = NULL;
    self.writerOutputURL = NULL;
    self.compressionMultiPassEnabled = NO;
    self.howManyPasses = 0 ;
    self.currPassRound = 0 ;
    self.furtherPass = NO;
    self.siloOut = NULL;
    self.multiPassStorageCMTimeRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
    self.multiPassStorageOut = NULL;
    self.multiPassStorageCreationOption_DoNotDelete =NO;
    self.nextPassStartSeqs = NULL;
    self.nextPassEndSeqs = NULL;
    self.nextIgnoreStartSeqs = NULL;
    self.nextIgnoreEndSeqs = NULL;
    self.compressionCodecType = kCMVideoCodecType_H264;
    self.compressionEncoderSpecification = NULL;
    self.compressionEncoderSpecificationConstructFromKeyValue =NO;
    self.encoderID = @"";
    self.compressionSourceImageBufferAttributes = NULL;
    self.compressionSourceImageBufferAttributesConstructFromKeyValue = NO;
    self.compressionCVPixelFormatTypeValue = kCVPixelFormatType_32BGRA;
    self.compressionSession = NULL;
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
    self.compressionEachSampleBufferCallback = NULL;
    self.VTCompressProcessingSerialQueue = NULL;
    self.VTCompressProcessingConcurrentQueue = NULL;
    self.deleteSourcesAfterCopyToAlbum = NO;
    self.deleteOutputFileInSandboxAfterCopyToAlbum = NO;
    self.compressionSourcesCount = 0;
    self.compressionSourceSeq = 0;
    self.compressionFinished = NO;
    self.compressionStartTime = NULL;
    self.compressionEndTime = NULL;
    self.writeToAlbum = NO;
    self.SYNC = NO;
}

-(void) resetParametersAtEnd
{
    self.presentationTimeStamps = NULL;
    self.useOnlyDurations = NO;
    self.useOnlyPresentations = NO;
    self.durations = NULL;
    self.sourceGIFURL = NULL;
    self.sourceGIFPath = NULL;
    self.GIFData = NULL;
    self.GIFCGImageSource = NULL;
    self.GIFImageSourceCount = 0;
    self.forceKeyFrameSigns = NULL;
    self.width = 0.0;
    self.height = 0.0;

    ////
    self.writerOutputFileType = NULL;
    self.writer = NULL;
    self.writerInput = NULL;
    self.writerPixelBufferAdaptor = NULL;
    self.writerInputSerialQueue = NULL;
    self.writerInputConcurrentQueue = NULL;
    self.deleteOutputDirBeforeWrite = NULL;
    self.writerOutputFileName = NULL;
    self.writerOutputRelativeDirPath = NULL;
    self.writerOutputPath = NULL;
    self.writerOutputURL = NULL;
    self.compressionMultiPassEnabled = NO;
    self.howManyPasses = 0 ;
    self.currPassRound = 0 ;
    self.furtherPass = NO;
    self.siloOut = NULL;
    self.multiPassStorageCMTimeRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
    self.multiPassStorageOut = NULL;
    self.multiPassStorageCreationOption_DoNotDelete =NO;
    self.nextPassStartSeqs = NULL;
    self.nextPassEndSeqs = NULL;
    self.nextIgnoreStartSeqs = NULL;
    self.nextIgnoreEndSeqs = NULL;
    self.compressionCodecType = kCMVideoCodecType_H264;
    self.compressionEncoderSpecification = NULL;
    self.compressionEncoderSpecificationConstructFromKeyValue =NO;
    self.encoderID = @"";
    self.compressionSourceImageBufferAttributes = NULL;
    self.compressionSourceImageBufferAttributesConstructFromKeyValue = NO;
    self.compressionCVPixelFormatTypeValue = kCVPixelFormatType_32BGRA;
    self.compressionSession = NULL;
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
    self.compressionEachSampleBufferCallback = NULL;
    self.VTCompressProcessingSerialQueue = NULL;
    self.VTCompressProcessingConcurrentQueue = NULL;
    self.deleteSourcesAfterCopyToAlbum = NO;
    self.deleteOutputFileInSandboxAfterCopyToAlbum = NO;
    self.compressionSourcesCount = 0;
    self.compressionSourceSeq = 0;
    self.compressionFinished = NO;
    self.compressionStartTime = NULL;
    self.compressionEndTime = NULL;
    self.writeToAlbum = NO;
    self.SYNC = NO;
}

-(void) printAndCheckParameters
{
    NSLog(@"presentationTimeStamps:%@",self.presentationTimeStamps);
    NSLog(@"self.useOnlyDurations:%d",self.useOnlyDurations);
    NSLog(@"self.useOnlyPresentations:%d",self.useOnlyPresentations);
    NSLog(@"durations:%@",self.durations);
    NSLog(@"sourceGIFURL:%@",self.sourceGIFURL);
    NSLog(@"sourceGIFPath:%@",self.sourceGIFPath);
    NSLog(@"self.GIFData:%@",self.GIFData);
    NSLog(@"self.GIFCGImageSource:%@",self.GIFCGImageSource);
    NSLog(@"self.GIFImageSourceCount:%lu",self.GIFImageSourceCount);
    
    NSLog(@"self.forceKeyFrameSigns:%@",self.forceKeyFrameSigns);
    NSLog(@"self.applyCIPT:%d",self.applyCIPT);
    NSLog(@"--------CIPT---------");
    printCGAffineTransform(self.CIPT);
    NSLog(@"--------CIPT---------");
    NSLog(@"self.widthCIPT:%f",self.widthCIPT);
    NSLog(@"self.heightCIPT:%f",self.heightCIPT);
    
    NSLog(@"self.applyOOBPT:%d",self.applyOOBPT);
    NSLog(@"--------OOBPT---------");
    printCGAffineTransform(self.preferedTransform);
    NSLog(@"--------OOBPT---------");
    
    NSLog(@"self.width:%f",self.width);
    NSLog(@"self.height:%f",self.height);

    NSLog(@"self.writerOutputFileType:%@",self.writerOutputFileType);
    NSLog(@"self.writer:%@",self.writer);
    NSLog(@"self.writerInput:%@",self.writerInput);
    NSLog(@"self.writerPixelBufferAdaptor:%@",self.writerPixelBufferAdaptor);
    NSLog(@"self.writerInputSerialQueue:%@",self.writerInputSerialQueue);
    NSLog(@"self.writerInputConcurrentQueue:%@",self.writerInputConcurrentQueue);
    NSLog(@"self.deleteOutputDirBeforeWrite:%d",self.deleteOutputDirBeforeWrite);
    NSLog(@"self.writerOutputFileName:%@",self.writerOutputFileName);
    NSLog(@"self.writerOutputRelativeDirPath:%@",self.writerOutputRelativeDirPath);
    NSLog(@"self.writerOutputPath:%@",self.writerOutputPath);
    NSLog(@"self.writerOutputURL:%@",self.writerOutputURL);
    NSLog(@"self.compressionMultiPassEnabled:%d",self.compressionMultiPassEnabled);
    NSLog(@"self.howManyPasses:%d",self.howManyPasses);
    NSLog(@"self.currPassRound:%d",self.currPassRound);
    NSLog(@"self.siloOut:%@",self.siloOut);
    NSLog(@"----self.multiPassStorageCMTimeRange----");
    CMTimeRangeShow(self.multiPassStorageCMTimeRange);
    NSLog(@"----self.multiPassStorageCMTimeRange----");
    NSLog(@"self.multiPassStorageOut:%@",self.multiPassStorageOut);
    NSLog(@"self.multiPassStorageCreationOption_DoNotDelete:%d",self.multiPassStorageCreationOption_DoNotDelete);
    NSLog(@"----self.compressionCodecType:%u----",(unsigned int)self.compressionCodecType);
    printKCMVideoCodecType(self.compressionCodecType);
    NSLog(@"----self.compressionCodecType:%u----",(unsigned int)self.compressionCodecType);
    NSLog(@"self.compressionEncoderSpecification:%@",self.compressionEncoderSpecification);
    NSLog(@"self.compressionEncoderSpecificationConstructFromKeyValue:%d",self.compressionEncoderSpecificationConstructFromKeyValue);
    NSLog(@"self.encoderID:%@",self.encoderID);
    NSLog(@"self.compressionSourceImageBufferAttributes:%@",self.compressionSourceImageBufferAttributes);
    NSLog(@"self.compressionSourceImageBufferAttributesConstructFromKeyValue:%d",self.compressionSourceImageBufferAttributesConstructFromKeyValue);
    NSLog(@"----self.compressionCVPixelFormatTypeValue----");
    printKCVPixelFormatType(self.compressionCVPixelFormatTypeValue);
    NSLog(@"----self.compressionCVPixelFormatTypeValue----");
    NSLog(@"self.compressionSession:%@",self.compressionSession);
    NSLog(@"self.compressionSessionProperties:%@",self.compressionSessionProperties);
    NSLog(@"self.compressionSessionPropertiesConstructFromKeyValue:%d",self.compressionSessionPropertiesConstructFromKeyValue);
    NSLog(@"self.compressionAllowFrameReordering:%d",self.compressionAllowFrameReordering);
    NSLog(@"self.compressionAllowTemporalCompression:%d",self.compressionAllowTemporalCompression);
    NSLog(@"self.compressionCleanAperture:%@",self.compressionCleanAperture);
    NSLog(@"self.compressionCleanApertureConstructFromKeyValue:%d",self.compressionCleanApertureConstructFromKeyValue);
    NSLog(@"self.cleanApertureWidth:%d",self.cleanApertureWidth);
    NSLog(@"self.cleanApertureHeight:%d",self.cleanApertureHeight);
    NSLog(@"self.cleanApertureHorizontalOffset:%d",self.cleanApertureHorizontalOffset);
    NSLog(@"self.cleanApertureVerticalOffset:%d",self.cleanApertureVerticalOffset);
    NSLog(@"self.compressionAverageBitRate:%d",self.compressionAverageBitRate);
    NSLog(@"self.compressionColorPrimaries:%@",self.compressionColorPrimaries);
    NSLog(@"self.compressionFieldCount:%d",self.compressionFieldCount);
    NSLog(@"self.compressionFieldDetail:%@",self.compressionFieldDetail);
    NSLog(@"self.compressionH264EntropyMode:%@",self.compressionH264EntropyMode);
    NSLog(@"self.compressionMaxFrameDelayCount:%d",self.compressionMaxFrameDelayCount);
    NSLog(@"self.compressionMaxKeyFrameInterval:%d",self.compressionMaxKeyFrameInterval);
    NSLog(@"self.compressionMaxKeyFrameIntervalDuration:%d",self.compressionMaxKeyFrameIntervalDuration);
    NSLog(@"self.compressionPixelAspectRatioConstructFromKeyValue:%d",self.compressionPixelAspectRatioConstructFromKeyValue);
    NSLog(@"self.compressionPixelAspectRatio:%@",self.compressionPixelAspectRatio);
    NSLog(@"self.pixelAspectRatioHorizontalSpacing:%d",self.pixelAspectRatioHorizontalSpacing);
    NSLog(@"self.pixelAspectRatioVerticalSpacing:%d",self.pixelAspectRatioVerticalSpacing);
    NSLog(@"self.compressionProfilelevel:%@",self.compressionProfilelevel);
    NSLog(@"self.compressionRealTime:%d",self.compressionRealTime);
    NSLog(@"self.compressionYCbCrMatrix:%@",self.compressionYCbCrMatrix);
    NSLog(@"self.compressionTransferFunction:%@",self.compressionTransferFunction);
    NSLog(@"self.VTCompressProcessingSerialQueue:%@",self.VTCompressProcessingSerialQueue);
    NSLog(@"self.VTCompressProcessingConcurrentQueue:%@",self.VTCompressProcessingConcurrentQueue);
    NSLog(@"self.deleteOutputFileInSandboxAfterCopyToAlbum:%d",self.deleteOutputFileInSandboxAfterCopyToAlbum);
    NSLog(@"self.deleteSourcesAfterCopyToAlbum:%d",self.deleteSourcesAfterCopyToAlbum);
    NSLog(@"self.compressionSourcesCount:%d",self.compressionSourcesCount);
    NSLog(@"self.compressionSourceSeq:%d",self.compressionSourceSeq);
    NSLog(@"self.compressionFinished:%d",self.compressionFinished);
    NSLog(@"self.compressionStartTime:%@",self.compressionStartTime);
    NSLog(@"self.compressionEndTime:%@",self.compressionEndTime);
    NSLog(@"self.writeToAlbum:%d",self.writeToAlbum);
    NSLog(@"self.SYNC:%d",self.SYNC);
}


-(void) makeSourceGIFPathsAndURLsReady
{
    @autoreleasepool {

        if (self.sourceGIFPath != NULL) {
            self.sourceGIFURL = [NSURL fileURLWithPath:self.sourceGIFPath];
        } else if (self.sourceGIFURL != NULL) {
            self.sourceGIFPath = [self.sourceGIFURL path];
        }
        
        self.GIFData = [NSData dataWithContentsOfURL:self.sourceGIFURL];
        

        if (!self.GIFData) {
            
        } else {
            
            
            
            self.GIFCGImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.GIFData, NULL);

            self.GIFImageSourceCount = CGImageSourceGetCount(self.GIFCGImageSource);

        }
   
    }
}

-(void) makePresentationsAndDurationsReady
{
    @autoreleasepool {
            
        
        if ((self.presentationTimeStamps != NULL) && (self.durations != NULL)) {
            
        } else if ((self.presentationTimeStamps == NULL) && (self.durations != NULL)) {
            self.useOnlyDurations = YES;
        } else if ((self.presentationTimeStamps != NULL) && (self.durations == NULL)) {
            self.useOnlyPresentations = YES;
        } else {
            
            self.durations = [[NSMutableArray alloc] init];

            for (int i = 0; i<self.GIFImageSourceCount; i++) {
                float du = GIFframeDurationAtIndex(i,self.GIFCGImageSource);
                CMTime duration = CMTimeMakeWithSeconds(du, 600);
                [self.durations addObject:[NSValue valueWithCMTime:duration]];
            }
            self.useOnlyDurations = YES;
        }
        
        
        
        if (self.useOnlyDurations) {
            self.presentationTimeStamps = NULL;
            self.presentationTimeStamps = [[NSMutableArray alloc] init];
            CMTime currP = kCMTimeZero;
            for (int i = 0; i < self.durations.count; i++) {
                [self.presentationTimeStamps addObject:[NSValue valueWithCMTime:currP]];
                currP = CMTimeAdd(currP, [self.durations[i] CMTimeValue]);
            }
            
        }
        
        if (self.useOnlyPresentations) {
            self.durations = NULL;
            self.durations = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < self.durations.count - 1; i++) {
                CMTime currP = [self.presentationTimeStamps[i] CMTimeValue];
                CMTime nextP = [self.presentationTimeStamps[i+1] CMTimeValue];
                [self.durations addObject:[NSValue valueWithCMTime:CMTimeSubtract(nextP, currP)]];
                
            }
        }
        
        

        
    }
}

-(void) makeReorderViaPresentation
{
    
    @autoreleasepool {
        NSMutableArray * parallelArrays = [[NSMutableArray alloc] init];
        
        for (int i = 0; i< self.presentationTimeStamps.count; i++) {
            NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
            CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
            CMTime duration = [self.durations[i] CMTimeValue];
            
            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"decodeTimeStamp"];
            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
            [parallel setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
            
            
            [parallel setValue:[NSNumber numberWithInt:i] forKey:@"origSeq"];
            [parallelArrays addObject:parallel];
        }
        
        
     
        
        
        [parallelArrays sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            NSDictionary * o1 = (NSDictionary *) obj1;
            NSDictionary * o2 = (NSDictionary *) obj2;
            
            CMTime pt1 = [[o1 valueForKey:@"presentationTimeStamp"] CMTimeValue];
            CMTime pt2 = [[o2 valueForKey:@"presentationTimeStamp"] CMTimeValue];
            
            if (pt1.value >= pt2.value) {
                return (NSComparisonResult)NSOrderedDescending;
            } else if (pt1.value < pt2.value) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        

        for (int i = 0; i< parallelArrays.count; i++) {
            NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
            parallel = parallelArrays[i];
            self.presentationTimeStamps[i] = [parallel valueForKey:@"presentationTimeStamp"];
            self.durations[i] = [parallel valueForKey:@"duration"];
            
        }
        

        
        if (self.compressionMultiPassEnabled) {
            CMTime si = [self.presentationTimeStamps[0] CMTimeValue];
            CMTime eip = [self.presentationTimeStamps[self.presentationTimeStamps.count-1] CMTimeValue];
            CMTime eid = [self.durations[self.durations.count-1] CMTimeValue];
            CMTime ei = CMTimeAdd(eip, eid);
            self.multiPassStorageCMTimeRange = CMTimeRangeMake(si, ei);
        }
        
    }
    
    


}

-(void) makeWidthAndHeightReady
{
    @autoreleasepool {
        CGImageRef image = CGImageSourceCreateImageAtIndex(self.GIFCGImageSource, 0, NULL);
        UIImage * uiimage = [UIImage imageWithCGImage:image];
        ////处理EXIF
        uiimage = imageRecoverToInternalFormat(uiimage);
        if ((self.width==0)&&(self.height==0)) {
            self.width = uiimage.size.width;
            self.height = uiimage.size.height;
        } else if ((self.width!=0)&&(self.height==0)) {
            self.height = uiimage.size.height;
        } else if ((self.width==0)&&(self.height!=0)) {
            self.width = uiimage.size.width;
        } else {
            
        }
        CGImageRelease(image);
        
    }
}

-(void)makeWriterReadyAndStart
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





void eachSampleBufferCallbackOfG2V(void *outputCallbackRefCon,
                                        void *sourceFrameRefCon,
                                        OSStatus status,
                                        VTEncodeInfoFlags infoFlags,
                                        CMSampleBufferRef sampleBuffer)
{
    

    
    
    
    
    @autoreleasepool {
        
        if (status != 0) {
            return;
        }
        if (sourceFrameRefCon)
        {
            ////CVPixelBufferRef pixelbuffer = sourceFrameRefCon;
            ////CVPixelBufferRelease(pixelbuffer);
        }
        if (!CMSampleBufferDataIsReady(sampleBuffer))
        {
            ////NSLog(@"VTCompressEachFrameCallback data is not ready ");
            return;
        }
        VTComp * encoder = (__bridge VTComp*)outputCallbackRefCon;
        while (!encoder.writerInput.readyForMoreMediaData) {
            ////NSLog(@"start wait");
            [NSThread sleepForTimeInterval:0.1f];
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
            
            
        };
        
        if (encoder.compressionMultiPassEnabled) {
            
        } else {
            encoder.compressionSourceSeq = encoder.compressionSourceSeq +1;
        }
        
        
    }
    
    
}


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
            self.compressionEncoderSpecification = CFDictionaryCreateMutable(
                                                                             kCFAllocatorDefault,
                                                                             5,
                                                                             &kCFTypeDictionaryKeyCallBacks,
                                                                             &kCFTypeDictionaryValueCallBacks);
        
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
                
            } else {
                
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
                
            } else {
                
            }
        }
        

        
        
        
        
        self.compressionEachSampleBufferCallback = eachSampleBufferCallbackOfG2V;
        
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
            NSLog(@"encoder Unable to create a H264 session:%d",status);
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


-(void) makeVTencodeEachFrameSinglePass
{
    

    NSTimeInterval tempTime = [[NSDate date] timeIntervalSince1970];
    long long int tempDate = (long long int)tempTime;
    self.compressionStartTime = [NSDate dateWithTimeIntervalSince1970:tempDate];
    CMTime cursor = kCMTimeZero;


    self.compressionSourcesCount = (int)self.GIFImageSourceCount ;
    for (int i = 0; i < self.GIFImageSourceCount; i++) {
        @autoreleasepool {
            CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
            CMTime newDuration = [self.durations[i] CMTimeValue];
            
            UIImage * tempImg;
            {
                CGImageRef image = CGImageSourceCreateImageAtIndex(self.GIFCGImageSource, i, NULL);
                UIImage * uiimage = [UIImage imageWithCGImage:image];
                ////处理EXIF
                tempImg = imageRecoverToInternalFormat(uiimage);
                CGImageRelease(image);
            }

            CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
            
            if (self.applyCIPT) {
                CIImage * cImg = [[CIImage alloc] initWithCVPixelBuffer:imgBUffer];
                cImg = [cImg imageByApplyingTransform:self.CIPT];
                imgBUffer = CIImageRefToCVImageBuffer(cImg, self.widthCIPT, self.heightCIPT);
            } else {
                
            }
            
            VTEncodeInfoFlags flags;
            
            
            OSStatus statusCode;
            if (self.forceKeyFrameSigns == NULL) {
                
                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                             imgBUffer,
                                                             presentationTimeStamp,
                                                             newDuration,
                                                             NULL, NULL, &flags);
            } else {
                int sign = (int)[self.forceKeyFrameSigns[i] integerValue];
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
                printVTError(statusCode);
                VTCompressionSessionInvalidate(self.compressionSession);
                CFRelease(self.compressionSession);
                self.compressionSession = NULL;
                return;
            }
            CFRelease(imgBUffer);
            cursor = CMTimeAdd(cursor, presentationTimeStamp);
            
        }
    }
    
    
    CMTime lastNewDuration = [self.durations[self.GIFImageSourceCount-1] CMTimeValue];
    cursor = CMTimeAdd(cursor, lastNewDuration);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @autoreleasepool {
        ////In addition to a simple time value, a CMTime can represent non-numeric values: +infinity, -infinity, and indefinite
        ////If completeUntilPresentationTimeStamp is non-numeric, all pending frames	will be emitted before the function returns
        VTCompressionSessionCompleteFrames(self.compressionSession, kCMTimeIndefinite);
        VTCompressionSessionInvalidate(self.compressionSession);
        CFRelease(self.compressionSession);
        self.compressionSession = NULL;
        checkAVAssetWriterStatus(self.writer);
        [self.writerInput markAsFinished];
        ////this is necessary to make sure the finishWritingWithCompletionHandler be excuted
        [self.writer endSessionAtSourceTime:cursor];
        checkAVAssetWriterStatus(self.writer);
        
      
        
    }
    
    
   
    
    
    
}


-(void) makeVTencodeEachFrameMultiPass
{
    NSTimeInterval tempTime = [[NSDate date] timeIntervalSince1970];
    long long int tempDate = (long long int)tempTime;
    self.compressionStartTime = [NSDate dateWithTimeIntervalSince1970:tempDate];
    
    CMTime cursor = kCMTimeZero;
    self.currPassRound = 1;
    ////---first round
    
    
    {
        VTCompressionSessionBeginPass(self.compressionSession, 0, NULL);

        ////
        self.compressionSourcesCount = (int)self.GIFImageSourceCount ;
        
        for (int i = 0; i < self.GIFImageSourceCount; i++) {
            @autoreleasepool {
                CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                CMTime newDuration = [self.durations[i] CMTimeValue];
                
                UIImage * tempImg;
                {
                    CGImageRef image = CGImageSourceCreateImageAtIndex(self.GIFCGImageSource, i, NULL);
                    UIImage * uiimage = [UIImage imageWithCGImage:image];
                    ////处理EXIF
                    tempImg = imageRecoverToInternalFormat(uiimage);
                    CGImageRelease(image);
                }
                
                
                
                CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
                
                
                if (self.applyCIPT) {
                    CIImage * cImg = [[CIImage alloc] initWithCVPixelBuffer:imgBUffer];
                    cImg = [cImg imageByApplyingTransform:self.CIPT];
                    imgBUffer = CIImageRefToCVImageBuffer(cImg, self.widthCIPT, self.heightCIPT);
                } else {
                    
                }
                
                VTEncodeInfoFlags flags;
                
                
                OSStatus statusCode;
                if (self.forceKeyFrameSigns == NULL) {
                    statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                 imgBUffer,
                                                                 presentationTimeStamp,
                                                                 newDuration,
                                                                 NULL, NULL, &flags);
                } else {
                    int sign = (int)[self.forceKeyFrameSigns[i] integerValue];
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
                CFRelease(imgBUffer);
                cursor = CMTimeAdd(cursor, presentationTimeStamp);
                
            }
        }
        
        CMTime lastNewDuration = [self.durations[self.GIFImageSourceCount-1] CMTimeValue];
        cursor =CMTimeAdd(cursor, lastNewDuration);
        
        
        
        ////
        
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
                {
                    for (int i = si; i <= ei; i++) {
                        @autoreleasepool {
                            CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                            CMTime newDuration = [self.durations[i] CMTimeValue];
                            
                            UIImage * tempImg;
                            {
                                CGImageRef image = CGImageSourceCreateImageAtIndex(self.GIFCGImageSource, i, NULL);
                                UIImage * uiimage = [UIImage imageWithCGImage:image];
                                ////处理EXIF
                                tempImg = imageRecoverToInternalFormat(uiimage);
                                CGImageRelease(image);
                            }
                            
                            
                            
                            
                            CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
                            
                            if (self.applyCIPT) {
                                CIImage * cImg = [[CIImage alloc] initWithCVPixelBuffer:imgBUffer];
                                cImg = [cImg imageByApplyingTransform:self.CIPT];
                                imgBUffer = CIImageRefToCVImageBuffer(cImg, self.widthCIPT, self.heightCIPT);
                            } else {
                                
                            }
                            
                            
                            VTEncodeInfoFlags flags;
                            
                            
                            OSStatus statusCode;
                            if (self.forceKeyFrameSigns == NULL) {
                                statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                                             imgBUffer,
                                                                             presentationTimeStamp,
                                                                             newDuration,
                                                                             NULL, NULL, &flags);
                            } else {
                                int sign = (int)[self.forceKeyFrameSigns[i] integerValue];
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
                            CFRelease(imgBUffer);
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
        

        
        
        VTCompressionSessionCompleteFrames(self.compressionSession, kCMTimeIndefinite);
        VTCompressionSessionInvalidate(self.compressionSession);
        CFRelease(self.compressionSession);
        self.compressionSession = NULL;
        checkAVAssetWriterStatus(self.writer);
        [self.writerInput markAsFinished];
        
        ////this is necessary to make sure the finishWritingWithCompletionHandler be excuted
        [self.writer endSessionAtSourceTime:cursor];
        ////checkAVAssetWriterStatus(self.writer);
        CFRelease(self.GIFCGImageSource);
        self.GIFCGImageSource = NULL;
    }
    
}








-(void) makeFinalOutputFile
{
    __block dispatch_semaphore_t semaCanReturn = dispatch_semaphore_create(0);
 
    
    [self.writer finishWritingWithCompletionHandler:^{
        
        
        @autoreleasepool {
            self.writerInput =NULL;
            self.writer = NULL;

            ////checkAVAssetWriterStatus(self.writer);
            
            ////使用这个功能会使得压缩实效
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
            
            
            if (self.deleteSourcesAfterCopyToAlbum) {
                
                [FileUitl deleteFile:self.sourceGIFPath];
            }
            if (self.writeToAlbum && self.deleteOutputFileInSandboxAfterCopyToAlbum){
                
                [FileUitl deleteTmpFile:self.writerOutputPath];
            }
            NSTimeInterval tempTime = [[NSDate date] timeIntervalSince1970];
            long long int tempDate = (long long int)tempTime;
            self.compressionEndTime = [NSDate dateWithTimeIntervalSince1970:tempDate];
            NSTimeInterval costedTime = [self.compressionEndTime timeIntervalSinceDate:self.compressionStartTime];
            NSLog(@"costed time :%f",costedTime);
            self.compressionFinished = YES;
            
            
        }
        
        if (self.SYNC) {
            dispatch_semaphore_signal(semaCanReturn);
        } else {
            [self resetParametersAtEnd];
            ////[self printAndCheckParameters];
        }
        
    }];
    
    if (self.SYNC) {
        while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        [self resetParametersAtEnd];
        ////[self printAndCheckParameters];
    }
    
    

    
}



-(void) makeCompress
{
    @autoreleasepool {
        [self makeSourceGIFPathsAndURLsReady];
        [self makePresentationsAndDurationsReady];
        [self makeReorderViaPresentation];
        [self makeWidthAndHeightReady];
        [self makeWriterReadyAndStart];
        [self makeVTCompressionSession];
        [self makeVTSessionPropertiesReadyAndStart];
        
        
        
        if (self.compressionMultiPassEnabled==YES) {
            [self makeVTencodeEachFrameMultiPass];
        } else {
            [self makeVTencodeEachFrameSinglePass];
        }
        [self makeFinalOutputFile];
    }
    

}


@end