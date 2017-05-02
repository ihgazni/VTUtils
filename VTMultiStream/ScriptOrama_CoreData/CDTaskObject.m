//
//  CDTaskObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDTaskObject.h"
#import "CDSceneObject.h"
#import "CDAudioSceneMusicObject.h"
#import "CDVideoLowerThirdObject.h"
#import "CDVideoOverlayObject.h"
#import "CDVideoTailObject.h"
#import "CDVideoTextOverBackGroundObject.h"
#import "CDVideoTitlesObject.h"
#import "CDUserObject.h"

@implementation CDTaskObject

// Insert code here to add functionality to your managed object subclass

-(void)removeSelfWithAllRelationshipsIfLonely
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        if (self.starter) {
            [self.starter MR_deleteEntityInContext:localContext];
        }
        
        if (self.scene) {
            if (self.scene.overlayPostCompositionFilter) {
                [self.scene.overlayPostCompositionFilter MR_deleteEntityInContext:localContext];
            }
            if (self.scene.lowerThirdPostOverlay) {
                [self.scene.lowerThirdPostOverlay MR_deleteEntityInContext:localContext];
            }
            if (self.scene.textOverBG) {
                [self.scene.textOverBG MR_deleteEntityInContext:localContext];
            }
            if (self.scene.musicPostBGIntergration) {
                [self.scene.musicPostBGIntergration MR_deleteEntityInContext:localContext];
            }
            if (self.scene.titles) {
                [self.scene.titles MR_deleteEntityInContext:localContext];
            }
            if (self.scene.tail) {
                [self.scene.tail MR_deleteEntityInContext:localContext];
            }
            
        }
        
        [self MR_deleteEntityInContext:localContext];
        
        
    }];
    
}


@end





void deleteAllCDTaskObjects()
{
    NSArray * tempCDTaskObjects = [CDUserObject MR_findAll];
    for (int i = 0 ; i<tempCDTaskObjects.count; i++) {
        CDTaskObject * obj = (CDTaskObject *)tempCDTaskObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}




void CDTaskObjectUpdateSceneObject(CDTaskObject * tobj,CDSceneObject * sobj,BOOL sync)
{
    
    if (sync) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            CDTaskObject * taskObj = [tobj MR_inContext:localContext];
            CDSceneObject * oldSceneObj = [tobj.scene MR_inContext:localContext];
            if (oldSceneObj) {
                [oldSceneObj MR_deleteEntityInContext:localContext];
                taskObj.scene = nil;
            } else {
                
            }
            CDSceneObject * newSceneObj = [sobj MR_inContext:localContext];
            if (newSceneObj) {
                newSceneObj.parentHashID = [NSNumber numberWithLongLong:tobj.objectID.hash];
                taskObj.scene = newSceneObj;
            }
            
        }];
    } else {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            
            CDTaskObject * taskObj = [tobj MR_inContext:localContext];
            CDSceneObject * oldSceneObj = [tobj.scene MR_inContext:localContext];
            if (oldSceneObj) {
                [oldSceneObj MR_deleteEntityInContext:localContext];
                taskObj.scene = nil;
            } else {
                
            }
            CDSceneObject * newSceneObj = [sobj MR_inContext:localContext];
            if (newSceneObj) {
                newSceneObj.parentHashID = [NSNumber numberWithLongLong:tobj.objectID.hash];
                taskObj.scene = newSceneObj;
            }
        } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
            
        }];
        
    }
    
    
}
