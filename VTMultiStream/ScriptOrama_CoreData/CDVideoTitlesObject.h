//
//  CDVideoTitlesObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDSceneObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoTitlesObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;
@end

NS_ASSUME_NONNULL_END

#import "CDVideoTitlesObject+CoreDataProperties.h"

void deleteAllTemporaryCDVideoTitlesObjects();
void deleteAllNonTempCDVideoTitlesObjects();
void deleteAllCDVideoTitlesObjects();

void CDVideoTitlesObjectPrint(CDVideoTitlesObject * _Nullable vtlsobj);
void CDVideoTitlesObjectNullifyExceptRelationShip(CDVideoTitlesObject * _Nullable asmobj,BOOL temporary);
void CDVideoTitlesObjectNullify(CDVideoTitlesObject * _Nullable asmobj,BOOL temporary);
