//
//  UVLooper.m
//  UView
//
//  Created by JinHao on 10/5/15.
//  Copyright © 2015 YesView. All rights reserved.
//

#import "UVLooper.h"

@implementation UVLooper

+ (void)loop:(NSUInteger)count action:(void (^)())action {
    for (int i = 0; i < count; i ++) {
        action();
    }
}

@end
