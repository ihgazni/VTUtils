//
//  CDVideoLowerThirdObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDSceneObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoLowerThirdObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;

@end

NS_ASSUME_NONNULL_END

#import "CDVideoLowerThirdObject+CoreDataProperties.h"

void deleteAllTemporaryCDVideoLowerThirdObjects();
void deleteAllNonTempCDVideoLowerThirdObjects();
void deleteAllCDVideoLowerThirdObjects();

void CDVideoLowerThirdObjectPrint(CDVideoLowerThirdObject * _Nullable vlthobj);
void CDVideoLowerThirdObjectNullifyExceptRelationShip(CDVideoLowerThirdObject * _Nullable vlthobj,BOOL temporary);
void CDVideoLowerThirdObjectNullify(CDVideoLowerThirdObject * _Nullable vlthobj,BOOL temporary);
