//
//  CDVideoTitlesObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDVideoTitlesObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoTitlesObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSNumber *parentHashID;
@property (nullable, nonatomic, retain) NSNumber *temporary;
@property (nullable, nonatomic, retain) NSString *timeFillingMode;
@property (nullable, nonatomic, retain) NSString *timeTrimingMode;
@property (nullable, nonatomic, retain) NSString *titlesURLstring;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) CDSceneObject *scene;

@end

NS_ASSUME_NONNULL_END
