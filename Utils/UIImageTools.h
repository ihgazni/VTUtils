//
//  UIImageTools.h
//  UView
//
//  Created by dli on 1/4/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#ifndef UIImageTools_h
#define UIImageTools_h


#endif /* UIImageTools_h */

#import <Foundation/Foundation.h>


@interface UIImageTools:NSObject

UIImage * imageResize(UIImage *image, CGSize newSize);
UIImage * imageCrop(UIImage * image,CGRect rect);
UIImage * geomPlaceImagesWithWidth(NSMutableArray* origianlImgs,CGSize finalSize);
CVImageBufferRef UIImageToCVImageBuffer(UIImage* uimg);
CVImageBufferRef CGImageRefToCVImageBuffer(CGImageRef cgimg);

@end


