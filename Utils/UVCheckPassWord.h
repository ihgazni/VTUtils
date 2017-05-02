//
//  UVCheckPassWord.h
//  UView
//
//  Created by WEICAO on 15/7/11.
//  Copyright (c) 2015年 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVCheckPassWord : NSObject
+ (BOOL) judgeRange:(NSArray*) _termArray Password:(NSString*) _password;

+ (BOOL) judgePasswordStrength:(NSString*) _password;
@end
