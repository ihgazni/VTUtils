//
//  CDVideoObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDTaskObject, CDVideoLocalRenderObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;

@end

NS_ASSUME_NONNULL_END

#import "CDVideoObject+CoreDataProperties.h"

void deleteAllTemporaryCDVideoObjects();
void deleteAllNonTempCDVideoObjects();
void deleteAllCDVideoObjects();
void CDVideoObjectSaveWithUpdatingAllChildrenParentHashID(CDVideoObject *  _Nonnull vobj,BOOL SYNC);
void CDVideoObjectPrint(CDVideoObject *  _Nonnull vobj);

