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

@interface coreMediaPrint:NSObject








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

BOOL isH264IFrame(CMSampleBufferRef sampleBuffer);

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


NSMutableArray * sortTracksArrayViaCMTDuration (NSMutableArray * tracks);

AVAssetTrack * getMaxCMTDurationTrackFromTracksArray(NSMutableArray * tracks);
AVAssetTrack * getMinCMTDurationTrackFromTracksArray(NSMutableArray * tracks);

void printCGAffineTransform(CGAffineTransform  transform);

NSMutableArray * addCMTimeRangeToNSMutableArray(NSMutableArray * ma ,CMTimeRange timerange);
NSMutableArray * addCMTimeToNSMutableArray(NSMutableArray * ma ,CMTime time);
NSMutableArray * addCMTimeMappingToNSMutableArray(NSMutableArray * ma ,CMTimeMapping timemapping);

NSMutableArray * addCGSizeToNSMutableArray(NSMutableArray * ma ,CGSize size);
NSMutableArray * addCGPointToNSMutableArray(NSMutableArray * ma ,CGPoint point);



NSMutableArray * sortTracksArrayViaNominalFrameRate (NSMutableArray * tracks);
AVAssetTrack * getMaxNominalFrameRateTrackFromTracksArray(NSMutableArray * tracks);
AVAssetTrack * getMinNominalFrameRateTrackFromTracksArray(NSMutableArray * tracks);

void CMSampleTimeInfoShow(CMSampleBufferRef sampleBuffer);







////-part1 :select audio/video tracks
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



////----part3:

/*
 tracks:
 [v1,v2,v3,v4.....]
 
 
 mode:
 merged:
 v1:---
 v2:----
 v3:-
 mergedV:----
 
 concated:
 v1:---
 v2:----
 v3:-
 concatedV:v1---v2----v3-
 
 */


////3.1 resize crop reoritation





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

NSURL * resizeVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,CGSize size);
NSURL * resizeVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,CGSize size);

NSURL * cropVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,CGSize size,CGPoint topLeftPosition);
NSURL * cropVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,CGSize size,CGPoint topLeftPosition);

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

@end