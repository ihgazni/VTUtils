//
//  CDVideoLowerThirdObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDVideoLowerThirdObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoLowerThirdObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bgImageURLstring;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSNumber *fontColorA;
@property (nullable, nonatomic, retain) NSNumber *fontColorB;
@property (nullable, nonatomic, retain) NSNumber *fontColorG;
@property (nullable, nonatomic, retain) NSNumber *fontColorR;
@property (nullable, nonatomic, retain) NSString *fontFamily;
@property (nullable, nonatomic, retain) NSNumber *fontSize;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSNumber *parentHashID;
@property (nullable, nonatomic, retain) NSString *petName;
@property (nullable, nonatomic, retain) NSNumber *startTime;
@property (nullable, nonatomic, retain) NSNumber *temporary;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) NSNumber *xOnVideo;
@property (nullable, nonatomic, retain) NSNumber *yOnVideo;
@property (nullable, nonatomic, retain) CDSceneObject *scene;

@end

NS_ASSUME_NONNULL_END
