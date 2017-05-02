//
//  CDVideoObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDVideoObject.h"
#import "CDTaskObject.h"
#import "CDVideoLocalRenderObject.h"
#import "CDVideoOverlayObject.h"

@implementation CDVideoObject

// Insert code here to add functionality to your managed object subclass

- (void)removeSelfWithAllRelationshipsIfLonely
{
    if ((self.temporary)&&((self.parentHashID ==0))) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            
            if (self.videoLocalRender!=NULL) {
                [self.videoLocalRender MR_deleteEntityInContext:localContext];
                if (self.videoLocalRender.videoOverlay!=NULL) {
                    [self.videoLocalRender.videoOverlay MR_deleteEntityInContext:localContext];
                }
            }
            
            [self MR_deleteEntityInContext:localContext];
            
            
        }];
        
    }
}

- (void)forceRemoveIfNoParent
{
    
    if ((self.parentHashID==0)) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            
            if (self.videoLocalRender.videoOverlay) {
                [self.videoLocalRender.videoOverlay MR_deleteEntityInContext:localContext];
            }
            if (self.videoLocalRender) {
                [self.videoLocalRender MR_deleteEntityInContext:localContext];
            }
            [self MR_deleteEntityInContext:localContext];
            
            
        }];
        
    } else {
    }
    
}

- (void)forceRemoveIgnoreParent
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        if (self.videoLocalRender.videoOverlay) {
            [self.videoLocalRender.videoOverlay MR_deleteEntityInContext:localContext];
        }
        if (self.videoLocalRender) {
            [self.videoLocalRender MR_deleteEntityInContext:localContext];
        }
        [self MR_deleteEntityInContext:localContext];
        
    }];
}


@end


void deleteAllTemporaryCDVideoObjects()
{
    
    
    NSArray * tempCDVideoObjects = [CDVideoObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDVideoObjects.count; i++) {
        CDVideoObject * obj = (CDVideoObject *)tempCDVideoObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
            
        }];
    }
}



void deleteAllNonTempCDVideoObjects()
{
    
    NSArray * tempCDVideoObjects = [CDVideoObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDVideoObjects.count; i++) {
        CDVideoObject * obj = (CDVideoObject *)tempCDVideoObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
            
        }];
    }
    
}


void deleteAllCDVideoObjects()
{
    NSArray * tempCDVideoObjects = [CDVideoObject MR_findAll];
    for (int i = 0 ; i<tempCDVideoObjects.count; i++) {
        CDVideoObject * obj = (CDVideoObject *)tempCDVideoObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
            
        }];
    }
}



void CDVideoObjectPrint(CDVideoObject *  _Nonnull vobj)
{
    NSLog(@"effct:%@",vobj.effct);
    NSLog(@"endTime:%f",vobj.endTime);
    NSLog(@"height:%lld",vobj.height);
    NSLog(@"isMagic:%d",vobj.isMagic);
    NSLog(@"isTask:%d",vobj.isTask);
    NSLog(@"isUploaded:%d",vobj.isUploaded);
    NSLog(@"length:%lld",vobj.length);
    NSLog(@"makerId:%@",vobj.makerId);
    NSLog(@"order:%lld",vobj.order);
    NSLog(@"parentHashID:%lld",vobj.parentHashID);
    NSLog(@"sourceType:%lld",vobj.sourceType);
    NSLog(@"startTime:%f",vobj.startTime);
    NSLog(@"temporary:%d",vobj.temporary);
    NSLog(@"videoId:%@",vobj.videoId);
    NSLog(@"width:%lld",vobj.width);
    NSLog(@"videoLocalRender:%@",vobj.videoLocalRender);
    NSLog(@"task:%@",vobj.task);
     
}

////主要同时会更新parentHashID
void CDVideoObjectSaveWithUpdatingAllChildrenParentHashID(CDVideoObject * vobj,BOOL SYNC)
{
    if (SYNC) {
        
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            ////save vobj 并等待 vobj.objectID.hash 稳定
        }];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            ////save  并等待 vobj.videoLocalRender.objectID.hash 稳定
            ////为了使所有情况生效要操作的对象和relationShip 必须提取到当前同一个context
            CDVideoObject * vobjLocal = [vobj MR_inContext:localContext];
            vobjLocal.videoLocalRender.parentHashID = [NSNumber numberWithLongLong:vobjLocal.objectID.hash];
        }];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            ////save  并等待 vobj.videoLocalRender.objectID.hash 稳定
            CDVideoObject * vobjLocal = [vobj MR_inContext:localContext];
            vobjLocal.videoLocalRender.videoOverlay.parentHashID = [NSNumber numberWithLongLong:vobjLocal.videoLocalRender.objectID.hash];
        }];
        
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext* _Nonnull localContext) {
            
        } completion: ^(BOOL contextDidSave, NSError * _Nullable error) {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                CDVideoObject * vobjLocal = [vobj MR_inContext:localContext];
                vobjLocal.videoLocalRender.parentHashID = [NSNumber numberWithLongLong:vobjLocal.objectID.hash];
            } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    CDVideoObject * vobjLocal = [vobj MR_inContext:localContext];
                    vobjLocal.videoLocalRender.videoOverlay.parentHashID = [NSNumber numberWithLongLong:vobjLocal.videoLocalRender.objectID.hash];
                }];
            }];
            
        }];
    }
    

}