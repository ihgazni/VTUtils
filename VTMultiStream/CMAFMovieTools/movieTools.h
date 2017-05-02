//
//  movieTools.h
//  UView
//
//  Created by dli on 1/13/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#ifndef movieTools_h
#define movieTools_h


#endif /* movieTools_h */

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import<QuartzCore/QuartzCore.h>
#include <VideoToolbox/VideoToolbox.h>
#import "MBProgressHUD+MJ.h"
#import "UVFileDownloader.h"
#import "NSString+Utils.h"
#import "FileUtil.h"
#import "coreMediaPrint.h"
#import "NYXImagesKit.h"
#import "VTMSComp.h"

/*
-----------------------------------------------------------------------------------------
<action> | <adj_1> | <mediaType> | <entity_1> | <from> | <entity_2> | <to>  | <entity_3>
 elegir  |  all    |  audio      |  track     |        |  asset     |       |  asset
 put     |  single |  video      |  channel   |        |  url       |       |  file
 save    |  multi  |  subtitle   |  tracks    |        |  path      |       |  array
 get     |  random |  meta       |  channels  |        |  bytes     |       |  stream
 split   |         |  srt        |  sample    |        |  data      |       |  data
 combine |         |  text       |  blkbuff   |        |  stream    |       |
 scale   |         |             |  imgbuff   |        |            |       |
 concat  |         |             |  h264      |        |            |       |
 merge   |         |             |            |        |            |       |
 rotate  |         |             |            |        |            |       |
 comp    |         |             |            |        |            |       |
-----------------------------------------------------------------------------------------
如果遇到单词超过7个字母的 用前4个字母的缩写
如果前四个字母缩写有冲突，那么用前5 个，以此类推,例如comp表示composition
    comp   : composition
如果前七个字母有不能明显表达意思，或者有歧义，那么用同意的西语单词，例如elegir表示带有copy选项的select
    elegir : select with copy option
*/

@interface movieTools : NSObject



@end

////<info>
float getTotalLengthOfMovieFromAsset(AVAsset *someAsset, int whichTrack,NSString*type);
int getTimeScaleFromAsset(AVAsset *someAsset, int whichTrack,NSString*type);
////</info>

////<tracks>
NSMutableArray * elegirAllAudioTracksFromAVAsset(AVAsset* asset,BOOL COPYITEM);
NSMutableArray * elegirAllVideoTracksFromAVAsset(AVAsset* asset,BOOL COPYITEM);
NSMutableArray * putAllAudioTracksToArrayFromAVAssets(NSMutableArray * assets,BOOL COPYITEM);
NSMutableArray * putAllVideoTracksToArrayFromAVAssets(NSMutableArray * assets,BOOL COPYITEM);
////</tracks>

////---remove video PT
AVMutableVideoComposition * getVideoCompositionForRemovingPT(AVAssetTrack * videoTrack,AVMutableCompositionTrack *compositionVideoTrack);

////<save>
void saveWithExportSession(AVAssetExportSession* assetExport,BOOL SYNC,BOOL SAVETOALBUM);
void saveAudioTrackToFile(AVAssetTrack * audioTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM);
void saveVideoTrackToFile(AVAssetTrack * videoTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM);
void trimAudioTrackToFile(CMTime trimTo,AVAssetTrack * audioTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM);
void trimVideoTrackToFile(CMTime trimTo,AVAssetTrack * videoTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM);
void rangeAudioTrackToFile(CMTime trimFrom,CMTime trimTo,AVAssetTrack * audioTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM);
void rangeVideoTrackToFile(CMTime trimFrom,CMTime trimTo,AVAssetTrack * videoTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM);
void repeatAudioTrackToFile(float times,AVAssetTrack * audioTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM);
void repeatVideoTrackToFile(float times,AVAssetTrack * videoTrack,BOOL SYNC,NSString*preset,NSURL * destinationURL, NSString *outputFileType,BOOL SAVETOALBUM);
////</save>



////<trim>
void trimSingleTrackAudioToFileFromURL(NSURL*sourceAudioURL,NSURL*destAudioURL,CMTime trimTo,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM);
void trimSingleTrackVideoToFileFromURL(NSURL*sourceVideoURL,NSURL*destVideoURL,CMTime trimTo,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM);
void rangeSingleTrackAudioToFileFromURL(NSURL*sourceAudioURL,NSURL*destAudioURL,CMTime trimFrom,CMTime trimTo,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM);
void rangeSingleTrackVideoToFileFromURL(NSURL*sourceVideoURL,NSURL*destVideoURL,CMTime trimFrom,CMTime trimTo,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM);
////</trim>

////<repeat>
void repeatSingleTrackVideoToFileFromURL(NSURL*sourceVideoURL,NSURL*destVideoURL,float times,int whichTrack,BOOL SYNC,BOOL SAVETOALBUM);
////</repeat>


////----split
////----把movie 按照音轨 视轨 彻底分解,并存储
NSMutableDictionary * splitMovieToFilesByTracksFromURL(NSURL*sourceMovieURL,NSURL*destAudioDirURL,NSURL*destVideoDirURL,BOOL SYNC,BOOL SAVETOALBUM);
NSMutableArray * splitAudioChannelsInSingleTrackToMultiMonoTrackFiles(NSURL*sourceAudioURL,NSURL*destAudioDirURL,BOOL SYNC,BOOL SAVETOALBUM);

////----combine 重组
////----把多个音频audioTracks合并到一个track的不同channel上
void combineAudioFilesToMultiChannelAudioFile(NSMutableArray*sourceAudioURLs,NSURL * destAudioURL, BOOL SYNC,BOOL SAVETOALBUM);
////----把多个音频文件合成一个音频文件的多条track
void combineAudioFilesToMultiTracksAudioFile(NSMutableArray*sourceAudioURLs,NSURL * destAudioURL, BOOL SYNC,BOOL SAVETOALBUM);
////----把多个视频文件removePT合成一个视频文件的多条track,apple  not support write multiTracks to a file
////----to implement this  you must  use trackGroup  per track/per trackgroup
////----AVAssetTrackGroup是一组track，同时只能播放其中一条track，但是不同的AVAssetTrackGroup中的track可以同时播放
void combineVideoFilesToMultiTracksVideoFile(NSMutableArray*sourceVideoURLs,NSURL * destVideoURL, BOOL SYNC,BOOL SAVETOALBUM);
////----把1个声音文件和1个所有tracks都removePT的视频文件合并成一个movie
void combineAudioFileAndVideoFileToMovieFile(NSURL*sourceAudioURL,NSURL*sourceVideoURL,NSURL*destMovieURL,BOOL SYNC,BOOL SAVETOALBUM);
////----把多个单轨声音文件和多个removePT的单轨视频文件合并成一个movie
void combineMultiSingleTrackAudioFilesAndMultiSingleTrackVideoFilesToMovieFile(NSMutableArray*sourceAudioURLs,NSMutableArray*sourceVideoURLs,NSURL*destMovieURL,BOOL SYNC,BOOL SAVETOALBUM);

void creatEmptyAudioFileViaCMTimeRange(CMTimeRange range,NSURL*destAudioURL,BOOL SYNC,BOOL SAVETOALBUM);
void creatEmptyVideoFileViaCMTimeRange(CGSize renderSize,CMTimeRange range,NSURL*destVideoURL,BOOL SYNC,BOOL SAVETOALBUM);
void addEmptyAudioRangeToVideoFileToMakeMovieFile(NSURL*sourceVideoURL,NSURL*destMovieURL);
void addEmptyVideoRangeToAudioFileToMakeMovieFile(NSURL*sourceAudioURL,NSURL*destMovieURL);


////<merge>
void mergeAudioFilesToSingleTrackAudioFile(NSMutableArray*sourceAudioURLs,NSURL * destAudioURL, BOOL SYNC,BOOL SAVETOALBUM);
////结果是按opacity比例调整，这个以后要换成GPUImage来做
void mergeVideoFilesToSingleTrackVideoFile(NSMutableArray*sourceVideoURLs,NSMutableArray * opacities,NSURL * destVideoURL, BOOL SYNC,BOOL SAVETOALBUM);

////---<video exclusive overlay>
NSMutableArray * creatAnimationTimeRangesAndTranslationsFromPathPoints(CMTime start,CMTime end,NSMutableArray * pathPoints,float backGroundHeight,float selfHeight);
void overlayVideoFilesToSingleTrackVideoFile(NSMutableArray*sourceVideoURLs,NSMutableArray * pathPointsArray,NSMutableArray * atTimes,NSURL * destVideoURL, BOOL SYNC,BOOL SAVETOALBUM);

void overlayVideoFilesWithMSAddModeSYNC(NSURL * videoSrcURL,NSURL * videoOverlaySrcURL,NSURL*writerOutputURL,float compWidth,float compHeight,int compAverageBitRate);
////---<video exclusive overlay>

////</merge>

////<geom>
////----<scale>
void resizeVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,CGSize size,BOOL SYNC,BOOL SAVETOALBUM);
void resizeVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,CGSize size,BOOL SYNC,BOOL SAVETOALBUM);
////----</scale>


////-CGPath
void movingVideoOnBackGroundFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,CGPoint anchorCoodZ,CGSize BGSize,NSMutableArray*pathPoints,NSMutableArray*keyTimes,NSMutableArray*timingFunctions,BOOL SYNC,BOOL SAVETOALBUM);
void movingVideoOnBackGroundFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,CGPoint anchorCoodZ,CGSize BGSize,NSMutableArray*pathPoints,NSMutableArray*keyTimes,NSMutableArray*timingFunctions,BOOL SYNC,BOOL SAVETOALBUM);
////-CGPath

////-<crop>
void cropAndRangeVideoFromSourceAsset(AVAsset*asset,int whichTrack,CMTimeRange timeRange,NSURL*destinationURL,CGSize size,CGPoint topLeftPosition,BOOL SYNC,BOOL SAVETOALBUM);
void cropAndRangeVideoFromSourceURL(NSURL*sourceURL,int whichTrack,CMTimeRange timeRange,NSURL*destinationURL,CGSize size,CGPoint topLeftPosition,BOOL SYNC,BOOL SAVETOALBUM);
////-</crop>

////</geom>

////---<get single frame>
void getSingleImageFromVideoURLWithCMTUnitIntervalAndSaveToURL(NSURL * videoURL ,CMTime atTime,NSURL * destURL);
////---<get single frame>
