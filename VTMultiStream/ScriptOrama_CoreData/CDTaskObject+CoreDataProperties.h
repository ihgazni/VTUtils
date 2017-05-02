//
//  CDTaskObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDTaskObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDTaskObject (CoreDataProperties)

@property (nonatomic) NSTimeInterval datetime;
@property (nullable, nonatomic, retain) NSString *descs;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nonatomic) int16_t type;
@property (nonatomic) int64_t videoCount;
@property (nullable, nonatomic, retain) CDSceneObject *scene;
@property (nullable, nonatomic, retain) CDUserObject *starter;
@property (nullable, nonatomic, retain) NSOrderedSet<CDVideoObject *> *videos;

@end

@interface CDTaskObject (CoreDataGeneratedAccessors)

- (void)insertObject:(CDVideoObject *)value inVideosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromVideosAtIndex:(NSUInteger)idx;
- (void)insertVideos:(NSArray<CDVideoObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeVideosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInVideosAtIndex:(NSUInteger)idx withObject:(CDVideoObject *)value;
- (void)replaceVideosAtIndexes:(NSIndexSet *)indexes withVideos:(NSArray<CDVideoObject *> *)values;
- (void)addVideosObject:(CDVideoObject *)value;
- (void)removeVideosObject:(CDVideoObject *)value;
- (void)addVideos:(NSOrderedSet<CDVideoObject *> *)values;
- (void)removeVideos:(NSOrderedSet<CDVideoObject *> *)values;

@end

NS_ASSUME_NONNULL_END
