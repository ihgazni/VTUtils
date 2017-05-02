//
//  VTComp.m
//  UView
//
//  Created by dli on 2/5/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "VTComp.h"


@implementation VTComp

-(void) resetParameters
{
    self.presentationTimeStamps = NULL;
    self.durations = NULL;
    self.sourceImageURLs = NULL;
    self.sourceImagePaths = NULL;
    self.sourceInfoURLs = NULL;
    self.sourceInfoPaths = NULL;
    self.sourceImageFileNamePattern = @"UIImage_([0-9]+)";
    self.sourceInfoFileNamePattern = @"TimeInfo_([0-9]+)";
    self.sourceDirURL = NULL;
    self.sourceDirPath = NULL;
    self.sourceRelativeDirPath = NULL;
    self.forceKeyFrameSigns = NULL;
    self.width = 0.0;
    self.height = 0.0;
    self.sourceUIImages = NULL;
    self.sourceCGImageRefs = NULL;
    self.sourceCVImageBuffers = NULL;
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
    self.compressionSessionPropertiesConstructFromKeyValue =NULL;
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
    self.deleteSourceOneByOneAfterAppendSinglePass = NO;
    self.deleteSourceOneByOneAfterAppendMultiPass = NO;
    self.compressionSourcesCount = 0;
    self.compressionSourceSeq = 0;
    self.compressionFinished = NO;
    self.compressionStartTime = NULL;
    self.compressionEndTime = NULL;
}

-(void) printAndCheckParameters
{
    NSLog(@"presentationTimeStamps:%@",self.presentationTimeStamps);
    NSLog(@"durations:%@",self.durations);
    NSLog(@"sourceImageURLs:%@",self.sourceImageURLs);
    NSLog(@"sourceImagePaths:%@",self.sourceImagePaths);
    NSLog(@"sourceInfoURLs:%@",self.sourceInfoURLs);
    NSLog(@"sourceInfoPaths:%@",self.sourceInfoURLs);
    NSLog(@"self.sourceImageFileNamePattern:%@",self.sourceImageFileNamePattern);
    NSLog(@"self.sourceInfoFileNamePattern:%@",self.sourceInfoFileNamePattern);
    NSLog(@"self.sourceDirURL:%@",self.sourceDirURL);
    NSLog(@"self.sourceDirPath:%@",self.sourceDirPath);
    NSLog(@"self.sourceRelativeDirPath:%@",self.sourceRelativeDirPath);
    NSLog(@"self.forceKeyFrameSigns:%@",self.forceKeyFrameSigns);
    /*
    NSLog(@":%@",);
    NSLog(@":%@",);
    NSLog(@":%@",);
    NSLog(@":%@",);
    NSLog(@":%@",);
    NSLog(@":%@",);
     */
    /*
    self.width = 0;
    self.height = 0;
    self.sourceUIImages = NULL;
    self.sourceCGImageRefs = NULL;
    self.sourceCVImageBuffers = NULL;
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
    self.siloOut = NULL;
    self.multiPassStorageCMTimeRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
    self.multiPassStorageOut = NULL;
    self.multiPassStorageCreationOption_DoNotDelete =NO;
    self.compressionCodecType = kCMVideoCodecType_H264;
    self.compressionEncoderSpecification = NULL;
    self.compressionEncoderSpecificationConstructFromKeyValue =NO;
    self.encoderID = @"";
    self.compressionSourceImageBufferAttributes = NULL;
    self.compressionSourceImageBufferAttributesConstructFromKeyValue = NO;
    self.compressionCVPixelFormatTypeValue = kCVPixelFormatType_32BGRA;
    self.compressionSession = NULL;
    self.compressionSessionProperties = NULL;
    self.compressionSessionPropertiesConstructFromKeyValue =NULL;
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
    self.deleteOutputFileInSandboxAfterCopyToAlbum = NO;
    self.deleteSourcesAfterCopyToAlbum = NO;
    self.deleteSourceOneByOneAfterAppendSinglePass = YES;
    self.deleteSourceOneByOneAfterAppendMultiPass = YES;
    self.compressionSourcesCount = 0;
    self.compressionSourceSeq = 0;
    self.compressionFinished = NO;
    self.compressionStartTime = NULL;
    self.compressionEndTime = NULL;
     */
}




-(void) makeSourceInfoPathsAndURLsReady
{
    if (self.sourceInfoPaths != NULL) {
        self.sourceInfoURLs = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.sourceInfoPaths.count; i++) {
            [self.sourceInfoURLs addObject:[NSURL fileURLWithPath:self.sourceInfoPaths[i]]];
        }
    } else if (self.sourceInfoURLs != NULL) {
        self.sourceInfoPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.sourceInfoPaths.count; i++) {
            [self.sourceInfoPaths addObject:[(NSURL *)self.sourceInfoURLs[i] path]];
        }
    } else {
        self.sourceDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.sourceRelativeDirPath];
        self.sourceDirURL = [NSURL fileURLWithPath:self.sourceDirPath];
        
        self.sourceInfoPaths = [[NSMutableArray alloc] init];
        self.sourceInfoPaths = [FileUitl getSpecificFilePathsOfSubDirOfTmp:self.sourceInfoFileNamePattern dirName:self.sourceRelativeDirPath];
        [self.sourceInfoPaths sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            NSString * s1 = (NSString *) obj1;
            NSString * s2 = (NSString *) obj2;
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.sourceInfoFileNamePattern
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray * matches1 = [regex matchesInString:s1
                                                options:0
                                                  range:NSMakeRange(0, [s1 length])];
            NSArray * matches2 = [regex matchesInString:s2
                                                options:0
                                                  range:NSMakeRange(0, [s2 length])];
            NSTextCheckingResult *match1 = matches1[0];
            NSTextCheckingResult *match2 = matches2[0];
            NSString * seq1Str = [s1 substringWithRange: [match1 rangeAtIndex:1]];
            NSString * seq2Str = [s2 substringWithRange: [match2 rangeAtIndex:1]];
            NSInteger seq1 = [seq1Str integerValue];
            NSInteger seq2 = [seq2Str integerValue];
            if (seq1 <= seq2) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (seq1 > seq2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        self.sourceInfoURLs = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.sourceInfoPaths.count; i++) {
            [self.sourceInfoURLs addObject:[NSURL fileURLWithPath:self.sourceInfoPaths[i]]];
        }
        

    }
    
}

-(void) makeSourceImagePathsAndURLsReady
{

    
    if (self.sourceImagePaths != NULL) {
        self.sourceImageURLs = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.sourceImagePaths.count; i++) {
            [self.sourceImageURLs addObject:[NSURL fileURLWithPath:self.sourceImagePaths[i]]];
        }
    } else if (self.sourceImageURLs != NULL) {
        self.sourceImagePaths = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.sourceImageURLs.count; i++) {
            [self.sourceImagePaths addObject:[(NSURL *)self.sourceImageURLs[i] path]];
        }
    } else {

        self.sourceImagePaths = [FileUitl getSpecificFilePathsOfSubDirOfTmp:self.sourceImageFileNamePattern dirName:self.sourceRelativeDirPath];
        [self.sourceImagePaths sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            NSString * s1 = (NSString *) obj1;
            NSString * s2 = (NSString *) obj2;
            
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.sourceImageFileNamePattern
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray * matches1 = [regex matchesInString:s1
                                                options:0
                                                  range:NSMakeRange(0, [s1 length])];
            
            NSArray * matches2 = [regex matchesInString:s2
                                                options:0
                                                  range:NSMakeRange(0, [s2 length])];
            
            
            NSTextCheckingResult *match1 = matches1[0];
            NSTextCheckingResult *match2 = matches2[0];
            NSString * seq1Str = [s1 substringWithRange: [match1 rangeAtIndex:1]];
            NSString * seq2Str = [s2 substringWithRange: [match2 rangeAtIndex:1]];
            NSInteger seq1 = [seq1Str integerValue];
            NSInteger seq2 = [seq2Str integerValue];
            if (seq1 <= seq2) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (seq1 > seq2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        

        self.sourceImageURLs = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.sourceImagePaths.count; i++) {
            [self.sourceImageURLs addObject:[NSURL fileURLWithPath:self.sourceImagePaths[i]]];
        }
    }
}


-(void) makePresentationsAndDurationsReady
{
    if ((self.presentationTimeStamps != NULL) && (self.durations != NULL)) {
        
    } else {
        [self makeSourceInfoPathsAndURLsReady];
        if ((self.presentationTimeStamps == NULL) && (self.durations != NULL)) {
            self.presentationTimeStamps = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.sourceInfoPaths.count; i++) {
                CMTime presentationTimeStamp = getCMTimeFromInfoFile(@"presentationTimeStamp", self.sourceInfoPaths[i]);
                [self.presentationTimeStamps addObject:[NSValue valueWithCMTime:presentationTimeStamp]];
            }
        } else if ((self.presentationTimeStamps != NULL) && (self.durations == NULL)) {
            self.durations = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.sourceInfoPaths.count; i++) {
                CMTime durationTimeStamp = getCMTimeFromInfoFile(@"duration", self.sourceInfoPaths[i]);
                [self.durations addObject:[NSValue valueWithCMTime:durationTimeStamp]];
            }
        } else {
            self.presentationTimeStamps = [[NSMutableArray alloc] init];
            self.durations = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.sourceInfoPaths.count; i++) {
                CMTime presentationTimeStamp = getCMTimeFromInfoFile(@"presentationTimeStamp", self.sourceInfoPaths[i]);
                [self.presentationTimeStamps addObject:[NSValue valueWithCMTime:presentationTimeStamp]];
                CMTime durationTimeStamp = getCMTimeFromInfoFile(@"duration", self.sourceInfoPaths[i]);
                [self.durations addObject:[NSValue valueWithCMTime:durationTimeStamp]];
            }
        }
    }
    
}


-(void) makeReorderViaPresentation
{
    NSMutableArray * parallelArrays = [[NSMutableArray alloc] init];
   
    for (int i = 0; i< self.presentationTimeStamps.count; i++) {
         NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
         CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
         CMTime duration = [self.durations[i] CMTimeValue];
         NSURL * extractedImgURL = self.sourceImageURLs[i];
         NSString * extractedImgPath = self.sourceImagePaths[i];
         [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"decodeTimeStamp"];
         [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
         [parallel setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
         [parallel setValue:extractedImgURL forKey:@"extractedImgURL"];
         [parallel setValue:extractedImgPath forKey:@"extractedImgPath"];
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
        self.sourceImagePaths[i] = [parallel valueForKey:@"extractedImgPath"];
        self.sourceImageURLs[i] = [parallel valueForKey:@"extractedImgURL"];
    }
    
    if (self.compressionMultiPassEnabled) {
        CMTime si = [self.presentationTimeStamps[0] CMTimeValue];
        CMTime eip = [self.presentationTimeStamps[self.presentationTimeStamps.count-1] CMTimeValue];
        CMTime eid = [self.durations[self.durations.count-1] CMTimeValue];
        CMTime ei = CMTimeAdd(eip, eid);
        self.multiPassStorageCMTimeRange = CMTimeRangeMake(si, ei);
    }


}




-(void) makeWidthAndHeightReady
{

    
    
    if (self.sourceCVImageBuffers != NULL) {
        CVImageBufferRef cvimgBufferRef = NULL;
        cvimgBufferRef = (CVImageBufferRef)CFArrayGetValueAtIndex(self.sourceCGImageRefs, 0);
        if ((self.width==0)||(self.height==0)) {
            self.width = CVPixelBufferGetWidth(cvimgBufferRef);
            self.height = CVPixelBufferGetHeight(cvimgBufferRef);
        } else if ((self.width!=0)||(self.height==0)) {
            self.height = CVPixelBufferGetHeight(cvimgBufferRef);
        } else if ((self.width==0)||(self.height!=0)) {
            self.width = CVPixelBufferGetWidth(cvimgBufferRef);
        } else {
            
        }
        CFRelease(cvimgBufferRef);    
    } else if (self.sourceCGImageRefs != NULL) {
        CGImageRef cgimg = NULL;
        cgimg =(CGImageRef)CFArrayGetValueAtIndex(self.sourceCGImageRefs, 0);
        if ((self.width==0)||(self.height==0)) {
            self.width = CGImageGetWidth(cgimg);
            self.height = CGImageGetHeight(cgimg);
        } else if ((self.width!=0)||(self.height==0)) {
            self.height = CGImageGetHeight(cgimg);
        } else if ((self.width==0)||(self.height!=0)) {
            self.width = CGImageGetWidth(cgimg);
        } else {
            
        }
        CFRelease(cgimg);
    } else if (self.sourceUIImages != NULL) {
        UIImage * uiimage = self.sourceUIImages[0];
        if ((self.width==0)||(self.height==0)) {
            self.width = uiimage.size.width;
            self.height = uiimage.size.height;
        } else if ((self.width!=0)||(self.height==0)) {
            self.height = uiimage.size.height;
        } else if ((self.width==0)||(self.height!=0)) {
            self.width = uiimage.size.width;
        } else {
            
        }
    } else {
       
       UIImage * uiimage = [[UIImage alloc] initWithContentsOfFile:self.sourceImagePaths[0]];
       if ((self.width==0)||(self.height==0)) {
            self.width = uiimage.size.width;
            self.height = uiimage.size.height;
        } else if ((self.width!=0)||(self.height==0)) {
            self.height = uiimage.size.height;
        } else if ((self.width==0)||(self.height!=0)) {
            self.width = uiimage.size.width;
        } else {
            
        }
    }
    
   
}


-(void)makeWriterReadyAndStart
{
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





void eachSampleBufferCallback(void *outputCallbackRefCon,
                                        void *sourceFrameRefCon,
                                        OSStatus status,
                                        VTEncodeInfoFlags infoFlags,
                                        CMSampleBufferRef sampleBuffer)
{
 
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
        NSLog(@"VTCompressEachFrameCallback data is not ready ");
        return;
    }
    VTComp * encoder = (__bridge VTComp*)outputCallbackRefCon;
    while (!encoder.writerInput.readyForMoreMediaData) {
        NSLog(@"start wait");
        [NSThread sleepForTimeInterval:0.1f];
        NSLog(@"did wait");
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
                        if (encoder.sourceCVImageBuffers != NULL) {
                            CVImageBufferRef imgBuffer = (CVImageBufferRef)CFArrayGetValueAtIndex(encoder.sourceCVImageBuffers, i);
                            CFRelease(imgBuffer);
                            CFArraySetValueAtIndex(encoder.sourceCVImageBuffers, i, NULL);
                        } else if (encoder.sourceCGImageRefs != NULL) {
                            CGImageRef cgimg = (CGImageRef)CFArrayGetValueAtIndex(encoder.sourceCGImageRefs, i);
                            CFRelease(cgimg);
                            CFArraySetValueAtIndex(encoder.sourceCGImageRefs, i, NULL);
                        } else if (encoder.sourceUIImages != NULL) {
                            encoder.sourceUIImages[i] = [NSNull null];
                        } else {
                            if (encoder.deleteSourceOneByOneAfterAppendMultiPass) {
                                [FileUitl deleteTmpFile:encoder.sourceImagePaths[i]];
                                [FileUitl deleteTmpFile:encoder.sourceInfoPaths[i]];
                            }
                            
                        }
                        
                    } else {
                        
                    }
                    
                }
             }
        } else {
            if (encoder.deleteSourceOneByOneAfterAppendSinglePass) {
                if (encoder.sourceCVImageBuffers != NULL) {
                    CVImageBufferRef imgBuffer = (CVImageBufferRef)CFArrayGetValueAtIndex(encoder.sourceCVImageBuffers, encoder.compressionSourceSeq);
                    CFRelease(imgBuffer);
                    CFArraySetValueAtIndex(encoder.sourceCVImageBuffers, encoder.compressionSourceSeq, NULL);
                    if (encoder.compressionSourceSeq == encoder.compressionSourcesCount - 1) {
                        CFRelease(encoder.sourceCVImageBuffers);
                    }
                } else if (encoder.sourceCGImageRefs != NULL) {
                    CGImageRef cgimg = (CGImageRef)CFArrayGetValueAtIndex(encoder.sourceCGImageRefs, encoder.compressionSourceSeq);
                    CFRelease(cgimg);
                    CFArraySetValueAtIndex(encoder.sourceCGImageRefs, encoder.compressionSourceSeq, NULL);
                    if (encoder.compressionSourceSeq == encoder.compressionSourcesCount - 1) {
                        CFRelease(encoder.sourceCGImageRefs);
                    }
                } else if (encoder.sourceUIImages != NULL) {
                    encoder.sourceUIImages[encoder.compressionSourceSeq] = [NSNull null];
                } else {
                    if (encoder.deleteSourceOneByOneAfterAppendSinglePass) {
                        [FileUitl deleteTmpFile:encoder.sourceImagePaths[encoder.compressionSourceSeq]];
                        [FileUitl deleteTmpFile:encoder.sourceInfoPaths[encoder.compressionSourceSeq]];
                    }
                    
                }
                
            } else {
                
            }
        }
        
    };
    
    if (encoder.compressionMultiPassEnabled) {
        
    } else {
        encoder.compressionSourceSeq = encoder.compressionSourceSeq +1;
    }
    
    
}


-(void) makeVTCompressionSession
{

    
    
    
    
    if (self.compressionEncoderSpecificationConstructFromKeyValue == YES) {
        self.compressionEncoderSpecification = NULL;
        self.compressionEncoderSpecification = CFDictionaryCreateMutable(
                                                          kCFAllocatorDefault,
                                                          1,
                                                          &kCFTypeDictionaryKeyCallBacks,
                                                          &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(self.compressionEncoderSpecification, kVTVideoEncoderSpecification_EncoderID, (__bridge CFStringRef)self.encoderID);
        
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
    
    
    

    

    self.compressionEachSampleBufferCallback = eachSampleBufferCallback;
    
   
  
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
        NSLog(@"encoder Unable to create a H264 session");
        return ;
    } else {
        NSLog(@"VTCompressionSessionCreated");
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


-(void) makeVTSessionPropertiesReadyAndStart
{
    
    if (self.compressionSessionPropertiesConstructFromKeyValue == YES) {
        
        
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
        
        
        
        
        if (self.compressionCleanApertureConstructFromKeyValue != NO){
            VTSessionSetCleanApertureFromValues(self.compressionSession,self.cleanApertureWidth,self.cleanApertureHeight,self.cleanApertureHorizontalOffset,self.cleanApertureVerticalOffset);
        } else {
            if (self.compressionCleanAperture != NULL) {
                VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_CleanAperture, self.compressionCleanAperture);
                CFRelease(self.compressionCleanAperture);
            } else {
                
            }
            
        }
       
        
        
        
        NSLog(@"compressionAverageBitRate:%d",self.compressionAverageBitRate);
        
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
        
        
        VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_H264EntropyMode, self.compressionH264EntropyMode);
        
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
        
        VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_ProfileLevel, self.compressionProfilelevel);
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
            VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
            VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_H264EntropyMode,kVTH264EntropyMode_CABAC);
            VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_AutoLevel);
            VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(1280000));
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
                NSLog(@"VTMultiPassStorageCreate fail:%d",status);
            }
            CFRelease(MPOptions);
        } else {
            OSStatus status = VTMultiPassStorageCreate(NULL, NULL, self.multiPassStorageCMTimeRange, NULL, &_multiPassStorageOut);
            if (status == 0) {
                
            } else {
                NSLog(@"VTMultiPassStorageCreate fail:%d",status);
            }
            
        }
         
        OSStatus status = VTSessionSetProperty(self.compressionSession,kVTCompressionPropertyKey_MultiPassStorage,self.multiPassStorageOut);
        if (status == 0) {
            
        } else {
            NSLog(@"kVTCompressionPropertyKey_MultiPassStorage fail:%d",status);
        }

        self.siloOut = NULL;
        status = VTFrameSiloCreate(NULL, NULL, self.multiPassStorageCMTimeRange, NULL, &_siloOut);
        if (status == 0) {
            
        } else {
            NSLog(@"VTFrameSiloCreate fail:%d",status);
        }
        
    }
    
    
    VTCompressionSessionPrepareToEncodeFrames(self.compressionSession);
}


-(void) makeVTencodeEachFrameSinglePass
{
    NSTimeInterval tempTime = [[NSDate date] timeIntervalSince1970];
    long long int tempDate = (long long int)tempTime;
    self.compressionStartTime = [NSDate dateWithTimeIntervalSince1970:tempDate];
    
    CMTime cursor = kCMTimeZero;
    if (self.sourceCVImageBuffers != NULL) {
        
        self.compressionSourcesCount = (int)CFArrayGetCount(self.sourceCVImageBuffers);
        for (int i = 0; i < self.compressionSourcesCount; i++) {
            CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
            CMTime newDuration = [self.durations[i] CMTimeValue];
            CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.sourceCVImageBuffers, i);
            ////creat  or copy   need CFRelease
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
            cursor = CMTimeAdd(cursor, presentationTimeStamp);
        }
    } else if (self.sourceCGImageRefs != NULL) {
        self.compressionSourcesCount = (int) CFArrayGetCount(self.sourceCGImageRefs);
        for (int i = 0; i < self.compressionSourcesCount; i++) {
            CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
            CMTime newDuration = [self.durations[i] CMTimeValue];
            
            CGImageRef cgimg = (CGImageRef)CFArrayGetValueAtIndex(self.sourceCGImageRefs, i);
            
            CVImageBufferRef imgBUffer = CGImageRefToCVImageBuffer(cgimg);
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
            CFRelease(cgimg);
            cursor = CMTimeAdd(cursor, presentationTimeStamp);
            
        }
        
        
        
    } else if (self.sourceUIImages != NULL) {
        self.compressionSourcesCount = (int)self.sourceUIImages.count ;
        for (int i = 0; i < self.sourceUIImages.count; i++) {
            CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
            CMTime newDuration = [self.durations[i] CMTimeValue];
            UIImage * tempImg = self.sourceUIImages[i];
            CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
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
        
    } else {
        self.compressionSourcesCount = (int)self.sourceImagePaths.count ;
        
        for (int i = 0; i < self.sourceImagePaths.count; i++) {
            CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
            CMTime newDuration = [self.durations[i] CMTimeValue];
            UIImage * tempImg = [[UIImage alloc] initWithContentsOfFile:self.sourceImagePaths[i]];;
            CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
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
    
    VTCompressionSessionCompleteFrames(self.compressionSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(self.compressionSession);
    CFRelease(self.compressionSession);
    self.compressionSession = NULL;
    checkAVAssetWriterStatus(self.writer);
    [self.writerInput markAsFinished];
    ////this is necessary to make sure the finishWritingWithCompletionHandler be excuted
    [self.writer endSessionAtSourceTime:cursor];
    checkAVAssetWriterStatus(self.writer);
    
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
        if (self.sourceCVImageBuffers != NULL) {
            
            self.compressionSourcesCount = (int)CFArrayGetCount(self.sourceCVImageBuffers);
            for (int i = 0; i < self.compressionSourcesCount; i++) {
                CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                CMTime newDuration = [self.durations[i] CMTimeValue];
                CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.sourceCVImageBuffers, i);
                ////creat  or copy   need CFRelease
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
                cursor = CMTimeAdd(cursor, presentationTimeStamp);
            }
        } else if (self.sourceCGImageRefs != NULL) {
            self.compressionSourcesCount = (int) CFArrayGetCount(self.sourceCGImageRefs);
            for (int i = 0; i < self.compressionSourcesCount; i++) {
                CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                CMTime newDuration = [self.durations[i] CMTimeValue];
                
                CGImageRef cgimg = (CGImageRef)CFArrayGetValueAtIndex(self.sourceCGImageRefs, i);
                
                CVImageBufferRef imgBUffer = CGImageRefToCVImageBuffer(cgimg);
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
                CFRelease(cgimg);
                cursor = CMTimeAdd(cursor, presentationTimeStamp);
                
            }
            
            
            
        } else if (self.sourceUIImages != NULL) {
            self.compressionSourcesCount = (int)self.sourceUIImages.count ;
            for (int i = 0; i < self.sourceUIImages.count; i++) {
                CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                CMTime newDuration = [self.durations[i] CMTimeValue];
                UIImage * tempImg = self.sourceUIImages[i];
                CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
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
            
        } else {
            self.compressionSourcesCount = (int)self.sourceImagePaths.count ;
            
            for (int i = 0; i < self.sourceImagePaths.count; i++) {
                CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                CMTime newDuration = [self.durations[i] CMTimeValue];
                UIImage * tempImg = [[UIImage alloc] initWithContentsOfFile:self.sourceImagePaths[i]];;
                CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
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
                CFRelease(timeRangeArrayOut);
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
                if (self.sourceCVImageBuffers != NULL) {
                    for (int i = si; i <= ei; i++) {
                        CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                        CMTime newDuration = [self.durations[i] CMTimeValue];
                        CVImageBufferRef imgBUffer = (CVImageBufferRef)CFArrayGetValueAtIndex(self.sourceCVImageBuffers, i);
                        ////creat  or copy   need CFRelease
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

                    }
                } else if (self.sourceCGImageRefs != NULL) {
                    for (int i = si; i <= ei; i++) {
                        CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                        CMTime newDuration = [self.durations[i] CMTimeValue];
                        
                        CGImageRef cgimg = (CGImageRef)CFArrayGetValueAtIndex(self.sourceCGImageRefs, i);
                        
                        CVImageBufferRef imgBUffer = CGImageRefToCVImageBuffer(cgimg);
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
                        CFRelease(cgimg);
                        
                    }
                    
                    
                    
                } else if (self.sourceUIImages != NULL) {
                    for (int i = si; i <= ei; i++) {
                        CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                        CMTime newDuration = [self.durations[i] CMTimeValue];
                        UIImage * tempImg = self.sourceUIImages[i];
                        CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
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
                    
                } else {
                    for (int i = si; i <= ei; i++) {
                        CMTime presentationTimeStamp = [self.presentationTimeStamps[i] CMTimeValue];
                        CMTime newDuration = [self.durations[i] CMTimeValue];
                        UIImage * tempImg = [[UIImage alloc] initWithContentsOfFile:self.sourceImagePaths[i]];;
                        CVImageBufferRef imgBUffer = UIImageToCVImageBuffer(tempImg);
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
   
        }////-else
        
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
        
        
        
    }////--while
    ////----next rounds
    
    
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
    
    
    ////
    if (self.deleteSourceOneByOneAfterAppendMultiPass) {
        if (self.sourceCVImageBuffers != NULL) {
            CFRelease(self.sourceCVImageBuffers);
        } else if (self.sourceCGImageRefs != NULL) {
            CFRelease(self.sourceCGImageRefs);
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
    [self.writer endSessionAtSourceTime:cursor];
    checkAVAssetWriterStatus(self.writer);
    
}








-(void) makeFinalOutputFile
{
    [self.writer finishWritingWithCompletionHandler:^{
        self.writerInput =NULL;
        self.writer = NULL;
        checkAVAssetWriterStatus(self.writer);
        NSLog(@"begin Export!");
        [FileUitl writeVideoToPhotoLibrary:self.writerOutputURL];
        NSLog(@"Export complete!");
        if (self.deleteSourcesAfterCopyToAlbum) {
            [FileUitl deleteSubDirOfTmp:self.sourceRelativeDirPath];
        }
        if (self.deleteOutputFileInSandboxAfterCopyToAlbum){
            [FileUitl deleteTmpFile:self.writerOutputPath];
        }
        NSTimeInterval tempTime = [[NSDate date] timeIntervalSince1970];
        long long int tempDate = (long long int)tempTime;
        self.compressionEndTime = [NSDate dateWithTimeIntervalSince1970:tempDate];
        NSTimeInterval costedTime = [self.compressionEndTime timeIntervalSinceDate:self.compressionStartTime];
        NSLog(@"timeCosted:%f",costedTime);
        self.compressionFinished = YES;
        
    }];
}



-(void) makeCompress
{
    [self makePresentationsAndDurationsReady];
    [self makeSourceImagePathsAndURLsReady];
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





@end