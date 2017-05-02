//
//  CDVideoLowerThirdObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDVideoLowerThirdObject.h"
#import "CDSceneObject.h"

@implementation CDVideoLowerThirdObject

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



void deleteAllTemporaryCDVideoLowerThirdObjects()
{
    NSArray * tempCDVideoLowerThirdObjects = [CDVideoLowerThirdObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDVideoLowerThirdObjects.count; i++) {
        CDVideoLowerThirdObject * obj = (CDVideoLowerThirdObject *)tempCDVideoLowerThirdObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void deleteAllNonTempCDVideoLowerThirdObjects()
{
    NSArray * tempCDVideoLowerThirdObjects = [CDVideoLowerThirdObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDVideoLowerThirdObjects.count; i++) {
        CDVideoLowerThirdObject * obj = (CDVideoLowerThirdObject *)tempCDVideoLowerThirdObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void deleteAllCDVideoLowerThirdObjects()
{
    NSArray * tempCDVideoLowerThirdObjects = [CDVideoLowerThirdObject MR_findAll];
    for (int i = 0 ; i<tempCDVideoLowerThirdObjects.count; i++) {
        CDVideoLowerThirdObject * obj = (CDVideoLowerThirdObject *)tempCDVideoLowerThirdObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void CDVideoLowerThirdObjectPrint(CDVideoLowerThirdObject * _Nullable vlthobj)
{
    NSLog(@"bgImageURLstring:%@",vlthobj.bgImageURLstring);
    NSLog(@"duration:%@",vlthobj.duration);
    NSLog(@"fontColorA:%@",vlthobj.fontColorA);
    NSLog(@"fontColorB:%@",vlthobj.fontColorB);
    NSLog(@"fontColorG:%@",vlthobj.fontColorG);
    NSLog(@"fontColorR:%@",vlthobj.fontColorR);
    NSLog(@"fontFamily:%@",vlthobj.fontFamily);
    NSLog(@"fontSize:%@",vlthobj.fontSize);
    NSLog(@"height:%@",vlthobj.height);
    NSLog(@"parentHashID:%@",vlthobj.parentHashID);
    NSLog(@"petName:%@",vlthobj.petName);
    NSLog(@"startTime:%@",vlthobj.startTime);
    NSLog(@"temporary:%@",vlthobj.temporary);
    NSLog(@"width:%@",vlthobj.width);
    NSLog(@"xOnVideo:%@",vlthobj.xOnVideo);
    NSLog(@"yOnVideo:%@",vlthobj.yOnVideo);
    NSLog(@"scene:%@",vlthobj.scene);
}
void CDVideoLowerThirdObjectNullifyExceptRelationShip(CDVideoLowerThirdObject * _Nullable vlthobj,BOOL temporary)
{
    vlthobj.bgImageURLstring = nil;
    vlthobj.duration = nil;
    vlthobj.fontColorA = nil;
    vlthobj.fontColorB = nil;
    vlthobj.fontColorG = nil;
    vlthobj.fontColorR = nil;
    vlthobj.fontFamily = nil;
    vlthobj.fontSize = nil;
    vlthobj.height = nil;
    vlthobj.parentHashID = nil;
    vlthobj.petName = nil;
    vlthobj.startTime = nil;
    vlthobj.temporary = [NSNumber numberWithBool:temporary];
    vlthobj.width = nil;
    vlthobj.xOnVideo = nil;
    vlthobj.yOnVideo = nil;
    
}
void CDVideoLowerThirdObjectNullify(CDVideoLowerThirdObject * _Nullable vlthobj,BOOL temporary)
{
    vlthobj.bgImageURLstring = nil;
    vlthobj.duration = nil;
    vlthobj.fontColorA = nil;
    vlthobj.fontColorB = nil;
    vlthobj.fontColorG = nil;
    vlthobj.fontColorR = nil;
    vlthobj.fontFamily = nil;
    vlthobj.fontSize = nil;
    vlthobj.height = nil;
    vlthobj.parentHashID = nil;
    vlthobj.petName = nil;
    vlthobj.startTime = nil;
    vlthobj.temporary = [NSNumber numberWithBool:temporary];
    vlthobj.width = nil;
    vlthobj.xOnVideo = nil;
    vlthobj.yOnVideo = nil;
    vlthobj.scene = nil;
}