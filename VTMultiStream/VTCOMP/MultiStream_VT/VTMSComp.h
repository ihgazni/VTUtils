//
//  VTMSComp.h
//  UView
//
//  Created by dli on 3/12/16.
//  Copyright © 2016 YesView. All rights reserved.
//


#ifndef VTMSComp_h
#define VTMSComp_h


#endif /* VTMSComp_h */



#import "VTMSDecomp.h"




@protocol MSFilterDelegate

@optional
-(void) forNextVersionUse;
@end







@interface VTMSComp : NSObject



////multiStreamSyncBuff
@property (atomic,assign) int maxStreamOfMSBuffers;
@property (nonatomic,retain) NSMutableArray * MSBuffers;
@property (nonatomic,retain) NSMutableArray * streams;


@property  (atomic, retain) dispatch_semaphore_t MSCanCompSema;



@property (nonatomic, strong,retain) dispatch_queue_t VTRecompressProcessingConcurrentQueue;
@property (nonatomic,retain) NSMutableDictionary * framesOfThisRound;
////multiStreamSyncBuff


////writer:
@property (nonatomic, strong,retain) NSString * writerOutputFileType;
@property (nonatomic, strong,retain) AVAssetWriter *writer;
@property (atomic,assign) BOOL writerShouldOptimizeForNetworkUse;
@property (nonatomic, strong,retain) AVAssetWriterInput *writerInput;
@property (nonatomic, strong,retain) AVAssetWriterInputPixelBufferAdaptor *writerPixelBufferAdaptor;
@property (atomic,assign) BOOL deleteOutputDirBeforeWrite;
@property (nonatomic,strong,retain) NSString * writerOutputFileName;
@property (nonatomic,strong,retain) NSString * writerOutputRelativeDirPath;
@property (nonatomic,strong,retain) NSString * writerOutputPath;
@property (nonatomic,strong,retain) NSURL * writerOutputURL;


////多流合成时候的 为了保证一致性，必须采用强制指定的duration, presentation从kCMTimeZero开始
@property (atomic,assign) CMTime compPresentationTimeStamp;
@property (atomic,assign) CMTime compDuration;
////



////
@property (atomic,assign) BOOL applyFilter;
@property (atomic,assign) int filterNumber;
@property (atomic,assign) CVPixelBufferPoolRef pixelBufferPool;
@property (atomic,assign) int minimumBufferCount;
@property (atomic,assign) int maximumBufferAge;
@property (atomic,assign) OSType pixelBufferFormatType;

////MS 这里需要时一个数组,数组中的元素是 GPUImageCVPixelBufferRefInput * CVPBRefInput;
@property (nonatomic,retain) NSMutableArray * CVPBRefInputs;






@property (nonatomic,retain) GPUImageFilter * initedFilter;
@property (nonatomic,retain) GPUImageFilter * terminatedFilter;
@property (atomic,assign) BOOL enablePreviousResultsBuffers;
@property (nonatomic,retain) NSMutableArray * previousResultsBuffers;
@property (atomic,assign) int previousResultsBuffersCapacity;
@property (nonatomic,retain) GPUImageCVPixelBufferRefOutput * CVPBRefOutput;
@property (nonatomic, weak) id<MSFilterDelegate> MSFilterDelegate;

@property (atomic,assign) float estimatedSourceTotalFramesCount;


/*
    weak指针主要用于“父-子”关系，父亲拥有一个儿子的strong指针，因此是儿子的所有者；
    但是为了阻止所有权回环，儿子需要使用weak指针指向父亲；
    你的viewcontroller通过strong指针拥有一个UITableview，
    tableview的datasource和delegate都是weak指针，指向viewcontroller，防止回环；
*/




@property (nonatomic,retain) NSDate * recompressionStartTime;




////


@property (atomic,assign) float compSessionHeight;
@property (atomic,assign) float compSessionWidth;


@property (atomic,assign) BOOL keepKeyFrameSigns;
@property (atomic,assign) int compressionSourcesCount;
@property (atomic,assign) int compressionSourceSeq;
////
@property (atomic,assign) CMVideoCodecType compressionCodecType;
@property (atomic,assign) CFMutableDictionaryRef  compressionEncoderSpecification;
@property (atomic,assign) BOOL compressionEncoderSpecificationConstructFromKeyValue;
@property (nonatomic,strong,retain) NSString * encoderID;
@property (nonatomic,strong,retain) NSString * CodecName;
@property (atomic,assign)  int	 CodecType;
@property (nonatomic,strong,retain) NSString * DisplayName;
@property (nonatomic,strong,retain) NSString * EncoderName;
@property (atomic,assign) CFDictionaryRef compressionSourceImageBufferAttributes;
@property (atomic,assign) BOOL compressionSourceImageBufferAttributesConstructFromKeyValue;
@property (atomic,assign) SInt32         compressionCVPixelFormatTypeValue;
////kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
////kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
////kCVPixelFormatType_32BGRA
@property (atomic,assign) VTCompressionSessionRef compressionSession;
@property (atomic,assign) VTCompressionOutputCallback compressionEachSampleBufferCallback;
////
@property (atomic,assign) CFDictionaryRef compressionSessionProperties;
@property (atomic,assign) BOOL compressionSessionPropertiesConstructFromKeyValue;
@property (atomic,assign) BOOL compressionAllowFrameReordering;
//////imagesToVideo if fail, set this to False
//////i dont know  why,  images to video  this must be set to False
//////Code=-11829,OSStatus 错误 -12848
@property (atomic,assign) BOOL compressionAllowTemporalCompression;
@property (atomic,assign) BOOL compressionCleanApertureConstructFromKeyValue;
//////VTSessionSetCleanApertureFromValues(self->compressionSession,cleanApertureWidth,cleanApertureHeight,cleanApertureHorizontalOffset,cleanApertureVerticalOffset);
//////clean aperture 的播放效果就是crop,但是实际大小不变
@property (atomic,assign) CFDictionaryRef compressionCleanAperture;
@property (atomic,assign) int  cleanApertureWidth;
@property (atomic,assign) int  cleanApertureHeight;
@property (atomic,assign) int  cleanApertureHorizontalOffset;
@property (atomic,assign) int  cleanApertureVerticalOffset;
@property (atomic,assign) int compressionAverageBitRate;
@property (atomic,assign) CFStringRef compressionColorPrimaries;
//////kCMFormatDescriptionColorPrimaries_ITU_R_709_2
//////kCMFormatDescriptionColorPrimaries_EBU_3213
//////kCMFormatDescriptionColorPrimaries_SMPTE_C
@property (atomic,assign) int compressionFieldCount;
//////1 progressive
//////2 interlaced
@property (atomic,assign) CFStringRef compressionFieldDetail;
//////kCMFormatDescriptionFieldDetail_SpatialFirstLineEarly;
//////kCMFormatDescriptionFieldDetail_SpatialFirstLineLate;
//////kCMFormatDescriptionFieldDetail_TemporalBottomFirst;
//////kCMFormatDescriptionFieldDetail_TemporalTopFirst;
@property (atomic,assign) CFStringRef compressionH264EntropyMode;
//////kVTH264EntropyMode_CAVLC
//////kVTH264EntropyMode_CABAC
@property (atomic,assign) int compressionMaxFrameDelayCount;
//////kVTUnlimitedFrameDelayCount
@property (atomic,assign) int compressionMaxKeyFrameInterval;
//////there must be a KeyFrame every compressionMaxKeyFrameInterval
@property (atomic,assign) int compressionMaxKeyFrameIntervalDuration;
@property (atomic,assign) BOOL compressionPixelAspectRatioConstructFromKeyValue;
//////----PixelAspectRatio,效果相当于缩放像素本身，
//////----h < v 不会改变dimension.
//////----h > v 不会改变dimension,  But will make average bitrate no effect. 并且quickTime显示大小变了
//////----h < v, for example:1:2 实际dimensions: 1280 x 720 不变 ，像素本身变为1:2 显示效果变为 640 X 720，quickTime显示1280 X 720(640 X 720)
//////----h > v,for example:6:5 实际dimensions: 1280 x 720 不变 ，像素本身变为1:2 显示效果变为 640 X 720, quickTime显示1280 X 600
@property (atomic,assign) CFDictionaryRef compressionPixelAspectRatio;
@property (atomic,assign) int pixelAspectRatioHorizontalSpacing;
@property (atomic,assign) int pixelAspectRatioVerticalSpacing;
@property (atomic,assign) CFStringRef compressionProfilelevel;
@property (atomic,assign) BOOL compressionRealTime;
@property (atomic,assign) CFStringRef compressionTransferFunction;
//////kCMFormatDescriptionTransferFunction_ITU_R_709_2
//////kCMFormatDescriptionTransferFunction_SMPTE_240M_1995
//////kCMFormatDescriptionTransferFunction_UseGamma
@property (atomic,assign) CFStringRef compressionYCbCrMatrix;
//////kCMFormatDescriptionYCbCrMatrix_ITU_R_709_2
//////kCMFormatDescriptionYCbCrMatrix_ITU_R_601_4
//////kCMFormatDescriptionYCbCrMatrix_SMPTE_240M_1995
@property (atomic,assign) int compressionExpectedFrameRate;
////
@property (atomic,assign) CMTime endSessionAtSourceTime;
////在eachSampleBufferCallbackOfMSComp回调中被更新
@property (atomic,assign) BOOL compressionFinished;
@property (nonatomic,retain) NSDate * recompressionEndTime;
////在self.writer finishWritingWithCompletionHandler中被更新
@property (atomic,assign) BOOL deleteOutputFileInSandboxAfterCopyToAlbum;
@property (atomic,assign) BOOL writeToAlbum;
@property (atomic,assign) BOOL SYNC;
////
@property (atomic,assign) BOOL enableProgressIndication;
@property (atomic,assign) float progressIndicationTimerInterval;
@property (atomic,assign) float progressIndication;
@property (atomic,assign) float currentIndication;
@property (atomic,assign) float totalIndication;


-(void) readMe;
-(void) resetParameters;
-(void) makeMSinit;
-(void) addDecompStream:(VTMSDecomp*)stream;


-(void) makeVTCompressionSession;
-(void) makeVTSessionPropertiesReadyAndStart;


-(void) makeFinalOutputFile;
-(void) makeRecomp;

@end


