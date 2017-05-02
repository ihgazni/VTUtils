//
//  CDVideoLocalRenderObject+CoreDataProperties.h
//  UView
//
//  Created by dli on 5/3/16.
//  Copyright © 2016 YesView. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDVideoLocalRenderObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDVideoLocalRenderObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cropPositionOnOriginalMaterialX;
@property (nullable, nonatomic, retain) NSNumber *cropPositionOnOriginalMaterialY;
@property (nullable, nonatomic, retain) NSNumber *cropSizeX;
@property (nullable, nonatomic, retain) NSNumber *cropSizeY;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSString *filter;
@property (nullable, nonatomic, retain) NSString *origAudioWorkDirURLstring;
@property (nullable, nonatomic, retain) NSString *origThumbnailURLstring;
@property (nullable, nonatomic, retain) NSString *origURLstring;
@property (nullable, nonatomic, retain) NSString *origVideoWorkDirURLstring;
@property (nullable, nonatomic, retain) NSNumber *parentHashID;
@property (nullable, nonatomic, retain) NSString *postCuttingAudioWorkDirURLstring;
@property (nullable, nonatomic, retain) NSString *postCuttingThumbnailURLstring;
@property (nullable, nonatomic, retain) NSString *postCuttingURLstring;
@property (nullable, nonatomic, retain) NSString *postCuttingVideoWorkDirURLstring;
@property (nullable, nonatomic, retain) NSString *postFilteringAudioWorkDirURLstring;
@property (nullable, nonatomic, retain) NSString *postFilteringThumbnailURLstring;
@property (nullable, nonatomic, retain) NSString *postFilteringURLstring;
@property (nullable, nonatomic, retain) NSString *postFilteringVideoWorkDirURLstring;
@property (nullable, nonatomic, retain) NSNumber *postRenderSizeX;
@property (nullable, nonatomic, retain) NSNumber *postRenderSizeY;
@property (nullable, nonatomic, retain) NSString *postRenderTempSavingURLstring;
@property (nullable, nonatomic, retain) NSNumber *savePostCutting;
@property (nullable, nonatomic, retain) NSNumber *savePostFiltering;
@property (nullable, nonatomic, retain) NSNumber *startTime;
@property (nullable, nonatomic, retain) NSNumber *temporary;
@property (nullable, nonatomic, retain) NSNumber *timeStampInScene;
@property (nullable, nonatomic, retain) NSString *origFromAlbumURLstring;
@property (nullable, nonatomic, retain) NSString *origFromAlbumAudioWorkDirURLstring;
@property (nullable, nonatomic, retain) NSString *origFromAlbumVideoWorkDirURLstring;
@property (nullable, nonatomic, retain) CDVideoObject *video;
@property (nullable, nonatomic, retain) CDVideoOverlayObject *videoOverlay;

@end

NS_ASSUME_NONNULL_END
