//
//  CDUserObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDUserObject.h"
#import "CDTaskObject.h"

@implementation CDUserObject

// Insert code here to add functionality to your managed object subclass


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



void deleteAllTemporaryCDUserObjects()
{
    NSArray * tempCDUserObjects = [CDUserObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDUserObjects.count; i++) {
        CDUserObject * obj = (CDUserObject *)tempCDUserObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void deleteAllNonTempCDUserObjects()
{
    NSArray * tempCDUserObjects = [CDUserObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDUserObjects.count; i++) {
        CDUserObject * obj = (CDUserObject *)tempCDUserObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void deleteAllCDUserObjects()
{
    NSArray * tempCDUserObjects = [CDUserObject MR_findAll];
    for (int i = 0 ; i<tempCDUserObjects.count; i++) {
        CDUserObject * obj = (CDUserObject *)tempCDUserObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}
