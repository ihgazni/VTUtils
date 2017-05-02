//
//  UVLooper.h
//  UView
//
//  Created by JinHao on 10/5/15.
//  Copyright © 2015 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVLooper : NSObject

+ (void)loop:(NSUInteger)count action:(void (^)())action;

@end
