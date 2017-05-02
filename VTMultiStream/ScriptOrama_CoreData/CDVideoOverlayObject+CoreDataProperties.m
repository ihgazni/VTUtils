//
//  CDVideoOverlayObject+CoreDataProperties.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDVideoOverlayObject+CoreDataProperties.h"

@implementation CDVideoOverlayObject (CoreDataProperties)

@dynamic absoluteURLstring;
@dynamic blendMode;
@dynamic duration;
@dynamic exist;
@dynamic height;
@dynamic movingPathCGpointXs;
@dynamic movingPathCGpointYs;
@dynamic movingSectionDurations;
@dynamic parentHashID;
@dynamic startTime;
@dynamic temporary;
@dynamic timeFillingMode;
@dynamic timeTrimingMode;
@dynamic type;
@dynamic width;
@dynamic scene;
@dynamic videoLocalRender;

@end



@implementation MovingPathCGpointXs
+ (Class)transformedValueClass
{
    return [NSMutableArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}
@end

@implementation MovingPathCGpointYs
+ (Class)transformedValueClass
{
    return [NSMutableArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}
@end

@implementation MovingSectionDurations
+ (Class)transformedValueClass
{
    return [NSMutableArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}
@end


