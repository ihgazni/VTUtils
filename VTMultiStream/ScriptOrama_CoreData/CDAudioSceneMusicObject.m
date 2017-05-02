//
//  CDAudioSceneMusicObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDAudioSceneMusicObject.h"
#import "CDSceneObject.h"

@implementation CDAudioSceneMusicObject

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


void deleteAllTemporaryCDAudioSceneMusicObjects()
{
    NSArray * tempCDAudioSceneMusicObjects = [CDAudioSceneMusicObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDAudioSceneMusicObjects.count; i++) {
        CDAudioSceneMusicObject * obj = (CDAudioSceneMusicObject *)tempCDAudioSceneMusicObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void deleteAllNonTempCDAudioSceneMusicObjects()
{
    NSArray * tempCDAudioSceneMusicObjects = [CDAudioSceneMusicObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDAudioSceneMusicObjects.count; i++) {
        CDAudioSceneMusicObject * obj = (CDAudioSceneMusicObject *)tempCDAudioSceneMusicObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void deleteAllCDAudioSceneMusicObjects()
{
    NSArray * tempCDAudioSceneMusicObjects = [CDAudioSceneMusicObject MR_findAll];
    for (int i = 0 ; i<tempCDAudioSceneMusicObjects.count; i++) {
        CDAudioSceneMusicObject * obj = (CDAudioSceneMusicObject *)tempCDAudioSceneMusicObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void CDAudioSceneMusicObjectPrint(CDAudioSceneMusicObject * asmobj)
{
    
    NSLog(@"animationDuration:%@",asmobj.animationDuration);
    NSLog(@"animationStartTime:%@",asmobj.animationStartTime);
    NSLog(@"duration:%@",asmobj.duration);
    NSLog(@"mixMode:%@",asmobj.mixMode);
    NSLog(@"musicURLstring:%@",asmobj.musicURLstring);
    NSLog(@"parentHashID:%@",asmobj.parentHashID);
    NSLog(@"startTime:%@",asmobj.startTime);
    NSLog(@"temporary:%@",asmobj.temporary);
    NSLog(@"timeFillingMode:%@",asmobj.timeFillingMode);
    NSLog(@"timeTrimingMode:%@",asmobj.timeTrimingMode);
    NSLog(@"volumeRatio:%@",asmobj.volumeRatio);
    NSLog(@"volumeSumWithOriginalVolume:%@",asmobj.volumeSumWithOriginalVolume);
    NSLog(@"scene:%@",asmobj.scene);
    
}

void CDAudioSceneMusicObjectNullifyExceptRelationShip(CDAudioSceneMusicObject * _Nullable asmobj,BOOL temporary)
{
    asmobj.animationDuration = nil;
    asmobj.animationStartTime = nil;
    asmobj.duration = nil;
    asmobj.mixMode = nil;
    asmobj.musicURLstring = nil;
    asmobj.parentHashID = nil;
    asmobj.startTime = nil;
    asmobj.temporary = [NSNumber numberWithBool:temporary];
    asmobj.timeFillingMode = nil;
    asmobj.timeTrimingMode = nil;
    asmobj.volumeRatio = nil;
    asmobj.volumeSumWithOriginalVolume = nil;
}

void CDAudioSceneMusicObjectNullify(CDAudioSceneMusicObject  * _Nullable asmobj,BOOL temporary)
{
    asmobj.animationDuration = nil;
    asmobj.animationStartTime = nil;
    asmobj.duration = nil;
    asmobj.mixMode = nil;
    asmobj.musicURLstring = nil;
    asmobj.parentHashID = nil;
    asmobj.startTime = nil;
    asmobj.temporary = [NSNumber numberWithBool:temporary];
    asmobj.timeFillingMode = nil;
    asmobj.timeTrimingMode = nil;
    asmobj.volumeRatio = nil;
    asmobj.volumeSumWithOriginalVolume = nil;
    asmobj.scene = nil;
}

