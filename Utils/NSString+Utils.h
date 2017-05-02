//
//  NSString+Utils.h
//  YesView
//
//  Created by JinHao on 5/19/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (NSString *)trim;
- (NSString *)md5;

- (NSString *)relativePath;
- (NSString *)fullPath;

- (NSString *)binStrToHexStr;
- (NSString *)hexStrToBinStr;
- (unsigned int) hexStrToInt;
- (unsigned int) binStrToInt;
- (BOOL) containsString: (NSString*) substring;
- (NSString *)trimLeft:(NSString*)charSetToTrim;
- (NSString *)trimRight:(NSString*)charSetToTrim;
- (NSString *)repeatTimes:(NSUInteger)times;

- (NSString *) hexStrToASCIIStr;
- (NSString *) ASCIIStrToHexStr;

@end

@interface NSString (UVFormat)

+ (NSString *)formattedTimeStringFromSeconds:(NSInteger)seconds;

@end
