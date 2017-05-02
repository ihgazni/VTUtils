//
//  scriptOrama.m
//  UView
//
//  Created by dli on 1/27/16.
//  Copyright © 2016 YesView. All rights reserved.
//


#import "scriptOrama.h"

@implementation videoOverlay
@end

@implementation videoLocalRender
@end

@implementation lowerThird
@end


////====================================================================================
//然后会给处理完sceneMaterialsUnifiedRender 操作后 加完滤镜sceneFilterPostUnifiedRender
//添加 videoOverlay * sceneOverlayPostUnifiedFilter
////====================================================================================

@implementation textOverBackground
@end


@implementation sceneMusic  
@end

@implementation titles;
@end


@implementation tail;
@end

@implementation scene;
@end



////-------



////CDVideoObject
void CDVideoObjectDeleteSelfVideoLocalRender(CDVideoObject*obj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        CDVideoObject * videoObj = [obj MR_inContext:localContext];
        CDVideoLocalRenderObject * videoLocalRenderObj = [videoObj.videoLocalRender MR_inContext:localContext];
        CDVideoOverlayObject * videoOverlayObj =  [videoLocalRenderObj.videoOverlay MR_inContext:localContext];
        
        if (videoOverlayObj) {
            [videoOverlayObj MR_deleteEntityInContext:localContext];
        }
        videoLocalRenderObj.videoOverlay = nil;
        if (videoLocalRenderObj) {
            [videoLocalRenderObj MR_deleteEntityInContext:localContext];
        }
        videoObj.videoLocalRender = nil;
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDVideoObjectCreatNewWithAllIteratedRelationships(BOOL tempOrNot)
{
    
    __block CDVideoOverlayObject * videoOverlayObject;
    __block CDVideoLocalRenderObject *videoLocalRenderObject;
    __block CDVideoObject * videoObject;
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        ////relationShip 必须在同一个context 下产生

        
        videoOverlayObject = [CDVideoOverlayObject MR_createEntityInContext:localContext];
        videoOverlayObject.temporary = [NSNumber numberWithBool:tempOrNot];
        
        videoLocalRenderObject = [CDVideoLocalRenderObject MR_createEntityInContext:localContext];
        videoLocalRenderObject.temporary = [NSNumber numberWithBool:tempOrNot];
        videoLocalRenderObject.videoOverlay = videoOverlayObject;
        
        
        videoObject = [CDVideoObject MR_createEntityInContext:localContext];
        videoObject.temporary = tempOrNot;
        videoObject.videoLocalRender = videoLocalRenderObject;
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            ////If the receiver has not yet been saved, the object ID is a temporary value that will change when the object is saved.
            CDVideoObject * videoObj = [videoObject MR_inContext:localContext];
            CDVideoLocalRenderObject * videoLocalRenderObj = [videoLocalRenderObject MR_inContext:localContext];
            videoLocalRenderObj.parentHashID = [NSNumber numberWithLongLong:videoObj.objectID.hash];
            CDVideoOverlayObject * videoOverlayObj = [videoOverlayObject MR_inContext:localContext];
            videoOverlayObj.parentHashID = [NSNumber numberWithLongLong:videoLocalRenderObj.objectID.hash];
            
        
        }];
        
    }];
    
}
void CDVideoObjectUpdateVideoLocalRender(CDVideoObject*obj,CDVideoLocalRenderObject*nrobj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {

        CDVideoObject * videoObj = [obj MR_inContext:localContext];
        CDVideoLocalRenderObject * videoLocalRenderObj =  [obj.videoLocalRender MR_inContext:localContext];
        CDVideoOverlayObject * videoOverlayObj =  [videoLocalRenderObj.videoOverlay MR_inContext:localContext];
        if (videoOverlayObj) {
            [videoOverlayObj MR_deleteEntityInContext:localContext];
            videoLocalRenderObj.videoOverlay = nil;
        }
        CDVideoLocalRenderObject * newVideoLocalRenderObj =  [nrobj MR_inContext:localContext];
        if (videoLocalRenderObj) {
            [videoLocalRenderObj MR_deleteEntityInContext:localContext];
            videoObj.videoLocalRender = nil;
        }
        if (newVideoLocalRenderObj) {
            newVideoLocalRenderObj.parentHashID = [NSNumber numberWithLongLong:videoObj.objectID.hash];
            videoObj.videoLocalRender  = newVideoLocalRenderObj;
        }
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDVideoObjectAddingAllIteratedRelationshipsIfNon(CDVideoObject * obj)
{
    if (obj.videoLocalRender) {
        
    } else {
        CDVideoLocalRenderObject * localRenderObj = [CDVideoLocalRenderObject MR_createEntity];
        CDVideoOverlayObject * overlayObj = [CDVideoOverlayObject MR_createEntity];
        localRenderObj.videoOverlay  = overlayObj;
        obj.videoLocalRender = localRenderObj;
        ////to avoid  temporaryID sometimes
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
}
////individual File Path and videoId and makerId

NSString* replaceAPPIDInABSURLString(NSString*str,NSString * newAPPIDInPath)
{
    NSMutableString *tempString = [NSMutableString stringWithString:str];
    NSError *error;
    NSString *regulaStr = [NSString stringWithFormat:@"(.*)://(.*Application/)([0-9A-F\\-]+)(/.*)"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:tempString options:0 range:NSMakeRange(0, [tempString length])];
    ////NSString *substringForMatch = [NSString string];
    NSString *scheme = [NSString string];
    NSString *preHalf = [NSString string];
    NSString *oldAPPIDInPath = [NSString string];
    NSString *postHalf = [NSString string];

    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        
        /*
        unsigned long rangeCount = [match numberOfRanges];
        for (int i = 0; i<rangeCount; i++) {
            NSString * substringForMatch = [tempString substringWithRange: [match rangeAtIndex:i]];
            NSLog(@"substringForMatch: %@",substringForMatch);
        }
         */
        scheme = [tempString substringWithRange: [match rangeAtIndex:1]];
        preHalf = [tempString substringWithRange: [match rangeAtIndex:2]];
        oldAPPIDInPath = [tempString substringWithRange: [match rangeAtIndex:3]];
        postHalf = [tempString substringWithRange: [match rangeAtIndex:4]];
        
    }
    
    /*
    NSLog(@"scheme:%@",scheme);
    NSLog(@"preHalf:%@",preHalf);
    NSLog(@"oldAPPIDInPath:%@",oldAPPIDInPath);
    NSLog(@"postHalf:%@",postHalf);
    */
    
    [tempString replaceOccurrencesOfString:oldAPPIDInPath withString:newAPPIDInPath options:NSBackwardsSearch range:NSMakeRange(0, [tempString length])];
    ////NSLog(@"tempString:%@",tempString);
    return tempString;
}



NSString* getSourcePathWithTopDirName(NSString * topDirName)
{
    if (topDirName) {
        
    } else {
        topDirName = @"video_source";
    }
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docDir = [paths objectAtIndex:0];
    NSString* sourceDir = [docDir stringByAppendingPathComponent:topDirName];
    return sourceDir;
}
NSString* getMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{

    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie.%@", videoId,suffix]];
    return path;
}
NSString* getAudioOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@",videoId,whichTrack,suffix]];
    return path;
}
NSString* getVideoOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getMovieFromAlbumFileDir(NSString*makerId ,NSString * topDirName)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getMovieFromAlbumFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie.%@", videoId,suffix]];
    return path;
}
NSString* getMovieFromAlbumAudioOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getMovieFromAlbumAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getMovieFromAlbumVideoOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getMovieFromAlbumVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}
NSString* getPostCuttingMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getPostCuttingMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie.%@", videoId,suffix]];
    return path;
}
NSString* getPostCuttingAudioOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getPostCuttingAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{

    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getPostCuttingVideoOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getPostCuttingVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getPostCuttingThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_CUTTING"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getPostCuttingThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
 
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_CUTTING"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}
NSString* getPostFilteringMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getPostFilteringMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie.%@", videoId,suffix]];
    return path;
}
NSString* getPostFilteringAudioOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getPostFilteringAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getPostFilteringVideoOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getPostFilteringVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getPostFilteringThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_FILTERING"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getPostFilteringThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_FILTERING"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}
NSString* getSceneTitlesMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TITLES"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTitlesMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-titles";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TITLES"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie.%@", videoId,suffix]];
    return path;
}
NSString* getSceneTitlesAudioOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TITLES"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTitlesAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-titles";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TITLES"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getSceneTitlesVideoOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TITLES"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTitlesVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-titles";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TITLES"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getSceneTitlesThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_TITLES"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTitlesThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-titles";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_TITLES"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}
NSString* getSceneTailMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTailMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-tail";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie.%@", videoId,suffix]];
    return path;
}
NSString* getSceneTailAudioOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TAIL"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTailAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-tail";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TAIL"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getSceneTailVideoOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TAIL"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTailVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-tail";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"TAIL"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getSceneTailThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_TAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTailThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-tail";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_TAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}
NSString* getSceneOverlayMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneOverlayMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-overlay";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie.%@", videoId,suffix]];
    return path;
}
NSString* getSceneOverlayAudioOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneOverlayAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-overlay";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getSceneOverlayVideoOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneOverlayVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-overlay";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getSceneOverlayThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_SCENEOVERLAY"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneOverlayThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-overlay";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_SCENEOVERLAY"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}
NSString* getMaterialOverlaysMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getMaterialOverlaysMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie.%@", videoId,suffix]];
    return path;
}
NSString* getMaterialOverlaysAudioOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getMaterialOverlaysAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getMaterialOverlaysVideoOnlyFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getMaterialOverlaysVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-movie_%d.%@", videoId,whichTrack,suffix]];
    return path;
}
NSString* getMaterialOverlaysThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_MATERIALOVERLAYS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getMaterialOverlaysThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL_MATERIALOVERLAYS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}
NSString* getSceneBackgroundFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"BACKGROUND"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneBackgroundFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-background";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"BACKGROUND"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}
NSString* getSceneMusicFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENEMUSIC"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneMusicFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-music";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENEMUSIC"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"png";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}


NSString* getSceneMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-movie";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}


NSString* getSceneAudioFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneAudioFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-audio";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}

NSString* getSceneThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-thumbnail";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}

NSString* getSceneVideoFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneVideoFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-video";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}

NSString* getSceneTransitionsFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    path = [path stringByAppendingPathComponent:@"TRANSISIONS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getSceneTransitionsFilePath(int seq, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString*videoId = @"scene-trans";
    videoId = [NSString stringWithFormat:@"%@_%d",videoId,seq];
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE"];
    path = [path stringByAppendingPathComponent:@"TRANSISIONS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}

////-----

NSString* getScenePostTransisionsMovieFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getScenePostTransisionsMovieFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{

    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mp4";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}


NSString* getScenePostTransisionsAudioFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getScenePostTransisionsAudioFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}


NSString* getScenePostTransisionsAudioOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    path = [path stringByAppendingPathComponent:@"AUDIO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.%@", videoId,whichTrack,suffix]];
    return path;
}



NSString* getScenePostTransisionsThumbnailFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getScenePostTransisionsThumbnailFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    videoId = @"scene-thumbnail";
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    path = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"m4a";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}

NSString* getScenePostTransisionsVideoFileDir(NSString*makerId ,NSString * topDirName)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}
NSString* getScenePostTransisionsVideoFilePath(NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", videoId,suffix]];
    return path;
}


NSString* getScenePostTransisionsVideoOnlyFilePath(int whichTrack,NSString*videoId, NSString*makerId ,NSString * topDirName,NSString * suffix)
{
    NSString* path = getSourcePathWithTopDirName(topDirName);
    path = [path stringByAppendingPathComponent:makerId];
    path = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    path = [path stringByAppendingPathComponent:@"VIDEO"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (suffix) {
        
    } else {
        suffix = @"mov";
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.%@", videoId,whichTrack,suffix]];
    return path;
}

////-----



NSURL *getPostCuttingMovieURLFromMoviePath(NSString * moviePath)
{
    
    NSString * postCuttingMovieDir = [moviePath stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    NSString * movieName = [moviePath lastPathComponent];
    NSString * postCuttingMovie = [postCuttingMovieDir stringByAppendingPathComponent:movieName];
    NSURL * postCuttingMovieURL = [NSURL fileURLWithPath:postCuttingMovie];
    return(postCuttingMovieURL);
}
NSURL *getPostCuttingAudioOnlyURLFromAudioOnlyPath(NSString * moviePath)
{
    
    NSString * postCuttingMovieDir = [moviePath stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"AUDIO"];
    NSString * movieName = [moviePath lastPathComponent];
    NSString * postCuttingMovie = [postCuttingMovieDir stringByAppendingPathComponent:movieName];
    NSURL * postCuttingMovieURL = [NSURL fileURLWithPath:postCuttingMovie];
    return(postCuttingMovieURL);
}
NSURL *getPostCuttingVideoOnlyURLFromVideoOnlyPath(NSString * moviePath)
{
    
    NSString * postCuttingMovieDir = [moviePath stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"VIDEO"];
    NSString * movieName = [moviePath lastPathComponent];
    NSString * postCuttingMovie = [postCuttingMovieDir stringByAppendingPathComponent:movieName];
    NSURL * postCuttingMovieURL = [NSURL fileURLWithPath:postCuttingMovie];
    return(postCuttingMovieURL);
}
NSURL *getPostCuttingThumbnailURLFromThumbnailPath(NSString * thumbnailPath,int whichTrack)
{
    
    NSString * postCuttingMovieDir = [thumbnailPath stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"THUMBNAIL_POST_CUTTING"];
    NSString * movieName;
    if (whichTrack == -1) {
        movieName = [thumbnailPath lastPathComponent];
    } else {
        movieName = [thumbnailPath lastPathComponent];
        NSString * prefix = [movieName stringByDeletingPathExtension];
        prefix = [prefix stringByAppendingFormat:@"_%d.",whichTrack];
        NSString * suffix = [movieName pathExtension];
        movieName = [prefix stringByAppendingString:suffix];
    }
    
    NSString * postCuttingMovie = [postCuttingMovieDir stringByAppendingPathComponent:movieName];
    NSURL * postCuttingMovieURL = [NSURL fileURLWithPath:postCuttingMovie];
    return(postCuttingMovieURL);
}
NSURL *getPostFilteringAudioOnlyURLFromAudioOnlyPath(NSString * moviePath)
{
    
    NSString * postCuttingMovieDir = [moviePath stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"AUDIO"];
    NSString * movieName = [moviePath lastPathComponent];
    NSString * postCuttingMovie = [postCuttingMovieDir stringByAppendingPathComponent:movieName];
    NSURL * postCuttingMovieURL = [NSURL fileURLWithPath:postCuttingMovie];
    return(postCuttingMovieURL);
}
NSURL *getPostFilteringVideoOnlyURLFromVideoOnlyPath(NSString * moviePath)
{
    
    NSString * postCuttingMovieDir = [moviePath stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"VIDEO"];
    NSString * movieName = [moviePath lastPathComponent];
    NSString * postCuttingMovie = [postCuttingMovieDir stringByAppendingPathComponent:movieName];
    NSURL * postCuttingMovieURL = [NSURL fileURLWithPath:postCuttingMovie];
    return(postCuttingMovieURL);
}
NSURL *getPostFilteringThumbnailURLFromThumbnailPath(NSString * thumbnailPath,int whichTrack)
{
    
    NSString * postCuttingMovieDir = [thumbnailPath stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByDeletingLastPathComponent];
    postCuttingMovieDir = [postCuttingMovieDir stringByAppendingPathComponent:@"THUMBNAIL_POST_FILTERING"];
    NSString * movieName;
    if (whichTrack == -1) {
        movieName = [thumbnailPath lastPathComponent];
    } else {
        movieName = [thumbnailPath lastPathComponent];
        NSString * prefix = [movieName stringByDeletingPathExtension];
        prefix = [prefix stringByAppendingFormat:@"_%d.",whichTrack];
        NSString * suffix = [movieName pathExtension];
        movieName = [prefix stringByAppendingString:suffix];
    }
    
    NSString * postCuttingMovie = [postCuttingMovieDir stringByAppendingPathComponent:movieName];
    NSURL * postCuttingMovieURL = [NSURL fileURLWithPath:postCuttingMovie];
    return(postCuttingMovieURL);
}




NSURL * _Nullable getAudioOnlyDirURLFromMoviePath(NSString * _Nullable moviePath)
{
    NSString * audioOnlyDir = [moviePath stringByDeletingLastPathComponent];
    audioOnlyDir = [audioOnlyDir stringByAppendingPathComponent:@"AUDIO"];
    NSURL * audioOnlyDirURL = [NSURL fileURLWithPath:audioOnlyDir];
    return(audioOnlyDirURL);
    
}
NSURL * _Nullable getVideoOnlyDirURLFromMoviePath(NSString * _Nullable moviePath)
{
    NSString * videoOnlyDir = [moviePath stringByDeletingLastPathComponent];
    videoOnlyDir = [videoOnlyDir stringByAppendingPathComponent:@"VIDEO"];
    NSURL * videoOnlyDirURL = [NSURL fileURLWithPath:videoOnlyDir];
    return(videoOnlyDirURL);
}

NSString * getVideoIdFromMoviePath(NSString * _Nullable moviePath)
{
    NSString * name = [moviePath lastPathComponent];
    
    NSError * error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray * matches1 = [regex matchesInString:name
                                        options:0
                                          range:NSMakeRange(0, [name length])];
    
    NSTextCheckingResult * match1 = matches1[0];
    NSString * videoId = [name substringWithRange: [match1 rangeAtIndex:0]];
    return(videoId);
}

NSMutableArray * findAllCorrespondingAudioFileURLsOfMoviePath(NSString * _Nullable moviePath)
{
    NSString * videoID = getVideoIdFromMoviePath(moviePath);
    NSString * audioOnlyDir = [moviePath stringByDeletingLastPathComponent];
    audioOnlyDir = [audioOnlyDir stringByAppendingPathComponent:@"AUDIO"];
    return([FileUitl findSpecificFileURLsOfSubDir:videoID dirName:audioOnlyDir]);
    
}
NSMutableArray * findAllCorrespondingVideoFileURLsOfMoviePath(NSString * _Nullable moviePath)
{
    NSString * videoID = getVideoIdFromMoviePath(moviePath);
    NSString * videoOnlyDir = [moviePath stringByDeletingLastPathComponent];
    videoOnlyDir = [videoOnlyDir stringByAppendingPathComponent:@"VIDEO"];
    return([FileUitl findSpecificFileURLsOfSubDir:videoID dirName:videoOnlyDir]);
}

int getWhichTrackFromPath(NSString * _Nullable moviePath)
{
    NSError * error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_([0-9]+)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray * matches1 = [regex matchesInString:moviePath
                                        options:0
                                          range:NSMakeRange(0, [moviePath length])];
    ////第0个整体match
    NSTextCheckingResult * match1 = matches1[0];
    ////第1个括号
    NSString * whichTrack = [moviePath substringWithRange: [match1 rangeAtIndex:1]];
    return((int)[whichTrack integerValue]);
}

NSMutableArray * findAllCorrespondingAudioTracksOfMoviePath(NSString * _Nullable moviePath)
{
    NSMutableArray  * trackNums = [[NSMutableArray alloc] init];
    NSString * videoID = getVideoIdFromMoviePath(moviePath);
    NSString * audioOnlyDir = [moviePath stringByDeletingLastPathComponent];
    audioOnlyDir = [audioOnlyDir stringByAppendingPathComponent:@"AUDIO"];
    NSMutableArray * URLs = [FileUitl findSpecificFileURLsOfSubDir:videoID dirName:audioOnlyDir];
    for (int i = 0; i < URLs.count; i++) {
        NSString * path = [(NSURL *)URLs[i] path];
        int whichTrack = getWhichTrackFromPath(path);
        [trackNums addObject:[NSNumber numberWithInt: whichTrack]];
    }
    return(trackNums);
    
}
NSMutableArray * findAllCorrespondingVideoTracksOfMoviePath(NSString * _Nullable moviePath)
{
    NSMutableArray  * trackNums = [[NSMutableArray alloc] init];
    NSString * videoID = getVideoIdFromMoviePath(moviePath);
    NSString * videoOnlyDir = [moviePath stringByDeletingLastPathComponent];
    videoOnlyDir = [videoOnlyDir stringByAppendingPathComponent:@"VIDEO"];
    NSMutableArray * URLs = [FileUitl findSpecificFileURLsOfSubDir:videoID dirName:videoOnlyDir];
    for (int i = 0; i < URLs.count; i++) {
        NSString * path = [(NSURL *)URLs[i] path];
        int whichTrack = getWhichTrackFromPath(path);
        [trackNums addObject:[NSNumber numberWithInt: whichTrack]];
    }
    return(trackNums);
}

void deleteCorrespondingAudioFilesOfMoviePath(NSString * _Nullable moviePath)
{
    NSString * videoID = getVideoIdFromMoviePath(moviePath);
    NSLog(@"videoID:%@",videoID);
    NSString * audioOnlyDir = [moviePath stringByDeletingLastPathComponent];
    audioOnlyDir = [audioOnlyDir stringByAppendingPathComponent:@"AUDIO"];
    [FileUitl deleteSpecificFilesOfSubDir:videoID dirName:audioOnlyDir];

}
void deleteCorrespondingVideoFilesOfMoviePath(NSString * _Nullable moviePath)
{
    NSString * videoID = getVideoIdFromMoviePath(moviePath);
    NSLog(@"videoID:%@",videoID);
    NSString * videoOnlyDir = [moviePath stringByDeletingLastPathComponent];
    videoOnlyDir = [videoOnlyDir stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSpecificFilesOfSubDir:videoID dirName:videoOnlyDir];
}


////

void CDVideoObjectNullifyLocalRenderSizeAndPointParameters(CDVideoObject * _Nullable obj)
{

    obj.videoLocalRender.postRenderSizeX = nil;
    obj.videoLocalRender.postRenderSizeY = nil;
    obj.videoLocalRender.cropSizeX = nil;
    obj.videoLocalRender.cropSizeY = nil;
    obj.videoLocalRender.cropPositionOnOriginalMaterialX = nil;
    obj.videoLocalRender.cropPositionOnOriginalMaterialY = nil;
}

void CDVideoObjectFulFillLocalRenderURLs(CDVideoObject * _Nullable obj)
{
    if (obj.makerId) {
        
    } else {
        obj.makerId = obj.task.objectId;
    }
    
    obj.videoLocalRender.origURLstring = [NSURL fileURLWithPath:getMovieFilePath(obj.videoId, obj.makerId, nil, nil)].absoluteString;
    obj.videoLocalRender.origAudioWorkDirURLstring = [NSURL fileURLWithPath:getAudioOnlyFileDir(obj.makerId, nil)].absoluteString;
    obj.videoLocalRender.origVideoWorkDirURLstring = [NSURL fileURLWithPath:getVideoOnlyFileDir(obj.makerId, nil)].absoluteString;

    obj.videoLocalRender.origFromAlbumURLstring = [NSURL fileURLWithPath:getMovieFromAlbumFilePath(obj.videoId, obj.makerId, nil, nil)].absoluteString;
    obj.videoLocalRender.origFromAlbumAudioWorkDirURLstring = [NSURL fileURLWithPath:getMovieFromAlbumAudioOnlyFileDir(obj.makerId, nil)].absoluteString;
    obj.videoLocalRender.origFromAlbumVideoWorkDirURLstring = [NSURL fileURLWithPath:getMovieFromAlbumVideoOnlyFileDir(obj.makerId, nil)].absoluteString;

   
    
    
    obj.videoLocalRender.origThumbnailURLstring = [NSURL fileURLWithPath:getThumbnailFilePath(obj.videoId, obj.makerId, nil, nil)].absoluteString;
    
    obj.videoLocalRender.postCuttingURLstring = [NSURL fileURLWithPath:getPostCuttingMovieFilePath(obj.videoId, obj.makerId, nil, nil)].absoluteString;
    obj.videoLocalRender.postCuttingAudioWorkDirURLstring = [NSURL fileURLWithPath:getPostCuttingAudioOnlyFileDir(obj.makerId, nil)].absoluteString;
    obj.videoLocalRender.postCuttingVideoWorkDirURLstring = [NSURL fileURLWithPath:getPostCuttingVideoOnlyFileDir(obj.makerId, nil)].absoluteString;
    obj.videoLocalRender.postCuttingThumbnailURLstring = [NSURL fileURLWithPath:getPostCuttingThumbnailFilePath(obj.videoId, obj.makerId, nil, nil)].absoluteString;
    
    obj.videoLocalRender.postFilteringURLstring = [NSURL fileURLWithPath:getPostFilteringMovieFilePath(obj.videoId, obj.makerId, nil, nil)].absoluteString;
    obj.videoLocalRender.postFilteringAudioWorkDirURLstring = [NSURL fileURLWithPath:getPostFilteringAudioOnlyFileDir(obj.makerId, nil)].absoluteString;
    obj.videoLocalRender.postFilteringVideoWorkDirURLstring = [NSURL fileURLWithPath:getPostFilteringVideoOnlyFileDir(obj.makerId, nil)].absoluteString;
    obj.videoLocalRender.postFilteringThumbnailURLstring = [NSURL fileURLWithPath:getPostFilteringThumbnailFilePath(obj.videoId, obj.makerId, nil, nil)].absoluteString;
    
    
}


void deleteAllCorrespondingFilesViaVideoObject(CDVideoObject*videoObject)
{
    NSLog(@"%@ in deleteAllCorrespondingFilesViaVideoObject",videoObject);
    
    if (videoObject.makerId) {
        
    } else {
        videoObject.makerId = videoObject.task.objectId;
    }
    
    
    //要不要删视频文件？
    NSString* videoPath = getMovieFilePath(videoObject.videoId,videoObject.makerId,nil,nil);
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
    
    ////NSLog(@"videoPath:%@",videoPath);
    
    
    deleteCorrespondingAudioFilesOfMoviePath(videoPath);
    deleteCorrespondingVideoFilesOfMoviePath(videoPath);
    
    
    
    NSString* videoFromAlbumPath = getMovieFromAlbumFilePath(videoObject.videoId,videoObject.makerId,nil,nil);
    [[NSFileManager defaultManager] removeItemAtPath:videoFromAlbumPath error:nil];
    
    ////NSLog(@"videoFromAlbumPath:%@",videoFromAlbumPath);
    
    deleteCorrespondingAudioFilesOfMoviePath(videoFromAlbumPath);
    deleteCorrespondingVideoFilesOfMoviePath(videoFromAlbumPath);
    
    
    
    NSString* thumbnailPath = getThumbnailFilePath(videoObject.videoId,videoObject.makerId,nil,nil);
    [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:nil];
    
    ////-dli-delete-all-corresponding-files
    
    NSString* PCMpath = getPostCuttingMovieFilePath(videoObject.videoId,videoObject.makerId,nil,nil);
    [[NSFileManager defaultManager] removeItemAtPath:PCMpath error:nil];
    
    deleteCorrespondingAudioFilesOfMoviePath(PCMpath);
    deleteCorrespondingVideoFilesOfMoviePath(PCMpath);

    NSString* PCTpath = getPostCuttingThumbnailFilePath(videoObject.videoId,videoObject.makerId,nil,nil);
    [[NSFileManager defaultManager] removeItemAtPath:PCTpath error:nil];
    
    NSString* PFMpath = getPostFilteringMovieFilePath(videoObject.videoId,videoObject.makerId,nil,nil);
    [[NSFileManager defaultManager] removeItemAtPath:PFMpath error:nil];
    
    deleteCorrespondingAudioFilesOfMoviePath(PFMpath);
    deleteCorrespondingVideoFilesOfMoviePath(PFMpath);
    
    NSString* PFTpath = getPostFilteringThumbnailFilePath(videoObject.videoId,videoObject.makerId,nil,nil);
    [[NSFileManager defaultManager] removeItemAtPath:PFTpath error:nil];
    
    ////-dli--delete-all-corresponding-files
}
////
void deleteWorkdirForSingleVideoMaterials(NSString * _Nullable makerId)
{
    NSString* path = getSourcePathWithTopDirName(nil);
    path = [path stringByAppendingPathComponent:makerId];
    
    NSString* pathM = [path stringByAppendingPathComponent:@"MOVIES"];
    [FileUitl deleteSubDir:pathM];
    
    NSString* videoFromAlbumPath = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    [FileUitl deleteSubDir:videoFromAlbumPath];
    
    NSString* pathT = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl deleteSubDir:pathT];
    
    NSString * pathMPC = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    [FileUitl deleteSubDir:pathMPC];

    NSString * pathTPC = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_CUTTING"];
    [FileUitl deleteSubDir:pathTPC];

    
    NSString * pathMPF = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    [FileUitl deleteSubDir:pathMPF];

    NSString * pathTPF = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_FILTERING"];
    [FileUitl deleteSubDir:pathTPF];
    
    
    NSString * pathTitles = [path stringByAppendingPathComponent:@"TITLES"];
    [FileUitl deleteSubDir:pathTitles];

    NSString * pathTitlesThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_TITLES"];
    [FileUitl deleteSubDir:pathTitlesThumb];
    
    
    NSString * pathTail = [path stringByAppendingPathComponent:@"TAIL"];
    [FileUitl deleteSubDir:pathTail];
    
    
    NSString * pathTailThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_TAIL"];
    [FileUitl deleteSubDir:pathTailThumb];

    
    NSString * pathSceneOverlay = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    [FileUitl deleteSubDir:pathSceneOverlay];
    
    NSString * pathSceneOverlayThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_SCENEOVERLAY"];
    [FileUitl deleteSubDir:pathSceneOverlayThumb];

    
    NSString * pathMaterialOverlays = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    [FileUitl deleteSubDir:pathMaterialOverlays];
    
    NSString * pathMaterialOverlaysThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_MATERIALOVERLAYS"];
    [FileUitl deleteSubDir:pathMaterialOverlaysThumb];
    

    NSString * pathBG = [path stringByAppendingPathComponent:@"BACKGROUND"];
    [FileUitl deleteSubDir:pathBG];

    
    NSString * pathSCENEMUSIC = [path stringByAppendingPathComponent:@"SCENEMUSIC"];
    [FileUitl deleteSubDir:pathSCENEMUSIC];
    
    
    NSString * pathSceneMovie = [path stringByAppendingPathComponent:@"SCENE"];
    [FileUitl deleteSubDir:pathSceneMovie];

    NSString * pathSceneAudio = [pathSceneMovie stringByAppendingPathComponent:@"AUDIO"];
    [FileUitl deleteSubDir:pathSceneAudio];

    NSString * pathSceneVideo = [pathSceneMovie stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathSceneVideo];

    NSString * pathSceneThumb = [pathSceneMovie stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl deleteSubDir:pathSceneThumb];

    NSString * pathSceneTrans = [pathSceneMovie stringByAppendingPathComponent:@"TRANSITIONS"];
    [FileUitl deleteSubDir:pathSceneTrans];

    
    NSString * pathScenePostTransMovie = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    [FileUitl deleteSubDir:pathScenePostTransMovie];
    NSString * pathScenePostTransAudio = [pathScenePostTransMovie stringByAppendingPathComponent:@"AUDIO"];
    [FileUitl deleteSubDir:pathScenePostTransAudio];

    NSString * pathScenePostTransVideo = [pathScenePostTransMovie stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathScenePostTransVideo];

    NSString * pathScenePostTransThumb = [pathScenePostTransMovie stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl deleteSubDir:pathScenePostTransThumb];


}
void supplementWorkdirForSingleVideoMaterials(NSString * _Nullable makerId)
{
    NSString* path = getSourcePathWithTopDirName(nil);
    path = [path stringByAppendingPathComponent:makerId];
    
    NSString* pathM = [path stringByAppendingPathComponent:@"MOVIES"];
    NSString * pathMA = [pathM stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathMV = [pathM stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathM];
    [FileUitl creatSubDir:pathMA];
    [FileUitl creatSubDir:pathMV];
    
    NSString* videoFromAlbumPath = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    NSString* PAFApath = [videoFromAlbumPath stringByAppendingPathComponent:@"AUDIO"];
    NSString* PVFApath = [videoFromAlbumPath stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:videoFromAlbumPath];
    [FileUitl creatSubDir:PAFApath];
    [FileUitl creatSubDir:PVFApath];
    
    
    NSString* pathT = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl creatSubDir:pathT];
    
    
    NSString * pathMPC = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    NSString * pathMPCA = [pathMPC stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathMPCV = [pathMPC stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathMPC];
    [FileUitl creatSubDir:pathMPCA];
    [FileUitl creatSubDir:pathMPCV];
    NSString * pathTPC = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_CUTTING"];
    [FileUitl creatSubDir:pathTPC];
    
    NSString * pathMPF = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    NSString * pathMPFA = [pathMPF stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathMPFV = [pathMPF stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathMPF];
    [FileUitl creatSubDir:pathMPFA];
    [FileUitl creatSubDir:pathMPFV];
    NSString * pathTPF = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_FILTERING"];
    [FileUitl creatSubDir:pathTPF];
    
    
    NSString * pathTitles = [path stringByAppendingPathComponent:@"TITLES"];
    NSString * pathTitlesA = [pathTitles stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathTitlesV = [pathTitles stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathTitles];
    [FileUitl creatSubDir:pathTitlesA];
    [FileUitl creatSubDir:pathTitlesV];
    NSString * pathTitlesThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_TITLES"];
    [FileUitl creatSubDir:pathTitlesThumb];
    
    
    
    NSString * pathTail = [path stringByAppendingPathComponent:@"TAIL"];
    NSString * pathTailA = [pathTail stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathTailV = [pathTail stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathTail];
    [FileUitl creatSubDir:pathTailA];
    [FileUitl creatSubDir:pathTailV];
    NSString * pathTailThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_TAIL"];
    [FileUitl creatSubDir:pathTailThumb];
    
    
    
    NSString * pathSceneOverlay = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    NSString * pathSceneOverlayA = [pathSceneOverlay stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathSceneOverlayV = [pathSceneOverlay stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathSceneOverlay];
    [FileUitl creatSubDir:pathSceneOverlayA];
    [FileUitl creatSubDir:pathSceneOverlayV];
    NSString * pathSceneOverlayThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_SCENEOVERLAY"];
    [FileUitl creatSubDir:pathSceneOverlayThumb];
    
    
    
    NSString * pathMaterialOverlays = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    NSString * pathMaterialOverlaysA = [pathMaterialOverlays stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathMaterialOverlaysV = [pathMaterialOverlays stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathMaterialOverlays];
    [FileUitl creatSubDir:pathMaterialOverlaysA];
    [FileUitl creatSubDir:pathMaterialOverlaysV];
    NSString * pathMaterialOverlaysThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_MATERIALOVERLAYS"];
    [FileUitl creatSubDir:pathMaterialOverlaysThumb];
    
    NSString * pathBG = [path stringByAppendingPathComponent:@"BACKGROUND"];
    [FileUitl creatSubDir:pathBG];
    [FileUitl creatSubDir:pathBG];
    
    NSString * pathSCENEMUSIC = [path stringByAppendingPathComponent:@"SCENEMUSIC"];
    [FileUitl creatSubDir:pathSCENEMUSIC];
    [FileUitl creatSubDir:pathSCENEMUSIC];
    
    NSString * pathSceneMovie = [path stringByAppendingPathComponent:@"SCENE"];
    [FileUitl creatSubDir:pathSceneMovie];
    NSString * pathSceneAudio = [pathSceneMovie stringByAppendingPathComponent:@"AUDIO"];
    [FileUitl creatSubDir:pathSceneAudio];
    NSString * pathSceneVideo = [pathSceneMovie stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathSceneVideo];
    NSString * pathSceneThumb = [pathSceneMovie stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl creatSubDir:pathSceneThumb];
    NSString * pathSceneTrans = [pathSceneMovie stringByAppendingPathComponent:@"TRANSITIONS"];
    [FileUitl creatSubDir:pathSceneTrans];
    
    NSString * pathScenePostTransMovie = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    [FileUitl creatSubDir:pathScenePostTransMovie];
    NSString * pathScenePostTransAudio = [pathScenePostTransMovie stringByAppendingPathComponent:@"AUDIO"];
    [FileUitl creatSubDir:pathScenePostTransAudio];
    NSString * pathScenePostTransVideo = [pathScenePostTransMovie stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl creatSubDir:pathScenePostTransVideo];
    NSString * pathScenePostTransThumb = [pathScenePostTransMovie stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl creatSubDir:pathScenePostTransThumb];


    
    
}
void resetWorkdirForSingleVideoMaterials(NSString * _Nullable makerId)
{
    NSString* path = getSourcePathWithTopDirName(nil);
    path = [path stringByAppendingPathComponent:makerId];
    
    NSString* pathM = [path stringByAppendingPathComponent:@"MOVIES"];
    NSString * pathMA = [pathM stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathMV = [pathM stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathM];
    [FileUitl creatSubDir:pathM];
    [FileUitl creatSubDir:pathMA];
    [FileUitl creatSubDir:pathMV];
    
    NSString* videoFromAlbumPath = [path stringByAppendingPathComponent:@"MOVIESFROMALBUM"];
    NSString* PAFApath = [videoFromAlbumPath stringByAppendingPathComponent:@"AUDIO"];
    NSString* PVFApath = [videoFromAlbumPath stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:videoFromAlbumPath];
    [FileUitl creatSubDir:videoFromAlbumPath];
    [FileUitl creatSubDir:PAFApath];
    [FileUitl creatSubDir:PVFApath];
    
    
    NSString* pathT = [path stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl deleteSubDir:pathT];
    [FileUitl creatSubDir:pathT];
    
    
    NSString * pathMPC = [path stringByAppendingPathComponent:@"MOVIES_POST_CUTTING"];
    NSString * pathMPCA = [pathMPC stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathMPCV = [pathMPC stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathMPC];
    [FileUitl creatSubDir:pathMPC];
    [FileUitl creatSubDir:pathMPCA];
    [FileUitl creatSubDir:pathMPCV];
    NSString * pathTPC = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_CUTTING"];
    [FileUitl deleteSubDir:pathTPC];
    [FileUitl creatSubDir:pathTPC];
    
    NSString * pathMPF = [path stringByAppendingPathComponent:@"MOVIES_POST_FILTERING"];
    NSString * pathMPFA = [pathMPF stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathMPFV = [pathMPF stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathMPF];
    [FileUitl creatSubDir:pathMPF];
    [FileUitl creatSubDir:pathMPFA];
    [FileUitl creatSubDir:pathMPFV];
    NSString * pathTPF = [path stringByAppendingPathComponent:@"THUMBNAIL_POST_FILTERING"];
    [FileUitl deleteSubDir:pathTPF];
    [FileUitl creatSubDir:pathTPF];
    
    NSString * pathTitles = [path stringByAppendingPathComponent:@"TITLES"];
    NSString * pathTitlesA = [pathTitles stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathTitlesV = [pathTitles stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathTitles];
    [FileUitl creatSubDir:pathTitlesA];
    [FileUitl creatSubDir:pathTitlesV];
    NSString * pathTitlesThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_TITLES"];
    [FileUitl deleteSubDir:pathTitlesThumb];
    [FileUitl creatSubDir:pathTitlesThumb];
    
    NSString * pathTail = [path stringByAppendingPathComponent:@"TAIL"];
    NSString * pathTailA = [pathTail stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathTailV = [pathTail stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathTail];
    [FileUitl creatSubDir:pathTailA];
    [FileUitl creatSubDir:pathTailV];
    NSString * pathTailThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_TAIL"];
    [FileUitl deleteSubDir:pathTailThumb];
    [FileUitl creatSubDir:pathTailThumb];
    
    
    NSString * pathSceneOverlay = [path stringByAppendingPathComponent:@"SCENEOVERLAY"];
    NSString * pathSceneOverlayA = [pathSceneOverlay stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathSceneOverlayV = [pathSceneOverlay stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathSceneOverlay];
    [FileUitl creatSubDir:pathSceneOverlayA];
    [FileUitl creatSubDir:pathSceneOverlayV];
    NSString * pathSceneOverlayThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_SCENEOVERLAY"];
    [FileUitl deleteSubDir:pathSceneOverlayThumb];
    [FileUitl creatSubDir:pathSceneOverlayThumb];
    
    NSString * pathMaterialOverlays = [path stringByAppendingPathComponent:@"MATERIALOVERLAYS"];
    NSString * pathMaterialOverlaysA = [pathMaterialOverlays stringByAppendingPathComponent:@"AUDIO"];
    NSString * pathMaterialOverlaysV = [pathMaterialOverlays stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathMaterialOverlays];
    [FileUitl creatSubDir:pathMaterialOverlaysA];
    [FileUitl creatSubDir:pathMaterialOverlaysV];
    NSString * pathMaterialOverlaysThumb = [path stringByAppendingPathComponent:@"THUMBNAIL_MATERIALOVERLAYS"];
    [FileUitl deleteSubDir:pathMaterialOverlaysThumb];
    [FileUitl creatSubDir:pathMaterialOverlaysThumb];
    
    
    NSString * pathBG = [path stringByAppendingPathComponent:@"BACKGROUND"];
    [FileUitl deleteSubDir:pathBG];
    [FileUitl creatSubDir:pathBG];
    
    NSString * pathSCENEMUSIC = [path stringByAppendingPathComponent:@"SCENEMUSIC"];
    [FileUitl deleteSubDir:pathSCENEMUSIC];
    [FileUitl creatSubDir:pathSCENEMUSIC];
    
    
    NSString * pathSceneMovie = [path stringByAppendingPathComponent:@"SCENE"];
    [FileUitl deleteSubDir:pathSceneMovie];
    [FileUitl creatSubDir:pathSceneMovie];
    NSString * pathSceneAudio = [pathSceneMovie stringByAppendingPathComponent:@"AUDIO"];
    [FileUitl deleteSubDir:pathSceneAudio];
    [FileUitl creatSubDir:pathSceneAudio];
    NSString * pathSceneVideo = [pathSceneMovie stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathSceneVideo];
    [FileUitl creatSubDir:pathSceneVideo];
    NSString * pathSceneThumb = [pathSceneMovie stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl deleteSubDir:pathSceneThumb];
    [FileUitl creatSubDir:pathSceneThumb];
    NSString * pathSceneTrans = [pathSceneMovie stringByAppendingPathComponent:@"TRANSITIONS"];
    [FileUitl deleteSubDir:pathSceneTrans];
    [FileUitl creatSubDir:pathSceneTrans];
    
    
    NSString * pathScenePostTransMovie = [path stringByAppendingPathComponent:@"SCENE_POST_TRANSITIONS"];
    [FileUitl deleteSubDir:pathScenePostTransMovie];
    [FileUitl creatSubDir:pathScenePostTransMovie];
    NSString * pathScenePostTransAudio = [pathScenePostTransMovie stringByAppendingPathComponent:@"AUDIO"];
    [FileUitl deleteSubDir:pathScenePostTransAudio];
    [FileUitl creatSubDir:pathScenePostTransAudio];
    NSString * pathScenePostTransVideo = [pathScenePostTransMovie stringByAppendingPathComponent:@"VIDEO"];
    [FileUitl deleteSubDir:pathScenePostTransVideo];
    [FileUitl creatSubDir:pathScenePostTransVideo];
    NSString * pathScenePostTransThumb = [pathScenePostTransMovie stringByAppendingPathComponent:@"THUMBNAIL"];
    [FileUitl deleteSubDir:pathScenePostTransThumb];
    [FileUitl creatSubDir:pathScenePostTransThumb];
    
    
}
////



////CDVideoLocalRenderObject
void CDVideoLocalRenderObjectDeleteSelfVideoOverlay(CDVideoLocalRenderObject*robj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        CDVideoLocalRenderObject * videoLocalRenderObj = [robj MR_inContext:localContext];
        CDVideoOverlayObject * videoOverlayObj =  [robj.videoOverlay MR_inContext:localContext];
        
        if (videoOverlayObj) {
            [videoOverlayObj MR_deleteEntityInContext:localContext];
        }
        videoLocalRenderObj.videoOverlay = nil;
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDVideoLocalRenderObjectCreatNewWithVideoOverlay(BOOL tempOrNot)
{
    __block CDVideoOverlayObject * videoOverlayObject;
    __block CDVideoLocalRenderObject *videoLocalRenderObject;
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        ////relationShip 必须在同一个context 下产生
        videoOverlayObject = [CDVideoOverlayObject MR_createEntityInContext:localContext];
        videoOverlayObject.temporary = [NSNumber numberWithBool:tempOrNot];

        videoLocalRenderObject = [CDVideoLocalRenderObject MR_createEntityInContext:localContext];
        videoLocalRenderObject.temporary = [NSNumber numberWithBool:tempOrNot];
        videoLocalRenderObject.videoOverlay = videoOverlayObject;
        
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            ////If the receiver has not yet been saved, the object ID is a temporary value that will change when the object is saved.
            CDVideoLocalRenderObject * videoLocalRenderObj = [videoLocalRenderObject MR_inContext:localContext];
            CDVideoOverlayObject * videoOverlayObj = [videoOverlayObject MR_inContext:localContext];
            videoOverlayObj.parentHashID = [NSNumber numberWithLongLong:videoLocalRenderObj.objectID.hash];
        }];
  
    }];
}
void CDVideoLocalRenderObjectUpdateVideoOverlay(CDVideoLocalRenderObject*robj,CDVideoOverlayObject*nvobj)
{
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        CDVideoLocalRenderObject * videoLocalRenderObj = [robj MR_inContext:localContext];
        CDVideoOverlayObject * videoOverlayObj =  [robj.videoOverlay MR_inContext:localContext];
        CDVideoOverlayObject * newVideoOverlayObj =  [nvobj MR_inContext:localContext];
        
        if (videoOverlayObj) {
            [videoOverlayObj MR_deleteEntityInContext:localContext];
            videoLocalRenderObj.videoOverlay = nil;
        }
        
        if (newVideoOverlayObj) {
            newVideoOverlayObj.parentHashID = [NSNumber numberWithLongLong:videoLocalRenderObj.objectID.hash];
            videoLocalRenderObj.videoOverlay = newVideoOverlayObj;
        }
        
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
    
}




////CDSceneObject
void CDSceneObjectDeleteAllSelfAttributes(CDSceneObject*sobj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        CDSceneObject * sceneObj = [sobj MR_inContext:localContext];
        CDVideoOverlayObject * videoOverlayObj =  [sceneObj.overlayPostCompositionFilter MR_inContext:localContext];
        CDVideoLowerThirdObject * lowerThirdObj = [sceneObj.lowerThirdPostOverlay MR_inContext:localContext];
        CDVideoTextOverBackGroundObject * textOverbackGroundObj = [sceneObj.textOverBG MR_inContext:localContext];
        CDAudioSceneMusicObject * musicPostBG = [sceneObj.musicPostBGIntergration MR_inContext:localContext];
        CDVideoTitlesObject * titles = [sceneObj.titles MR_inContext:localContext];
        CDVideoTailObject * tail =[sceneObj.tail MR_inContext:localContext];

        if (videoOverlayObj) {
            [videoOverlayObj MR_deleteEntityInContext:localContext];
        }
        sceneObj.overlayPostCompositionFilter = nil;
        
        if (lowerThirdObj) {
            [lowerThirdObj MR_deleteEntityInContext:localContext];
        }
        sceneObj.lowerThirdPostOverlay = nil;
        
        if (textOverbackGroundObj) {
            [textOverbackGroundObj MR_deleteEntityInContext:localContext];
        }
        sceneObj.textOverBG = nil;
        
        if (musicPostBG) {
            [musicPostBG MR_deleteEntityInContext:localContext];
        }
        sceneObj.musicPostBGIntergration = nil;
        
        if (titles) {
            [titles MR_deleteEntityInContext:localContext];
        }
        sceneObj.titles= nil;
        
        if (tail) {
            [tail MR_deleteEntityInContext:localContext];
        }
        sceneObj.tail= nil;
        

    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDSceneObjectCreatNewWithAllIteratedRelationships(BOOL tempOrNot)
{
    
    __block CDSceneObject * sceneObj ;
    __block CDVideoOverlayObject * videoOverlayObj ;
    __block CDVideoLowerThirdObject * lowerThirdObj;
    __block CDVideoTextOverBackGroundObject * textOverbackGroundObj;
    __block CDAudioSceneMusicObject * musicPostBG ;
    __block CDVideoTitlesObject * titles;
    __block CDVideoTailObject * tail;

    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        ////relationShip 必须在同一个context 下产生
        
        
        videoOverlayObj = [CDVideoOverlayObject MR_createEntityInContext:localContext];
        videoOverlayObj.temporary = [NSNumber numberWithBool:tempOrNot];
        
        lowerThirdObj = [CDVideoLowerThirdObject MR_createEntityInContext:localContext];
        lowerThirdObj.temporary = [NSNumber numberWithBool:tempOrNot];

        
        textOverbackGroundObj = [CDVideoTextOverBackGroundObject MR_createEntityInContext:localContext];
        textOverbackGroundObj.temporary = [NSNumber numberWithBool:tempOrNot];
        
        
        musicPostBG = [CDAudioSceneMusicObject MR_createEntityInContext:localContext];
        musicPostBG.temporary = [NSNumber numberWithBool:tempOrNot];

        
        titles = [CDVideoTitlesObject MR_createEntityInContext:localContext];
        titles.temporary = [NSNumber numberWithBool:tempOrNot];

        
        tail = [CDVideoTailObject MR_createEntityInContext:localContext];
        tail.temporary = [NSNumber numberWithBool:tempOrNot];
        
        
        sceneObj =[CDSceneObject MR_createEntityInContext:localContext];
        sceneObj.temporary = [NSNumber numberWithBool:tempOrNot];
        
        sceneObj.overlayPostCompositionFilter = videoOverlayObj;
        sceneObj.lowerThirdPostOverlay = lowerThirdObj;
        sceneObj.textOverBG = textOverbackGroundObj;
        sceneObj.musicPostBGIntergration = musicPostBG;
        sceneObj.titles = titles;
        sceneObj.tail = tail;
        

        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            ////If the receiver has not yet been saved, the object ID is a temporary value that will change when the object is saved.
            CDSceneObject * sceneObject = [sceneObj MR_inContext:localContext];
            CDVideoOverlayObject * videoOverlayObject = [videoOverlayObj MR_inContext:localContext];
            videoOverlayObject.parentHashID = [NSNumber numberWithLongLong:sceneObject.objectID.hash];
            CDVideoLowerThirdObject * lowerThirdObject = [lowerThirdObj MR_inContext:localContext];
            lowerThirdObject.parentHashID = [NSNumber numberWithLongLong:sceneObject.objectID.hash];
            CDVideoTextOverBackGroundObject * textOverBackGroundObject = [textOverbackGroundObj MR_inContext:localContext];
            textOverBackGroundObject.parentHashID = [NSNumber numberWithLongLong:sceneObject.objectID.hash];
            CDAudioSceneMusicObject * musicPostBGObject = [musicPostBG MR_inContext:localContext];
            musicPostBGObject.parentHashID = [NSNumber numberWithLongLong:sceneObject.objectID.hash];
            CDVideoTitlesObject * titlesObject = [titles MR_inContext:localContext];
            titlesObject.parentHashID = [NSNumber numberWithLongLong:sceneObject.objectID.hash];
            CDVideoTailObject * tailObject = [tail MR_inContext:localContext];
            tailObject.parentHashID = [NSNumber numberWithLongLong:sceneObject.objectID.hash];
            
        }];
        
    }];
    
}





void CDSceneObjectUpdateVideoOverlayObject(CDSceneObject*sobj,CDVideoOverlayObject * voobj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        CDSceneObject * sceneObj = [sobj MR_inContext:localContext];
        CDVideoOverlayObject * videoOverlayObj =[sceneObj.overlayPostCompositionFilter MR_inContext:localContext];
        if (videoOverlayObj) {
            [videoOverlayObj MR_deleteEntityInContext:localContext];
            sceneObj.overlayPostCompositionFilter = nil;
        }
        CDVideoOverlayObject * newVideoOverlayObj =  [voobj MR_inContext:localContext];
        if (newVideoOverlayObj) {
            newVideoOverlayObj.parentHashID = [NSNumber numberWithLongLong:sceneObj.objectID.hash];
            sceneObj.overlayPostCompositionFilter  = newVideoOverlayObj;
        }
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDSceneObjectUpdateLowerThirdObject(CDSceneObject * sobj,CDVideoLowerThirdObject * ltobj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        CDSceneObject * sceneObj = [sobj MR_inContext:localContext];
        CDVideoLowerThirdObject * videoLowerThirdObj =[sceneObj.lowerThirdPostOverlay MR_inContext:localContext];
        if (videoLowerThirdObj) {
            [videoLowerThirdObj MR_deleteEntityInContext:localContext];
            sceneObj.lowerThirdPostOverlay = nil;
        }
        CDVideoLowerThirdObject * newVideoLowerThirdObj =  [ltobj MR_inContext:localContext];
        if (newVideoLowerThirdObj) {
            newVideoLowerThirdObj.parentHashID = [NSNumber numberWithLongLong:sceneObj.objectID.hash];
            sceneObj.lowerThirdPostOverlay  = newVideoLowerThirdObj;
        }
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDSceneObjectUpdateTextOverBackGroundObject(CDSceneObject * sobj,CDVideoTextOverBackGroundObject * tobgobj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        CDSceneObject * sceneObj = [sobj MR_inContext:localContext];
        CDVideoTextOverBackGroundObject * videoTextOverBackGroundObj =[sceneObj.textOverBG MR_inContext:localContext];
        if (videoTextOverBackGroundObj) {
            [videoTextOverBackGroundObj MR_deleteEntityInContext:localContext];
            sceneObj.textOverBG = nil;
        }
        CDVideoTextOverBackGroundObject * newVideoTextOverBackGroundObj =  [tobgobj MR_inContext:localContext];
        if (newVideoTextOverBackGroundObj) {
            newVideoTextOverBackGroundObj.parentHashID = [NSNumber numberWithLongLong:sceneObj.objectID.hash];
            sceneObj.textOverBG  = newVideoTextOverBackGroundObj;
        }
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDSceneObjectUpdateAudioSceneMusicObject(CDSceneObject * sobj,CDAudioSceneMusicObject * mobj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        CDSceneObject * sceneObj = [sobj MR_inContext:localContext];
        CDAudioSceneMusicObject * musicPostBGObj = [sceneObj.musicPostBGIntergration MR_inContext:localContext];
        
        if (musicPostBGObj) {
            [musicPostBGObj MR_deleteEntityInContext:localContext];
            sceneObj.musicPostBGIntergration = nil;
        }
        CDAudioSceneMusicObject * newMusicPostBGObj =  [mobj MR_inContext:localContext];
        if (newMusicPostBGObj) {
            newMusicPostBGObj.parentHashID = [NSNumber numberWithLongLong:sceneObj.objectID.hash];
            sceneObj.musicPostBGIntergration  = newMusicPostBGObj;
        }
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDSceneObjectUpdateTitlesObject(CDSceneObject * sobj,CDVideoTitlesObject * titlesobj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        CDSceneObject * sceneObj = [sobj MR_inContext:localContext];
        CDVideoTitlesObject * titlesObj = [sceneObj.titles MR_inContext:localContext];
        
        if (titlesObj) {
            [titlesObj MR_deleteEntityInContext:localContext];
            sceneObj.titles = nil;
        }
        CDVideoTitlesObject * newTitlesObj =  [titlesObj MR_inContext:localContext];
        if (newTitlesObj) {
            newTitlesObj.parentHashID = [NSNumber numberWithLongLong:sceneObj.objectID.hash];
            sceneObj.titles  = newTitlesObj;
        }
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}
void CDSceneObjectUpdateTailObject(CDSceneObject * sobj,CDVideoTitlesObject * tailobj)
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        CDSceneObject * sceneObj = [sobj MR_inContext:localContext];
        CDVideoTailObject * tailObj = [sceneObj.tail MR_inContext:localContext];
        
        if (tailObj) {
            [tailObj MR_deleteEntityInContext:localContext];
            sceneObj.tail = nil;
        }
        CDVideoTailObject * newTailObj =  [tailObj MR_inContext:localContext];
        if (newTailObj) {
            newTailObj.parentHashID = [NSNumber numberWithLongLong:sceneObj.objectID.hash];
            sceneObj.tail  = newTailObj;
        }
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];
}


////-----processing Flow
////CDVideoOverlayObject




int overlayTypeToEnum(NSString*type)
{
    
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"image"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches = [regex matchesInString:type
                                           options:0
                                             range:NSMakeRange(0, [type length])];
        if (matches.count>0) {
            return(0);
        }
    }
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"GIF"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches = [regex matchesInString:type
                                           options:0
                                             range:NSMakeRange(0, [type length])];
        if (matches.count>0) {
            return(1);
        }
    }
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"video"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches = [regex matchesInString:type
                                           options:0
                                             range:NSMakeRange(0, [type length])];
        if (matches.count>0) {
            return(2);
        }
    }
    return(-1);
}
NSString * enumToOverlayType(int typeNum)
{
    switch (typeNum) {
        case overlayType_Image:
        {
            return(@"image");
        }
        case overlayType_GIF:
        {
            return(@"GIF");
        }
        case overlayType_Video:
        {
            return(@"video");
        }
        default:
            return(NULL);
    }
}
NSURL *getPostStateOneProcessingVideoOnlyURLFromOverlayPath(NSString * overlayPath,int whichTrack)
{
    NSString * postStateOneProcessingDir = [overlayPath stringByDeletingLastPathComponent];
    NSString *  videoOnlyDir = [postStateOneProcessingDir stringByAppendingPathComponent:@"VIDEO"];
    NSString * name = [overlayPath lastPathComponent];
    name = [name stringByDeletingPathExtension];
    name = [name stringByAppendingFormat:@"_%d.mov",whichTrack];
    NSString * videoPath = [videoOnlyDir stringByAppendingPathComponent:name];
    NSURL * videoURL = [NSURL fileURLWithPath:videoPath];
    return(videoURL);
}
NSURL *getPostStateOneProcessingAudioOnlyURLFromOverlayPath(NSString * overlayPath,int whichTrack)
{
    NSString * postStateOneProcessingDir = [overlayPath stringByDeletingLastPathComponent];
    NSString *  audioOnlyDir = [postStateOneProcessingDir stringByAppendingPathComponent:@"AUDIO"];
    NSString * name = [overlayPath lastPathComponent];
    name = [name stringByDeletingPathExtension];
    name = [name stringByAppendingFormat:@"_%d.m4a",whichTrack];
    NSString * audioPath = [audioOnlyDir stringByAppendingPathComponent:name];
    NSURL * audioURL = [NSURL fileURLWithPath:audioPath];
    return(audioURL);
}
int timeTrimmingTypeToEnum(NSString*type)
{
    
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"tail"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches = [regex matchesInString:type
                                           options:0
                                             range:NSMakeRange(0, [type length])];
        if (matches.count>0) {
            return(0);
        }
    }
    return(-1);
}
NSString * enumToTimeTrimmingType(int typeNum)
{
    switch (typeNum) {
        case timeTrimmingModeType_Tail:
        {
            return(@"image");
        }
        default:
            return(NULL);
    }
}
int timeFillingTypeToEnum(NSString*type)
{
    
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"repeat"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches = [regex matchesInString:type
                                           options:0
                                             range:NSMakeRange(0, [type length])];
        if (matches.count>0) {
            return(0);
        }
    }
    return(-1);
}
NSString * enumToTimeFillingType(int typeNum)
{
    switch (typeNum) {
        case timeFillingModeType_Repeat:
        {
            return(@"repeat");
        }
        default:
            return(NULL);
    }
}
int blendTypeToEnum(NSString*type)
{
    {
        if (type) {
            
        } else {
            return(-1);
        }
    }
    
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"normal"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches = [regex matchesInString:type
                                           options:0
                                             range:NSMakeRange(0, [type length])];
        
        
        if (matches.count>0) {
            return(0);
        }
    }
    
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"msadd"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches = [regex matchesInString:type
                                           options:0
                                             range:NSMakeRange(0, [type length])];
        if (matches.count>0) {
            return(1);
        }
    }
    
    return(-1);
}
NSString * enumToBlendType(int typeNum)
{
    switch (typeNum) {
        case blendModeType_Normal:
        {
            return(@"normal");
        }
        default:
            return(NULL);
    }
}


////CDVideoOverlay素材初始化
void CDVideoOverlayObjectStateOneProcessingFlow(CDVideoOverlayObject * _Nullable voobj,BOOL SAVEHERE,BOOL SYNCSAVE)
{
    BOOL exist = [voobj.exist boolValue];
    if (exist) {
        voobj.absoluteURLstring = replaceAPPIDInABSURLString(voobj.absoluteURLstring,getCurrAPPIDInPath());
        float origLength = 0.0;
        ////因为image 必须用到 requiredLength
        ////所以需要有默认数值
        ////voobj.duration --->voobj.videoLocalRender.duration ---->1.0
        float requiredLength = 0.0;
        if (voobj.duration) {
            requiredLength = [voobj.duration floatValue];
        } else if (voobj.videoLocalRender) {
            if (voobj.videoLocalRender.duration) {
                requiredLength = [voobj.videoLocalRender.duration floatValue];
            } else {
                requiredLength = 1.0;
            }
        } else {
            ////如果是scene overlay 那么duration是必须填的，因为scene是由 多个video 组成的，
            ////总长度需要确定多个overlay后再加起来 才能获得
            requiredLength = 1.0;
        }
        ////handle types------image GIF video  3 types
        int  typeNum = overlayTypeToEnum(voobj.type);
        switch (typeNum) {
            case overlayType_Image:
            {
                
               NSMutableArray * sourceImageURLs = [[NSMutableArray alloc] init];
               NSURL * sourceURL = [NSURL URLWithString: voobj.absoluteURLstring];
               [sourceImageURLs addObject:sourceURL];
               NSString * sourcePath = [sourceURL path];
               ////获取相应文件夹下/VIDEO 名字与所关联的videoObject相关
               NSURL * writerOutputURL = getPostStateOneProcessingVideoOnlyURLFromOverlayPath(sourcePath,0);
               NSString * writerOutputPath  = [writerOutputURL path];
               [FileUitl deleteFile:writerOutputPath];
               NSMutableArray * durations = [[NSMutableArray alloc] init];
               CMTime du = CMTimeMakeWithSeconds(requiredLength, 600);
               [durations addObject:[NSValue valueWithCMTime:du]];
               origLength = origLength + requiredLength;
               imagesToVideoFIleFromSourceImageURLsUntilCompletion(sourceImageURLs, NULL, durations, writerOutputURL);
               [FileUitl deleteFile:sourcePath];
                voobj.absoluteURLstring = [writerOutputURL absoluteString];
                voobj.type = @"video";
                break;
            }
            case overlayType_GIF:
            {
                NSURL * sourceGIFURL;
                sourceGIFURL = [NSURL URLWithString:voobj.absoluteURLstring];
                origLength = getGIFDurationFromURL(sourceGIFURL);
                NSString * sourceGIFPath = [sourceGIFURL path];
                NSURL * writerOutputURL = getPostStateOneProcessingVideoOnlyURLFromOverlayPath(sourceGIFPath,0);
                NSString * writerOutputPath  = [writerOutputURL path];
                [FileUitl deleteFile:writerOutputPath];
                GIFToVideoFIleFromSourceGIFURLUntilCompletion(sourceGIFURL, NULL, NULL, writerOutputURL);
                [FileUitl deleteFile:sourceGIFPath];
                voobj.absoluteURLstring = [writerOutputURL absoluteString];
                voobj.type = @"video";
                break;
            }
            case overlayType_Video:
            {
                NSURL * sourceMovieURL;
                sourceMovieURL = [NSURL URLWithString:voobj.absoluteURLstring];
                NSString * sourceMoviePath = [sourceMovieURL path];
                NSURL * destAudioDirURL = getAudioOnlyDirURLFromMoviePath(sourceMoviePath);
                NSURL * destVideoDirURL = getVideoOnlyDirURLFromMoviePath(sourceMoviePath);
                NSMutableArray * destAudioURLs =  findAllCorrespondingAudioFileURLsOfMoviePath(sourceMoviePath);
                for (int i = 0; i < destAudioURLs.count; i++) {
                    [FileUitl deleteFile:[(NSURL *)destAudioURLs[i] path]];
                }
                NSMutableArray * destVideoURLs =  findAllCorrespondingVideoFileURLsOfMoviePath(sourceMoviePath);
                for (int i = 0; i < destVideoURLs.count; i++) {
                    [FileUitl deleteFile:[(NSURL *)destVideoURLs[i] path]];
                }
                splitMovieToFilesByTracksFromURL(sourceMovieURL, destAudioDirURL, destVideoDirURL, YES, NO);
                ////视频仅针对单轨视频，多轨的仅提取track 0
                NSURL * writerOutputURL = getPostStateOneProcessingVideoOnlyURLFromOverlayPath(sourceMoviePath,0);
                AVAsset * someAsset = [AVAsset assetWithURL:sourceMovieURL];
                origLength = getTotalLengthOfMovieFromAsset(someAsset, 0, nil);
                someAsset = NULL;
                voobj.absoluteURLstring = [writerOutputURL absoluteString];
                voobj.type = @"video";
                break;
            }
            default:
            {
                NSLog(@"only support Image/GIF/video,if null treated as video");
                NSURL * sourceMovieURL;
                sourceMovieURL = [NSURL URLWithString:voobj.absoluteURLstring];
                NSString * sourceMoviePath = [sourceMovieURL path];
                NSURL * destAudioDirURL = getAudioOnlyDirURLFromMoviePath(sourceMoviePath);
                NSURL * destVideoDirURL = getVideoOnlyDirURLFromMoviePath(sourceMoviePath);
                NSMutableArray * destAudioURLs =  findAllCorrespondingAudioFileURLsOfMoviePath(sourceMoviePath);
                for (int i = 0; i < destAudioURLs.count; i++) {
                    [FileUitl deleteFile:[(NSURL *)destAudioURLs[i] path]];
                }
                NSMutableArray * destVideoURLs =  findAllCorrespondingVideoFileURLsOfMoviePath(sourceMoviePath);
                for (int i = 0; i < destVideoURLs.count; i++) {
                    [FileUitl deleteFile:[(NSURL *)destVideoURLs[i] path]];
                }
                splitMovieToFilesByTracksFromURL(sourceMovieURL, destAudioDirURL, destVideoDirURL, YES, NO);
                ////视频仅针对单轨视频，多轨的仅提取track 0
                NSURL * writerOutputURL = getPostStateOneProcessingVideoOnlyURLFromOverlayPath(sourceMoviePath,0);
                AVAsset * someAsset = [AVAsset assetWithURL:sourceMovieURL];
                origLength = getTotalLengthOfMovieFromAsset(someAsset, 0, nil);
                someAsset = NULL;
                voobj.absoluteURLstring = [writerOutputURL absoluteString];
                voobj.type = @"video";
            }
        }
        //// trimming and filling
        if (fabsf(origLength - requiredLength) < 1.0/30 ) {
            ////
        } else {
            
            NSURL * sourceOverlayVideoURL;
            sourceOverlayVideoURL = [NSURL URLWithString:voobj.absoluteURLstring];
            NSString * sourceOverlayVideoPath = [sourceOverlayVideoURL path];
            NSString * writerOutputPath = [sourceOverlayVideoPath stringByAppendingString:@".tmp"];
            NSURL * writerOutputURL = [NSURL fileURLWithPath:writerOutputPath];
            [FileUitl deleteFile:writerOutputPath];
            if (origLength > requiredLength) {
                CMTime trimTo = CMTimeMakeWithSeconds(requiredLength, 600);
                int typeNum = timeTrimmingTypeToEnum(voobj.timeTrimingMode);
                switch (typeNum) {
                    case timeTrimmingModeType_Tail:
                    {
                        trimSingleTrackVideoToFileFromURL(sourceOverlayVideoURL,writerOutputURL , trimTo, 0, YES, NO);
                        break;

                    }
                    default:
                    {
                        NSLog(@"if null treated as tail mode");
                        trimSingleTrackVideoToFileFromURL(sourceOverlayVideoURL,writerOutputURL , trimTo, 0, YES, NO);
                        break;

                    }
                }
                
            } else {
                float times = (float)requiredLength / (float)origLength;
                int typeNum = timeFillingTypeToEnum(voobj.timeFillingMode);
                switch (typeNum) {
                    case timeFillingModeType_Repeat:
                    {
                        repeatSingleTrackVideoToFileFromURL(sourceOverlayVideoURL,writerOutputURL , times, 0, YES, NO);
                        break;
                    }
                    default:
                    {
                        NSLog(@"if null treated as repeat mode");
                        repeatSingleTrackVideoToFileFromURL(sourceOverlayVideoURL,writerOutputURL , times, 0, YES, NO);
                        break;

                    }
                }
            }
            [FileUitl deleteFile:sourceOverlayVideoPath];
            [[NSFileManager defaultManager] moveItemAtPath:writerOutputPath toPath:sourceOverlayVideoPath error:nil];
            voobj.absoluteURLstring = [sourceOverlayVideoURL absoluteString];
            voobj.type = @"video";
        }
        //// blend mode, normal: overlay 在上面,真正的视频在下面
        //// 此处只是记录mode 在合成的时候才真正处理
        typeNum = blendTypeToEnum(voobj.blendMode);
        switch (typeNum) {
            case blendModeType_Normal:
            {
                break;
            }
            case blendModeType_MSAdd:
            {
                break;
            }
            default:
            {
                NSLog(@"if null treated as normal blend mode");
                break;
            }
        }
        
        //// width height,指的是overlay视频本身的大小
        //// 最终效果是overlay 放在background上的
        NSURL * sourceOverlayVideoURL;
        sourceOverlayVideoURL = [NSURL URLWithString:voobj.absoluteURLstring];
        NSString * sourceOverlayVideoPath = [sourceOverlayVideoURL path];
        NSString * writerOutputPath = [sourceOverlayVideoPath stringByAppendingString:@".tmp"];
        NSURL * writerOutputURL = [NSURL fileURLWithPath:writerOutputPath];
        [FileUitl deleteFile:writerOutputPath];
        if ([voobj.width floatValue] * [voobj.height floatValue] < 64.0) {
            
        } else {
            CGSize overlaySize = CGSizeMake([voobj.width floatValue], [voobj.height floatValue]);
            resizeVideoFromSourceURL(sourceOverlayVideoURL, 0,writerOutputURL ,overlaySize , YES, NO);
            [FileUitl deleteFile:sourceOverlayVideoPath];
            [[NSFileManager defaultManager] moveItemAtPath:writerOutputPath toPath:sourceOverlayVideoPath error:nil];
        }
        float widthBG;
        float heightBG;
        if (voobj.scene) {
            widthBG = [voobj.scene.backgroundSizeX floatValue];
            heightBG = [voobj.scene.backgroundSizeY floatValue];
        } else if (voobj.videoLocalRender) {
            widthBG = [voobj.videoLocalRender.postRenderSizeX floatValue];
            heightBG = [voobj.videoLocalRender.postRenderSizeY floatValue];
        } else {
            widthBG = 1280.0;
            heightBG = 720.0;
        }
        NSMutableArray * movingPathCGpointXs  = voobj.movingPathCGpointXs;
        NSMutableArray * movingPathCGpointYs  = voobj.movingPathCGpointYs;
        NSMutableArray * movingSectionDurations = voobj.movingSectionDurations;
        NSMutableArray * pathPoints;
        NSMutableArray * animationTimes;
        if (movingPathCGpointXs && movingPathCGpointYs) {

        } else {
            [movingPathCGpointXs addObject:[NSNumber numberWithFloat:0.0]];
            [movingPathCGpointYs addObject:[NSNumber numberWithFloat:0.0]];
            movingSectionDurations= NULL;
        }
        pathPoints = reconstructMovingPath(movingPathCGpointXs, movingPathCGpointYs);
        if (movingSectionDurations) {
            animationTimes = movingSectionDurationsToAnimationTimes(movingSectionDurations, [voobj.duration floatValue]);
        } else {
            animationTimes = NULL;
        }
        ////注:这一步暂时不处理，因为目前这个功能还是用 AVFoundation实现的，黑色背景的视频与原视频合成AVF依赖opacity效果不理想
        ////所以这一步放到后面使用overlayVideoFilesToSingleTrackVideoFile处理,这里只保留参数
        ////{
        ////movingVideoOnBackGroundFromSourceURL(sourceOverlayVideoURL, 0, writerOutputURL, CGPointMake(0.0,0.0), CGSizeMake(widthBG, heightBG), pathPoints, animationTimes,NULL,YES,NO);
        ////}
        ////overlay pre handle ready
        voobj.movingSectionDurations = movingSectionDurations;
        voobj.movingPathCGpointXs = movingPathCGpointXs;
        voobj.movingPathCGpointYs = movingPathCGpointYs;
        if (SAVEHERE) {
            if (SYNCSAVE) {
                [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                    CDVideoOverlayObject * overlayObj = [voobj MR_inContext:localContext];
                    overlayObj.type = voobj.type;
                    overlayObj.absoluteURLstring = voobj.absoluteURLstring;
                    overlayObj.movingPathCGpointXs = voobj.movingPathCGpointXs;
                    overlayObj.movingPathCGpointYs = voobj.movingPathCGpointYs;
                    overlayObj.movingSectionDurations = voobj.movingSectionDurations;
                }];
            } else {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    CDVideoOverlayObject * overlayObj = [voobj MR_inContext:localContext];
                    overlayObj.type = voobj.type;
                    overlayObj.absoluteURLstring = voobj.absoluteURLstring;
                    overlayObj.movingPathCGpointXs = voobj.movingPathCGpointXs;
                    overlayObj.movingPathCGpointYs = voobj.movingPathCGpointYs;
                    overlayObj.movingSectionDurations = voobj.movingSectionDurations;
                }];
            }

        } else {
            
        }
        
        
    } else {
        NSLog(@"no overlay will be applied");
        return;
    }
  
}

#import "UVVideoManager.h"


void CDVideoLocalRenderObjectStateOneProcessingFlow(CDVideoLocalRenderObject * _Nullable vlrobj,BOOL SAVEHERE,BOOL SYNCSAVE)
{
    ////A----分离语音和视频
    NSURL * sourceMovieURL;
    NSURL * destAudioDirURL;
    NSURL * destVideoDirURL;
    switch (vlrobj.video.sourceType) {
        case(UVVideoSourceType_Record):
        {
           sourceMovieURL  =  [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origURLstring,getCurrAPPIDInPath())];
           destAudioDirURL =  [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origAudioWorkDirURLstring,getCurrAPPIDInPath())];
           destVideoDirURL =  [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origVideoWorkDirURLstring,getCurrAPPIDInPath())];
           break;
        }
        case(UVVideoSourceType_Album):
        {
            sourceMovieURL = [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origFromAlbumURLstring,getCurrAPPIDInPath())];
            destAudioDirURL =  [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origFromAlbumAudioWorkDirURLstring,getCurrAPPIDInPath())];
            destVideoDirURL =  [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origFromAlbumVideoWorkDirURLstring,getCurrAPPIDInPath())];
            
            break;
        }
        default:
        {
            sourceMovieURL = [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origFromAlbumURLstring,getCurrAPPIDInPath())];
            destAudioDirURL =  [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origFromAlbumAudioWorkDirURLstring,getCurrAPPIDInPath())];
            destVideoDirURL =  [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origFromAlbumVideoWorkDirURLstring,getCurrAPPIDInPath())];
            break;
        }
    }
    
    
    
    ////分离音频视频前 清理MOVIES/AUDIO/  和 MOVIES/VIDEO/ 下相应videoId的文件
    [FileUitl deleteSpecificFilesOfSubDir:vlrobj.video.videoId dirName:[destAudioDirURL path]];
    [FileUitl deleteSpecificFilesOfSubDir:vlrobj.video.videoId dirName:[destVideoDirURL path]];
    NSMutableDictionary * rslt = splitMovieToFilesByTracksFromURL(sourceMovieURL, destAudioDirURL, destVideoDirURL, YES, NO);
    NSMutableArray * destAudioURLs = [rslt valueForKey:@"audio"];
    NSMutableArray * destVideoURLs = [rslt valueForKey:@"video"];
    ////B---cutting, localRender的startTime 和 Duration 是从video信息获取的
    ////然后自动填充
    vlrobj.startTime = [NSNumber numberWithFloat:-1.0];
    vlrobj.duration = [NSNumber numberWithFloat:-1.0];
    if (vlrobj.video) {
        vlrobj.startTime = [NSNumber numberWithFloat:vlrobj.video.startTime];
        vlrobj.duration = [NSNumber numberWithFloat:(vlrobj.video.endTime - vlrobj.video.startTime)];
    } else {

    }
    AVAsset * someAsset = [AVAsset assetWithURL:sourceMovieURL];
    float origLength = getTotalLengthOfMovieFromAsset(someAsset, 0, nil);
    someAsset = NULL;
    BOOL EXECCUTTING;
    if (([vlrobj.startTime floatValue]<0) &&([vlrobj.duration floatValue]<0)) {
        vlrobj.startTime = [NSNumber numberWithFloat:0.0];
        vlrobj.duration = [NSNumber numberWithFloat:origLength];
        EXECCUTTING = NO;
    } else if([vlrobj.startTime floatValue]<0) {
        vlrobj.startTime = [NSNumber numberWithFloat:0.0];
        EXECCUTTING = YES;
    } else {
        EXECCUTTING = YES;
    }

    ////上一步操作的destAudioURLs 和 destVideoURLs 是本次操作的源
    ////savePostCutting
    NSMutableArray * sourceAudioURLs =[[NSMutableArray alloc] init];
    NSMutableArray * sourceVideoURLs =[[NSMutableArray alloc] init];
    CMTime from;
    CMTime to;
    CMTimeRange timeRange;
    ////为了后续逻辑简单 这里无论是否发生CUTTING,都会在
    ////MOVIES_POST_CUTTING/AUDIO/ 和MOVIES_POST_CUTTING/VIDEO/
    ////生成中间文件，不发生 CUTTING时只是copy
    vlrobj.savePostCutting = [NSNumber numberWithBool:YES];
    if (EXECCUTTING) {
        for (int i = 0; i<destAudioURLs.count; i++) {
            NSURL * audioSrcURL = destAudioURLs[i];
            NSString * audioSrcPath = [audioSrcURL path];
            NSURL * audioDstURL = getPostCuttingAudioOnlyURLFromAudioOnlyPath(audioSrcPath);
            NSString * audioDstPath = [audioDstURL path];
            [FileUitl deleteFile:audioDstPath];
            AVAsset * asset = [AVAsset assetWithURL:audioSrcURL];
            int timeScale = getTimeScaleFromAsset(asset, 0, @"audio");
            from = CMTimeMakeWithSeconds([vlrobj.startTime floatValue], timeScale);
            to = CMTimeMakeWithSeconds(([vlrobj.startTime floatValue] + [vlrobj.duration floatValue] ), timeScale);
            rangeSingleTrackAudioToFileFromURL(audioSrcURL, audioDstURL, from, to, 0, YES, NO);
            [sourceAudioURLs addObject:audioDstURL];
            
        }
        for (int i = 0; i<destVideoURLs.count; i++) {
            NSURL * videoSrcURL = destVideoURLs[i];
            NSString * videoSrcPath = [videoSrcURL path];
            NSURL * videoDstURL = getPostCuttingVideoOnlyURLFromVideoOnlyPath(videoSrcPath);
            NSString * videoDstPath = [videoDstURL path];
            [FileUitl deleteFile:videoDstPath];
            AVAsset * asset = [AVAsset assetWithURL:videoSrcURL];
            int timeScale = getTimeScaleFromAsset(asset, 0, @"video");
            from = CMTimeMakeWithSeconds([vlrobj.startTime floatValue], timeScale);
            to = CMTimeMakeWithSeconds(([vlrobj.startTime floatValue] + [vlrobj.duration floatValue] ), timeScale);
            rangeSingleTrackVideoToFileFromURL(videoSrcURL, videoDstURL, from, to, 0, YES, NO);
            [sourceVideoURLs addObject:videoDstURL];
            ////这里除了要处理图像还要更新postcutting thumbnail
            NSURL * thumbnailURL = [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origThumbnailURLstring, getCurrAPPIDInPath())];
            NSString * thumbnailPath = [thumbnailURL path];
            NSURL * postCuttingThumbnailURL = getPostCuttingThumbnailURLFromThumbnailPath(thumbnailPath,i);
            NSString * postCuttingThumbnailPath = [postCuttingThumbnailURL path];
            [FileUitl deleteFile:postCuttingThumbnailPath];
            getSingleImageFromVideoURLWithCMTUnitIntervalAndSaveToURL(videoDstURL, kCMTimeZero, postCuttingThumbnailURL);
            
        }
    } else {
        for (int i = 0; i<destAudioURLs.count; i++) {
            NSURL * audioSrcURL = destAudioURLs[i];
            AVAsset * asset = [AVAsset assetWithURL:audioSrcURL];
            int timeScale = getTimeScaleFromAsset(asset, 0, @"audio");
            from = CMTimeMakeWithSeconds([vlrobj.startTime floatValue], timeScale);
            to = CMTimeMakeWithSeconds(([vlrobj.startTime floatValue] + [vlrobj.duration floatValue] ), timeScale);
            
            NSString * audioSrcPath = [audioSrcURL path];
            NSURL * audioDstURL = getPostCuttingAudioOnlyURLFromAudioOnlyPath(audioSrcPath);
            NSString * audioDstPath = [audioDstURL path];
            [FileUitl deleteFile:audioDstPath];
            [[NSFileManager defaultManager] copyItemAtPath:audioSrcPath toPath:audioDstPath error:nil];
            [sourceAudioURLs addObject:audioDstURL];
            
            
        }
        for (int i = 0; i<destVideoURLs.count; i++) {
            NSURL * videoSrcURL = destVideoURLs[i];
            AVAsset * asset = [AVAsset assetWithURL:videoSrcURL];
            int timeScale = getTimeScaleFromAsset(asset, 0, @"video");
            from = CMTimeMakeWithSeconds([vlrobj.startTime floatValue], timeScale);
            to = CMTimeMakeWithSeconds(([vlrobj.startTime floatValue] + [vlrobj.duration floatValue] ), timeScale);
            
            NSString * videoSrcPath = [videoSrcURL path];
            NSURL * videoDstURL = getPostCuttingVideoOnlyURLFromVideoOnlyPath(videoSrcPath);
            NSString * videoDstPath = [videoDstURL path];
            [FileUitl deleteFile:videoDstPath];
            [[NSFileManager defaultManager] copyItemAtPath:videoSrcPath toPath:videoDstPath error:nil];
            [sourceVideoURLs addObject:videoDstURL];
            ////这里除了要处理图像还要更新postcutting thumbnail
            NSURL * thumbnailURL = [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origThumbnailURLstring, getCurrAPPIDInPath())];
            NSString * thumbnailPath = [thumbnailURL path];
            NSURL * postCuttingThumbnailURL = getPostCuttingThumbnailURLFromThumbnailPath(thumbnailPath,i);
            NSString * postCuttingThumbnailPath = [postCuttingThumbnailURL path];
            [FileUitl deleteFile:postCuttingThumbnailPath];
            [[NSFileManager defaultManager] copyItemAtPath:thumbnailPath toPath:postCuttingThumbnailPath error:nil];
        }
    }
    
    timeRange = CMTimeRangeMake(from, CMTimeSubtract(to, from));
    
    CMTimeShow(from);
    CMTimeShow(to);
    CMTimeRangeShow(timeRange);
    
    
    
    
    
    ////C----上一个阶段完成后sourceAudioURLs 和  sourceVideoURLs
    ////位于MOVIES_POST_CUTTING/AUDIO/  MOVIES_POST_CUTTING/VIDEO/
    ////开始crop
    ////workdir 使用postCutiingWorkDir
    ////从sourceVideoURLs
    if (vlrobj.cropSizeX &&
        vlrobj.cropSizeY &&
        vlrobj.cropPositionOnOriginalMaterialX &&
        vlrobj.cropPositionOnOriginalMaterialY) {
        ////crop 只针对video
        for (int i = 0; i<sourceVideoURLs.count; i++) {
            ////上一步之后video所在路径 /MOVIES_POST_CUTTING/VIDEO/下
            NSURL * videoURL = (NSURL*)sourceVideoURLs[i];
            NSString * videoPath = [videoURL path];
            ////中间文件路径 /MOVIES_POST_CUTTING/VIDEO/下 名字加个_tmp
            NSString * suffix = [videoPath pathExtension];
            NSString * tmpCropPath = [videoPath stringByDeletingPathExtension];
            tmpCropPath = [tmpCropPath stringByAppendingFormat:@"_tmp.%@",suffix];
            NSURL * tmpCropURL = [NSURL fileURLWithPath:tmpCropPath];
            [FileUitl deleteFile:tmpCropPath];
            float widthCropTo = [vlrobj.cropSizeX floatValue];
            float heightCropTo = [vlrobj.cropSizeY floatValue];
            float topLeftPointX = [vlrobj.cropPositionOnOriginalMaterialX floatValue];
            float topLeftPointY = [vlrobj.cropPositionOnOriginalMaterialY floatValue];
            cropAndRangeVideoFromSourceURL(videoURL, 0, timeRange, tmpCropURL, CGSizeMake(widthCropTo,heightCropTo), CGPointMake(topLeftPointX,topLeftPointY), YES, NO);
            ////完成crop后删除上一步的video,然后把新video move 到 上一步的video路径
            [FileUitl deleteFile:videoPath];
            [[NSFileManager defaultManager] moveItemAtPath:tmpCropPath toPath:videoPath error:nil];
            ////这里除了要处理图像还要更新thumbnail,因为新的thumbnail要和track对应
            ////所以无论之前是否savePostCutting,这里都要保存thumnail
            NSURL * thumbnailURL = [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origThumbnailURLstring, getCurrAPPIDInPath())];
            NSString * thumbnailPath = [thumbnailURL path];
            NSURL * postCropThumbnailURL;
            postCropThumbnailURL = getPostCuttingThumbnailURLFromThumbnailPath(thumbnailPath,i);
            NSString * postCropThumbnailPath = [postCropThumbnailURL path];
            [FileUitl deleteFile:postCropThumbnailPath];
            getSingleImageFromVideoURLWithCMTUnitIntervalAndSaveToURL(videoURL, kCMTimeZero, postCropThumbnailURL);
        }
    } else {
        ////不发生crop,此时无变化
    }
    
    ////D----filter
    ////上一个阶段完成后sourceAudioURLs 和  sourceVideoURLs
    ////依然位于MOVIES_POST_CUTTING/AUDIO/  MOVIES_POST_CUTTING/VIDEO/
    ////为了后续逻辑简单 这里无论是否发生CUTTING,都会在
    ////MOVIES_POST_FILTERING/AUDIO/ 和MOVIES_POST_FILTERING/VIDEO/
    ////生成中间文件，不发生FILTERING时只是copy
    for (int i = 0; i<sourceAudioURLs.count; i++) {
        ////暂时不支持音频滤镜功能，所以音频只是简单copy
        NSURL * srcAudioURL = (NSURL*)sourceAudioURLs[i];
        NSString * srcAudioPath = [srcAudioURL path];
        NSURL * origAudioURL = destAudioURLs[i];
        NSString * origAudioPath = [origAudioURL path];
        NSURL * postFilterAudioURL = getPostFilteringAudioOnlyURLFromAudioOnlyPath(origAudioPath);
        NSString * postFilterAudioPath = [postFilterAudioURL path];
        [FileUitl deleteFile:postFilterAudioPath];
        [[NSFileManager defaultManager] copyItemAtPath:srcAudioPath toPath:postFilterAudioPath error:nil];
        [sourceAudioURLs replaceObjectAtIndex:i withObject:postFilterAudioURL];
    }
    for (int i = 0; i<sourceVideoURLs.count; i++) {
        NSURL * srcVideoURL = (NSURL*)sourceVideoURLs[i];
        NSString * srcVideoPath = [srcVideoURL path];
        NSURL * origVideoURL = destVideoURLs[i];
        NSString * origVideoPath = [origVideoURL path];
        NSURL * postFilterVideoURL = getPostFilteringVideoOnlyURLFromVideoOnlyPath(origVideoPath);
        NSString * postFilterVideoPath = [postFilterVideoURL path];
        [FileUitl deleteFile:postFilterVideoPath];
        if (vlrobj.filter!=NULL) {
            applyGPUImageFilterToVideoAndWait(srcVideoURL, postFilterVideoURL, vlrobj.filter, NULL);
        } else {
            [[NSFileManager defaultManager] copyItemAtPath:srcVideoPath toPath:postFilterVideoPath error:nil];
        }
        [sourceVideoURLs replaceObjectAtIndex:i withObject:postFilterVideoURL];
        
        ////这里除了要处理图像还要更新thumbnail,因为新的thumbnail要和track对应
        ////所以无论之前是否savePostCutting,这里都要保存thumnail
        NSURL * thumbnailURL = [NSURL URLWithString:replaceAPPIDInABSURLString(vlrobj.origThumbnailURLstring, getCurrAPPIDInPath())];
        NSString * thumbnailPath = [thumbnailURL path];
        NSURL * postFilteringThumbnailURL;
        postFilteringThumbnailURL = getPostFilteringThumbnailURLFromThumbnailPath(thumbnailPath, i);
        NSString * postFilteringThumbnailPath = [postFilteringThumbnailURL path];
        [FileUitl deleteFile:postFilteringThumbnailPath];
        getSingleImageFromVideoURLWithCMTUnitIntervalAndSaveToURL(postFilterVideoURL, kCMTimeZero, postFilteringThumbnailURL);
        
    }
    
    
    ////resize,到标准大小，这样接下来和videoOverlay合成的时候，就不需要考虑scale的事情
    for (int i = 0; i<sourceVideoURLs.count; i++) {
        NSURL * srcVideoURL = (NSURL*)sourceVideoURLs[i];
        NSString * srcVideoPath = [srcVideoURL path];
        ////中间文件路径 /MOVIES_POST_FILTERING/VIDEO/下 名字加个_tmp
        NSString * suffix = [srcVideoPath pathExtension];
        NSString * tmpScalePath = [srcVideoPath stringByDeletingPathExtension];
        tmpScalePath = [tmpScalePath stringByAppendingFormat:@"_tmp.%@",suffix];
        NSURL * tmpScaleURL = [NSURL fileURLWithPath:tmpScalePath];
        [FileUitl deleteFile:tmpScalePath];
        if (vlrobj.postRenderSizeX && vlrobj.postRenderSizeY) {
            
        } else {
            vlrobj.postRenderSizeX = [NSNumber numberWithFloat:1280.0];
            vlrobj.postRenderSizeY = [NSNumber numberWithFloat:720.0];
        }
        resizeVideoFromSourceURL(srcVideoURL, i, tmpScaleURL, CGSizeMake([vlrobj.postRenderSizeX floatValue],[vlrobj.postRenderSizeY floatValue]), YES, NO);
        [FileUitl deleteFile:srcVideoPath];
        [[NSFileManager defaultManager] moveItemAtPath:tmpScalePath toPath:srcVideoPath error:nil];
    }
    
    
    ////--------dli---
    ////然后处理自己的overlay
    if (vlrobj.videoOverlay) {
        CDVideoOverlayObjectStateOneProcessingFlow(vlrobj.videoOverlay, YES, YES);
        ////合成
        ////把自己的video和overlay合成
        for (int i = 0; i<sourceVideoURLs.count; i++) {
            NSURL * srcVideoURL = (NSURL*)sourceVideoURLs[i];
            NSString * srcVideoPath = [srcVideoURL path];
            ////中间文件路径 /MOVIES_POST_FILTERING/VIDEO/下 名字加个_tmp
            NSString * suffix = [srcVideoPath pathExtension];
            NSString * tmpMergePath = [srcVideoPath stringByDeletingPathExtension];
            tmpMergePath = [tmpMergePath stringByAppendingFormat:@"_tmp.%@",suffix];
            NSURL * tmpMergeURL = [NSURL fileURLWithPath:tmpMergePath];
            [FileUitl deleteFile:tmpMergePath];
            ////overlay合成
            NSMutableArray * movingPathCGpointXs  = vlrobj.videoOverlay.movingPathCGpointXs;
            NSMutableArray * movingPathCGpointYs  = vlrobj.videoOverlay.movingPathCGpointYs;
            NSMutableArray * movingSectionDurations = vlrobj.videoOverlay.movingSectionDurations;
            NSMutableArray * pathPoints;
            if (movingPathCGpointXs && movingPathCGpointYs) {
                
            } else {
                [movingPathCGpointXs addObject:[NSNumber numberWithFloat:0.0]];
                [movingPathCGpointYs addObject:[NSNumber numberWithFloat:0.0]];
                movingSectionDurations= NULL;
            }
            pathPoints = reconstructMovingPath(movingPathCGpointXs, movingPathCGpointYs);
            ////这里需要把带速度的轨迹点分段集合 重新构造成一组匀速的点，因为overlayVideoFilesToSingleTrackVideoFile
            ////不支持带速度，想反应速度只能分割
            ////例如 4.0====2sec======6.0  需要在中间插入一个点变成 4.0==1sec==5.0 5.0==1sec==6.0
            NSMutableArray * newPathPoints;
            newPathPoints = toAverageSpeedMovingPathPoints(pathPoints, movingSectionDurations);
            NSMutableArray * mergeVideoURLs = [[NSMutableArray alloc] init];
            ////注:这一步，因为目前这个功能还是用 AVFoundation实现的，黑色背景的视频与原视频合成AVF依赖opacity效果不理想
            ////所以这一步使用overlayVideoFilesToSingleTrackVideoFile处理
            ////
           
            
            int typeNum = blendTypeToEnum(vlrobj.videoOverlay.blendMode);
            
            
            
            
            ////当前只支持normal,也就是overlay在video上面
            switch (typeNum) {
                case blendModeType_Normal:
                {
                    [mergeVideoURLs addObject:[NSURL URLWithString: vlrobj.videoOverlay.absoluteURLstring]];
                    [mergeVideoURLs addObject:srcVideoURL];
                    break;
                }
                case blendModeType_MSAdd:
                {
                    [mergeVideoURLs addObject:[NSURL URLWithString: vlrobj.videoOverlay.absoluteURLstring]];
                    [mergeVideoURLs addObject:srcVideoURL];
                    break;
                }
                default:
                {
                    [mergeVideoURLs addObject:[NSURL URLWithString: vlrobj.videoOverlay.absoluteURLstring]];
                    [mergeVideoURLs addObject:srcVideoURL];
                    break;
                }
            }
            NSMutableArray * atTimes = [[NSMutableArray alloc] init];
            [atTimes addObject:vlrobj.videoOverlay.startTime];
            [atTimes addObject:[NSNumber numberWithFloat:0.0]];
            
            
            NSMutableArray * pathPointsArray = [[NSMutableArray alloc] init];
            [pathPointsArray addObject:newPathPoints];
            [pathPointsArray addObject:[NSNull null]];
            
            
            switch (typeNum) {
                case blendModeType_Normal:
                {
                    overlayVideoFilesToSingleTrackVideoFile(mergeVideoURLs,pathPointsArray,atTimes, tmpMergeURL, YES, NO);
                    break;
                }
                case blendModeType_MSAdd:
                {
                    overlayVideoFilesWithMSAddModeSYNC(srcVideoURL, [NSURL URLWithString: vlrobj.videoOverlay.absoluteURLstring], tmpMergeURL, [vlrobj.postRenderSizeX floatValue], [vlrobj.postRenderSizeY floatValue], 1280000);
                    break;
                }
                default:
                {
                    overlayVideoFilesToSingleTrackVideoFile(mergeVideoURLs,pathPointsArray,atTimes, tmpMergeURL, YES, NO);
                    break;
                }
            }

            [FileUitl deleteFile:srcVideoPath];
            [[NSFileManager defaultManager] moveItemAtPath:tmpMergePath toPath:srcVideoPath error:nil];
        }
        
    } else {
        
    }
    ////最终合成
    ////所有处理过的音轨,视轨，合成一个movie
    ////把自己的videos audios 一起合成movie
    ////其实合成有很多种情况,首先多video轨道 因为大多播放器不支持暂时不考虑
    ////多音频在这里先合成了一个音轨
    ////也就是说目前只保留第一个视频轨道(通常播放器也只能播放第一个)
    ////其次无论原文件有多少条音轨，最后都合并成一条,下面规则::
    ////
    //// <video only keep one>
    //// <audio all in one>
    ////
    ////{
    ////----把多个音频文件合成一个音频文件的多条track
    ////void combineAudioFilesToMultiTracksAudioFile(NSMutableArray*sourceAudioURLs,NSURL * destAudioURL, BOOL SYNC,BOOL SAVETOALBUM);
    ////----把多个视频文件removePT合成一个视频文件的多条track,apple  not support write multiTracks to a file
    ////----to implement this  you must  use trackGroup  per track/per trackgroup
    ////----AVAssetTrackGroup是一组track，同时只能播放其中一条track，但是不同的AVAssetTrackGroup中的track可以同时播放
    ////void combineVideoFilesToMultiTracksVideoFile(NSMutableArray*sourceVideoURLs,NSURL * destVideoURL, BOOL SYNC,BOOL SAVETOALBUM);
    //// 上面这两个功能步在这里使用，避免繁杂的逻辑
    ////}
    NSString * finalSingleMoviePath = getPostFilteringMovieFilePath(vlrobj.video.videoId, vlrobj.video.makerId, nil, nil);
    NSURL * finalSingleMovieURL = [NSURL fileURLWithPath:finalSingleMoviePath];
    [FileUitl deleteFile:finalSingleMoviePath];
    combineMultiSingleTrackAudioFilesAndMultiSingleTrackVideoFilesToMovieFile(sourceAudioURLs, sourceVideoURLs,finalSingleMovieURL, YES, NO);
    
}


void CDTaskObjectStateOneProcessingFlow(CDTaskObject * _Nullable tobj,BOOL SAVEHERE,BOOL SYNCSAVE)
{
    ////预处理:,因为每个videoObj已经处理过音频视频并合成过了
    ////第一步要把文件从MOVIES_POST_FILTERING copy到SCENE_POST_TRANSITIONS下，为了统一流程
    ////添加片头
    CDSceneObject * sobj = tobj.scene;
    NSMutableArray * srcMovieURLs = [[NSMutableArray alloc] init];
    [srcMovieURLs addObject:[NSURL URLWithString:replaceAPPIDInABSURLString(sobj.titles.titlesURLstring,getCurrAPPIDInPath())]];
    ////添加materials
    for (int i = 0; i<tobj.videos.count; i++) {
        CDVideoObject * vobj = tobj.videos[i];
        NSURL * postFilterMovieURL = [NSURL URLWithString:replaceAPPIDInABSURLString(vobj.videoLocalRender.postFilteringURLstring,getCurrAPPIDInPath())];
        NSString * postTransMoviePath = getScenePostTransisionsMovieFilePath(vobj.videoId, vobj.makerId, nil, nil);
        NSURL * postTransMovieURL = [NSURL fileURLWithPath:postTransMoviePath];
        NSError * error;
        [[NSFileManager defaultManager] copyItemAtURL:postFilterMovieURL toURL:postTransMovieURL error:&error];
        [srcMovieURLs addObject:postTransMovieURL];
    }
    ////添加片尾
    [srcMovieURLs addObject:[NSURL URLWithString:replaceAPPIDInABSURLString(sobj.tail.tailURLstring,getCurrAPPIDInPath())]];
    
    
    
    ////分解为声音和视频
    ////第一步中的srcMovie 因为在videoLocalRender postFiltering 过程中被处理过了 ，所以都是只包含一个声轨 一个视频轨的
    ////没有multiTracks 的
    ////对于没有声轨 或者没有视轨的 在这一步要添加空轨
    NSMutableArray * srcAudioURLs = [[NSMutableArray alloc] init];
    NSMutableArray * srcVideoURLs = [[NSMutableArray alloc] init];
    NSMutableArray * destAudioURLs = [[NSMutableArray alloc] init];
    NSMutableArray * destVideoURLs = [[NSMutableArray alloc] init];
    ////分离片头
    {
        NSURL * sourceMovieURL;
        NSURL * destAudioDirURL;
        NSURL * destVideoDirURL;
        CDVideoObject * vobj = tobj.videos[0];
        sourceMovieURL = (NSURL*)srcMovieURLs[0];
        
        destAudioDirURL = [NSURL fileURLWithPath:getSceneTitlesAudioOnlyFileDir(vobj.makerId, nil)];
        destVideoDirURL = [NSURL fileURLWithPath:getSceneTitlesVideoOnlyFileDir(vobj.makerId, nil)];
        
        [FileUitl deleteSpecificFilesOfSubDir:@"scene-titles" dirName:[destAudioDirURL path]];
        [FileUitl deleteSpecificFilesOfSubDir:@"scene-titles" dirName:[destVideoDirURL path]];
        NSMutableDictionary * rslt = splitMovieToFilesByTracksFromURL(sourceMovieURL, destAudioDirURL, destVideoDirURL, YES, NO);
        destAudioURLs = [rslt valueForKey:@"audio"];
        destVideoURLs = [rslt valueForKey:@"video"];
        
        ////添加空轨
        if (destAudioURLs) {

            
        } else {
            for (int j = 0; j<destVideoURLs.count; j++) {
                AVAsset * asset = [AVAsset assetWithURL:destVideoURLs[j]];
                AVAssetTrack * vt = asset.tracks[0];
                NSURL * destAudioURL =[NSURL fileURLWithPath: getSceneTitlesAudioOnlyFilePath(j, vobj.videoId, vobj.makerId, nil, nil)];
                creatEmptyAudioFileViaCMTimeRange(vt.timeRange, destAudioURL, YES, NO);
                [destAudioURLs addObject:destAudioURL];
            }
        }
        
        
        if (destVideoURLs) {
            
        } else {
            for (int j = 0; j<destAudioURLs.count; j++) {
                AVAsset * asset = [AVAsset assetWithURL:destAudioURLs[j]];
                AVAssetTrack * at = asset.tracks[0];
                NSURL * destVideoURL =[NSURL fileURLWithPath: getSceneTitlesVideoOnlyFilePath(j, vobj.videoId, vobj.makerId, nil, nil)];
                creatEmptyAudioFileViaCMTimeRange(at.timeRange, destVideoURL, YES, NO);
                [destVideoURLs addObject:destVideoURL];
            }
        }
        ////添加空轨
        
        for (int j = 0; j<destAudioURLs.count; j++) {
            [srcAudioURLs addObject:destAudioURLs[j]];
        }
        for (int j = 0; j<destVideoURLs.count; j++) {
            [srcVideoURLs addObject:destVideoURLs[j]];
        }
        
    }
    
    
    for (int i = 1; i<srcMovieURLs.count -1; i++) {
        NSURL * sourceMovieURL;
        NSURL * destAudioDirURL;
        NSURL * destVideoDirURL;
        CDVideoObject * vobj = tobj.videos[i-1];
        sourceMovieURL = (NSURL*)srcMovieURLs[i];
        destAudioDirURL = [NSURL fileURLWithPath:getScenePostTransisionsAudioFileDir(vobj.makerId, nil)];
        destVideoDirURL = [NSURL fileURLWithPath:getScenePostTransisionsVideoFileDir(vobj.makerId, nil)];
        
        
        [FileUitl deleteSpecificFilesOfSubDir:vobj.videoId dirName:[destAudioDirURL path]];
        [FileUitl deleteSpecificFilesOfSubDir:vobj.videoId dirName:[destVideoDirURL path]];
        
        
        NSMutableDictionary * rslt = splitMovieToFilesByTracksFromURL(sourceMovieURL, destAudioDirURL, destVideoDirURL, YES, NO);
        destAudioURLs = [rslt valueForKey:@"audio"];
        destVideoURLs = [rslt valueForKey:@"video"];
        
        
        
        ////添加空轨
        if (destAudioURLs) {
            
            
        } else {
            for (int j = 0; j<destVideoURLs.count; j++) {
                AVAsset * asset = [AVAsset assetWithURL:destVideoURLs[j]];
                AVAssetTrack * vt = asset.tracks[0];
                NSURL * destAudioURL =[NSURL fileURLWithPath: getSceneTitlesAudioOnlyFilePath(j, vobj.videoId, vobj.makerId, nil, nil)];
                creatEmptyAudioFileViaCMTimeRange(vt.timeRange, destAudioURL, YES, NO);
                [destAudioURLs addObject:destAudioURL];
            }
        }
        
        
        if (destVideoURLs) {
            
        } else {
            for (int j = 0; j<destAudioURLs.count; j++) {
                AVAsset * asset = [AVAsset assetWithURL:destAudioURLs[j]];
                AVAssetTrack * at = asset.tracks[0];
                NSURL * destVideoURL =[NSURL fileURLWithPath: getSceneTitlesVideoOnlyFilePath(j, vobj.videoId, vobj.makerId, nil, nil)];
                creatEmptyAudioFileViaCMTimeRange(at.timeRange, destVideoURL, YES, NO);
                [destVideoURLs addObject:destVideoURL];
            }
        }
        ////添加空轨
        
        
        for (int j = 0; j<destAudioURLs.count; j++) {
            [srcAudioURLs addObject:destAudioURLs[j]];
        }
        for (int j = 0; j<destVideoURLs.count; j++) {
            [srcVideoURLs addObject:destVideoURLs[j]];
        }
        
    }
    
    
    
    
    ////分离片尾
    
    {
        NSURL * sourceMovieURL;
        NSURL * destAudioDirURL;
        NSURL * destVideoDirURL;
        CDVideoObject * vobj = tobj.videos[0];
        sourceMovieURL = (NSURL*)srcMovieURLs[srcMovieURLs.count -1];
        destAudioDirURL = [NSURL fileURLWithPath:getSceneTailAudioOnlyFileDir(vobj.makerId, nil)];
        destVideoDirURL = [NSURL fileURLWithPath:getSceneTailVideoOnlyFileDir(vobj.makerId, nil)];
        
        [FileUitl deleteSpecificFilesOfSubDir:@"scene-tail" dirName:[destAudioDirURL path]];
        [FileUitl deleteSpecificFilesOfSubDir:@"scene-tail" dirName:[destVideoDirURL path]];
        NSMutableDictionary * rslt = splitMovieToFilesByTracksFromURL(sourceMovieURL, destAudioDirURL, destVideoDirURL, YES, NO);
        destAudioURLs = [rslt valueForKey:@"audio"];
        destVideoURLs = [rslt valueForKey:@"video"];
        
        
        ////添加空轨
        if (destAudioURLs) {
            
            
        } else {
            for (int j = 0; j<destVideoURLs.count; j++) {
                AVAsset * asset = [AVAsset assetWithURL:destVideoURLs[j]];
                AVAssetTrack * vt = asset.tracks[0];
                NSURL * destAudioURL =[NSURL fileURLWithPath: getSceneTitlesAudioOnlyFilePath(j, vobj.videoId, vobj.makerId, nil, nil)];
                creatEmptyAudioFileViaCMTimeRange(vt.timeRange, destAudioURL, YES, NO);
                [destAudioURLs addObject:destAudioURL];
            }
        }
        
        
        if (destVideoURLs) {
            
        } else {
            for (int j = 0; j<destAudioURLs.count; j++) {
                AVAsset * asset = [AVAsset assetWithURL:destAudioURLs[j]];
                AVAssetTrack * at = asset.tracks[0];
                NSURL * destVideoURL =[NSURL fileURLWithPath: getSceneTitlesVideoOnlyFilePath(j, vobj.videoId, vobj.makerId, nil, nil)];
                creatEmptyAudioFileViaCMTimeRange(at.timeRange, destVideoURL, YES, NO);
                [destVideoURLs addObject:destVideoURL];
            }
        }
        ////添加空轨
        
        
        
        for (int j = 0; j<destAudioURLs.count; j++) {
            [srcAudioURLs addObject:destAudioURLs[j]];
        }
        for (int j = 0; j<destVideoURLs.count; j++) {
            [srcVideoURLs addObject:destVideoURLs[j]];
        }
    }

    
    ////----处理transitions 这一步比较复杂transitions的声音和视频都要处理，而且必须同步处理
    
    
    
    
    
    
    
}




////

////----GPUImage
#import "GPUImage.h"
GPUImageFilter * installGPUImageFilter(NSString * filterName,NSMutableDictionary * parameters)
{
    if ([filterName isEqualToString:@"Bilateral"]) {
        GPUImageBilateralFilter * bilateral = [[GPUImageBilateralFilter alloc] init];
        NSNumber  * TSM = [parameters valueForKey:@"texelSpacingMultiplier"];
        NSNumber  * DNF = [parameters valueForKey:@"distanceNormalizationFactor"];
        CGFloat texelSpacingMultiplier;
        CGFloat distanceNormalizationFactor;
        if (TSM == NULL && DNF == NULL) {
            texelSpacingMultiplier =  8.8;
            distanceNormalizationFactor = 6.0;
        } else {
            texelSpacingMultiplier = [TSM floatValue];
            distanceNormalizationFactor = [DNF floatValue];
        }
        bilateral.texelSpacingMultiplier = texelSpacingMultiplier;
        bilateral.distanceNormalizationFactor = distanceNormalizationFactor;
        return(bilateral);
    }
    else if ([filterName isEqualToString:@""]) {
        GPUImageFilter * defaultFilter = [[GPUImageFilter alloc] init];
        return(defaultFilter);
    } else {
        GPUImageFilter * defaultFilter = [[GPUImageFilter alloc] init];
        return(defaultFilter);
    }
        
}

////----
////prores 4444  手机端 Video tool box 不支持prores 4444

////----

void applySingleInputGPUImageFilterAndWait(AVAsset * asset,AVAssetTrack * vt,GPUImageFilter * filter,NSURL * destVideoURL)
{
    ////movie
    GPUImageMovie * movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    movieFile.runBenchmark = NO;
    movieFile.playAtActualSpeed = NO;
    [movieFile addTarget:filter];
    GPUImageMovieWriter * movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:destVideoURL size:vt.naturalSize];
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count == 0) {
    } else {
        movieWriter.hasAudioTrack = YES;
        movieWriter.shouldPassthroughAudio = YES;
        movieWriter.shouldInvalidateAudioSampleWhenDone = YES;
        movieFile.audioEncodingTarget = movieWriter;
    }
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    [movieWriter startRecording];
    [filter addTarget:movieWriter];
    [movieFile startProcessing];
    
    
    __block dispatch_semaphore_t semaCanReturn;
    semaCanReturn = dispatch_semaphore_create(0);
    [movieWriter setCompletionBlock:^{
        dispatch_semaphore_signal(semaCanReturn);
    }];
    
    while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    [filter removeTarget:movieWriter];
    [movieWriter finishRecording];
    [movieFile removeTarget:filter];
    movieFile = nil;
    filter = nil;
    movieWriter = nil;
}
void applyGPUImageFilterToVideoAndWait(NSURL * srcVideoURL,NSURL * destVideoURL, NSString * filterName,NSMutableDictionary * parameters)
{
    if ([filterName isEqualToString:@"Bilateral"]) {
        GPUImageBilateralFilter * bilateral = [[GPUImageBilateralFilter alloc] init];
        NSNumber  * TSM = [parameters valueForKey:@"texelSpacingMultiplier"];
        NSNumber  * DNF = [parameters valueForKey:@"distanceNormalizationFactor"];
        CGFloat texelSpacingMultiplier;
        CGFloat distanceNormalizationFactor;
        if (TSM == NULL && DNF == NULL) {
            texelSpacingMultiplier =  8.8;
            distanceNormalizationFactor = 6.0;
        } else {
            texelSpacingMultiplier = [TSM floatValue];
            distanceNormalizationFactor = [DNF floatValue];
        }
        bilateral.texelSpacingMultiplier = texelSpacingMultiplier;
        bilateral.distanceNormalizationFactor = distanceNormalizationFactor;
        ////
        AVAsset * asset = [AVAsset assetWithURL:srcVideoURL];
        AVAssetTrack * vt = (AVAssetTrack *)asset.tracks[0];
        ////movie
        applySingleInputGPUImageFilterAndWait(asset, vt, bilateral, destVideoURL);
    } else if ([filterName isEqualToString:@"Exposure"]) {
        ////textureColor.rgb * pow(2.0, exposure)
        GPUImageExposureFilter * exposure = [[GPUImageExposureFilter alloc] init];
        NSNumber  * EXPO = [parameters valueForKey:@"exposure"];
        CGFloat expo;
        if (EXPO == NULL) {
            expo = 0.0;
        } else {
            expo = [EXPO floatValue];
        }
        exposure.exposure = expo;
        ////
        AVAsset * asset = [AVAsset assetWithURL:srcVideoURL];
        AVAssetTrack * vt = (AVAssetTrack *)asset.tracks[0];
        ////movie
        applySingleInputGPUImageFilterAndWait(asset, vt, exposure, destVideoURL);
    }  else if ([filterName isEqualToString:@""]) {
        [[NSFileManager defaultManager] copyItemAtPath:[srcVideoURL path] toPath:[destVideoURL path] error:nil];
    } else {
        [[NSFileManager defaultManager] copyItemAtPath:[srcVideoURL path] toPath:[destVideoURL path] error:nil];
    }
}


