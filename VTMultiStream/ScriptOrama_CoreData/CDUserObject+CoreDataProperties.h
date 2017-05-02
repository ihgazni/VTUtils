//
//  CDUserObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDUserObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDUserObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *avatarUri;
@property (nullable, nonatomic, retain) NSString *bgUrl;
@property (nullable, nonatomic, retain) NSString *geo;
@property (nullable, nonatomic, retain) NSNumber *isFollower;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *parentHashID;
@property (nullable, nonatomic, retain) NSString *petName;
@property (nullable, nonatomic, retain) NSString *sex;
@property (nullable, nonatomic, retain) NSString *signature;
@property (nullable, nonatomic, retain) NSNumber *temporary;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) CDTaskObject *task;

@end

NS_ASSUME_NONNULL_END
