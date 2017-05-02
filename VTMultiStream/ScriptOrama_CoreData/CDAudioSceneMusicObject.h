//
//  CDAudioSceneMusicObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDSceneObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDAudioSceneMusicObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;
@end

NS_ASSUME_NONNULL_END

#import "CDAudioSceneMusicObject+CoreDataProperties.h"
void deleteAllTemporaryCDAudioSceneMusicObjects();
void deleteAllNonTempCDAudioSceneMusicObjects();
void deleteAllCDAudioSceneMusicObjects();

void CDAudioSceneMusicObjectPrint(CDAudioSceneMusicObject *  _Nullable asmobj);
void CDAudioSceneMusicObjectNullifyExceptRelationShip(CDAudioSceneMusicObject * _Nullable asmobj,BOOL temporary);
void CDAudioSceneMusicObjectNullify(CDAudioSceneMusicObject  * _Nullable asmobj,BOOL temporary);
