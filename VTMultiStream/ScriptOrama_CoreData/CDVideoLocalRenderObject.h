//
//  CDVideoLocalRenderObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDVideoObject, CDVideoOverlayObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoLocalRenderObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;
@end

NS_ASSUME_NONNULL_END

#import "CDVideoLocalRenderObject+CoreDataProperties.h"
void deleteAllTemporaryCDVideoLocalRenderObjects();
void deleteAllNonTempCDVideoLocalRenderObjects();
void deleteAllCDVideoLocalRenderObjects();
void CDVideoLocalRenderObjectNullifyExceptRelationShip(CDVideoLocalRenderObject * _Nonnull  vlrobj,BOOL temporary);

