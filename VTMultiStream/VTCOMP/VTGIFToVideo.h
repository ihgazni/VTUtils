//
//  VTGIFToVideo.h
//  UView
//
//  Created by dli on 2/5/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#ifndef VTGIFToVideo_h
#define VTGIFToVideo_h


#endif /* VTVTGIFToVideo_h */
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import<QuartzCore/QuartzCore.h>
#include <VideoToolbox/VideoToolbox.h>
#import "FileUtil.h"
#import "coreMediaPrint.h"
#import "UIImageTools.h"


@interface VTGIFToVideo : NSObject

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

@property (atomic,assign) BOOL applyCIPT;
    ////是否在解压过程中纠正图像
    ////if typeForBuffer = @"CVImage"  and  storeInDick == NO, will never applyCIPT
    ////you should keep the PT and CIPT for furture use
@property (atomic,assign) CGAffineTransform CIPT;
    //// 从preferedTransform变换而来，给CIImage 用
@property (atomic,assign) float heightCIPT;
@property (atomic,assign) float widthCIPT;


@property (atomic,assign) BOOL applyOOBPT;
@property (atomic,assign) CGAffineTransform preferedTransform;


@property (nonatomic, strong,retain) NSMutableArray * presentationTimeStamps;
@property (atomic,assign) BOOL useOnlyDurations;
@property (atomic,assign) BOOL useOnlyPresentations;
@property (nonatomic, strong,retain) NSMutableArray * durations;
@property (nonatomic, strong,retain) NSURL * sourceGIFURL;
@property (nonatomic, strong,retain) NSString * sourceGIFPath;
@property (nonatomic, strong,retain) NSData * GIFData;
@property (atomic,assign) CGImageSourceRef GIFCGImageSource;
@property (atomic,assign) unsigned long GIFImageSourceCount;

@property (atomic,assign) BOOL deleteSourcesAfterCopyToAlbum;
    ////delete source images and infoFiles
@property (atomic,assign) BOOL deleteOutputFileInSandboxAfterCopyToAlbum;





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
@property (nonatomic,strong,retain) NSString * CodecName;
@property (atomic,assign)  int	 CodecType;
@property (nonatomic,strong,retain) NSString * DisplayName;
@property (nonatomic,strong,retain) NSString * encoderID;
@property (nonatomic,strong,retain) NSString * EncoderName;
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
@property (atomic,assign) BOOL writeToAlbum;
@property (nonatomic, strong,retain) NSDate * compressionStartTime;
@property (nonatomic, strong,retain) NSDate * compressionEndTime;
@property (atomic,assign) BOOL SYNC;



-(void) readMe;
-(void) resetParameters;
-(void) resetParametersAtEnd;
-(void) printAndCheckParameters;
-(void) makeSourceGIFPathsAndURLsReady;
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




