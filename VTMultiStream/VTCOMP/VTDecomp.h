//
//  VTDecomp.h
//  UView
//
//  Created by dli on 2/17/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#ifndef VTDecomp_h
#define VTDecomp_h


#endif /* VTDecomp_h */

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import<QuartzCore/QuartzCore.h>
#include <VideoToolbox/VideoToolbox.h>
#import "FileUtil.h"
#import "coreMediaPrint.h"

@interface VTDecomp : NSObject

@property (nonatomic,copy) NSString * sourceVideoFilename;
@property (nonatomic,copy) NSString * sourceVideoRelativeDir;
@property (nonatomic,copy) NSString * sourceVideoPath;
@property (nonatomic,retain) NSURL * sourceVideoURL;
@property (nonatomic,retain) AVAssetReader *reader;
@property (nonatomic,retain) AVAsset *readerAsset;
@property (atomic,assign) int whichTrack;
@property (nonatomic,retain) AVAssetTrack * sourceVideoTrack;
@property (atomic,assign) CGAffineTransform preferedTransform;
    //// 直接从videoTrack读出的preferedTransform,可以应用于AVFoundation layerInstruction
@property (atomic,assign) float height;
@property (atomic,assign) float width;
@property (atomic,assign) BOOL applyOOBPT;

@property (atomic,assign) BOOL applyCIPT;
    ////是否在解压过程中纠正图像
    ////if typeForBuffer = @"CVImage"  and  storeInDick == NO, will never applyCIPT
    ////you should keep the PT and CIPT for furture use
@property (atomic,assign) CGAffineTransform CIPT;
    //// 从preferedTransform变换而来，给CIImage 用
@property (atomic,assign) float heightCIPT;
@property (atomic,assign) float widthCIPT;
    ////for internal use , not for scale,  the real with and height after CIPT
@property (nonatomic,retain) AVAssetReaderTrackOutput* readerOutput;


@property (atomic,assign) BOOL storeInDisk;
@property (atomic,assign) BOOL deleteExtractedImagesDirBeforeWrite;
@property (nonatomic,copy) NSString * extractedImagesRelativeDir;
@property (nonatomic,copy) NSString * extractedImagesDirPath;
@property (nonatomic,retain) NSURL * extractedImagesDirURL;
@property (nonatomic,copy) NSString * extractedImageFormat;
    ////png or jpeg
@property (atomic,assign) float extractedJPEGQuality;
   ////0.0 -1.0

@property (nonatomic,copy) NSString * typeForBuffer;
@property (atomic,assign) CVImageBufferRef eachExtractedCVImage;
@property (nonatomic,retain) CIImage * eachExtractedCIImage;
@property (atomic,assign) CGImageRef eachExtractedCGImage;
@property (nonatomic,retain) UIImage * eachExtractedUIImage;



@property (atomic,assign) CFMutableArrayRef extractedCVImageRefs;
@property (nonatomic,retain) NSMutableArray * extractedImages;
    ////could be used to store UIImages  or CIImages
@property (atomic,assign) CFMutableArrayRef extractedCGImageRefs;
@property (nonatomic,retain) NSMutableArray * presentationTimeStamps;
@property (nonatomic,retain) NSMutableArray * decodeTimeStamps;
@property (nonatomic,retain) NSMutableArray * durations;
@property (nonatomic,retain) NSMutableArray * keyFrameSigns;

@property (atomic,assign) BOOL currKeyFrameIndicator;
////just for pass value to callback function when blockbuffer
@property (nonatomic,retain) NSMutableArray * parallelArray;
@property (atomic,assign) int goodSamCounts;
@property (atomic,assign) int origGoodSamCounts;
@property (atomic,assign) VTDecompressionSessionRef decompressionSession;
@property (atomic,assign) VTDecompressionOutputCallback decompressionEachFrameCallback;
@property (atomic,assign) BOOL constructDestinationImageBufferAttributesFromKeyValue;
@property (atomic,assign) CFDictionaryRef destinationImageBufferAttributes;
@property (atomic,assign) unsigned int destinationImageBufferKCVPixelFormatType;
@property (atomic,assign) BOOL constructDecompressionDecodeSpecificationFromKeyValue;
@property (atomic,assign) CFDictionaryRef decompressionDecodeSpecification;
@property (atomic,assign) CMVideoFormatDescriptionRef decompressionVideoFormatDescription;




@property (atomic,assign) BOOL sortImagesAfterDecompression;
@property (atomic,assign) BOOL newSessionEachKeyFrame;
@property (atomic,assign) BOOL removeNegativeCMTime;
    ////
@property (atomic,assign) int reducedFrameNumerator;
@property (atomic,assign) int reducedFrameDenominator;
   //// reducedFrameNumerator = 2
   //// reducedFrameDenominator = 5
   //// 此时每5 frames 丢弃 2 frames
   //// the implement cant be drop during decode , must be dropped after decode , coz the prev  will cause blur and bad image
   //// if use this two parameters, must handle the output presentationTimeStamp 







@property (nonatomic,retain) NSDate * decompressionStartTime;
@property (nonatomic,retain) NSDate * decompressionEndTime;
@property (atomic,assign) BOOL decompressionFinished;


-(void) readMe;
-(void) resetParameters;
-(void) printAndCheckParameters;
-(void) makeSourceVideoPathsAndURLsReady;
-(void) makeDestinationImagePathsAndURLsReady;
-(void) makeReaderReadyAndStart;
-(void) makeVTDecompressionSession;
-(void) makeDecomp;
-(void) resetParametersForNotStoreInDisk;

@end