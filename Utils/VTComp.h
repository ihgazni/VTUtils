//
//  VTComp.h
//  UView
//
//  Created by dli on 2/5/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#ifndef VTComp_h
#define VTComp_h


#endif /* VTComp_h */
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import<QuartzCore/QuartzCore.h>
#include <VideoToolbox/VideoToolbox.h>
#import "FileUtil.h"
#import "coreMediaPrint.h"


@interface VTComp : NSObject

@property (atomic,assign) BOOL compressionMultiPassEnabled;
@property (atomic,assign) int howManyPasses;
    ////if = 0; means exec until no further pass could be execed
@property (atomic,assign) int currPassRound;
@property (atomic,assign) BOOL furtherPass;
@property (atomic,assign) VTFrameSiloRef siloOut;
   ////multiPass siloOut
@property (atomic,assign) CMTimeRange multiPassStorageCMTimeRange;
   ////used to creat multi Pass Storage
@property (atomic,assign) VTMultiPassStorageRef multiPassStorageOut;
@property (atomic,assign) BOOL multiPassStorageCreationOption_DoNotDelete;
@property (nonatomic, strong,retain) NSMutableArray * nextPassStartSeqs;
@property (nonatomic, strong,retain) NSMutableArray * nextPassEndSeqs;
@property (nonatomic, strong,retain) NSMutableArray * nextIgnoreStartSeqs;
@property (nonatomic, strong,retain) NSMutableArray * nextIgnoreEndSeqs;

@property (nonatomic, strong,retain) NSMutableArray * presentationTimeStamps;
@property (nonatomic, strong,retain) NSMutableArray * durations;
@property (nonatomic, strong,retain) NSMutableArray * sourceImageURLs;
@property (nonatomic, strong,retain) NSMutableArray * sourceImagePaths;
@property (nonatomic, strong,retain) NSMutableArray * sourceInfoURLs;
@property (nonatomic, strong,retain) NSMutableArray * sourceInfoPaths;
@property (nonatomic, strong,retain) NSString * sourceImageFileNamePattern;
@property (nonatomic, strong,retain) NSString * sourceInfoFileNamePattern;
@property (nonatomic, strong,retain) NSURL * sourceDirURL;
@property (nonatomic, strong,retain) NSString * sourceDirPath;
@property (nonatomic, strong,retain) NSString * sourceRelativeDirPath;
@property (atomic,assign) BOOL deleteSourcesAfterCopyToAlbum;
    ////delete source images and infoFiles
@property (atomic,assign) BOOL deleteOutputFileInSandboxAfterCopyToAlbum;
@property (atomic,assign) BOOL deleteSourceOneByOneAfterAppendSinglePass;
@property (atomic,assign) BOOL deleteSourceOneByOneAfterAppendMultiPass;
@property (nonatomic, strong,retain) NSMutableArray * sourceUIImages;
@property (atomic, assign) CFMutableArrayRef sourceCGImageRefs;
@property (atomic, assign) CFMutableArrayRef sourceCVImageBuffers;


@property (atomic,assign) float height;
@property (atomic,assign) float width;
@property (nonatomic, strong,retain) NSString * writerOutputFileType;
@property (nonatomic, strong,retain) AVAssetWriter *writer;
@property (nonatomic, strong,retain) AVAssetWriterInput *writerInput;
@property (nonatomic, strong,retain) AVAssetWriterInputPixelBufferAdaptor *writerPixelBufferAdaptor;
@property (nonatomic, strong,retain) dispatch_queue_t writerInputSerialQueue;
@property (nonatomic, strong,retain) dispatch_queue_t writerInputConcurrentQueue;
@property (atomic,assign) BOOL deleteOutputDirBeforeWrite;
@property (nonatomic,strong,retain) NSString * writerOutputFileName;
@property (nonatomic, strong,retain) NSString * writerOutputRelativeDirPath;
@property (nonatomic, strong,retain) NSString * writerOutputPath;
@property (nonatomic, strong,retain) NSURL * writerOutputURL;

@property (atomic,assign) CMVideoCodecType	compressionCodecType;
@property (atomic,assign) CFMutableDictionaryRef  compressionEncoderSpecification;
@property (atomic,assign) BOOL compressionEncoderSpecificationConstructFromKeyValue;
@property (nonatomic,strong,retain) NSString * encoderID;
@property (atomic,assign) CFDictionaryRef compressionSourceImageBufferAttributes;
@property (atomic,assign) BOOL compressionSourceImageBufferAttributesConstructFromKeyValue;
@property (atomic,assign) SInt32         compressionCVPixelFormatTypeValue;
    ////kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    ////kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    ////kCVPixelFormatType_32BGRA
@property (atomic,assign) VTCompressionSessionRef compressionSession;
@property (atomic,assign) CFDictionaryRef compressionSessionProperties;
@property (atomic,assign) BOOL compressionSessionPropertiesConstructFromKeyValue;
@property (atomic,assign) BOOL compressionAllowFrameReordering;
    ////imagesToVideo if fail, set this to False
    ////i dont know  why,  images to video  this must be set to False
    ////Code=-11829,OSStatus 错误 -12848
@property (atomic,assign) BOOL compressionAllowTemporalCompression;
@property (atomic,assign) BOOL compressionCleanApertureConstructFromKeyValue;
    ////VTSessionSetCleanApertureFromValues(self->compressionSession,cleanApertureWidth,cleanApertureHeight,cleanApertureHorizontalOffset,cleanApertureVerticalOffset);
    ////clean aperture 的播放效果就是crop,但是实际大小不变
@property (atomic,assign) CFDictionaryRef compressionCleanAperture;
@property (atomic,assign) int  cleanApertureWidth;
@property (atomic,assign) int  cleanApertureHeight;
@property (atomic,assign) int  cleanApertureHorizontalOffset;
@property (atomic,assign) int  cleanApertureVerticalOffset;
@property (atomic,assign) int compressionAverageBitRate;
@property (atomic,assign) CFStringRef compressionColorPrimaries;
    ////kCMFormatDescriptionColorPrimaries_ITU_R_709_2
    ////kCMFormatDescriptionColorPrimaries_EBU_3213
    ////kCMFormatDescriptionColorPrimaries_SMPTE_C
@property (atomic,assign) int compressionFieldCount;
    ////1 progressive
    ////2 interlaced
@property (atomic,assign) CFStringRef compressionFieldDetail;
    ////kCMFormatDescriptionFieldDetail_SpatialFirstLineEarly;
    ////kCMFormatDescriptionFieldDetail_SpatialFirstLineLate;
    ////kCMFormatDescriptionFieldDetail_TemporalBottomFirst;
    ////kCMFormatDescriptionFieldDetail_TemporalTopFirst;
@property (atomic,assign) CFStringRef compressionH264EntropyMode;
    ////kVTH264EntropyMode_CAVLC
    ////kVTH264EntropyMode_CABAC
@property (atomic,assign) int compressionMaxFrameDelayCount;
    ////kVTUnlimitedFrameDelayCount
@property (atomic,assign) int compressionMaxKeyFrameInterval;
    ////there must be a KeyFrame every compressionMaxKeyFrameInterval
@property (atomic,assign) int compressionMaxKeyFrameIntervalDuration;
@property (atomic,assign) BOOL compressionPixelAspectRatioConstructFromKeyValue;
    ////----PixelAspectRatio,效果相当于缩放像素本身，
    ////----h < v 不会改变dimension.
    ////----h > v 不会改变dimension,  But will make average bitrate no effect. 并且quickTime显示大小变了
    ////----h < v, for example:1:2 实际dimensions: 1280 x 720 不变 ，像素本身变为1:2 显示效果变为 640 X 720，quickTime显示1280 X 720(640 X 720)
    ////----h > v,for example:6:5 实际dimensions: 1280 x 720 不变 ，像素本身变为1:2 显示效果变为 640 X 720, quickTime显示1280 X 600
@property (atomic,assign) CFDictionaryRef compressionPixelAspectRatio;
@property (atomic,assign) int pixelAspectRatioHorizontalSpacing;
@property (atomic,assign) int pixelAspectRatioVerticalSpacing;
@property (atomic,assign) CFStringRef compressionProfilelevel;
@property (atomic,assign) BOOL compressionRealTime;
@property (atomic,assign) CFStringRef compressionTransferFunction;
    ////kCMFormatDescriptionTransferFunction_ITU_R_709_2
    ////kCMFormatDescriptionTransferFunction_SMPTE_240M_1995
    ////kCMFormatDescriptionTransferFunction_UseGamma
@property (atomic,assign) CFStringRef compressionYCbCrMatrix;
    ////kCMFormatDescriptionYCbCrMatrix_ITU_R_709_2
    ////kCMFormatDescriptionYCbCrMatrix_ITU_R_601_4
    ////kCMFormatDescriptionYCbCrMatrix_SMPTE_240M_1995
@property (atomic,assign) VTCompressionOutputCallback compressionEachSampleBufferCallback;
@property (nonatomic, strong,retain) dispatch_queue_t VTCompressProcessingSerialQueue;
@property (nonatomic, strong,retain) dispatch_queue_t VTCompressProcessingConcurrentQueue;
@property (nonatomic, strong,retain) NSMutableArray * forceKeyFrameSigns;
    ////used to set frameProperties in VTCompressionSessionEncodeFrame for each frame
@property (atomic,assign) int compressionSourcesCount;
@property (atomic,assign) int compressionSourceSeq;
@property (atomic,assign) BOOL compressionFinished;

@property (nonatomic, strong,retain) NSDate * compressionStartTime;
@property (nonatomic, strong,retain) NSDate * compressionEndTime;

-(void) resetParameters;
-(void) printAndCheckParameters;
-(void) makeSourceInfoPathsAndURLsReady;
-(void) makeSourceImagePathsAndURLsReady;
-(void) makePresentationsAndDurationsReady;
-(void) makeReorderViaPresentation;
-(void) makeWidthAndHeightReady;
-(void) makeWriterReadyAndStart;
-(void) makeVTCompressionSession;
-(void) makeVTSessionPropertiesReadyAndStart;
-(void) makeVTencodeEachFrameSinglePass;
-(void) makeVTencodeEachFrameMultiPass;
-(void) makeFinalOutputFile;
-(void) makeCompress;



@end



////----reference:
////printVTCompressionSessionSupportedProperties(self->compressionSession);
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_AllowFrameReordering);
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_AllowTemporalCompression);
////printVTCompressionSessionPropertyValue(self->compressionSession, kVTCompressionPropertyKey_CleanAperture);
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_AverageBitRate);
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_ColorPrimaries);
//==printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_AspectRatio16x9);
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_DataRateLimits);
////==printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_Depth);
////default = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_ExpectedDuration);
////default = 0
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_ExpectedFrameRate);
////default = 30
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_FieldCount);
////1 progressive
////2 interlaced
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_FieldDetail);
////kCMFormatDescriptionFieldDetail_SpatialFirstLineEarly;
////kCMFormatDescriptionFieldDetail_SpatialFirstLineLate;
////kCMFormatDescriptionFieldDetail_TemporalBottomFirst;
////kCMFormatDescriptionFieldDetail_TemporalTopFirst;
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_H264EntropyMode);
////kVTH264EntropyMode_CAVLC
////kVTH264EntropyMode_CABAC
////==printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_ICCProfile);
////CFData
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_MaxFrameDelayCount);
////default kVTUnlimitedFrameDelayCount
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_MaxH264SliceBytes);
////not Supported
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_MaxKeyFrameInterval);
////default 30
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration);
////default 0
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_MoreFramesAfterEnd);
////not supported
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_MoreFramesBeforeStart);
////not supported
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_MultiPassStorage);
////VTMultiPassStorageRef
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_NumberOfPendingFrames);
//// for reading
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_PixelAspectRatio);
////kCMFormatDescriptionKey_PixelAspectRatioHorizontalSpacing // CFNumber
////kCMFormatDescriptionKey_PixelAspectRatioVerticalSpacing	 // CFNumber
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_PixelBufferPoolIsShared);
////default False
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_PixelTransferProperties);
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_ProfileLevel);
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_ProgressiveScan);
////not supported
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_Quality);
////not for H.264
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_RealTime);
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_SourceFrameCount);
////default 0
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_TransferFunction);
////kCMFormatDescriptionTransferFunction_ITU_R_709_2
////kCMFormatDescriptionTransferFunction_SMPTE_240M_1995
////kCMFormatDescriptionTransferFunction_UseGamma
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_VideoEncoderPixelBufferAttributes);
/*
 这个数值是被  VTCompressionSessionCreate 时的 compressionSourceImageBufferAttributes  初始化的
 2016-02-08 16:44:39.233 yesview[1916:2616682] key:VideoEncoderPixelBufferAttributes
 2016-02-08 16:44:39.235 yesview[1916:2616682] value:{
 BytesPerRowAlignment = 64;
 CacheMode =     (
 1024,
 0,
 256,
 512,
 768,
 1280
 );
 Height = 720;
 IOSurfaceProperties =     {
 IOSurfaceIsGlobal = 1;
 };
 PixelFormatType =     (
 875704438,
 875704422,
 2033463856,
 1714696752
 );
 PlaneAlignment = 64;
 Width = 1280;
 }
 */
////printVTCompressionSessionPropertyValue(self->compressionSession,kVTCompressionPropertyKey_YCbCrMatrix);
////kCMFormatDescriptionYCbCrMatrix_ITU_R_709_2
////kCMFormatDescriptionYCbCrMatrix_ITU_R_601_4
////kCMFormatDescriptionYCbCrMatrix_SMPTE_240M_1995
////-reference
