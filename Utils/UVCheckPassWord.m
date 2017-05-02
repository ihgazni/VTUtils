//
//  UVCheckPassWord.m
//  UView
//
//  Created by WEICAO on 15/7/11.
//  Copyright (c) 2015年 YesView. All rights reserved.
//

#import "UVCheckPassWord.h"

@implementation UVCheckPassWord

+ (BOOL) judgeRange:(NSArray*) _termArray Password:(NSString*) _password

{
    
    NSRange range;
    
    BOOL result =NO;
    
    for(int i=0; i<[_termArray count]; i++)
        
    {
        
        range = [_password rangeOfString:[_termArray objectAtIndex:i]];
        
        if(range.location != NSNotFound)
            
        {
            
            result =YES;
            
        }
        
    }
    
    return result;
    
}

//条件

+ (BOOL) judgePasswordStrength:(NSString*) _password

{
    
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    
    
    
    NSArray* termArray1 = [[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    
    NSArray* termArray2 = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", nil];
    
    NSArray* termArray3 = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    NSArray* termArray4 = [[NSArray alloc] initWithObjects:@"~",@"`",@"@",@"#",@"$",@"%",@"^",@"&",@"*",@"(",@")",@"-",@"_",@"+",@"=",@"{",@"}",@"[",@"]",@"|",@":",@";",@"“",@"'",@"‘",@"<",@",",@".",@">",@"?",@"/",@"、", nil];
    
    
    
    NSString* result1 = [NSString stringWithFormat:@"%d",[self judgeRange:termArray1 Password:_password]];
    
    NSString* result2 = [NSString stringWithFormat:@"%d",[self judgeRange:termArray2 Password:_password]];
    
    NSString* result3 = [NSString stringWithFormat:@"%d",[self judgeRange:termArray3 Password:_password]];
    
    NSString* result4 = [NSString stringWithFormat:@"%d",[self judgeRange:termArray4 Password:_password]];
    
    
    
    [resultArray addObject:[NSString stringWithFormat:@"%@",result1]];
    
    [resultArray addObject:[NSString stringWithFormat:@"%@",result2]];
    
    [resultArray addObject:[NSString stringWithFormat:@"%@",result3]];
    
    [resultArray addObject:[NSString stringWithFormat:@"%@",result4]];
    
    
    
    int intResult=0;
    
    for (int j=0; j<[resultArray count]; j++)
        
    {
        
        
        
        if ([[resultArray objectAtIndex:j] isEqualToString:@"1"])
            
        {
            
            intResult++;
            
        }
        
    }
    
    
    if (intResult > 3 &&[_password length]>=6)
        
    {
        
        return YES;
        
    }
    
    
    
    return NO;
    
}
@end
