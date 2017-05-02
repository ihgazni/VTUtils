//
//  VTRecompress.h
//  UView
//
//  Created by dli on 12/28/15.
//  Copyright © 2015 YesView. All rights reserved.
//

#ifndef VTRecompress_h
#define VTRecompress_h


#endif /* VTRecompress_h */


#import "UVBaseViewController.h"


#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import<QuartzCore/QuartzCore.h>
#include <VideoToolbox/VideoToolbox.h>



@interface VTRecompress : NSObject




@property (nonatomic, copy) NSString * readerInputPath;
@property (nonatomic, copy) NSURL * readerInputURL;
@property (nonatomic, strong) AVAssetReader *reader;
@property (nonatomic, strong) AVAsset *readerAsset;


////使用所有tracks，用AVAssetReaderAudioMixOutput和AVAssetReaderVideoCompositionOutput处理
@property (nonatomic, strong) AVAssetReaderAudioMixOutput * readerAudioMixOutput;
@property (nonatomic, copy) AVAudioMix * readerAudioOutputMix;
@property (nonatomic, strong) AVAssetReaderVideoCompositionOutput *readerVideoCompositionOutput;


////使用某个track，用AVAssetReaderTrackOutput处理
@property (nonatomic, strong) AVAssetReaderTrackOutput * readerAudioOutputSpecificTrack;
@property (nonatomic, strong) AVAssetReaderTrackOutput * readerVideoOutputSpecificTrack;



////使用某几个track，用AVMutableComposition处理
@property (nonatomic, strong) AVAssetReaderTrackOutput * readerAudioOutputWithTrackSelection;
@property (nonatomic, strong) AVAssetReaderTrackOutput * readerVideoOutputWithTrackSelection;




////使用所有tracks，用AVMutableComposition处理
@property (nonatomic, strong) AVAssetReaderTrackOutput * readerAudioOutputWithAllTracks;
@property (nonatomic, strong) AVAssetReaderTrackOutput * readerVideoOutputWithAllTracks;


////mixComposion only Audio
@property (nonatomic, strong) AVMutableComposition *mixAudioComposition;
////mixComposion only Video
@property (nonatomic, strong) AVMutableComposition *mixVideoComposition;
////mixComposion Audio+Video
@property (nonatomic, strong) AVMutableComposition *mixAudioAndVideoComposition;


- (id)initReaderWithPath:(NSString *)path;
- (id)initReaderWithURL:(NSURL *)url;
- (id)initReaderWithAsset:(AVAsset *)asset;












/*
                                         |readerInputVideoTracks
 readerInputURL -> readerInputAVAsset -> |
                                         |readerInputAudioTracks
 
 
 */

@property (nonatomic, copy) NSString * writerOutputPath;
@property (nonatomic, copy) NSURL * writerOutputURL;
@property (nonatomic, copy) NSString * writerOutputFileType;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *writerAudioInput;
@property (nonatomic, strong) AVAssetWriterInput *writerVideoInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *writerVideoPixelBufferAdaptor;



@property (nonatomic, strong) dispatch_queue_t writerInputSharedSerialQueue;
@property (nonatomic, strong) dispatch_queue_t writerInputsharedConcurrentQueue;

@property (nonatomic, strong) dispatch_queue_t writerInputAudioSerialQueue;
@property (nonatomic, strong) dispatch_queue_t writerInputAudioConcurrentQueue;

@property (nonatomic, strong) dispatch_queue_t writerInputVideoSerialQueue;
@property (nonatomic, strong) dispatch_queue_t writerInputVideoConcurrentQueue;




////VT



@property (nonatomic, assign) VTDecompressionSessionRef decompressionSession;
@property (nonatomic, assign) CMVideoFormatDescriptionRef formatDescOfDecompress;


@property (nonatomic, assign) CVImageBufferRef reCompressImageBuffer;
@property (nonatomic, assign) CMTime reCompressPresentationTimeStamp;
@property (nonatomic, assign) CMTime reCompressDurationTimeStamp;


@property (nonatomic, strong) dispatch_semaphore_t semaCanWriteReCompressBuffer;
@property (nonatomic, strong) dispatch_semaphore_t semaCanReadReCompressBuffer;

@property (atomic, assign) int compressFrameLabel;
@property (nonatomic, assign) CMTime  startSessionAtSourceTime;

@property (atomic, assign) int decompressFrameLabel;




@property (nonatomic, strong) dispatch_queue_t VTDecompressAsyncProcessingConcurrentQueue;
@property (nonatomic, strong) dispatch_queue_t VTCompressAsyncProcessingConcurrentQueue;



@property (nonatomic,assign) VTCompressionSessionRef compressionSession;


@property (nonatomic,assign) NSFileHandle * reCompressedFileHandle;
@property (nonatomic,assign) NSString * reCompressedFile;



@property (nonatomic,assign) NSFileHandle * reCompressedMP4FileHandle;
@property (nonatomic,assign) NSString * reCompressedMP4File;


@property (nonatomic,assign) BOOL deCompressFinished;


@end