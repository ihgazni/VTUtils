//
//  CDVideoTailObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDSceneObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoTailObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;
@end

NS_ASSUME_NONNULL_END

#import "CDVideoTailObject+CoreDataProperties.h"

void deleteAllTemporaryCDVideoTailObjects();
void deleteAllNonTempCDVideoTailObjects();
void deleteAllCDVideoTailObjects();

void CDVideoTailObjectPrint(CDVideoTailObject * _Nullable vtobj);
void CDVideoTailObjectNullifyExceptRelationShip(CDVideoTailObject * _Nullable vtobj,BOOL temporary);
void CDVideoTailObjectNullify(CDVideoTailObject * _Nullable vtobj,BOOL temporary);
