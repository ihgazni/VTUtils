//
//  CDVideoOverlayObject.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDSceneObject, CDVideoLocalRenderObject;

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoOverlayObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
// Insert code here to declare functionality of your managed object subclass
- (void)removeSelfWithAllRelationshipsIfLonely;
- (void)forceRemoveIfNoParent;
- (void)forceRemoveIgnoreParent;

@end

NS_ASSUME_NONNULL_END

#import "CDVideoOverlayObject+CoreDataProperties.h"


CGPoint movingPathElementToCGpoint(NSValue * _Nonnull ele);
NSMutableArray * _Nonnull reconstructMovingPath(NSMutableArray * _Nonnull movingPathCGpointXs,NSMutableArray * _Nonnull movingPathCGpointYs);
NSMutableDictionary * _Nonnull splitMovingPathToXsAndYs(NSMutableArray * _Nonnull movingPath);
NSMutableArray * _Nonnull movingSectionDurationsToAnimationTimes(NSMutableArray * _Nonnull durations,float acturalVideoLength);
NSMutableArray * _Nonnull animationTimesToMovingSectionDurations(NSMutableArray * _Nonnull  animationTimes,float acturalVideoLength);
NSMutableArray *  _Nonnull  toAverageSpeedMovingPathPoints(NSMutableArray*  _Nonnull  movingPathPoints,NSMutableArray*  _Nonnull  movingSectionDurations);
void deleteAllTemporaryCDVideoOverlayObjects();
void deleteAllNonTempCDVideoOverlayObjects();
void deleteAllCDVideoOverlayObjects();

void CDVideoOverlayObjectNullify(CDVideoOverlayObject *  _Nonnull  voobj,BOOL temporary);
void CDVideoOverlayObjectNullifyExceptRelationShip(CDVideoOverlayObject * _Nonnull  voobj,BOOL temporary);
void CDVideoOverlayObjectPrint(CDVideoOverlayObject * _Nullable  voobj);