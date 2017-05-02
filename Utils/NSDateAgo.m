//
//  NSDate+Ago.m
//  LCAppliances
//
//  Created by Baby on 14-5-4.
//  Copyright (c) 2014年 *****. All rights reserved.
//

#import "NSDateAgo.h"

@implementation NSDateAgo


+ (NSString*)intervalSinceNowFromDate: (NSDate *)theDate
{
    //取到的时间是 UTC时区  比服务器存储的createAt 字段慢8小时
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [NSDate date];
    NSDate *yesterday;

    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];

    NSString * dateString = [[theDate description] substringToIndex:10];
    if([dateString isEqualToString:yesterdayString]){
       return NSLocalizedString(@"昨天", nil);
    }
 
    NSDate *d = theDate;
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha= now - late;
    
  
 
    
    //发表在1小时之内
    if(cha / 3600 < 1) {
        //发表时间在1分钟之内
        if(cha / 60 < 1) {
            
            timeString = [NSString stringWithFormat:@"%f", cha];
            timeString = [timeString substringToIndex:timeString.length-7];
            timeString=[NSString stringWithFormat:@"%@秒钟前", timeString];
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
            timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        }
        
        
    }
    //在一小时以上24小以内
    else if(cha / 3600 > 1 && cha / 86400 < 1) {
        timeString = [NSString stringWithFormat:@"%f", cha / 3600];
        timeString = [timeString substringToIndex:timeString.length - 7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    //发表在24以上7天以内
    else if(cha / 86400 > 1 && cha / 518400 < 1)
    {
        timeString = [NSString stringWithFormat:@"%f", 1.0 + (cha / 86400)];
        timeString = [timeString substringToIndex:timeString.length - 7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    //发表时间大于7天
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        timeString = [dateFormatter stringFromDate:theDate];
    }
    
    return timeString;
    
}

@end
