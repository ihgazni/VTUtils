//
//  CDVideoTextOverBackGroundObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDSceneObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoTextOverBackGroundObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;

@end

NS_ASSUME_NONNULL_END

#import "CDVideoTextOverBackGroundObject+CoreDataProperties.h"

void deleteAllTemporaryCDVideoTextOverBackGroundObjects();
void deleteAllNonTempCDVideoTextOverBackGroundObjects();
void deleteAllCDVideoTextOverBackGroundObjects();

void CDVideoTextOverBackGroundObjectPrint(CDVideoTextOverBackGroundObject * _Nullable tobgobj);
void CDVideoTextOverBackGroundObjectNullifyExceptRelationShip(CDVideoTextOverBackGroundObject * _Nullable tobgobj,BOOL temporary);
void CDVideoTextOverBackGroundObjectNullify(CDVideoTextOverBackGroundObject * _Nullable tobgobj,BOOL temporary);
