//
//  CDSceneObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDSceneObject.h"
#import "CDAudioSceneMusicObject.h"
#import "CDTaskObject.h"
#import "CDVideoLowerThirdObject.h"
#import "CDVideoOverlayObject.h"
#import "CDVideoTailObject.h"
#import "CDVideoTextOverBackGroundObject.h"
#import "CDVideoTitlesObject.h"

@implementation CDSceneObject

// Insert code here to add functionality to your managed object subclass

-(void)removeSelfWithAllRelationshipsIfLonely
{
    if ((self.temporary == [NSNumber numberWithBool:YES])&&(([self.parentHashID longLongValue]==0)||(self.parentHashID==NULL))) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            if (self.overlayPostCompositionFilter) {
                [self.overlayPostCompositionFilter MR_deleteEntityInContext:localContext];
            }
            if (self.lowerThirdPostOverlay) {
                [self.lowerThirdPostOverlay MR_deleteEntityInContext:localContext];
            }
            if (self.textOverBG) {
                [self.textOverBG MR_deleteEntityInContext:localContext];
            }
            if (self.musicPostBGIntergration) {
                [self.musicPostBGIntergration MR_deleteEntityInContext:localContext];
            }
            if (self.titles) {
                [self.titles MR_deleteEntityInContext:localContext];
            }
            if (self.tail) {
                [self.tail MR_deleteEntityInContext:localContext];
            }
            [self MR_deleteEntityInContext:localContext];
            
            
        }];
        
    }
}


- (void)forceRemoveIfNoParent
{
    if (([self.parentHashID longLongValue]==0)) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            if (self.overlayPostCompositionFilter) {
                [self.overlayPostCompositionFilter MR_deleteEntityInContext:localContext];
            }
            if (self.lowerThirdPostOverlay) {
                [self.lowerThirdPostOverlay MR_deleteEntityInContext:localContext];
            }
            if (self.textOverBG) {
                [self.textOverBG MR_deleteEntityInContext:localContext];
            }
            if (self.musicPostBGIntergration) {
                [self.musicPostBGIntergration MR_deleteEntityInContext:localContext];
            }
            if (self.titles) {
                [self.titles MR_deleteEntityInContext:localContext];
            }
            if (self.tail) {
                [self.tail MR_deleteEntityInContext:localContext];
            }
            [self MR_deleteEntityInContext:localContext];
            
        }];
    } else {
        
    }
    
}

- (void)forceRemoveIgnoreParent
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        if (self.overlayPostCompositionFilter) {
            [self.overlayPostCompositionFilter MR_deleteEntityInContext:localContext];
        }
        if (self.lowerThirdPostOverlay) {
            [self.lowerThirdPostOverlay MR_deleteEntityInContext:localContext];
        }
        if (self.textOverBG) {
            [self.textOverBG MR_deleteEntityInContext:localContext];
        }
        if (self.musicPostBGIntergration) {
            [self.musicPostBGIntergration MR_deleteEntityInContext:localContext];
        }
        if (self.titles) {
            [self.titles MR_deleteEntityInContext:localContext];
        }
        if (self.tail) {
            [self.tail MR_deleteEntityInContext:localContext];
        }
        [self MR_deleteEntityInContext:localContext];
        
    }];
}




@end


void deleteAllTemporaryCDSceneObjects()
{
    
    
    NSArray * tempCDSceneObjects = [CDSceneObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDSceneObjects.count; i++) {
        CDSceneObject * obj = (CDSceneObject *)tempCDSceneObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
            
        }];
    }
}



void deleteAllNonTempCDSceneObjects()
{
    
    NSArray * tempCDSceneObjects = [CDSceneObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDSceneObjects.count; i++) {
        CDSceneObject * obj = (CDSceneObject *)tempCDSceneObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
            
        }];
    }
    
}


void deleteAllCDSceneObjects(BOOL SYNC)
{
    NSArray * tempCDSceneObjects = [CDSceneObject MR_findAll];
    for (int i = 0 ; i<tempCDSceneObjects.count; i++) {
        CDSceneObject * obj = (CDSceneObject *)tempCDSceneObjects[i];
        if (SYNC) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                [obj MR_deleteEntityInContext:localContext];
            }];
        } else {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                [obj MR_deleteEntityInContext:localContext];
            }];
        }

    }
}







void CDSceneObjectPrint(CDSceneObject * _Nullable sobj)
{
    NSLog(@"anchorOnSelfXpostLowerThird:%@",sobj.anchorOnSelfXpostLowerThird);
    NSLog(@"anchorOnSelfYpostLowerThird:%@",sobj.anchorOnSelfYpostLowerThird);
    NSLog(@"averageBitRateForCompressing:%@",sobj.averageBitRateForCompressing);
    NSLog(@"backgroundSizeX:%@",sobj.backgroundSizeX);
    NSLog(@"backgroundSizeY:%@",sobj.backgroundSizeY);
    NSLog(@"bgImageURLstring:%@",sobj.bgImageURLstring);
    NSLog(@"categoryId:%@",sobj.categoryId);
    NSLog(@"compositionMode:%@",sobj.compositionMode);
    NSLog(@"coverImgUrl:%@",sobj.coverImgUrl);
    NSLog(@"creatorId:%@",sobj.creatorId);
    NSLog(@"demoVideoUrl:%@",sobj.demoVideoUrl);
    NSLog(@"descs:%@",sobj.descs);
    NSLog(@"editMode:%@",sobj.editMode);
    NSLog(@"expectedTotalDuration:%@",sobj.expectedTotalDuration);
    NSLog(@"filterPostCompositionDuration:%@",sobj.filterPostCompositionDuration);
    NSLog(@"filterPostCompositionExist:%@",sobj.filterPostCompositionExist);
    NSLog(@"filterPostCompositionName:%@",sobj.filterPostCompositionName);
    NSLog(@"filterPostCompositionStartTime:%@",sobj.filterPostCompositionStartTime);
    NSLog(@"finalOutputCGsizeX:%@",sobj.finalOutputCGsizeX);
    NSLog(@"finalOutputCGsizeY:%@",sobj.finalOutputCGsizeY);
    NSLog(@"geomTransformPostLowerThirdExist:%@",sobj.geomTransformPostLowerThirdExist);
    NSLog(@"interleaveInterval:%@",sobj.interleaveInterval);
    NSLog(@"interleaveMode:%@",sobj.interleaveMode);
    NSLog(@"lowerThirdPostOverlayExist:%@",sobj.lowerThirdPostOverlayExist);
    NSLog(@"musicPostBackgroundIntergrationExist:%@",sobj.musicPostBackgroundIntergrationExist);
    NSLog(@"name:%@",sobj.name);
    NSLog(@"objectId:%@",sobj.objectId);
    NSLog(@"overlayPostCompositionFilterExist:%@",sobj.overlayPostCompositionFilterExist);
    NSLog(@"parentHashID:%@",sobj.parentHashID);
    NSLog(@"postBGTempURLstring:%@",sobj.postBGTempURLstring);
    NSLog(@"rotationDegreePostLowerThird:%@",sobj.rotationDegreePostLowerThird);
    NSLog(@"sizeXpostLowerThird:%@",sobj.sizeXpostLowerThird);
    NSLog(@"sizeYpostLowerThird:%@",sobj.sizeYpostLowerThird);
    NSLog(@"temporary:%@",sobj.temporary);
    NSLog(@"textOverBackgroundExist:%@",sobj.textOverBackgroundExist);
    NSLog(@"titlesExist:%@",sobj.titlesExist);
    NSLog(@"transitionModes:%@",sobj.transitionModes);
    NSLog(@"transitionSectionDurations:%@",sobj.transitionSectionDurations);
    NSLog(@"videoCount:%@",sobj.videoCount);
    NSLog(@"xOnBGPostLowerThird:%@",sobj.xOnBGPostLowerThird);
    NSLog(@"yOnBGPostLowerThird:%@",sobj.yOnBGPostLowerThird);
    NSLog(@"lowerThirdPostOverlay:%@",sobj.lowerThirdPostOverlay);
    NSLog(@"musicPostBGIntergration:%@",sobj.musicPostBGIntergration);
    NSLog(@"overlayPostCompositionFilter:%@",sobj.overlayPostCompositionFilter);
    NSLog(@"tail:%@",sobj.tail);
    NSLog(@"textOverBG:%@",sobj.textOverBG);
    NSLog(@"titles:%@",sobj.titles);
    NSLog(@"task:%@",sobj.task);
}



void CDSceneObjectNullifyExceptRelationShip(CDSceneObject * _Nullable sobj,BOOL temporary)
{
    sobj.anchorOnSelfXpostLowerThird = nil;
    sobj.anchorOnSelfYpostLowerThird = nil;
    sobj.averageBitRateForCompressing = nil;
    sobj.backgroundSizeX = nil;
    sobj.backgroundSizeY = nil;
    sobj.bgImageURLstring = nil;
    sobj.categoryId = nil;
    sobj.compositionMode = nil;
    sobj.coverImgUrl = nil;
    sobj.creatorId = nil;
    sobj.demoVideoUrl = nil;
    sobj.descs = nil;
    sobj.editMode = nil;
    sobj.expectedTotalDuration = nil;
    sobj.filterPostCompositionDuration = nil;
    sobj.filterPostCompositionExist = nil;
    sobj.filterPostCompositionName = nil;
    sobj.filterPostCompositionStartTime = nil;
    sobj.finalOutputCGsizeX = nil;
    sobj.finalOutputCGsizeY = nil;
    sobj.geomTransformPostLowerThirdExist = nil;
    sobj.interleaveInterval = nil;
    sobj.interleaveMode = nil;
    sobj.lowerThirdPostOverlayExist = nil;
    sobj.musicPostBackgroundIntergrationExist = nil;
    sobj.name = nil;
    sobj.objectId = nil;
    sobj.overlayPostCompositionFilterExist = nil;
    sobj.parentHashID  = nil ;
    sobj.postBGTempURLstring  = nil ;
    sobj.rotationDegreePostLowerThird   = nil ;
    sobj.sizeXpostLowerThird = nil ;
    sobj.sizeYpostLowerThird = nil  ;
    sobj.temporary = [NSNumber numberWithBool:temporary];
    sobj.textOverBackgroundExist = nil  ;
    sobj.titlesExist = nil   ;
    sobj.transitionModes  = nil  ;
    sobj.transitionSectionDurations = nil  ;
    sobj.videoCount = nil  ;
    sobj.xOnBGPostLowerThird  = nil;
    sobj.yOnBGPostLowerThird  = nil;
    

}

void CDSceneObjectNullify(CDSceneObject * _Nullable sobj,BOOL temporary)
{
    sobj.anchorOnSelfXpostLowerThird = nil;
    sobj.anchorOnSelfYpostLowerThird = nil;
    sobj.averageBitRateForCompressing = nil;
    sobj.backgroundSizeX = nil;
    sobj.backgroundSizeY = nil;
    sobj.bgImageURLstring = nil;
    sobj.categoryId = nil;
    sobj.compositionMode = nil;
    sobj.coverImgUrl = nil;
    sobj.creatorId = nil;
    sobj.demoVideoUrl = nil;
    sobj.descs = nil;
    sobj.editMode = nil;
    sobj.expectedTotalDuration = nil;
    sobj.filterPostCompositionDuration = nil;
    sobj.filterPostCompositionExist = nil;
    sobj.filterPostCompositionName = nil;
    sobj.filterPostCompositionStartTime = nil;
    sobj.finalOutputCGsizeX = nil;
    sobj.finalOutputCGsizeY = nil;
    sobj.geomTransformPostLowerThirdExist = nil;
    sobj.interleaveInterval = nil;
    sobj.interleaveMode = nil;
    sobj.lowerThirdPostOverlayExist = nil;
    sobj.musicPostBackgroundIntergrationExist = nil;
    sobj.name = nil;
    sobj.objectId = nil;
    sobj.overlayPostCompositionFilterExist = nil;
    sobj.parentHashID  = nil ;
    sobj.postBGTempURLstring  = nil ;
    sobj.rotationDegreePostLowerThird   = nil ;
    sobj.sizeXpostLowerThird = nil ;
    sobj.sizeYpostLowerThird = nil  ;
    sobj.temporary = [NSNumber numberWithBool:temporary];
    sobj.textOverBackgroundExist = nil  ;
    sobj.titlesExist = nil   ;
    sobj.transitionModes  = nil  ;
    sobj.transitionSectionDurations = nil  ;
    sobj.videoCount = nil  ;
    sobj.xOnBGPostLowerThird  = nil;
    sobj.yOnBGPostLowerThird  = nil;
    
    sobj.lowerThirdPostOverlay  = nil;
    sobj.musicPostBGIntergration  = nil;
    sobj.overlayPostCompositionFilter = nil;
    sobj.tail = nil;
    sobj.textOverBG = nil;
    sobj.titles = nil;
    sobj.task = nil;
}

CDSceneObject * CDSceneObjectSyncCreatNewWithAllChildrenRelationShip(BOOL tempOrNot)
{
    __block CDSceneObject * sceneObj ;
    __block CDVideoOverlayObject * videoOverlayObj ;
    __block CDVideoLowerThirdObject * lowerThirdObj;
    __block CDVideoTextOverBackGroundObject * textOverbackGroundObj;
    __block CDAudioSceneMusicObject * musicPostBG ;
    __block CDVideoTitlesObject * titles;
    __block CDVideoTailObject * tail;
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        videoOverlayObj = [CDVideoOverlayObject MR_createEntityInContext:localContext];
        CDVideoOverlayObjectNullifyExceptRelationShip(videoOverlayObj, tempOrNot);
        
        lowerThirdObj = [CDVideoLowerThirdObject MR_createEntityInContext:localContext];
        CDVideoLowerThirdObjectNullify(lowerThirdObj, tempOrNot);
        
        
        textOverbackGroundObj = [CDVideoTextOverBackGroundObject MR_createEntityInContext:localContext];
        CDVideoTextOverBackGroundObjectNullify(textOverbackGroundObj, tempOrNot);
        
        
        musicPostBG = [CDAudioSceneMusicObject MR_createEntityInContext:localContext];
        CDAudioSceneMusicObjectNullify(musicPostBG, tempOrNot);
        
        
        titles = [CDVideoTitlesObject MR_createEntityInContext:localContext];
        CDVideoTitlesObjectNullify(titles, tempOrNot);
        
        
        tail = [CDVideoTailObject MR_createEntityInContext:localContext];
        CDVideoTailObjectNullify(tail,tempOrNot);
        
        
        sceneObj =[CDSceneObject MR_createEntityInContext:localContext];
        sceneObj.temporary = [NSNumber numberWithBool:tempOrNot];
        sceneObj.overlayPostCompositionFilter = videoOverlayObj;
        sceneObj.lowerThirdPostOverlay = lowerThirdObj;
        sceneObj.textOverBG = textOverbackGroundObj;
        sceneObj.musicPostBGIntergration = musicPostBG;
        sceneObj.titles = titles;
        sceneObj.tail = tail;
        
    }];
    
    
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
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
    

    return([sceneObj MR_inContext:[NSManagedObjectContext MR_defaultContext]]);

}
