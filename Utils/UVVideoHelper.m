//
//  UVVideoHelper.m
//  UView
//
//  Created by zorro on 15/8/23.
//  Copyright (c) 2015年 YesView. All rights reserved.
//

#import "UVVideoHelper.h"

@implementation UVVideoHelper

+ (NSInteger)totalSecondsOfVideos:(NSArray *)videos {
    __block NSTimeInterval totalDuration = 0.f;
    
    [videos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAsset *asset = obj;
        
        totalDuration += asset.duration;
    }];
    
    return (NSInteger)totalDuration;
}

+ (NSString *)totalTimeOfVideos:(NSArray *)videos {
    NSInteger seconds = [self totalSecondsOfVideos:videos];
    
    long min = seconds/60;
    long second = seconds%60;
    
    NSString *time = [NSString stringWithFormat:@"%02ld:%02ld", min, second];
    
    return time;
}

+ (void)generatThumbnailForAsset:(PHAsset *)videoAsset
                        withSize:(CGSize)size
                      completion:(void (^)(UIImage *image))completion {

    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    [imageManager requestImageForAsset:videoAsset
                            targetSize:size
                           contentMode:PHImageContentModeDefault
                               options:[[PHImageRequestOptions alloc] init]
                         resultHandler:^void(UIImage *image, NSDictionary *info) {
                             if (completion) {
                                 completion(image);
                             }
                         }];
}

+ (UIImage *)movieFirstFrameImageFromURL:(NSURL *)videoURL {
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(10, 10) actualTime:NULL error:nil];
    UIImage *image = [UIImage imageWithCGImage:img];
    CGImageRelease(img);
    
    return image;
}

+ (UIImage *)gaussImage:(UIImage *)image {
    //高斯模糊效果
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:image];
    
    // create gaussian blur filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
    
    // blur image
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return resultImage;
}

@end
