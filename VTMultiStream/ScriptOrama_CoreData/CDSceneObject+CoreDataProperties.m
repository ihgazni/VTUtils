//
//  CDSceneObject+CoreDataProperties.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDSceneObject+CoreDataProperties.h"

@implementation CDSceneObject (CoreDataProperties)

@dynamic anchorOnSelfXpostLowerThird;
@dynamic anchorOnSelfYpostLowerThird;
@dynamic averageBitRateForCompressing;
@dynamic backgroundSizeX;
@dynamic backgroundSizeY;
@dynamic bgImageURLstring;
@dynamic categoryId;
@dynamic compositionMode;
@dynamic coverImgUrl;
@dynamic creatorId;
@dynamic demoVideoUrl;
@dynamic descs;
@dynamic editMode;
@dynamic expectedTotalDuration;
@dynamic filterPostCompositionDuration;
@dynamic filterPostCompositionExist;
@dynamic filterPostCompositionName;
@dynamic filterPostCompositionStartTime;
@dynamic finalOutputCGsizeX;
@dynamic finalOutputCGsizeY;
@dynamic geomTransformPostLowerThirdExist;
@dynamic interleaveInterval;
@dynamic interleaveMode;
@dynamic lowerThirdPostOverlayExist;
@dynamic musicPostBackgroundIntergrationExist;
@dynamic name;
@dynamic objectId;
@dynamic overlayPostCompositionFilterExist;
@dynamic parentHashID;
@dynamic postBGTempURLstring;
@dynamic rotationDegreePostLowerThird;
@dynamic sizeXpostLowerThird;
@dynamic sizeYpostLowerThird;
@dynamic temporary;
@dynamic textOverBackgroundExist;
@dynamic titlesExist;
@dynamic transitionModes;
@dynamic transitionSectionDurations;
@dynamic videoCount;
@dynamic xOnBGPostLowerThird;
@dynamic yOnBGPostLowerThird;
@dynamic lowerThirdPostOverlay;
@dynamic musicPostBGIntergration;
@dynamic overlayPostCompositionFilter;
@dynamic tail;
@dynamic textOverBG;
@dynamic titles;
@dynamic task;

@end




@implementation transitionModes
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



@implementation transitionSectionDurations
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
