//
//  VTMSDecomp.h
//  UView
//
//  Created by dli on 3/12/16.
//  Copyright © 2016 YesView. All rights reserved.
//


#ifndef VTMSDecomp_h
#define VTMSDecomp_h


#endif /* VTMSDecomp_h */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import<QuartzCore/QuartzCore.h>
#include <VideoToolbox/VideoToolbox.h>
#import "FileUtil.h"
#import "coreMediaPrint.h"
#import "GPUImage.h"
#import "UIImageTools.h"




@protocol frameFilterDelegate

@optional
-(void) forNextVersionUse;
@end







@interface VTMSDecomp : NSObject


////multiStreamSyncBuff
@property (nonatomic,retain) NSMutableArray * MSBuffers;
////严格的讲因为NSMutableArray不是线程安全的
////所以要加锁，但是因为reader线程只是append，reader stream相互之间是独立的缓存，所以reader可以同时append
////主要问题在于reader的 append 和writer的 draw会同时发生
////并且writer draw完之后 数组的特性会整体前移(自动的),类似FIFO效果
////That is, if one or more threads are changing the same array, problems can occur.
////You must lock around spots where reads and writes occur to assure thread safety.
////但是测试单流 存在cache时reader与writer之间同时读写并没有发生明显问题
////而多流只是reader流增多， reader流之间buffer互不影响
////暂时先不加锁，如果有问题再加， 视频流偶尔错位一两frame无大碍
////如果有问题 就使用 STL priority queue库
////当前流的流号,流号就是当前流的MSBuffer的第一维的序号，初始化MSBuffer时自动更新
@property (atomic,assign) int streamNumber;
@property (atomic,assign) int maxFramesNumberOfEachStream;
@property (readwrite) dispatch_semaphore_t MSCanDecompSema;

////multiStreamSyncBuff




////source
@property (nonatomic,retain) NSURL * sourceVideoURL;
@property (nonatomic,copy) NSString * sourceVideoPath;
@property (nonatomic,copy) NSString * sourceVideoFilename;
@property (nonatomic,copy) NSString * sourceVideoRelativeDir;
////reader:
@property (nonatomic,retain) AVAssetReader *reader;
@property (nonatomic,retain) AVAsset *readerAsset;
@property (atomic,assign) int whichTrack;
@property (nonatomic,retain) AVAssetTrack * sourceVideoTrack;
@property (atomic,assign) float estimatedSourceTotalFramesCount;
@property (atomic,assign) CGAffineTransform preferedTransform;
//////直接从videoTrack读出的preferedTransform,可以应用于AVFoundation layerInstruction
@property (atomic,assign) float height;
@property (atomic,assign) float width;
@property (atomic,assign) BOOL applyOOBPT;
@property (nonatomic,retain) AVAssetReaderTrackOutput* readerOutput;
@property (atomic,assign) BOOL readerOutputAlwaysCopiesSampleData;

////在makeReaderReadyAndStart中初始化，在Decomp过程中更新
@property (atomic,assign) float totalIndication;
@property (atomic,assign) BOOL enableProgressIndication;
@property (atomic,assign) float progressIndicationTimerInterval;
@property (atomic,assign) float progressIndication;
@property (atomic,assign) float currentIndication;




////cache:
//// 命名优点奇艺
//// 这里eachModifiedCVImage 只是用于交换的 临时缓存
//// 应用滤镜之后的frame 依然存储在 eachExtractedCVImage
@property (atomic,assign) CVImageBufferRef eachExtractedCVImage;
@property (atomic,assign) CVImageBufferRef eachModifiedCVImage;
////
@property (atomic,assign) BOOL applyFilter;
@property (atomic,assign) int filterNumber;
@property (atomic,assign) CVPixelBufferPoolRef pixelBufferPool;
@property (atomic,assign) int minimumBufferCount;
@property (atomic,assign) int maximumBufferAge;
@property (atomic,assign) OSType pixelBufferFormatType;

@property (nonatomic,retain) GPUImageCVPixelBufferRefInput * CVPBRefInput;
@property (nonatomic,retain) GPUImageCVPixelBufferRefInput * CVPBRefInputAux1;

@property (nonatomic,retain) GPUImageFilter * initedFilter;
@property (nonatomic,retain) GPUImageFilter * terminatedFilter;
@property (atomic,assign) BOOL enablePreviousResultsBuffers;
@property (nonatomic,retain) NSMutableArray * previousResultsBuffers;
@property (atomic,assign) int previousResultsBuffersCapacity;
@property (nonatomic,retain) GPUImageCVPixelBufferRefOutput * CVPBRefOutput;
@property (nonatomic, weak) id<frameFilterDelegate> frameFilterDelegate;

/*
    weak指针主要用于“父-子”关系，父亲拥有一个儿子的strong指针，因此是儿子的所有者；
    但是为了阻止所有权回环，儿子需要使用weak指针指向父亲；
    你的viewcontroller通过strong指针拥有一个UITableview，
    tableview的datasource和delegate都是weak指针，指向viewcontroller，防止回环；
*/


@property (atomic,assign) BOOL useCacheArray;
@property (atomic,assign) int cacheArraySize;
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
@property (atomic,assign) BOOL currKeyFrameIndicator;
//////just for pass value to callback function when blockbuffer
@property (atomic,assign) BOOL newSessionEachKeyFrame;
////makeDecompress
@property (atomic,assign) BOOL sortImagesAfterDecompression;
@property (atomic,assign) BOOL useOnlyDurations;
@property (atomic,assign) CMTime currCacheStartPresentation;

@property (atomic,assign) BOOL decompressionStarted;
@property (atomic,assign) BOOL decompressionFinished;
////





@property (atomic,assign) BOOL keepKeyFrameSigns;



////
-(void) readMe;
-(void) resetParameters;
-(void) makeSourceVideoPathsAndURLsReady;
-(void) makeReaderReadyAndStart;
-(void) makeVTDecompressionSession;
-(void) streamReady;
-(void) makeDecomp;


@end


