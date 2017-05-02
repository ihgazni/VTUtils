//
//  CDAudioSceneMusicObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDAudioSceneMusicObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDAudioSceneMusicObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *animationDuration;
@property (nullable, nonatomic, retain) NSNumber *animationStartTime;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSString *mixMode;
@property (nullable, nonatomic, retain) NSString *musicURLstring;
@property (nullable, nonatomic, retain) NSNumber *parentHashID;
@property (nullable, nonatomic, retain) NSNumber *startTime;
@property (nullable, nonatomic, retain) NSNumber *temporary;
@property (nullable, nonatomic, retain) NSString *timeFillingMode;
@property (nullable, nonatomic, retain) NSString *timeTrimingMode;
@property (nullable, nonatomic, retain) NSNumber *volumeRatio;
@property (nullable, nonatomic, retain) NSNumber *volumeSumWithOriginalVolume;
@property (nullable, nonatomic, retain) CDSceneObject *scene;

@end

NS_ASSUME_NONNULL_END
