//
//  NSDate+Format.m
//  UView
//
//  Created by JinHao on 7/20/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

- (NSString *)formatDateWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}

@end
