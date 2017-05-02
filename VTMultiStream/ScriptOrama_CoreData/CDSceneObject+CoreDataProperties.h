//
//  CDSceneObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDSceneObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDSceneObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *anchorOnSelfXpostLowerThird;
@property (nullable, nonatomic, retain) NSNumber *anchorOnSelfYpostLowerThird;
@property (nullable, nonatomic, retain) NSNumber *averageBitRateForCompressing;
@property (nullable, nonatomic, retain) NSNumber *backgroundSizeX;
@property (nullable, nonatomic, retain) NSNumber *backgroundSizeY;
@property (nullable, nonatomic, retain) NSString *bgImageURLstring;
@property (nullable, nonatomic, retain) NSString *categoryId;
@property (nullable, nonatomic, retain) NSString *compositionMode;
@property (nullable, nonatomic, retain) NSString *coverImgUrl;
@property (nullable, nonatomic, retain) NSString *creatorId;
@property (nullable, nonatomic, retain) NSString *demoVideoUrl;
@property (nullable, nonatomic, retain) NSString *descs;
@property (nullable, nonatomic, retain) NSString *editMode;
@property (nullable, nonatomic, retain) NSNumber *expectedTotalDuration;
@property (nullable, nonatomic, retain) NSNumber *filterPostCompositionDuration;
@property (nullable, nonatomic, retain) NSNumber *filterPostCompositionExist;
@property (nullable, nonatomic, retain) NSString *filterPostCompositionName;
@property (nullable, nonatomic, retain) NSNumber *filterPostCompositionStartTime;
@property (nullable, nonatomic, retain) NSNumber *finalOutputCGsizeX;
@property (nullable, nonatomic, retain) NSNumber *finalOutputCGsizeY;
@property (nullable, nonatomic, retain) NSNumber *geomTransformPostLowerThirdExist;
@property (nullable, nonatomic, retain) NSNumber *interleaveInterval;
@property (nullable, nonatomic, retain) NSString *interleaveMode;
@property (nullable, nonatomic, retain) NSNumber *lowerThirdPostOverlayExist;
@property (nullable, nonatomic, retain) NSNumber *musicPostBackgroundIntergrationExist;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *overlayPostCompositionFilterExist;
@property (nullable, nonatomic, retain) NSNumber *parentHashID;
@property (nullable, nonatomic, retain) NSString *postBGTempURLstring;
@property (nullable, nonatomic, retain) NSNumber *rotationDegreePostLowerThird;
@property (nullable, nonatomic, retain) NSNumber *sizeXpostLowerThird;
@property (nullable, nonatomic, retain) NSNumber *sizeYpostLowerThird;
@property (nullable, nonatomic, retain) NSNumber *temporary;
@property (nullable, nonatomic, retain) NSNumber *textOverBackgroundExist;
@property (nullable, nonatomic, retain) NSNumber *titlesExist;
@property (nullable, nonatomic, retain) id transitionModes;
@property (nullable, nonatomic, retain) id transitionSectionDurations;
@property (nullable, nonatomic, retain) NSNumber *videoCount;
@property (nullable, nonatomic, retain) NSNumber *xOnBGPostLowerThird;
@property (nullable, nonatomic, retain) NSNumber *yOnBGPostLowerThird;
@property (nullable, nonatomic, retain) CDVideoLowerThirdObject *lowerThirdPostOverlay;
@property (nullable, nonatomic, retain) CDAudioSceneMusicObject *musicPostBGIntergration;
@property (nullable, nonatomic, retain) CDVideoOverlayObject *overlayPostCompositionFilter;
@property (nullable, nonatomic, retain) CDVideoTailObject *tail;
@property (nullable, nonatomic, retain) CDVideoTextOverBackGroundObject *textOverBG;
@property (nullable, nonatomic, retain) CDVideoTitlesObject *titles;
@property (nullable, nonatomic, retain) CDTaskObject *task;

@end

NS_ASSUME_NONNULL_END


@interface transitionModes: NSValueTransformer
@end

@interface transitionSectionDurations: NSValueTransformer
@end


