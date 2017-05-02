//
//  coreMediaPrint.h
//  UView
//
//  Created by dli on 12/26/15.
//  Copyright © 2015 YesView. All rights reserved.
//

#ifndef coreMediaPrint_h
#define coreMediaPrint_h


#endif /* coreMediaPrint_h */


#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#include <VideoToolbox/VideoToolbox.h>
#import "UIImageTools.h"
#import "FileUtil.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import "TFHpple.h"
#import "XPathQuery.h"

@interface coreMediaPrint:NSObject



////--part0
typedef enum {
    HomeButtonAtRight,//UIImageOrientationUp
    HomeButtonAtLeft ,//UIImageOrientationDown
    HomeButtonAtBottom ,//UIImageOrientationLeft
    HomeButtonAtTop, //UIImageOrientationRight
    HomeButtonAtRightMirrored, //UIImageOrientationUpMirrored
    HomeButtonAtLeftMirrored , //UIImageOrientationDownMirrored
    HomeButtonAtBottomMirrored ,//UIImageOrientationLeftMirrored
    HomeButtonAtTopMirrored, //UIImageOrientationRightMirrored
    HomeButtonAtRightXMirrored,//UIImageOrientationUpXMirrored
    HomeButtonAtLeftXMirrored ,//UIImageOrientationDownXMirrored
    HomeButtonAtBottomXMirrored ,//UIImageOrientationLeftXMirrored
    HomeButtonAtTopXMirrored, //UIImageOrientationRight
} HomeButtonOrientation;

typedef enum {
    HUmanRight,//HomeButtonAtRight,UIImageOrientationUp
    HumanLeft,//HomeButtonAtLeft ,UIImageOrientationDown
    HumanUp, //HomeButtonAtBottom ,UIImageOrientationLeft
    HumanDown, //HomeButtonAtTop ,UIImageOrientationRight
    HUmanRightMirrored,//HomeButtonAtRight,UIImageOrientationUpMirrored
    HumanLeftMirrored,//HomeButtonAtLeft ,UIImageOrientationDownMirrored
    HumanUpMirrored, //HomeButtonAtBottom ,UIImageOrientationLeftMirrored
    HumanDownMirrored, //HomeButtonAtTop ,UIImageOrientationRightMirrored
    HUmanRightXMirrored,//HomeButtonAtRight,UIImageOrientationUpXMirrored
    HumanLeftXMirrored,//HomeButtonAtLeft ,UIImageOrientationDownXMirrored
    HumanUpXMirrored, //HomeButtonAtBottom ,UIImageOrientationLeftXMirrored
    HumanDownXMirrored, //HomeButtonAtTop ,UIImageOrientationRightXMirrored
} HumanOrientation;

typedef enum {
    extUIImageOrientationUp,
    extUIImageOrientationDown ,
    extUIImageOrientationLeft ,
    extUIImageOrientationRight ,
    extUIImageOrientationUpMirrored ,
    extUIImageOrientationDownMirrored ,
    extUIImageOrientationLeftMirrored ,
    extUIImageOrientationRightMirrored ,
    extUIImageOrientationUpXMirrored,
    extUIImageOrientationDownXMirrored,
    extUIImageOrientationLeftXMirrored,
    extUIImageOrientationRightXMirrored
} extUIImageOrientation;


////-part1 :select audio/video tracks
NSMutableArray * selectAllVideoTracksFromAVAssetNoCopyItem(AVAsset* asset);
NSMutableArray * selectAudioTracksFromAVAssetWithTracksSelection(AVAsset * asset,NSMutableArray*indexes);
NSMutableArray * selectVideoTracksFromAVAssetWithTracksSelection(AVAsset * asset,NSMutableArray*indexes);
NSMutableArray * selectAllAudioTracksFromAVAsset(AVAsset * asset);
NSMutableArray * selectAllVideoTracksFromAVAsset(AVAsset * asset);
NSDictionary * selectAudioTracksFromMovieURLWithTracksSelection(NSURL*sourceMovieURL,NSMutableArray*indexes);
NSDictionary  * selectVideoTracksFromMovieURLWithTracksSelection(NSURL*sourceMovieURL,NSMutableArray*indexes);
NSDictionary * selectAllAudioTracksFromMovieURL(NSURL*sourceMovieURL);
NSDictionary * selectAllVideoTracksFromMovieURL(NSURL*sourceMovieURL);


////-part2: puts selected tracks into array
NSMutableArray * putsAllAudioTracksIntoTracksArrayFromAssets(NSMutableArray * assets);
NSMutableArray * putsAllVideoTracksIntoTracksArrayFromAssets(NSMutableArray * assets);
NSMutableArray * putsAllAudioTracksIntoTracksWithAssetArrayFromSourceURLs(NSMutableArray * sourceURLs);
NSMutableArray * putsAllVideoTracksIntoTracksWithAssetArrayFromSourceURLs(NSMutableArray * sourceURLs);
NSMutableArray * getAllTracksFromTracksWithAssetArray(NSMutableArray* tracksWithAsset);



////-part3: tracks array  sort
NSMutableArray * sortTracksArrayViaCMTDuration (NSMutableArray * tracks);
AVAssetTrack * getMaxCMTDurationTrackFromTracksArray(NSMutableArray * tracks);
AVAssetTrack * getMinCMTDurationTrackFromTracksArray(NSMutableArray * tracks);
NSMutableArray * sortTracksArrayViaNominalFrameRate (NSMutableArray * tracks);
AVAssetTrack * getMaxNominalFrameRateTrackFromTracksArray(NSMutableArray * tracks);
AVAssetTrack * getMinNominalFrameRateTrackFromTracksArray(NSMutableArray * tracks);




/////--------------

void printCMTime(CMTime t,NSString*indent);
void printTimeRange(CMTimeRange tr,NSString*indent);
void printTimeMapping(CMTimeMapping tm,NSString*indent);
void printEachSampleTimeInfo(CMSampleBufferRef sampleBuffer);
void printCFDictionaryRef(CFDictionaryRef formDict,CFIndex formDictCount);
CFArrayRef getAndPrintAllSampleAttachments(CMSampleBufferRef sampleBuffer, BOOL noprint);
void printParameterSets(CMSampleBufferRef sampleBuffer);
NSString * hexFromNSData(NSData* nsData);
NSData * getH264Para (CMFormatDescriptionRef formDesc,int i);
CMFormatDescriptionRef getVideoTrack_I_Descs(NSArray * videoTracks,int i);
void printVideoMediaSubType(CMFormatDescriptionRef formDesc);
void printMediaType(CMFormatDescriptionRef formDesc);
BOOL isH264IFrame(CMSampleBufferRef sampleBuffer,int which);
NSData * copyDataFromBlock(CMSampleBufferRef sampleBuffer);
CFMutableDictionaryRef  getBlockTimingInfo(CMSampleBufferRef sampleBuffer);
CFMutableDictionaryRef  getBlocksizeArrayOut(CMSampleBufferRef sampleBuffer);

int roundSecondsToCorrespondingCMTUnit(float seconds,CMTime cmt);
float roundCMTUnitToCorrespondingSeconds(int unit,CMTime cmt);
BOOL CMTimeDurationLT(CMTime cmt1,CMTime cmt2);
BOOL CMTimeDurationLE(CMTime cmt1,CMTime cmt2);
BOOL CMTimeDurationEQ(CMTime cmt1,CMTime cmt2);
BOOL CMTimeDurationGE(CMTime cmt1,CMTime cmt2);
BOOL CMTimeDurationGT(CMTime cmt1,CMTime cmt2);


int getNominalFrameRate(AVAsset *someAsset, int seq);


void checkAVAssetWriterStatus(AVAssetWriter * videoWriter);


CGSize getNaturalSize(AVAsset *someAsset, int seq);


NSMutableArray * generateIndicationImagesFromAVAssetWithSecondsInterval(AVAsset * asset ,float interval,float width,float height);
NSMutableArray * generateIndicationImagesFromAVAssetWithCMTUnitInterval(AVAsset * asset ,int realInterval,float width,float height);

int getAVGRealInterval(AVAsset*asset,float totalLength,float eachLength);
float getAVGSecondsInterval(AVAsset*asset,float totalLength,float eachLength);




void printCGAffineTransform(CGAffineTransform  transform);

NSMutableArray * addCMTimeRangeToNSMutableArray(NSMutableArray * ma ,CMTimeRange timerange);
NSMutableArray * addCMTimeToNSMutableArray(NSMutableArray * ma ,CMTime time);
NSMutableArray * addCMTimeMappingToNSMutableArray(NSMutableArray * ma ,CMTimeMapping timemapping);

NSMutableArray * addCGSizeToNSMutableArray(NSMutableArray * ma ,CGSize size);
NSMutableArray * addCGPointToNSMutableArray(NSMutableArray * ma ,CGPoint point);




void CMSampleTimeInfoShow(CMSampleBufferRef sampleBuffer);



////-part0: split a movie

NSMutableArray * splitVideoCMTimeViaAverageIntervalFromAVAsset(AVAsset * asset,int whichTrack,float intervalSeconds);
NSMutableArray * splitVideoCMTimeViaAverageIntervalFromMovieURL(NSURL*sourceMovieURL,int whichTrack,float intervalSeconds);
NSMutableArray * splitVideoToAssetsAndPTsViaAverageIntervalFromAVAsset(AVAsset * asset,int whichTrack,float intervalSeconds);
NSMutableArray * splitVideoToAssetsAndPTsViaAverageIntervalFromMovieURL(NSURL*sourceMovieURL,int whichTrack,float intervalSeconds);
NSMutableArray * splitVideoToVideosViaAverageIntervalFromAVAsset(AVAsset * asset,int whichTrack,float intervalSeconds,NSString * destinationRelativeDir);
NSMutableArray * splitVideoToVideosAndPTsViaAverageIntervalFromMovieURL(NSURL*sourceMovieURL,int whichTrack,float intervalSeconds,NSString * destinationRelativeDir);














////


NSNumber * whichPT(CGAffineTransform pt);

CGSize acturalSizeToInternalSize(CGSize acturalSize,CGAffineTransform t2);
CGSize internalSizeToActuralSize(CGSize internalSize,CGAffineTransform t2);




CGAffineTransform getUIImageOrientationUpToDownPT(float width,float height);
CGAffineTransform getUIImageOrientationUpToLeftPT(float width,float height);
CGAffineTransform getUIImageOrientationUpToRightPT(float width,float height);

CGAffineTransform getUIImageOrientationDownToUpPT(float width,float height);
CGAffineTransform getUIImageOrientationDownToLeftPT(float width,float height);
CGAffineTransform getUIImageOrientationDownToRightPT(float width,float height);

CGAffineTransform getUIImageOrientationLeftToUpPT(float width,float height);
CGAffineTransform getUIImageOrientationLeftToDownPT(float width,float height);
CGAffineTransform getUIImageOrientationLeftToRightPT(float width,float height);

CGAffineTransform getUIImageOrientationRightToUpPT(float width,float height);
CGAffineTransform getUIImageOrientationRightToDownPT(float width,float height);
CGAffineTransform getUIImageOrientationRightToLeftPT(float width,float height);




CGPoint acturalPositionToInternalPosition(CGSize acturalSize,CGPoint acturalPoint,CGAffineTransform t2);
CGPoint internalPositionToActuralPosition(CGPoint internalPoint,CGAffineTransform t2);




//// if  preferedTransform  info  is losted ,the orientaion  is  treated as UIImageOrientationUp:which means homeButtonAtRight
NSMutableDictionary * getVideoRecordingOrientationFromSourceAsset(AVAsset*asset,int whichTrack);
NSMutableDictionary * getVideoRecordingOrientationFromSourceURL(NSURL*sourceURL,int whichTrack);

//// did not do preferedTransform
NSURL * getInternalVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL);
NSURL * getInternalVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL);


NSURL * setVideoOpacityFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,float opacity);
NSURL * setVideoOpacityFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,float opacity);


////if  preferedTransform  info  is losted ,the orientaion  is  treated as UIImageOrientationUp:which means homeButtonAtRight
NSURL * rotateVideoAroundTopLeftClockwiseFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,float rotateDegree);
NSURL * rotateVideoAroundTopLeftClockwiseFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,float rotateDegree);


////if  preferedTransform  info  is losted ,the orientaion  is  treated as UIImageOrientationUp:which means homeButtonAtRight
////this is a absolute orientation change, homeButtonAtRight is treated as Up
NSURL * changeVideoAbsoluteOrientationFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,extUIImageOrientation orientation);
NSURL * changeVideoAbsoluteOrientationFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,extUIImageOrientation orientation);
////-


////if  preferedTransform  info  is losted ,the orientaion  is  treated as UIImageOrientationUp:which means homeButtonAtRight
////this is a relative orientation change, the original video is treated as Up
NSURL * changeVideoRelativeOrientationFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,extUIImageOrientation orientation);
NSURL * changeVideoRelativeOrientationFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,extUIImageOrientation orientation);
////-




NSURL * geomePlaceVideosIntoOneFromSourceAssets(NSMutableArray * assets,NSMutableArray* whichTracks,NSMutableArray*positions,NSMutableArray*sizes,CGSize renderSize,NSURL*destinationURL);
NSURL * geomePlaceVideosIntoOneFromSourceSourceURLs(NSMutableArray * sourceURLs,NSMutableArray* whichTracks,NSMutableArray*positions,NSMutableArray*sizes,CGSize renderSize,NSURL*destinationURL);



NSURL * interleaveVideosAtCMTimeLevelFromSourceAssets(NSMutableArray * assets,NSMutableArray* whichTracks,NSMutableArray*intervals,CGSize renderSize,NSURL*destinationURL);
NSURL * interleaveVideosAtCMTimeLevelFromSourceSourceURLs(NSMutableArray * sourceURLs,NSMutableArray* whichTracks,NSMutableArray*intervals,CGSize renderSize,NSURL*destinationURL);








////if  preferedTransform  info  is losted ,the orientaion  is  treated as UIImageOrientationUp:which means homeButtonAtRight
////this use  videoLayer to handle CounterClockwise
NSURL * rotateOn2DVideoCounterClockwiseFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,float rotateDegree,CGPoint anchorCood);
NSURL * rotateOn2DVideoCounterClockwiseFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,float rotateDegree,CGPoint anchorCood);
////-


NSURL * rotateOn3DVideoCounterClockwiseFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,float rotateDegree,CGPoint anchorCoodZ,float axisX,float axisY, float axisZ,float m34);
NSURL * rotateOn3DVideoCounterClockwiseFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,float rotateDegree,CGPoint anchorCoodZ,float axisX,float axisY, float axisZ,float m34);



////slow down or FF
NSURL * FForSlowDownVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,NSMutableArray * sectionStarts,NSMutableArray * sectionEnds,NSMutableArray * ratios);
NSURL * FForSlowDownVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,NSMutableArray * sectionStarts,NSMutableArray * sectionEnds,NSMutableArray * ratios);


NSMutableArray * creatTimeInfoForReversingVideoFromSourceAsset(AVAsset*asset,int whichTrack);
NSMutableArray * creatTimeInfoForReversingVideoFromSourceURL(NSURL*sourceURL,int whichTrack);



NSURL * noisingOrRecoverVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL);
NSURL * noisingOrRecoverVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL);



////---
////videoToImages is implemented by VT refer to videoToImages
////---

////---
////reverse part is implemented by VT refer to reverseAfterV2I
////---

////---
////imagesToVideo is implemented by VT refer to imagesToVideo
////---


////----
////imagesToGIF
////----

////----
////GIFToImages
////----




////3.2 puts tracks into one composition track for concat
AVMutableCompositionTrack  * creatConcatedAudioCompTrackWithTracksSelection(NSMutableArray*audioTracks, NSMutableArray*indexes,AVMutableComposition *mixComposition);
AVMutableCompositionTrack  * creatConcatedAudioCompTrackWithAllTracks(NSMutableArray * audioTracks,AVMutableComposition *mixComposition);
AVMutableCompositionTrack  * creatConcatedAudioCompTrackWithTracksSelectionWithCMTimeRangeSelection(NSMutableArray*audioTracks, NSMutableArray*indexes,NSMutableArray*timeRanges,AVMutableComposition *mixComposition);
AVMutableCompositionTrack  * creatConcatedAudioCompTrackWithAllTracksWithCMTimeRangeSelection(NSMutableArray * audioTracks,NSMutableArray*timeRanges,AVMutableComposition *mixComposition);



AVMutableCompositionTrack  * creatConcatedVideoCompTrackWithTracksSelection(NSMutableArray*videoTracks,NSMutableArray*indexes,AVMutableComposition *mixComposition);
AVMutableCompositionTrack  * creatConcatedVideoCompTrackWithAllTracks(NSMutableArray * videoTracks,AVMutableComposition *mixComposition);
AVMutableCompositionTrack  * creatConcatedVideoCompTrackWithTracksSelectionWithCMTimeRangeSelection(NSMutableArray*videoTracks, NSMutableArray*indexes,NSMutableArray*timeRanges,AVMutableComposition *mixComposition);
AVMutableCompositionTrack  * creatConcatedVideoCompTrackWithAllTracksWithCMTimeRangeSelection(NSMutableArray * videoTracks,NSMutableArray*timeRanges,AVMutableComposition *mixComposition);














////3.3 puts tracks into  composition tracks array for merge
NSMutableArray  * creatMergedAudioCompTracksWithTracksSelection(NSMutableArray*audioTracks, NSMutableArray*indexes,AVMutableComposition *mixComposition);
NSMutableArray  * creatMergedAudioCompTracksWithAllTracks(NSMutableArray * audioTracks,AVMutableComposition *mixComposition);
NSMutableArray  * creatMergedAudioCompTracksWithTracksSelectionWithCMTimeRangeSelection(NSMutableArray*audioTracks, NSMutableArray*indexes,NSMutableArray*timeRanges,AVMutableComposition *mixComposition);
NSMutableArray  * creatMergedAudioCompTracksWithAllTracksWithCMTimeRangeSelection(NSMutableArray * audioTracks,NSMutableArray*timeRanges,AVMutableComposition *mixComposition);



NSMutableArray  * creatMergedVideoCompTracksWithTracksSelection(NSMutableArray*videoTracks,NSMutableArray*indexes,AVMutableComposition *mixComposition);
NSMutableArray  * creatMergedVideoCompTracksWithAllTracks(NSMutableArray * videoTracks,AVMutableComposition *mixComposition);
NSMutableArray  * creatMergedVideoCompTracksWithTracksSelectionWithCMTimeRangeSelection(NSMutableArray*videoTracks, NSMutableArray*indexes,NSMutableArray*timeRanges,AVMutableComposition *mixComposition);
NSMutableArray  * creatMergedVideoCompTracksWithAllTracksWithCMTimeRangeSelection(NSMutableArray * videoTracks,NSMutableArray*timeRanges,AVMutableComposition *mixComposition);





////--part4






////--part5

NSURL * creatRangeOfMovieFromAVAsset(AVAsset * asset,CMTimeRange range,NSURL*destinationMovieURL);


////--- need  using sema to make synced
NSURL * creatMovieFromAVMutableCompositionPassThrough(AVMutableComposition*mixComposition,NSURL*destinationMovieURL);
NSURL * creatMovieFromAVMutableCompositionWithPreset(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName);
NSURL * creatMovieFromAVMutableCompositionWithParameters(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName,AVVideoComposition* videoComposition);


NSURL * creatMovieFromAVMutableCompositionPassThroughSema(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,dispatch_semaphore_t sema,BOOL writeToAlbum);
NSURL * creatMovieFromAVMutableCompositionWithPresetSema(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName,dispatch_semaphore_t sema,BOOL writeToAlbum);
NSURL * creatMovieFromAVMutableCompositionWithParametersSema(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName,AVVideoComposition* videoComposition,dispatch_semaphore_t sema,BOOL writeToAlbum);



////-----



NSURL * creatMergeMovieFromAudioTracksAndVideoTracks(NSArray * audioTracks,NSArray * videoTracks,NSURL*destinationMovieURL);
NSURL * creatConcatMovieFromAudioTracksAndVideoTracks(NSArray * audioTracks,NSArray * videoTracks,NSURL*destinationMovieURL);
NSURL * creatMergeAudioOnlyMovieFromTracks(NSArray * audioTracks,NSURL*destinationMovieURL);
NSURL * creatConcatAudioOnlyMovieFromTracks(NSArray * audioTracks,NSURL*destinationMovieURL);

NSURL * creatMergeVideoOnlyMovieFromTracks(NSMutableArray * videoTracks,NSURL*destinationMovieURL);
NSURL * creatMergeVideoOnlyMovieFromAssets(NSMutableArray * assets,NSURL*destinationMovieURL);
NSURL * creatMergeVideoOnlyMovieFromSourceURLs(NSMutableArray *sourceMovieURLs,NSURL*destinationMovieURL);



NSURL * creatConcatVideoOnlyMovieFromTracks(NSArray * videoTracks,NSURL*destinationMovieURL);

NSURL * creatMovieFromAudioOnlyFileAndVideoOnlyFile(NSURL*audioOnlyFileURL,NSURL*videoOnlyFileURL,NSURL*destinationMovieURL);



NSURL * concatMoviesFromSourceURLs(NSArray*sourceMovieURLs,NSURL*destinationMovieURL);
NSURL * concatMoviesFromSourcesAssets(NSArray*sourceAssets,NSURL*destinationMovieURL);



NSURL * mergeMoviesFromSourceAssets(NSArray*sourceAssets,NSURL*destinationMovieURL);
NSURL * mergeMoviesFromSourceURLs(NSArray*sourceMovieURLs,NSURL*destinationMovieURL);



CMTime getCMTimeFromInfoFile(NSString*key,NSString*sourceInfoPath);

void printVTCompressionSessionPropertyValue(VTCompressionSessionRef compressionSession, CFStringRef propertyKey);

void printVTCompressionSessionSupportedProperties(VTCompressionSessionRef compressionSession);


void VTSessionSetCleanApertureFromValues(VTCompressionSessionRef compressionSession,int cleanApertureWidth,int cleanApertureHeight,int cleanApertureHorizontalOffset,int cleanApertureVerticalOffset);
void VTSessionSetCleanApertureFromCFDict(VTCompressionSessionRef compressionSession,CFDictionaryRef CFCleanAperture);
void VTSessionSetCleanApertureFromNSDict(VTCompressionSessionRef compressionSession,NSDictionary * NSCleanAperture);

int usingWhichP(CMTime n, CMTime p1,int k1,CMTime d1,CMTime p2,CMTime d2,int k2);

int selectNearestFromCMTimeArray(CMTime n,NSMutableArray * presentations,NSMutableArray * durations);


void printKCMVideoCodecType(CMVideoCodecType cond);

void printKCVPixelFormatType(OSType n);

NSURL * creatConcatMovieFromAudioTracksAndVideoTracksSema(NSArray * audioTracks,NSArray * videoTracks,NSURL*destinationMovieURL,dispatch_semaphore_t sema,BOOL writeToAlbum);

NSURL * concatMoviesFromSourceURLsSema(NSArray*sourceMovieURLs,NSURL*destinationMovieURL,dispatch_semaphore_t sema,BOOL writeToAlbum);



NSURL * ptVideoFromSourceAssetSema(AVAsset*asset,int whichTrack,NSURL*destinationURL,dispatch_semaphore_t sema,BOOL writeToAlbum,CGAffineTransform t2);
NSURL * ptVideoFromSourceURLSema(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,dispatch_semaphore_t sema,BOOL writeToAlbum,CGAffineTransform t2);

NSString * kCMVideoCodecTypeToString(CMVideoCodecType cond);

void printVTError(OSStatus status);
int printVTEncoderList(CFDictionaryRef options);
void printVTEncodeInfoFlags(VTEncodeInfoFlags infoFlags);



CFNumberRef getVTCompressionPropertyKey_NumberOfPendingFrames(VTCompressionSessionRef compressionSession);
CFBooleanRef getVTCompressionPropertyKey_PixelBufferPoolIsShared(VTCompressionSessionRef compressionSession);
CFDictionaryRef getVTCompressionPropertyKey_VideoEncoderPixelBufferAttributes(VTCompressionSessionRef compressionSession);


NSString * getCallStackPrependForDebugLog(int topLevel, NSString * indent);

CVPixelBufferPoolRef makeCVPixelBufferPool(int minimumBufferCount,int maximumBufferAge,OSType pixelFormatType,int width,int height);

CVPixelBufferRef copyCVPixelBufferToBufferPoolGeneratedBuffer(CVPixelBufferRef sourceImageBuffer,CVPixelBufferPoolRef pixelBufferPool);
CVPixelBufferRef copyCVPixelBufferToNewCreatedBuffer(CVPixelBufferRef sourceImageBuffer,NSMutableDictionary * options);
CVPixelBufferRef copyCVPixelBufferToNewCreatedBufferWithBytes(CVPixelBufferRef sourceImageBuffer,NSMutableDictionary * options);



NSMutableArray * splitVideoToVideosViaCMTimeRangeArrayFromAVAsset(AVAsset * asset,int whichTrack,NSMutableArray * cmtrs,NSMutableArray * destURLs);
NSMutableArray * splitVideoToVideosViaCMTimeRangeArrayFromMovieURL(NSURL * sourceMovieURL,int whichTrack,NSMutableArray * cmtrs,NSMutableArray * destURLs);

////--srt parser:
NSString * getVideoDirPath(NSString* workdir);
NSArray * parseSrtGetSrtEntries(NSString * string);
float parseSrtTime(NSString * time);
NSMutableDictionary * parseSrtPosition(NSString * position);
NSMutableDictionary * parseSrtEachEntry(NSString * entry);
NSMutableDictionary * parseSrtTimeAndPosition(NSString * timeAndPosition);
NSString * parseSrtToUTF8Words(NSString * words);
NSMutableArray * parseSrtNext(NSMutableArray * sections_1);
int parseSrtNotAllLeafs(NSMutableArray * currSections);
NSMutableDictionary * parseSrtEachEntry(NSString * entry);
void addNewVideoToDataBase(NSString * relativePath,NSString * workdir,NSString * sourceVideoPath,NSString * sourceSrtPath,int fromSupportedEncoder);




NSMutableDictionary* pixelBufferAttributesForAVPlayerItemVideoOutputOfSize(CGSize size);


/////-------------
NSMutableArray * sortCMTArrayViaCMTDuration (NSMutableArray * CMTs);
CMTime getMaxCMTDurationCMTFromArray(NSMutableArray * CMTs);
CMTime getMinCMTDurationCMTFromArray(NSMutableArray * CMTs);




////-audio
void printCMAudioFormatDescription(CMAudioFormatDescriptionRef fDesc);
void printAudioFormatFlags(AudioFormatFlags i);
void printAudioStreamBasicDescription(AudioStreamBasicDescription mASBD);
void printAudioChannelLayoutTag(AudioChannelLayoutTag i);
void printAudioChannelFlags(AudioChannelFlags i);
void printAudioChannelLabel(AudioChannelLabel i);
void printAudioChannelDescription(AudioChannelDescription acd);
void printAudioChannelBitmap(AudioChannelBitmap i);
NSMutableDictionary * getAudioWriterInputOutputSettingsFromCMAudioFormatDescription(CMAudioFormatDescriptionRef fDesc,int defaultBitDepth);
NSMutableDictionary * getAudioReaderOutputSettingsFromCMAudioFormatDescription(CMAudioFormatDescriptionRef fDesc,int defaultBitDepth);
NSMutableDictionary * creatMonoAudioWriterInputOutputSettingsFromCMAudioFormatDescription(CMAudioFormatDescriptionRef fDesc,int defaultBitDepth);
AudioBufferList * allocateNewAudioBufferList(UInt32 mNumberBuffers,UInt32 mNumberChannels, UInt32 bitDepth, bool interleaved,UInt32 framesNumber);
void freeAudioBufferList(AudioBufferList * bufferList);
void printAudioBufferList(AudioBufferList bufferList);
CMFormatDescriptionRef creatMonoAudioFormatDescFromOrigLinePCMSampleBuffer(CMSampleBufferRef sampleBuffer,int bitDepth);






@end