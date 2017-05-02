//
//  CDVideoTitlesObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDVideoTitlesObject.h"
#import "CDSceneObject.h"

@implementation CDVideoTitlesObject

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




void deleteAllTemporaryCDVideoTitlesObjects()
{
    NSArray * tempCDVideoTitlesObjects = [CDVideoTitlesObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDVideoTitlesObjects.count; i++) {
        CDVideoTitlesObject * obj = (CDVideoTitlesObject *)tempCDVideoTitlesObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void deleteAllNonTempCDVideoTitlesObjects()
{
    NSArray * tempCDVideoTitlesObjects = [CDVideoTitlesObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDVideoTitlesObjects.count; i++) {
        CDVideoTitlesObject * obj = (CDVideoTitlesObject *)tempCDVideoTitlesObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void deleteAllCDVideoTitlesObjects()
{
    NSArray * tempCDVideoTitlesObjects = [CDVideoTitlesObject MR_findAll];
    for (int i = 0 ; i<tempCDVideoTitlesObjects.count; i++) {
        CDVideoTitlesObject * obj = (CDVideoTitlesObject *)tempCDVideoTitlesObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void CDVideoTitlesObjectPrint(CDVideoTitlesObject * vtlsobj)
{
    NSLog(@"duration:%@",vtlsobj.duration);
    NSLog(@"height:%@",vtlsobj.height);
    NSLog(@"parentHashID:%@",vtlsobj.parentHashID);
    NSLog(@"temporary:%@",vtlsobj.temporary);
    NSLog(@"timeFillingMode:%@",vtlsobj.timeFillingMode);
    NSLog(@"timeTrimingMode:%@",vtlsobj.timeTrimingMode);
    NSLog(@"titlesURLstring:%@",vtlsobj.titlesURLstring);
    NSLog(@"type:%@",vtlsobj.type);
    NSLog(@"width:%@",vtlsobj.width);
    NSLog(@"scene:%@",vtlsobj.scene);
}

void CDVideoTitlesObjectNullifyExceptRelationShip(CDVideoTitlesObject * _Nullable vtlsobj,BOOL temporary)
{
    vtlsobj.duration = nil;
    vtlsobj.height = nil;
    vtlsobj.parentHashID = nil;
    vtlsobj.temporary = [NSNumber numberWithBool:temporary];;
    vtlsobj.timeFillingMode = nil;
    vtlsobj.timeTrimingMode = nil;
    vtlsobj.titlesURLstring = nil;
    vtlsobj.type = nil;
    vtlsobj.width = nil;
}

void CDVideoTitlesObjectNullify(CDVideoTitlesObject * _Nullable vtlsobj,BOOL temporary)
{
    vtlsobj.duration = nil;
    vtlsobj.height = nil;
    vtlsobj.parentHashID = nil;
    vtlsobj.temporary = [NSNumber numberWithBool:temporary];;
    vtlsobj.timeFillingMode = nil;
    vtlsobj.timeTrimingMode = nil;
    vtlsobj.titlesURLstring = nil;
    vtlsobj.type = nil;
    vtlsobj.width = nil;
    vtlsobj.scene = nil;
}



