//
//  CDVideoTailObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDVideoTailObject.h"
#import "CDSceneObject.h"

@implementation CDVideoTailObject

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



void deleteAllTemporaryCDVideoTailObjects()
{
    NSArray * tempCDVideoTailObjects = [CDVideoTailObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDVideoTailObjects.count; i++) {
        CDVideoTailObject * obj = (CDVideoTailObject *)tempCDVideoTailObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void deleteAllNonTempCDVideoTailObjects()
{
    NSArray * tempCDVideoTailObjects = [CDVideoTailObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDVideoTailObjects.count; i++) {
        CDVideoTailObject * obj = (CDVideoTailObject *)tempCDVideoTailObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void deleteAllCDVideoTailObjects()
{
    NSArray * tempCDVideoTailObjects = [CDVideoTailObject MR_findAll];
    for (int i = 0 ; i<tempCDVideoTailObjects.count; i++) {
        CDVideoTailObject * obj = (CDVideoTailObject *)tempCDVideoTailObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void CDVideoTailObjectPrint(CDVideoTailObject * vtobj)
{
    NSLog(@"duration:%@",vtobj.duration);
    NSLog(@"height:%@",vtobj.height);
    NSLog(@"mode:%@",vtobj.mode);
    NSLog(@"parentHashID:%@",vtobj.parentHashID);
    NSLog(@"tailURLstring:%@",vtobj.tailURLstring);
    NSLog(@"temporary:%@",vtobj.temporary);
    NSLog(@"timeFillingMode:%@",vtobj.timeFillingMode);
    NSLog(@"timeTrimingMode:%@",vtobj.timeTrimingMode);
    NSLog(@"type:%@",vtobj.type);
    NSLog(@"width:%@",vtobj.width);
    NSLog(@"scene:%@",vtobj.scene);
}


void CDVideoTailObjectNullifyExceptRelationShip(CDVideoTailObject * _Nullable vtobj,BOOL temporary)
{
    vtobj.duration = nil;
    vtobj.height = nil;
    vtobj.mode = nil;
    vtobj.parentHashID = nil;
    vtobj.tailURLstring = nil;
    vtobj.temporary = [NSNumber numberWithBool:temporary];
    vtobj.timeFillingMode = nil;
    vtobj.timeTrimingMode = nil;
    vtobj.type = nil;
    vtobj.width = nil;

}
void CDVideoTailObjectNullify(CDVideoTailObject * _Nullable vtobj,BOOL temporary)
{
    vtobj.duration = nil;
    vtobj.height = nil;
    vtobj.mode = nil;
    vtobj.parentHashID = nil;
    vtobj.tailURLstring = nil;
    vtobj.temporary = [NSNumber numberWithBool:temporary];
    vtobj.timeFillingMode = nil;
    vtobj.timeTrimingMode = nil;
    vtobj.type = nil;
    vtobj.width = nil;
    vtobj.scene = nil;
}
