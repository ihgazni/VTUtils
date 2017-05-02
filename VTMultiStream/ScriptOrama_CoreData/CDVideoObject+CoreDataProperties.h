//
//  CDVideoObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDVideoObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *effct;
@property (nonatomic) float endTime;
@property (nonatomic) int64_t height;
@property (nonatomic) BOOL isMagic;
@property (nonatomic) BOOL isTask;
@property (nonatomic) BOOL isUploaded;
@property (nonatomic) int64_t length;
@property (nullable, nonatomic, retain) NSString *makerId;
@property (nonatomic) int64_t order;
@property (nonatomic) int64_t parentHashID;
@property (nonatomic) int64_t sourceType;
@property (nonatomic) float startTime;
@property (nonatomic) BOOL temporary;
@property (nullable, nonatomic, retain) NSString *videoId;
@property (nonatomic) int64_t width;
@property (nullable, nonatomic, retain) CDVideoLocalRenderObject *videoLocalRender;
@property (nullable, nonatomic, retain) CDTaskObject *task;

@end

NS_ASSUME_NONNULL_END
