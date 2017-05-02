//
//  CDVideoOverlayObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDVideoOverlayObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoOverlayObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *absoluteURLstring;
@property (nullable, nonatomic, retain) NSString *blendMode;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSNumber *exist;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) id movingPathCGpointXs;
@property (nullable, nonatomic, retain) id movingPathCGpointYs;
@property (nullable, nonatomic, retain) id movingSectionDurations;
@property (nullable, nonatomic, retain) NSNumber *parentHashID;
@property (nullable, nonatomic, retain) NSNumber *startTime;
@property (nullable, nonatomic, retain) NSNumber *temporary;
@property (nullable, nonatomic, retain) NSString *timeFillingMode;
@property (nullable, nonatomic, retain) NSString *timeTrimingMode;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) CDSceneObject *scene;
@property (nullable, nonatomic, retain) CDVideoLocalRenderObject *videoLocalRender;

@end

NS_ASSUME_NONNULL_END


@interface MovingPathCGpointXs: NSValueTransformer
@end

@interface MovingPathCGpointYs: NSValueTransformer
@end

@interface MovingSectionDurations: NSValueTransformer
@end

