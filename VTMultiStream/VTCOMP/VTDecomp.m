//
//  VTDecomp.m
//  UView
//
//  Created by dli on 2/17/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "VTDecomp.h"

@implementation VTDecomp

-(void)readMe
{
    NSLog(@"=====part1:how to use:=====");
    NSString * part1 = @"VTDecomp * vtdc=[[VTDecomp alloc] init];\
    [vtdc resetParameters];\
    vtdc.sourceVideoURL = self.multiMovieURLs[0];\
    vtdc.extractedImagesRelativeDir = @'ExtractedImages';\
    [vtdc makeDecomp];\
    ";
    NSLog(@"%@",part1);
    NSLog(@"=====part1:how to use:=====");
}

-(void) resetParameters
{
    self.sourceVideoFilename = NULL;
    self.sourceVideoRelativeDir = NULL;
    self.sourceVideoPath = NULL;
    self.sourceVideoURL = NULL;
    self.reader = NULL;
    self.readerAsset = NULL;
    self.whichTrack = 0;
    self.sourceVideoTrack = NULL;
    self.preferedTransform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    self.width = 0.0;
    self.height = 0.0;
    self.applyOOBPT = YES;
    self.CIPT = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    self.widthCIPT = 0.0;
    self.heightCIPT = 0.0;
    self.applyCIPT = YES;
    self.readerOutput = NULL;
    
    self.storeInDisk = YES;
    self.deleteExtractedImagesDirBeforeWrite = YES;
    self.extractedImagesRelativeDir = NULL;
    self.extractedImagesDirPath = NULL;
    self.extractedImagesDirURL = NULL;
    self.extractedImageFormat = @"png";
    self.extractedJPEGQuality = 1.0;
    
    self.eachExtractedCVImage = NULL;
    self.eachExtractedCIImage = NULL;
    self.eachExtractedCGImage = NULL;
    self.eachExtractedUIImage = NULL;
    
    
    self.typeForBuffer = @"CVImage";
    self.sortImagesAfterDecompression = YES;
    self.extractedCVImageRefs = NULL;
    self.extractedImages = NULL;
    self.extractedCGImageRefs = NULL;
    self.presentationTimeStamps = NULL;
    self.decodeTimeStamps = NULL;
    self.durations = NULL;
    self.keyFrameSigns = NULL;
    
    
    self.currKeyFrameIndicator = NO;
    self.parallelArray = NULL;
    self.goodSamCounts = 0;
    self.origGoodSamCounts = 0;
    
    self.newSessionEachKeyFrame = NO;
    self.reducedFrameNumerator = 0 ;
    self.reducedFrameDenominator = 0;
    
    self.decompressionSession = NULL;
    self.decompressionEachFrameCallback = NULL;
    self.decompressionVideoFormatDescription = NULL;
    self.destinationImageBufferAttributes = NULL;
    self.removeNegativeCMTime = YES;
    self.constructDestinationImageBufferAttributesFromKeyValue = NO;
    self.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    self.constructDecompressionDecodeSpecificationFromKeyValue = NO;
    self.decompressionDecodeSpecification = NULL;
    self.decompressionStartTime = NULL;
    self.decompressionEndTime = NULL;
    self.decompressionFinished =NO;
    
}


-(void) resetParametersKeepPT
{
    self.sourceVideoFilename = NULL;
    self.sourceVideoRelativeDir = NULL;
    self.sourceVideoPath = NULL;
    self.sourceVideoURL = NULL;
    self.reader = NULL;
    self.readerAsset = NULL;
    self.whichTrack = 0;
    self.sourceVideoTrack = NULL;
    self.readerOutput = NULL;
    
    self.storeInDisk = YES;
    self.deleteExtractedImagesDirBeforeWrite = YES;
    self.extractedImagesRelativeDir = NULL;
    self.extractedImagesDirPath = NULL;
    self.extractedImagesDirURL = NULL;
    self.extractedImageFormat = @"png";
    self.extractedJPEGQuality = 1.0;
    
    self.eachExtractedCVImage = NULL;
    self.eachExtractedCIImage = NULL;
    self.eachExtractedCGImage = NULL;
    self.eachExtractedUIImage = NULL;
    
    
    self.typeForBuffer = @"CVImage";
    self.sortImagesAfterDecompression = YES;
    self.extractedCVImageRefs = NULL;
    self.extractedImages = NULL;
    self.extractedCGImageRefs = NULL;
    self.presentationTimeStamps = NULL;
    self.decodeTimeStamps = NULL;
    self.durations = NULL;
    self.keyFrameSigns = NULL;
    
    
    self.currKeyFrameIndicator = NO;
    self.parallelArray = NULL;
    self.goodSamCounts = 0;
    self.origGoodSamCounts = 0;
    
    self.newSessionEachKeyFrame = NO;
    self.reducedFrameNumerator = 0 ;
    self.reducedFrameDenominator = 0;
    
    self.decompressionSession = NULL;
    self.decompressionEachFrameCallback = NULL;
    self.decompressionVideoFormatDescription = NULL;
    self.destinationImageBufferAttributes = NULL;
    self.removeNegativeCMTime = YES;
    self.constructDestinationImageBufferAttributesFromKeyValue = NO;
    self.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
                                                    
    self.constructDecompressionDecodeSpecificationFromKeyValue = NO;
    self.decompressionDecodeSpecification = NULL;
    self.decompressionStartTime = NULL;
    self.decompressionEndTime = NULL;
    self.decompressionFinished =NO;
    
}







-(void) resetParametersForNotStoreInDisk
{
    self.sourceVideoFilename = NULL;
    self.sourceVideoRelativeDir = NULL;
    self.sourceVideoPath = NULL;
    self.sourceVideoURL = NULL;
    self.reader = NULL;
    self.readerAsset = NULL;
    self.whichTrack = 0;
    self.sourceVideoTrack = NULL;

    self.applyOOBPT = YES;
    self.applyCIPT = YES;
    self.readerOutput = NULL;
    
    self.storeInDisk = YES;
    self.deleteExtractedImagesDirBeforeWrite = YES;
    self.extractedImagesRelativeDir = NULL;
    self.extractedImagesDirPath = NULL;
    self.extractedImagesDirURL = NULL;
    self.extractedImageFormat = @"png";
    self.extractedJPEGQuality = 1.0;
    
    self.eachExtractedCVImage = NULL;
    self.eachExtractedCIImage = NULL;
    self.eachExtractedCGImage = NULL;
    self.eachExtractedUIImage = NULL;
    
    
    
    self.sortImagesAfterDecompression = YES;
    if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
        self.extractedCGImageRefs = NULL;
        self.extractedImages = NULL;
    } else if([self.typeForBuffer isEqualToString:@"CGImage"]) {
        self.extractedCVImageRefs = NULL;
        self.extractedImages = NULL;
    } else if([self.typeForBuffer isEqualToString:@"CIImage"]) {
        self.extractedCVImageRefs = NULL;
        self.extractedCGImageRefs = NULL;
    } else if([self.typeForBuffer isEqualToString:@"UIImage"]) {
        self.extractedCVImageRefs = NULL;
        self.extractedCGImageRefs = NULL;
    }


    self.typeForBuffer = @"CVImage";
    
    
    self.currKeyFrameIndicator = NO;
    self.parallelArray = NULL;
    self.goodSamCounts = 0;
    self.origGoodSamCounts = 0;
    self.newSessionEachKeyFrame = NO;
    
    self.reducedFrameNumerator = 0 ;
    self.reducedFrameDenominator = 0;
    
    self.decompressionSession = NULL;
    self.decompressionEachFrameCallback = NULL;
    self.decompressionVideoFormatDescription = NULL;
    self.destinationImageBufferAttributes = NULL;
    self.removeNegativeCMTime = YES;
    self.constructDestinationImageBufferAttributesFromKeyValue = NO;
    self.destinationImageBufferKCVPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    ////if this is not support by slow openGL ,
    ////use kCVPixelFormatType_32BGRA
    self.constructDecompressionDecodeSpecificationFromKeyValue = NO;
    self.decompressionDecodeSpecification = NULL;
    self.decompressionStartTime = NULL;
    self.decompressionEndTime = NULL;
    self.decompressionFinished =NO;
}




-(void) printAndCheckParameters
{
    NSLog(@"self.sourceVideoFilename:%@",self.sourceVideoFilename);
    NSLog(@"self.sourceVideoRelativeDir:%@",self.sourceVideoRelativeDir);
    NSLog(@"self.sourceVideoPath:%@",self.sourceVideoPath);
    NSLog(@"self.sourceVideoURL:%@",self.sourceVideoURL);
    NSLog(@"self.reader:%@",self.reader);
    NSLog(@"self.readerAsset:%@",self.readerAsset);
    NSLog(@"----self.preferedTransform:----");
    printCGAffineTransform(self.preferedTransform);
    NSLog(@"----self.preferedTransform:----");
    NSLog(@"----self.CIPT:----");
    printCGAffineTransform(self.CIPT);
    NSLog(@"----self.CIPT:----");
    NSLog(@"self.height:%f",self.height);
    NSLog(@"self.width:%f",self.width);
    NSLog(@"self.applyOOBPT:%d",self.applyOOBPT);
    NSLog(@"self.heightCIPT:%f",self.heightCIPT);
    NSLog(@"self.widthCIPT:%f",self.widthCIPT);
    NSLog(@"self.applyCIPT:%d",self.applyCIPT);
    NSLog(@"self.whichTrack:%d",self.whichTrack);
    
    NSLog(@"self.sourceVideoTrack:%@",self.sourceVideoTrack);
    NSLog(@"self.readerOutput:%@",self.readerOutput);
    NSLog(@"self.storeInDisk:%d",self.storeInDisk);
    NSLog(@"self.deleteExtractedImagesDirBeforeWrite:%d",self.deleteExtractedImagesDirBeforeWrite);
    NSLog(@"self.extractedImagesRelativeDir:%@",self.extractedImagesRelativeDir);
    NSLog(@"self.extractedImagesDirPath:%@",self.extractedImagesDirPath);
    NSLog(@"self.extractedImagesDirURL:%@",self.extractedImagesDirURL);
    NSLog(@"self.extractedImageFormat:%@",self.extractedImageFormat);
    NSLog(@"self.extractedJPEGQuality:%f",self.extractedJPEGQuality);
    NSLog(@"self.typeForBuffer:%@",self.typeForBuffer);
    NSLog(@"self.eachExtractedCIImage:%@",self.eachExtractedCIImage);
    NSLog(@"self.eachExtractedUIImage:%@",self.eachExtractedUIImage);
    NSLog(@"self.eachExtractedCGImage:%@",self.eachExtractedCGImage);
    NSLog(@"self.sortImagesAfterDecompression:%d",self.sortImagesAfterDecompression);
    NSLog(@"self.extractedImages:%@",self.extractedImages);
    NSLog(@"self.extractedCVImageRefs:%@",(__bridge NSMutableArray *)self.extractedCVImageRefs);
    NSLog(@"self.extractedCGImageRefs:%@",(__bridge NSMutableArray *)self.extractedCGImageRefs);
    NSLog(@"self.presentationTimeStamps:%@",self.presentationTimeStamps);
    NSLog(@"self.decodeTimeStamps:%@",self.decodeTimeStamps);
    NSLog(@"self.durations:%@",self.durations);
    NSLog(@"self.keyFrameSigns:%@",self.keyFrameSigns);
    NSLog(@"self.currKeyFrameIndicator:%d",self.currKeyFrameIndicator);
    NSLog(@"self.parallelArray:%@",self.parallelArray);
    NSLog(@"self.goodSamCounts:%d",self.goodSamCounts);
    NSLog(@"self.origGoodSamCounts:%d",self.origGoodSamCounts);
    
    NSLog(@"self.newSessionEachKeyFrame:%d",self.newSessionEachKeyFrame);
    
    NSLog(@"self.reducedFrameNumerator:%d",self.reducedFrameNumerator);
    NSLog(@"self.reducedFrameDenominator:%d",self.reducedFrameDenominator);
    
    
    NSLog(@"self.decompressionSession:%@",self.decompressionSession);
    NSLog(@"self.decompressionVideoFormatDescription:%@",self.decompressionVideoFormatDescription);
    NSLog(@"self.destinationImageBufferAttributes:%@",self.destinationImageBufferAttributes);
    NSLog(@"self.constructDestinationImageBufferAttributesFromKeyValue:%d",self.constructDestinationImageBufferAttributesFromKeyValue);
    NSLog(@"----self.destinationImageBufferKCVPixelFormatType:----");
    printKCVPixelFormatType(self.destinationImageBufferKCVPixelFormatType);
    NSLog(@"----self.destinationImageBufferKCVPixelFormatType:----");
    NSLog(@"self.constructDecompressionDecodeSpecificationFromKeyValue:%d",self.constructDecompressionDecodeSpecificationFromKeyValue);
    NSLog(@"self.decompressionDecodeSpecification:%@",self.decompressionDecodeSpecification);
    NSLog(@"self.decompressionStartTime:%@",self.decompressionStartTime);
    NSLog(@"self.decompressionEndTime:%@",self.decompressionEndTime);
    NSLog(@"self.decompressionFinished:%d",self.decompressionFinished);    
}



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

-(void) makeDestinationImagePathsAndURLsReady
{
   
    @autoreleasepool {
        if (self.extractedImagesDirURL != NULL) {
            self.extractedImagesDirPath = [self.extractedImagesDirURL path];
            self.extractedImagesRelativeDir = [self.extractedImagesDirPath lastPathComponent];
        } else if (self.extractedImagesDirPath != NULL) {
            self.extractedImagesDirURL = [NSURL fileURLWithPath:self.extractedImagesDirPath];
            self.extractedImagesDirPath = [self.extractedImagesDirURL path];
            self.extractedImagesRelativeDir = [self.extractedImagesDirPath lastPathComponent];
        } else {
            self.extractedImagesDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.extractedImagesRelativeDir];
            self.extractedImagesDirURL = [NSURL fileURLWithPath:self.extractedImagesDirPath];
        }
        
        if (self.deleteExtractedImagesDirBeforeWrite && self.extractedImagesRelativeDir) {
            [FileUitl deleteSubDirOfTmp:self.extractedImagesRelativeDir];
            [FileUitl creatSubDirOfTmp:self.extractedImagesRelativeDir];
        }
    }
    

    
}



-(void) makeReaderReadyAndStart
{
    
    
    
    
    
    
    @autoreleasepool {
        
        if (self.applyOOBPT) {
            
            if (self.readerAsset == NULL) {
                self.readerAsset = [AVAsset assetWithURL:self.sourceVideoURL];
                NSError * error ;
                self.reader = [[AVAssetReader alloc] initWithAsset:self.readerAsset error:&error];
                self.sourceVideoTrack = [selectAllVideoTracksFromAVAsset(self.readerAsset) objectAtIndex:self.whichTrack];
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
                self.sourceVideoTrack = [selectAllVideoTracksFromAVAsset(self.readerAsset) objectAtIndex:self.whichTrack];
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
        self.sourceVideoTrack = [selectAllVideoTracksFromAVAsset(self.readerAsset) objectAtIndex:self.whichTrack];
        self.preferedTransform = [self.sourceVideoTrack preferredTransform];
        self.width = self.sourceVideoTrack.naturalSize.width;
        self.height = self.sourceVideoTrack.naturalSize.height;
        
        self.CIPT = [self.sourceVideoTrack preferredTransform];
        self.widthCIPT = self.width;
        self.heightCIPT = self.height;
        float width = self.widthCIPT;
        float height = self.heightCIPT;
        if (self.preferedTransform.a==0.0 && self.preferedTransform.b==1.0 && self.preferedTransform.c==-1.0 && self.preferedTransform.d == 0.0) {
            width = self.heightCIPT;
            height = self.widthCIPT;
            ////图像的旋转与layerInstruction pt 不同，逆时针为正,并且y向上,取像区域在第一象限
            self.CIPT = CGAffineTransformMake(0.0, -1.0, 1.0, 0.0, 0.0, height);
        } else if (self.preferedTransform.a==1.0 && self.preferedTransform.b==0.0 && self.preferedTransform.c==0.0 && self.preferedTransform.d == 1.0) {
        } else if (self.preferedTransform.a==-1.0 && self.preferedTransform.b==0.0 && self.preferedTransform.c==0.0 && self.preferedTransform.d == -1.0) {
        } else if (self.preferedTransform.a==0.0 && self.preferedTransform.b==-1.0 && self.preferedTransform.c==1.0 && self.preferedTransform.d == 0.0) {
            width = self.heightCIPT;
            height = self.widthCIPT;
            ////图像的旋转与layerInstruction pt 不同，逆时针为正,并且y向上,取像区域在第一象限
            self.CIPT = CGAffineTransformMake(0.0, 1.0,-1.0, 0.0, width, 0.0);
        } else {
            ////
        }
        self.widthCIPT = width;
        self.heightCIPT = height;
        
        

        
              
        
        self.readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:self.sourceVideoTrack outputSettings:nil];
        [self.reader addOutput:self.readerOutput];
        [self.reader startReading];
    }
    


}


void eachFrameCallback(void *decompressionOutputRefCon,
                                   void *sourceFrameRefCon,
                                   OSStatus status,
                                   VTDecodeInfoFlags infoFlags,
                                   CVImageBufferRef imageBuffer,
                                   CMTime presentationTimeStamp,
                                   CMTime duration)
{
    
    @autoreleasepool {
        VTDecomp *deoder = (__bridge VTDecomp *)decompressionOutputRefCon;

        if (status != noErr)
        {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Decompressed error: %@", error);
        }
        else
        {
            
            if (deoder.removeNegativeCMTime == YES) {
                if (presentationTimeStamp.value < 0 || presentationTimeStamp.timescale < 0 ) {
                    return;
                }
                
                if (duration.value < 0 || duration.timescale < 0) {
                    return;
                }
            } else {
                
            }
            
            CVPixelBufferLockBaseAddress(imageBuffer,0);
            ////除了 typeForBuffer = @"CVImage", 其他类型都要CI 这个中间过程 CVI-->CI-->CGI-->UI
            ////根据是否applyCIPT 来决定是否操作
            CIContext *temporaryContext = NULL;
            
            if ([deoder.typeForBuffer isEqualToString:@"CVImage"]) {
                ////if typeForBuffer = @"CVImage"  and  storeInDick == NO, will never applyCIPT
                deoder.eachExtractedCVImage = imageBuffer;
            } else if ([deoder.typeForBuffer isEqualToString:@"CGImage"]) {
                deoder.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                temporaryContext = [CIContext contextWithOptions:nil];
                if (deoder.applyCIPT) {
                    deoder.eachExtractedCIImage  = [deoder.eachExtractedCIImage imageByApplyingTransform:deoder.CIPT];
                    deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.widthCIPT, deoder.heightCIPT)];
                } else {
                    deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.width, deoder.height)];
                }
           } else if ([deoder.typeForBuffer isEqualToString:@"CIImage"]) {
                deoder.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                temporaryContext = [CIContext contextWithOptions:nil];
                 if (deoder.applyCIPT) {
                     deoder.eachExtractedCIImage  = [deoder.eachExtractedCIImage imageByApplyingTransform:deoder.CIPT];
                     deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.widthCIPT, deoder.heightCIPT)];
                 } else {
                     deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.width, deoder.height)];
                 }
            } else if ([deoder.typeForBuffer isEqualToString:@"UIImage"]) {
                deoder.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                temporaryContext = [CIContext contextWithOptions:nil];
                if (deoder.applyCIPT) {
                    deoder.eachExtractedCIImage  = [deoder.eachExtractedCIImage imageByApplyingTransform:deoder.CIPT];
                    deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.widthCIPT, deoder.heightCIPT)];
                } else {
                    deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.width, deoder.height)];
                }
                deoder.eachExtractedUIImage = [[UIImage alloc] initWithCGImage:deoder.eachExtractedCGImage scale:1.0 orientation:UIImageOrientationUp];
            }
            

            NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
            [parallel setValue:deoder.typeForBuffer forKey:@"type"];
            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"decodeTimeStamp"];
            [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"presentationTimeStamp"];
            [parallel setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
                ////decoder.currKeyFrameIndicator的更新和此处不同步，所以这里先用NO 占位
            [parallel setValue:[NSNumber numberWithBool:NO] forKey:@"isKeyFrame"];
            [parallel setValue:[NSNumber numberWithInt:deoder.goodSamCounts] forKey:@"origSeq"];
            
            
            if (deoder.storeInDisk) {
                
                if ([deoder.typeForBuffer isEqualToString:@"CVImage"]) {
                    deoder.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                    temporaryContext = [CIContext contextWithOptions:nil];
                    if (deoder.applyCIPT) {
                        deoder.eachExtractedCIImage  = [deoder.eachExtractedCIImage imageByApplyingTransform:deoder.CIPT];
                        deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.widthCIPT, deoder.heightCIPT)];
                    } else {
                        deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.width, deoder.height)];
                    }
                } else if ([deoder.typeForBuffer isEqualToString:@"CGImage"]) {
                    
                } else if ([deoder.typeForBuffer isEqualToString:@"CIImage"]) {
                    if (deoder.applyCIPT) {
                        deoder.eachExtractedCIImage  = [deoder.eachExtractedCIImage imageByApplyingTransform:deoder.CIPT];
                        deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.widthCIPT, deoder.heightCIPT)];
                    } else {
                        deoder.eachExtractedCGImage = [temporaryContext createCGImage:deoder.eachExtractedCIImage fromRect:CGRectMake(0, 0, deoder.width, deoder.height)];
                    }
                } else if ([deoder.typeForBuffer isEqualToString:@"UIImage"]) {
                    
                }
                

                NSString * label = [NSString stringWithFormat:@"%d",deoder.goodSamCounts];
                NSString * fileName = @"UIImage_";
                fileName = [fileName stringByAppendingString:label];
                fileName = [fileName stringByAppendingString:@"."];
                fileName = [fileName stringByAppendingString:deoder.extractedImageFormat];
                
                NSString * extractedImgPath;
                
                if ([deoder.typeForBuffer isEqualToString:@"UIImage"] ) {
                    extractedImgPath = [FileUitl saveUIImageToTmpFile:deoder.eachExtractedUIImage  fileName:fileName dirName:deoder.extractedImagesRelativeDir format:deoder.extractedImageFormat jpegQuality:deoder.extractedJPEGQuality];
                } else {
                    extractedImgPath = [FileUitl saveCGImageToTmpFile:deoder.eachExtractedCGImage  fileName:fileName dirName:deoder.extractedImagesRelativeDir format:deoder.extractedImageFormat jpegQuality:deoder.extractedJPEGQuality];
                }
                
                NSURL * extractedImgURL = [NSURL fileURLWithPath:extractedImgPath];
                fileName = @"TimeInfo_";
                fileName = [fileName stringByAppendingString:label];
                fileName = [fileName stringByAppendingString:@".txt"];
                fileName = [deoder.extractedImagesDirPath stringByAppendingPathComponent:fileName];
                [[NSFileManager defaultManager] createFileAtPath:fileName  contents:[parallel.description dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
                NSString * extractedInfoPath = fileName;
                NSURL * extractedInfoURL = [NSURL fileURLWithPath:extractedInfoPath];
                [parallel setValue:extractedImgURL forKey:@"extractedImgURL"];
                [parallel setValue:extractedImgPath forKey:@"extractedImgPath"];
                [parallel setValue:extractedInfoURL forKey:@"extractedInfoURL"];
                [parallel setValue:extractedInfoPath forKey:@"extractedInfoPath"];
                
            } else {
                if ([deoder.typeForBuffer isEqualToString:@"CVImage"]) {
                    [parallel setValue:(__bridge id)deoder.eachExtractedCVImage forKey:@"CVImage"];
                } else if ([deoder.typeForBuffer isEqualToString:@"CGImage"]) {
                    [parallel setValue:(__bridge id)deoder.eachExtractedCGImage forKey:@"CGImage"];
                } else if ([deoder.typeForBuffer isEqualToString:@"UIImage"]) {
                    [parallel setValue:deoder.eachExtractedUIImage forKey:@"UIImage"];
                } else {
                    [parallel setValue:deoder.eachExtractedCIImage forKey:@"CIImage"];
                }
                
            }
            [deoder.parallelArray addObject:parallel];
            
            
            if ([deoder.typeForBuffer isEqualToString:@"CVImage"]) {
                CGImageRelease(deoder.eachExtractedCGImage);
            } else if ([deoder.typeForBuffer isEqualToString:@"CGImage"]) {
                
            } else if ([deoder.typeForBuffer isEqualToString:@"UIImage"]) {
                CGImageRelease(deoder.eachExtractedCGImage);
            } else {
                CGImageRelease(deoder.eachExtractedCGImage);
            }

            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
            deoder.goodSamCounts ++;
            deoder.origGoodSamCounts ++;
        }
        
        ////we should not release CVImageBufferRef imageBuffer here

    }
    
  
}



-(void) makeVTDecompressionSession
{
    
    @autoreleasepool {
        
        self.decompressionSession = NULL;
        self.decompressionEachFrameCallback = eachFrameCallback;
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
    
        
        OSStatus status =  VTDecompressionSessionCreate(kCFAllocatorDefault,
                                                        self.decompressionVideoFormatDescription,
                                                        self.decompressionDecodeSpecification,
                                                        self.destinationImageBufferAttributes,
                                                        &callBackRecord,
                                                        &_decompressionSession);
        
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



-(void) makeDecomp {
    
    [self makeSourceVideoPathsAndURLsReady];
    [self makeDestinationImagePathsAndURLsReady];
    [self makeReaderReadyAndStart];
    
    self.keyFrameSigns = [[NSMutableArray  alloc] init];
    self.extractedImages = [[NSMutableArray alloc] init];
    self.presentationTimeStamps = [[NSMutableArray alloc] init];
    self.durations  = [[NSMutableArray alloc] init];
    self.decodeTimeStamps = [[NSMutableArray alloc] init];
    
    self.parallelArray = [[NSMutableArray  alloc] init];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long int date = (long long int)time;
    self.decompressionStartTime = [NSDate dateWithTimeIntervalSince1970:date];
    BOOL done = NO;
    self.goodSamCounts = 0;
    self.origGoodSamCounts = 0;
    
    
    BOOL firstGoodIFrame = NO;
    
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
                        CIContext *temporaryContext = NULL;
                        
                        if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                            ////if typeForBuffer = @"CVImage"  and  storeInDick == NO, will never applyCIPT
                            self.eachExtractedCVImage = imageBuffer;
                        } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                            self.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                            temporaryContext = [CIContext contextWithOptions:nil];
                            if (self.applyCIPT) {
                                self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                            } else {
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                            }
                        } else if ([self.typeForBuffer isEqualToString:@"CIImage"]) {
                            self.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                            temporaryContext = [CIContext contextWithOptions:nil];
                            if (self.applyCIPT) {
                                self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                            } else {
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                            }
                        } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                            self.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                            temporaryContext = [CIContext contextWithOptions:nil];
                            if (self.applyCIPT) {
                                self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                            } else {
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                            }
                            self.eachExtractedUIImage = [[UIImage alloc] initWithCGImage:self.eachExtractedCGImage scale:1.0 orientation:UIImageOrientationUp];
                        }
                        
                        
                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                        [parallel setValue:self.typeForBuffer forKey:@"type"];
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
                        if (self.storeInDisk) {
                            if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                                temporaryContext = [CIContext contextWithOptions:nil];
                                self.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                                if (self.applyCIPT) {
                                    self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                    self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                                } else {
                                    self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                                }
                                
                            } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                                
                            } else if ([self.typeForBuffer isEqualToString:@"CIImage"]) {
                                if (self.applyCIPT) {
                                    self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                    self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                                } else {
                                    self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                                }
                            } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                                
                            }
                            
                            NSString * label = [NSString stringWithFormat:@"%d",self.goodSamCounts];
                            NSString * fileName = @"UIImage_";
                            fileName = [fileName stringByAppendingString:label];
                            fileName = [fileName stringByAppendingString:@"."];
                            fileName = [fileName stringByAppendingString:self.extractedImageFormat];
                            
                            
                            NSString * extractedImgPath;
                            
                            if ([self.typeForBuffer isEqualToString:@"UIImage"] ) {
                                extractedImgPath = [FileUitl saveUIImageToTmpFile:self.eachExtractedUIImage  fileName:fileName dirName:self.extractedImagesRelativeDir format:self.extractedImageFormat jpegQuality:self.extractedJPEGQuality];
                            } else {
                                extractedImgPath = [FileUitl saveCGImageToTmpFile:self.eachExtractedCGImage  fileName:fileName dirName:self.extractedImagesRelativeDir format:self.extractedImageFormat jpegQuality:self.extractedJPEGQuality];
                            }
                            
                            NSURL * extractedImgURL = [NSURL fileURLWithPath:extractedImgPath];
                            fileName = @"TimeInfo_";
                            fileName = [fileName stringByAppendingString:label];
                            fileName = [fileName stringByAppendingString:@".txt"];
                            fileName = [self.extractedImagesDirPath stringByAppendingPathComponent:fileName];
                            [[NSFileManager defaultManager] createFileAtPath:fileName  contents:[parallel.description dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
                            NSString * extractedInfoPath = fileName;
                            NSURL * extractedInfoURL = [NSURL fileURLWithPath:extractedInfoPath];
                            [parallel setValue:extractedImgURL forKey:@"extractedImgURL"];
                            [parallel setValue:extractedImgPath forKey:@"extractedImgPath"];
                            [parallel setValue:extractedInfoURL forKey:@"extractedInfoURL"];
                            [parallel setValue:extractedInfoPath forKey:@"extractedInfoPath"];
                            
                        } else {
                            if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                                [parallel setValue:(__bridge id)self.eachExtractedCVImage forKey:@"CVImage"];
                            } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                                [parallel setValue:(__bridge id)self.eachExtractedCGImage forKey:@"CGImage"];
                            } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                                [parallel setValue:self.eachExtractedUIImage forKey:@"UIImage"];
                            } else {
                                [parallel setValue:self.eachExtractedCIImage forKey:@"CIImage"];
                            }
                            
                        }
                        [self.parallelArray addObject:parallel];
                        if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                            CGImageRelease(self.eachExtractedCGImage);
                        } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                            
                        } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                            CGImageRelease(self.eachExtractedCGImage);
                        } else {
                            CGImageRelease(self.eachExtractedCGImage);
                        }
                        
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
                                                                                  sourceFrameRefCon,
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
    

    
    
    
    
    
    while (!done)
    {
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

                        
                        CIContext *temporaryContext = NULL;
                        
                        if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                            ////if typeForBuffer = @"CVImage"  and  storeInDick == NO, will never applyCIPT
                            self.eachExtractedCVImage = imageBuffer;
                        } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                            self.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                            temporaryContext = [CIContext contextWithOptions:nil];
                            if (self.applyCIPT) {
                                self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                            } else {
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                            }
                        } else if ([self.typeForBuffer isEqualToString:@"CIImage"]) {
                            self.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                            temporaryContext = [CIContext contextWithOptions:nil];
                            if (self.applyCIPT) {
                                self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                            } else {
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                            }
                        } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                            self.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                            temporaryContext = [CIContext contextWithOptions:nil];
                            if (self.applyCIPT) {
                                self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                            } else {
                                self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                            }
                            self.eachExtractedUIImage = [[UIImage alloc] initWithCGImage:self.eachExtractedCGImage scale:1.0 orientation:UIImageOrientationUp];
                        }
                        
                        
                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                        [parallel setValue:self.typeForBuffer forKey:@"type"];
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
                        if (self.storeInDisk) {
                            if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                                temporaryContext = [CIContext contextWithOptions:nil];
                                self.eachExtractedCIImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
                                if (self.applyCIPT) {
                                    self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                    self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                                } else {
                                    self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                                }
                                
                            } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                                
                            } else if ([self.typeForBuffer isEqualToString:@"CIImage"]) {
                                if (self.applyCIPT) {
                                    self.eachExtractedCIImage  = [self.eachExtractedCIImage imageByApplyingTransform:self.CIPT];
                                    self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.widthCIPT, self.heightCIPT)];
                                } else {
                                    self.eachExtractedCGImage = [temporaryContext createCGImage:self.eachExtractedCIImage fromRect:CGRectMake(0, 0, self.width, self.height)];
                                }
                            } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                                
                            }
                            
                            NSString * label = [NSString stringWithFormat:@"%d",self.goodSamCounts];
                            NSString * fileName = @"UIImage_";
                            fileName = [fileName stringByAppendingString:label];
                            fileName = [fileName stringByAppendingString:@"."];
                            fileName = [fileName stringByAppendingString:self.extractedImageFormat];
                            
                            
                            NSString * extractedImgPath;
                            
                            if ([self.typeForBuffer isEqualToString:@"UIImage"] ) {
                                extractedImgPath = [FileUitl saveUIImageToTmpFile:self.eachExtractedUIImage  fileName:fileName dirName:self.extractedImagesRelativeDir format:self.extractedImageFormat jpegQuality:self.extractedJPEGQuality];
                            } else {
                                extractedImgPath = [FileUitl saveCGImageToTmpFile:self.eachExtractedCGImage  fileName:fileName dirName:self.extractedImagesRelativeDir format:self.extractedImageFormat jpegQuality:self.extractedJPEGQuality];
                            }
                            
                            NSURL * extractedImgURL = [NSURL fileURLWithPath:extractedImgPath];
                            fileName = @"TimeInfo_";
                            fileName = [fileName stringByAppendingString:label];
                            fileName = [fileName stringByAppendingString:@".txt"];
                            fileName = [self.extractedImagesDirPath stringByAppendingPathComponent:fileName];
                            [[NSFileManager defaultManager] createFileAtPath:fileName  contents:[parallel.description dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
                            NSString * extractedInfoPath = fileName;
                            NSURL * extractedInfoURL = [NSURL fileURLWithPath:extractedInfoPath];
                            [parallel setValue:extractedImgURL forKey:@"extractedImgURL"];
                            [parallel setValue:extractedImgPath forKey:@"extractedImgPath"];
                            [parallel setValue:extractedInfoURL forKey:@"extractedInfoURL"];
                            [parallel setValue:extractedInfoPath forKey:@"extractedInfoPath"];
                            
                        } else {
                            if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                                [parallel setValue:(__bridge id)self.eachExtractedCVImage forKey:@"CVImage"];
                            } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                                [parallel setValue:(__bridge id)self.eachExtractedCGImage forKey:@"CGImage"];
                            } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                                [parallel setValue:self.eachExtractedUIImage forKey:@"UIImage"];
                            } else {
                                [parallel setValue:self.eachExtractedCIImage forKey:@"CIImage"];
                            }

                        }
                        [self.parallelArray addObject:parallel];
                        if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                            CGImageRelease(self.eachExtractedCGImage);
                        } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                            
                        } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                            CGImageRelease(self.eachExtractedCGImage);
                        } else {
                            CGImageRelease(self.eachExtractedCGImage);
                        }

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
                                                                                  sourceFrameRefCon,
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
                    [self.reader cancelReading];
                    break;
                }
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
        
        
        ////decompressionOutputCallback 是异步的
        if (self.removeNegativeCMTime) {
            ////not complemented yet
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
                    
                    
                    
                    if (self.storeInDisk) {
                        NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                        parallel = self.parallelArray[i];
                        NSString * extractedImgPath = [parallel valueForKey:@"extractedImgPath"];
                        NSString * extractedInfoPath = [parallel valueForKey:@"extractedInfoPath"];
                        
                        NSError *error = nil;
                        [[NSFileManager defaultManager] removeItemAtPath:extractedImgPath error:&error];
                        
                        [[NSFileManager defaultManager] removeItemAtPath:extractedInfoPath error:&error];
                        
                        
                    }
                } else {
                    [bakParallelArray addObject:self.parallelArray[i]];
                }
                
                
                
                
            }
            
            
            self.parallelArray = NULL;
            self.parallelArray = bakParallelArray;
            bakParallelArray = NULL;


  
        }
        
        
       
        
        
        ////-----人工剔除frame
        
        
        
        
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
        
         
        
        
        
        if((self.reducedFrameNumerator > 0) && (self.reducedFrameDenominator > 0) && (self.reducedFrameNumerator < self.reducedFrameDenominator)) {

            if (self.storeInDisk) {
                ////需要修改 timeinfo txt
                for (int i = 0; i< self.parallelArray.count - 1; i++) {
                    NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                    parallel = self.parallelArray[i];
                    NSString * extractedInfoPath = [parallel valueForKey:@"extractedInfoPath"];
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:extractedInfoPath error:&error];
                    [[NSFileManager defaultManager] createFileAtPath:extractedInfoPath  contents:[parallel.description dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
                    
                }
            }
            

  
        }
        
        
        

       ////----如果人工降低frame rate 需要调整duration Time
        
       
        
        
        
        
        
        
        if (self.storeInDisk) {
            for (int i = 0; i< self.parallelArray.count; i++) {
                NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                parallel = self.parallelArray[i];
                int currSeq = i;
                NSString * extractedImgPath = [parallel valueForKey:@"extractedImgPath"];
                NSString * extractedInfoPath = [parallel valueForKey:@"extractedInfoPath"];
                
                NSString * newImgPath = [extractedImgPath stringByDeletingLastPathComponent];
                newImgPath = [newImgPath stringByAppendingPathComponent:@"_UIImage_"];
                newImgPath = [newImgPath stringByAppendingString:[NSString stringWithFormat:@"%d.",currSeq]];
                newImgPath = [newImgPath stringByAppendingString:self.extractedImageFormat];
                NSString * newInfoPath = [extractedInfoPath stringByDeletingLastPathComponent];
                newInfoPath = [newInfoPath stringByAppendingPathComponent:@"_TimeInfo_"];
                newInfoPath = [newInfoPath stringByAppendingString:[NSString stringWithFormat:@"%d.",currSeq]];
                newInfoPath = [newInfoPath stringByAppendingString:@"txt"];
                
                
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtPath:extractedImgPath toPath:newImgPath error:&error];
                [[NSFileManager defaultManager] moveItemAtPath:extractedInfoPath toPath:newInfoPath error:&error];
            }
            
            
            
            NSMutableArray *tempPaths = [[NSMutableArray alloc] init];
            tempPaths = [FileUitl getSpecificFilePathsOfSubDirOfTmp:@"UIImage" dirName:self.extractedImagesRelativeDir];
            
            
            
            
            [tempPaths sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                NSString * s1 = (NSString *) obj1;
                NSString * s2 = (NSString *) obj2;
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_UIImage_([0-9]+)"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                NSArray * matches1 = [regex matchesInString:s1
                                                    options:0
                                                      range:NSMakeRange(0, [s1 length])];
                NSArray * matches2 = [regex matchesInString:s2
                                                    options:0
                                                      range:NSMakeRange(0, [s2 length])];
                
                
                NSTextCheckingResult * match1 = matches1[0];
                NSTextCheckingResult * match2 = matches2[0];
                
                
                
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
            
            
            
            for (int i = 0; i < tempPaths.count; i++) {
                NSString * newImgPath = [tempPaths[i] stringByDeletingLastPathComponent];
                newImgPath = [newImgPath stringByAppendingPathComponent:@"UIImage_"];
                newImgPath = [newImgPath stringByAppendingString:[NSString stringWithFormat:@"%d.",i]];
                newImgPath = [newImgPath stringByAppendingString:self.extractedImageFormat];
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtPath:tempPaths[i] toPath:newImgPath error:&error];
            }
            
            
            
            
            
            tempPaths = [[NSMutableArray alloc] init];
            tempPaths = [FileUitl getSpecificFilePathsOfSubDirOfTmp:@"TimeInfo_" dirName:self.extractedImagesRelativeDir];
            
            
            
            
            [tempPaths sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                NSString * s1 = (NSString *) obj1;
                NSString * s2 = (NSString *) obj2;
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_TimeInfo_([0-9]+)"
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
            
            
            
            
            for (int i = 0; i < tempPaths.count; i++) {
                NSString * newImgPath = [tempPaths[i] stringByDeletingLastPathComponent];
                newImgPath = [newImgPath stringByAppendingPathComponent:@"TimeInfo_"];
                newImgPath = [newImgPath stringByAppendingString:[NSString stringWithFormat:@"%d.",i]];
                newImgPath = [newImgPath stringByAppendingString:@"txt"];
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtPath:tempPaths[i] toPath:newImgPath error:&error];
            }
            
            
            
        } else {

            if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                
                self.extractedCVImageRefs = CFArrayCreateMutable(NULL,  (CFIndex)self.parallelArray.count, &kCFTypeArrayCallBacks);
            }
            
            if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                self.extractedCGImageRefs = CFArrayCreateMutable(NULL,  (CFIndex)self.parallelArray.count, &kCFTypeArrayCallBacks);
            }
            
            for (int i = 0; i< self.parallelArray.count; i++) {
                NSMutableDictionary * parallel = [[NSMutableDictionary alloc] init];
                parallel = self.parallelArray[i];
                self.presentationTimeStamps[i] = [parallel valueForKey:@"presentationTimeStamp"];
                self.durations[i] = [parallel valueForKey:@"duration"];
                self.decodeTimeStamps[i] = [parallel valueForKey:@"decodeTimeStamp"];
                self.keyFrameSigns[i] = [parallel valueForKey:@"isKeyFrame"];
                
                if ([self.typeForBuffer isEqualToString:@"CVImage"]) {
                    
                    CFArrayAppendValue(self.extractedCVImageRefs, (__bridge CGImageRef)([parallel valueForKey:@"CVImage"]));
                    
                } else if ([self.typeForBuffer isEqualToString:@"CGImage"]) {
                    
                    CFArrayAppendValue(self.extractedCGImageRefs, (__bridge CGImageRef)([parallel valueForKey:@"CGImage"]));
                    
                } else if ([self.typeForBuffer isEqualToString:@"UIImage"]) {
                    self.extractedImages[i] = [parallel valueForKey:@"UIImage"];
                } else {
                    self.extractedImages[i] = [parallel valueForKey:@"CIImage"];
                }
                
                
                
            }
        }
        
    }
    
  
    
   time = [[NSDate date] timeIntervalSince1970];
   date = (long long int)time;
   self.decompressionEndTime = [NSDate dateWithTimeIntervalSince1970:date];
   NSTimeInterval costedTime = [self.decompressionEndTime timeIntervalSinceDate:self.decompressionStartTime];
   NSLog(@"timeCosted:%f",costedTime);
    
   self.decompressionFinished =YES;
    
    
    
    
    
    

    ////----
    if (self.storeInDisk) {
        [self resetParametersKeepPT];
    
    } else {
        
        [self resetParametersForNotStoreInDisk];
    }
    ////----
    

    
}







@end


/*

 */
