//
//  VTRecomp.h
//  UView
//
//  Created by dli on 3/8/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#ifndef VTRecomp_h
#define VTRecomp_h


#endif /* VTRecomp_h */


#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import<QuartzCore/QuartzCore.h>
#include <VideoToolbox/VideoToolbox.h>
#import "FileUtil.h"
#import "coreMediaPrint.h"

@interface VTRecomp : NSObject
////source
@property (nonatomic,retain) NSURL * sourceVideoURL;
@property (nonatomic,copy) NSString * sourceVideoPath;
@property (nonatomic,copy) NSString * sourceVideoFilename;
@property (nonatomic,copy) NSString * sourceVideoRelativeDir;
////writer:
@property (nonatomic, strong,retain) NSString * writerOutputFileType;
@property (nonatomic, strong,retain) AVAssetWriter *writer;
@property (nonatomic, strong,retain) AVAssetWriterInput *writerInput;
@property (nonatomic, strong,retain) AVAssetWriterInputPixelBufferAdaptor *writerPixelBufferAdaptor;
@property (atomic,assign) BOOL deleteOutputDirBeforeWrite;
@property (nonatomic,strong,retain) NSString * writerOutputFileName;
@property (nonatomic,strong,retain) NSString * writerOutputRelativeDirPath;
@property (nonatomic,strong,retain) NSString * writerOutputPath;
@property (nonatomic,strong,retain) NSURL * writerOutputURL;
////reader:
@property (nonatomic,retain) AVAssetReader *reader;
@property (nonatomic,retain) AVAsset *readerAsset;
@property (atomic,assign) int whichTrack;
@property (nonatomic,retain) AVAssetTrack * sourceVideoTrack;
@property (atomic,assign) CGAffineTransform preferedTransform;
    //////直接从videoTrack读出的preferedTransform,可以应用于AVFoundation layerInstruction
@property (atomic,assign) float height;
@property (atomic,assign) float width;
@property (nonatomic,retain) AVAssetReaderTrackOutput* readerOutput;
////cache:
@property (nonatomic, strong,retain) dispatch_queue_t VTRecompressProcessingSerialQueue;
    //////暂时无用
@property (nonatomic, strong,retain) dispatch_queue_t VTRecompressProcessingConcurrentQueue;
    //////VTRecomp 分decomp 和  comp 两个线程
@property (atomic,assign) BOOL useCacheArray;
    //////如果不使用cacheArray 那么排序功能被禁止，此时最好完全不适用原始的presentationTime
    //////useOnlyDurations = YES;
    //////useOnlyPresentations = NO;
@property (atomic,assign) int cacheArraySize;
@property (atomic,assign) int cacheAlreadyFilledCount;
@property (atomic,assign) int cacheAlreadyHandledCount;
@property (nonatomic,retain) NSLock * cacheLock;
@property (nonatomic,retain) dispatch_semaphore_t bufferFilledSema;
@property (nonatomic,retain) dispatch_semaphore_t bufferHandledSema;
@property (atomic,assign) CVImageBufferRef eachExtractedCVImage;
@property (atomic,assign) CFMutableArrayRef extractedCVImageRefs;
@property (nonatomic,retain) NSMutableArray * presentationTimeStamps;
@property (nonatomic,retain) NSMutableArray * decodeTimeStamps;
@property (nonatomic,retain) NSMutableArray * durations;
@property (nonatomic,retain) NSMutableArray * keyFrameSigns;
@property (nonatomic,retain) NSMutableArray * parallelArray;
////decomp each frame call back
@property (atomic,assign) BOOL removeNegativeCMTime;
@property (atomic,assign) int goodSamCounts;
@property (atomic,assign) int origGoodSamCounts;
////make decomp session
@property (atomic,assign) VTDecompressionSessionRef decompressionSession;
@property (atomic,assign) VTDecompressionOutputCallback decompressionEachFrameCallback;
@property (atomic,assign) BOOL constructDestinationImageBufferAttributesFromKeyValue;
@property (atomic,assign) CFDictionaryRef destinationImageBufferAttributes;
@property (atomic,assign) unsigned int destinationImageBufferKCVPixelFormatType;
@property (atomic,assign) BOOL constructDecompressionDecodeSpecificationFromKeyValue;
@property (atomic,assign) CFDictionaryRef decompressionDecodeSpecification;
@property (atomic,assign) CMVideoFormatDescriptionRef decompressionVideoFormatDescription;
////
@property (nonatomic,retain) NSDate * recompressionStartTime;
@property (atomic,assign) BOOL currKeyFrameIndicator;
    //////just for pass value to callback function when blockbuffer
@property (atomic,assign) BOOL newSessionEachKeyFrame;
////makeDecompress
@property (atomic,assign) BOOL sortImagesAfterDecompression;
@property (atomic,assign) int reducedFrameNumerator;
@property (atomic,assign) int reducedFrameDenominator;
    ////// reducedFrameNumerator = 2
    ////// reducedFrameDenominator = 5
    ////// 此时每5 frames 丢弃 2 frames
    ////// the implement cant be drop during decode , must be dropped after decode , coz the prev  will cause blur and bad image
    ////// if use this two parameters, must handle the output presentationTimeStamp
@property (atomic,assign) BOOL useOnlyDurations;
@property (atomic,assign) BOOL useOnlyPresentations;
@property (atomic,assign) CMTime currCacheStartPresentation;
@property (atomic,assign) BOOL doneDoneDone;
@property (atomic,assign) BOOL decompressionFinished;
////
@property (atomic,assign) BOOL compressionMultiPassEnabled;
@property (atomic,assign) CMTimeRange multiPassStorageCMTimeRange;
    //////used to creat multi Pass Storage
@property (atomic,assign) BOOL deleteSourceOneByOneAfterAppendSinglePass;
@property (atomic,assign) BOOL deleteSourceOneByOneAfterAppendMultiPass;
@property (nonatomic, strong,retain) NSMutableArray * nextPassStartSeqs;
@property (nonatomic, strong,retain) NSMutableArray * nextPassEndSeqs;
@property (nonatomic, strong,retain) NSMutableArray * nextIgnoreStartSeqs;
@property (nonatomic, strong,retain) NSMutableArray * nextIgnoreEndSeqs;
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
@property (atomic,assign) VTFrameSiloRef siloOut;
    //////multiPass siloOut
@property (atomic,assign) VTMultiPassStorageRef multiPassStorageOut;
@property (atomic,assign) BOOL multiPassStorageCreationOption_DoNotDelete;
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
////
@property (atomic,assign) BOOL keepKeyFrameSigns;
    //////used to set frameProperties in VTCompressionSessionEncodeFrame for each frame
@property (atomic,assign) CMTime endSessionAtSourceTime;
////
@property (atomic,assign) int howManyPasses;
    ////if = 0; means exec until no further pass could be execed
@property (atomic,assign) int currPassRound;
@property (atomic,assign) BOOL furtherPass;
////
@property (atomic,assign) BOOL applyOOBPT;
@property (atomic,assign) BOOL compressionFinished;
@property (nonatomic,retain) NSDate * recompressionEndTime;
@property (atomic,assign) BOOL deleteOutputFileInSandboxAfterCopyToAlbum;
@property (atomic,assign) BOOL writeToAlbum;
@property (atomic,assign) BOOL SYNC;

-(void) readMe;
-(void) resetParameters;
-(void) printAndCheckParameters;
-(void) makeSourceVideoPathsAndURLsReady;
-(void) makeReaderReadyAndStart;
-(void) makeVTDecompressionSession;
-(void) makeDecomp;
-(void) makeCacheQueueSemaReady;
-(void) makeParallelArrayReadyAfterCacheFilled;
-(void) makeVTCompressionSession;
-(void) makeVTSessionPropertiesReadyAndStart;
-(void) makeVTencodeEachFrameSinglePass;
-(void) makeVTencodeEachFrameMultiPass;
-(void) makeFinalOutputFile;
-(void) makeComp;
-(void) makeRecomp;

@end