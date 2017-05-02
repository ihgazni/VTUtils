//
//  NSDate+Ago.h
//  LCAppliances
//
//  Created by Baby on 14-5-4.
//  Copyright (c) 2014年 *****. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateAgo : NSObject
+ (NSString*)intervalSinceNowFromDate: (NSDate *) theDate;
@end
