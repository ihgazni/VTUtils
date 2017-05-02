//
//  CDVideoOverlayObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDVideoOverlayObject.h"
#import "CDSceneObject.h"
#import "CDVideoLocalRenderObject.h"

@implementation CDVideoOverlayObject

// Insert code here to add functionality to your managed object subclass

-(void)removeSelfWithAllRelationshipsIfLonely
{
    if ((self.temporary == [NSNumber numberWithBool:YES])&&(([self.parentHashID longLongValue]==0)||(self.parentHashID==NULL))) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [self MR_deleteEntityInContext:localContext];
        }];
        
    }
}

- (void)forceRemoveIfNoParent
{
    if (([self.parentHashID longLongValue]==0)) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [self MR_deleteEntityInContext:localContext];
        }];
    } else {
        
    }
    
}

- (void)forceRemoveIgnoreParent
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [self MR_deleteEntityInContext:localContext];
    }];
}


@end

CGPoint movingPathElementToCGPoint(NSValue * _Nonnull ele)
{
    CGPoint xy = [ele CGPointValue];
    return(xy);
}

NSMutableArray * _Nonnull reconstructMovingPath(NSMutableArray * _Nonnull movingPathCGpointXs,NSMutableArray * _Nonnull movingPathCGpointYs)
{
    int countX = (int)movingPathCGpointXs.count;
    int countY = (int)movingPathCGpointYs.count;
    int count = MIN(countX, countY);
    NSMutableArray * movingPath = [[NSMutableArray alloc] init];
    for (int i = 0; i< count; i++) {
        CGPoint xy = CGPointMake([movingPathCGpointXs[i] floatValue],[movingPathCGpointYs[i] floatValue]);
        [movingPath addObject:[NSValue valueWithCGPoint:xy]];
    }
    return(movingPath);
    
}

NSMutableDictionary * _Nonnull splitMovingPathToXsAndYs(NSMutableArray * _Nonnull movingPath)
{
    NSMutableDictionary * rslt = [[NSMutableDictionary alloc] init];
    NSMutableArray * movingPathCGpointXs = [[NSMutableArray alloc] init];
    NSMutableArray * movingPathCGpointYs = [[NSMutableArray alloc] init];
    int count = (int)movingPath.count;
    for (int i = 0; i< count; i++) {
        CGPoint xy = [movingPath[i] CGPointValue];
        [movingPathCGpointXs addObject:[NSNumber numberWithFloat:xy.x]];
        [movingPathCGpointYs addObject:[NSNumber numberWithFloat:xy.y]];
    }
    [rslt setValue:movingPathCGpointXs forKey:@"X"];
    [rslt setValue:movingPathCGpointYs forKey:@"Y"];
    return(rslt);
}



NSMutableArray * movingSectionDurationsToAnimationTimes(NSMutableArray * durations,float acturalVideoLength)
{
    NSMutableArray * times = [[NSMutableArray alloc] init];
    unsigned long count = durations.count;
    float atPercentTime = 0.0;
    for (int i = 0; i<count; i++) {
        float du = [durations[i] floatValue];
        float ratio = du / acturalVideoLength;
        atPercentTime = atPercentTime + ratio;
        [times addObject:[NSNumber numberWithFloat:atPercentTime]];
        
    }
    [times addObject:[NSNumber numberWithFloat:1.0]];
    return(times);
}

NSMutableArray * animationTimesToMovingSectionDurations(NSMutableArray * animationTimes,float acturalVideoLength)
{
    NSMutableArray * movingSectionDurations = [[NSMutableArray alloc] init];
    unsigned long count = animationTimes.count;
    float atPercentTime = [animationTimes[0] floatValue];
    [movingSectionDurations addObject:[NSNumber numberWithFloat:(atPercentTime* acturalVideoLength)]];
    for (int i = 1; i<count; i++) {
        float apt = [animationTimes[i] floatValue];
        float duration = (apt - atPercentTime) * acturalVideoLength;
        atPercentTime =  apt;
        [movingSectionDurations addObject:[NSNumber numberWithFloat:duration]];
    }
    return(movingSectionDurations);
}


NSMutableArray * toAverageSpeedMovingPathPoints(NSMutableArray* movingPathPoints,NSMutableArray*movingSectionDurations)
{
    NSMutableArray * newPathPoints = [[NSMutableArray alloc] init];
    ////找出最小的duration
    float min = [movingSectionDurations[0] floatValue];
    for (int i =1; i<movingSectionDurations.count; i++) {
        min = MIN(min, [movingSectionDurations[i] floatValue]);
    }
    if (movingSectionDurations) {
        for (int i =0; i<movingPathPoints.count - 1; i++) {
            CGPoint sp = [movingPathPoints[i] CGPointValue];
            CGPoint ep = [movingPathPoints[i+1] CGPointValue];
            float duration = [movingSectionDurations[i] floatValue];
            int insertedPointsNum = (int) (duration/min) - 1;
            float currX = sp.x;
            float currY = sp.y;
            float stepX = (ep.x - sp.x)/insertedPointsNum;
            float stepY = (ep.y - sp.y)/insertedPointsNum;
            [newPathPoints addObject:[NSValue valueWithCGPoint:sp]];
            for (int j =0; j<insertedPointsNum; j++) {
                CGPoint xy = CGPointMake(currX+stepX, currY+stepY);
                [newPathPoints addObject:[NSValue valueWithCGPoint:xy]];
                currX = currX + stepX;
                currY = currY + stepY;
            }
            ////[newPathPoints addObject:[NSValue valueWithCGPoint:ep]];
        }
    } else {
        newPathPoints = movingPathPoints;
    }
    return(newPathPoints);
}




void deleteAllTemporaryCDVideoOverlayObjects()
{
    NSArray * tempCDVideoOverlayObjects = [CDVideoOverlayObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDVideoOverlayObjects.count; i++) {
        CDVideoOverlayObject * obj = (CDVideoOverlayObject *)tempCDVideoOverlayObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void deleteAllNonTempCDVideoOverlayObjects()
{
    NSArray * tempCDVideoOverlayObjects = [CDVideoOverlayObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDVideoOverlayObjects.count; i++) {
        CDVideoOverlayObject * obj = (CDVideoOverlayObject *)tempCDVideoOverlayObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}


void deleteAllCDVideoOverlayObjects()
{
    NSArray * tempCDVideoOverlayObjects = [CDVideoOverlayObject MR_findAll];
    for (int i = 0 ; i<tempCDVideoOverlayObjects.count; i++) {
        CDVideoOverlayObject * obj = (CDVideoOverlayObject *)tempCDVideoOverlayObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
        }];
    }
}

void CDVideoOverlayObjectNullify(CDVideoOverlayObject *voobj,BOOL temporary)
{
    voobj.temporary = [NSNumber numberWithBool:temporary];
    voobj.absoluteURLstring = nil;
    voobj.blendMode = nil;
    voobj.duration = nil;
    voobj.exist = nil;
    voobj.height = nil;
    voobj.movingPathCGpointXs = nil;
    voobj.movingPathCGpointYs = nil;
    voobj.movingSectionDurations = nil;
    voobj.parentHashID = nil;
    voobj.startTime = nil;
    voobj.timeFillingMode = nil;
    voobj.timeTrimingMode = nil;
    voobj.type = nil;
    voobj.width = nil;
    voobj.videoLocalRender = nil;
    voobj.scene = nil;
}
void CDVideoOverlayObjectNullifyExceptRelationShip(CDVideoOverlayObject *voobj,BOOL temporary)
{
    voobj.temporary = [NSNumber numberWithBool:temporary];
    voobj.absoluteURLstring = nil;
    voobj.blendMode = nil;
    voobj.duration = nil;
    voobj.exist = nil;
    voobj.height = nil;
    voobj.movingPathCGpointXs = nil;
    voobj.movingPathCGpointYs = nil;
    voobj.movingSectionDurations = nil;
    voobj.parentHashID = nil;
    voobj.startTime = nil;
    voobj.timeFillingMode = nil;
    voobj.timeTrimingMode = nil;
    voobj.type = nil;
    voobj.width = nil;
}

void CDVideoOverlayObjectPrint(CDVideoOverlayObject *voobj)
{
    NSLog(@"voobj.absoluteURLstring:%@",voobj.absoluteURLstring);
    NSLog(@"voobj.blendMode:%@",voobj.blendMode);
    NSLog(@"voobj.duration:%@",voobj.duration);
    NSLog(@"voobj.exist:%@",voobj.exist);
    NSLog(@"voobj.height:%@",voobj.height);
    NSLog(@"voobj.movingPathCGpointXs:%@",voobj.movingPathCGpointXs);
    NSLog(@"voobj.movingPathCGpointYs:%@",voobj.movingPathCGpointYs);
    NSLog(@"voobj.movingSectionDurations:%@",voobj.movingSectionDurations);
    NSLog(@"voobj.parentHashID:%@",voobj.parentHashID);
    NSLog(@"voobj.startTime:%@",voobj.startTime);
    NSLog(@"voobj.temporary:%@",voobj.temporary);
    NSLog(@"voobj.timeFillingMode:%@",voobj.timeFillingMode);
    NSLog(@"voobj.timeTrimingMode:%@",voobj.timeTrimingMode);
    NSLog(@"voobj.type:%@",voobj.type);
    NSLog(@"voobj.width:%@",voobj.width);
    NSLog(@"voobj.scene:%@",voobj.scene);
    NSLog(@"voobj.videoLocalRender:%@",voobj.videoLocalRender);
}
