//
//  CDTaskObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDSceneObject, CDUserObject, CDVideoObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDTaskObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
@end

NS_ASSUME_NONNULL_END

#import "CDTaskObject+CoreDataProperties.h"
void deleteAllCDTaskObjects();

void CDTaskObjectUpdateSceneObject(CDTaskObject * _Nullable tobj,CDSceneObject *  _Nullable  sobj,BOOL sync);