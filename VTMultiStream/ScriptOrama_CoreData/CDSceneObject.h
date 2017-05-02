//
//  CDSceneObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDAudioSceneMusicObject, CDTaskObject, CDVideoLowerThirdObject, CDVideoOverlayObject, CDVideoTailObject, CDVideoTextOverBackGroundObject, CDVideoTitlesObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDSceneObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;
@end

NS_ASSUME_NONNULL_END

#import "CDSceneObject+CoreDataProperties.h"
void deleteAllTemporaryCDSceneObjects();
void deleteAllNonTempCDSceneObjects();
void deleteAllCDSceneObjects(BOOL SYNC);

void CDSceneObjectPrint(CDSceneObject * _Nullable sobj);
void CDSceneObjectNullifyExceptRelationShip(CDSceneObject * _Nullable sobj,BOOL temporary);
void CDSceneObjectNullify(CDSceneObject * _Nullable sobj,BOOL temporary);
CDSceneObject *  _Nullable CDSceneObjectSyncCreatNewWithAllChildrenRelationShip(BOOL tempOrNot);

