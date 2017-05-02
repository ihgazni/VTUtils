//
//  CDVideoTextOverBackGroundObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDVideoTextOverBackGroundObject.h"
#import "CDSceneObject.h"

@implementation CDVideoTextOverBackGroundObject

// Insert code here to add functionality to your managed object subclass


-(void)removeSelfWithAllRelationshipsIfLonely
{
    if ((self.temporary == [NSNumber numberWithBool:YES])&&(([self.parentHashID longLongValue]==0)||(self.parentHashID==NULL))) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [self MR_deleteEntityInContext:localContext];
        }];
        
    }
}

- (void)forceRemoveIfNoParent
{
    if (([self.parentHashID longLongValue]==0)) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [self MR_deleteEntityInContext:localContext];
        }];
    } else {
        
    }
    
}

- (void)forceRemoveIgnoreParent
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [self MR_deleteEntityInContext:localContext];
    }];
}

@end



void deleteAllTemporaryCDVideoTextOverBackGroundObjects()
{
    NSArray * tempCDVideoTextOverBackGroundObjects = [CDVideoTextOverBackGroundObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDVideoTextOverBackGroundObjects.count; i++) {
        CDVideoTextOverBackGroundObject * obj = (CDVideoTextOverBackGroundObject *)tempCDVideoTextOverBackGroundObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void deleteAllNonTempCDVideoTextOverBackGroundObjects()
{
    NSArray * tempCDVideoTextOverBackGroundObjects = [CDVideoTextOverBackGroundObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDVideoTextOverBackGroundObjects.count; i++) {
        CDVideoTextOverBackGroundObject * obj = (CDVideoTextOverBackGroundObject *)tempCDVideoTextOverBackGroundObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void deleteAllCDVideoTextOverBackGroundObjects()
{
    NSArray * tempCDVideoTextOverBackGroundObjects = [CDVideoTextOverBackGroundObject MR_findAll];
    for (int i = 0 ; i<tempCDVideoTextOverBackGroundObjects.count; i++) {
        CDVideoTextOverBackGroundObject * obj = (CDVideoTextOverBackGroundObject *)tempCDVideoTextOverBackGroundObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}



void CDVideoTextOverBackGroundObjectPrint(CDVideoTextOverBackGroundObject * tobgobj)
{
    NSLog(@"animationMode:%@",tobgobj.animationMode);
    NSLog(@"content:%@",tobgobj.content);
    NSLog(@"fontColorA:%@",tobgobj.fontColorA);
    NSLog(@"fontColorB:%@",tobgobj.fontColorB);
    NSLog(@"fontColorG:%@",tobgobj.fontColorG);
    NSLog(@"fontColorR:%@",tobgobj.fontColorR);
    NSLog(@"fontFamily:%@",tobgobj.fontFamily);
    NSLog(@"fontSize:%@",tobgobj.fontSize);
    NSLog(@"height:%@",tobgobj.height);
    NSLog(@"parentHashID:%@",tobgobj.parentHashID);
    NSLog(@"showStage:%@",tobgobj.showStage);
    NSLog(@"startTime:%@",tobgobj.startTime);
    NSLog(@"temporary:%@",tobgobj.temporary);
    NSLog(@"width:%@",tobgobj.width);
    NSLog(@"xOnBG:%@",tobgobj.xOnBG);
    NSLog(@"yOnBG:%@",tobgobj.yOnBG);
    NSLog(@"scene:%@",tobgobj.scene);
}

void CDVideoTextOverBackGroundObjectNullifyExceptRelationShip(CDVideoTextOverBackGroundObject * _Nullable tobgobj,BOOL temporary)
{
    tobgobj.animationMode = nil;
    tobgobj.content = nil;
    tobgobj.fontColorA = nil;
    tobgobj.fontColorB = nil;
    tobgobj.fontColorG = nil;
    tobgobj.fontColorR = nil;
    tobgobj.fontFamily = nil;
    tobgobj.fontSize = nil;
    tobgobj.height = nil;
    tobgobj.parentHashID = nil;
    tobgobj.showStage = nil;
    tobgobj.startTime = nil;
    tobgobj.temporary = [NSNumber numberWithBool:temporary];
    tobgobj.width = nil;
    tobgobj.xOnBG = nil;
    tobgobj.yOnBG = nil;
}
void CDVideoTextOverBackGroundObjectNullify(CDVideoTextOverBackGroundObject * _Nullable tobgobj,BOOL temporary)
{
    tobgobj.animationMode = nil;
    tobgobj.content = nil;
    tobgobj.fontColorA = nil;
    tobgobj.fontColorB = nil;
    tobgobj.fontColorG = nil;
    tobgobj.fontColorR = nil;
    tobgobj.fontFamily = nil;
    tobgobj.fontSize = nil;
    tobgobj.height = nil;
    tobgobj.parentHashID = nil;
    tobgobj.showStage = nil;
    tobgobj.startTime = nil;
    tobgobj.temporary = [NSNumber numberWithBool:temporary];
    tobgobj.width = nil;
    tobgobj.xOnBG = nil;
    tobgobj.yOnBG = nil;
    tobgobj.scene = nil;
}
