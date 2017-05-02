//
//  UVVideoHelper.h
//  UView
//
//  Created by zorro on 15/8/23.
//  Copyright (c) 2015年 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;

@interface UVVideoHelper : NSObject

+ (NSInteger)totalSecondsOfVideos:(NSArray *)videos;

+ (NSString *)totalTimeOfVideos:(NSArray *)videos;

+ (void)generatThumbnailForAsset:(PHAsset *)videoAsset
                        withSize:(CGSize)size
                      completion:(void (^)(UIImage *image))completion;

+ (UIImage *)gaussImage:(UIImage *)image;

@end
