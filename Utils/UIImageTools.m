//
//  UIImageTools.m
//  UView
//
//  Created by dli on 1/4/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageTools.h"

@implementation UIImageTools

UIImage * imageResize(UIImage *image, CGSize newSize)
{
    /*
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
     */
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



inline double rad(double deg)
{
    return deg / 180.0 * M_PI;
}

UIImage * imageCrop(UIImage* img, CGRect rect)
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, img.scale, img.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:img.scale orientation:img.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}



UIImage * geomPlaceImagesWithWidth(NSMutableArray* origianlImgs,CGSize finalSize)
{
    
    
    UIImage * viewImage = nil ;
    

    NSLog(@"originalImgs.count:%lu",(unsigned long)origianlImgs.count);
    
    
    float x = 0.0;
    UIImage * img;
    ////UIImageView * imgV;
    
    
    UIGraphicsBeginImageContext(finalSize);
    
    
    for (int i=0; i<origianlImgs.count; i++) {
        
        NSLog(@"x:%lf",x);
        img = (UIImage *)origianlImgs[i];
        
        if((x+img.size.width)>finalSize.width){
            break;
        }
        
        [img drawInRect:CGRectMake(x, 0, img.size.width, img.size.height)];
        x = x + img.size.width;

    }
    
    

    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
   
    UIGraphicsEndImageContext();
    
    
    
    return viewImage;
    
    
    
    
}




CVImageBufferRef UIImageToCVImageBuffer(UIImage* uimg)
{
    /*
     If you do a search on CVPixelBufferRef in the Xcode docs, you'll find the following:
     typedef CVImageBufferRef CVPixelBufferRef;
     So a CVImageBufferRef is a synonym for a CVPixelBufferRef. They are interchangeable.
     */
    
    CGImageRef cgimg=[uimg CGImage];
    
    CGSize frameSize = CGSizeMake(CGImageGetWidth(cgimg), CGImageGetHeight(cgimg));
    NSDictionary *options = @{
                              (__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey: @(NO),
                              (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(NO)
                              };
    CVPixelBufferRef pixelBuffer;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height,
                                                 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
                                                 (CGBitmapInfo) kCGImageAlphaPremultipliedFirst);
    //kCGImageAlphaNoneSkipLast
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(cgimg),
                                           CGImageGetHeight(cgimg)), cgimg);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return(pixelBuffer);
    
}



CVImageBufferRef CGImageRefToCVImageBuffer(CGImageRef cgimg)
{
    /*
     If you do a search on CVPixelBufferRef in the Xcode docs, you'll find the following:
     typedef CVImageBufferRef CVPixelBufferRef;
     So a CVImageBufferRef is a synonym for a CVPixelBufferRef. They are interchangeable.
     */
    
    
    CGSize frameSize = CGSizeMake(CGImageGetWidth(cgimg), CGImageGetHeight(cgimg));
    NSDictionary *options = @{
                              (__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey: @(NO),
                              (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(NO)
                              };
    CVPixelBufferRef pixelBuffer;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height,
                                                 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
                                                 (CGBitmapInfo) kCGImageAlphaPremultipliedFirst);
    //kCGImageAlphaNoneSkipLast
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(cgimg),
                                           CGImageGetHeight(cgimg)), cgimg);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return(pixelBuffer);
    
}



@end