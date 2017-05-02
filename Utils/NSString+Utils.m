//
//  NSString+Utils.m
//  YesView
//
//  Created by JinHao on 5/19/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Utils)

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);

    NSMutableString *md5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5 appendFormat:@"%02x", result[i]];
    }

    return md5;
}

- (NSString *)relativePath
{
    NSString *sandboxPath = NSHomeDirectory();
    if ([self hasPrefix:sandboxPath]) {
        return [self substringFromIndex:sandboxPath.length];
    }
    
    return self;
}

- (NSString *)fullPath
{
    NSString *sandboxPath = NSHomeDirectory();
    if (![self hasPrefix:sandboxPath]) {
        return [sandboxPath stringByAppendingString:self];
    }
    
    return self;
}




////-dli
- (NSString *)binStrToHexStr
{
    
    NSString * strBinary = [self uppercaseString];
    NSString *strResult = @"";
    NSDictionary *dictBinToHax = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"0",@"0000",
                                  @"1",@"0001",
                                  @"2",@"0010",
                                  @"3",@"0011",
                                  @"4",@"0100",
                                  @"5",@"0101",
                                  @"6",@"0110",
                                  @"7",@"0111",
                                  @"8",@"1000",
                                  @"9",@"1001",
                                  @"A",@"1010",
                                  @"B",@"1011",
                                  @"C",@"1100",
                                  @"D",@"1101",
                                  @"E",@"1110",
                                  @"F",@"1111", nil];
    
    for (int i = 0;i < [strBinary length]; i+=4)
    {
        NSString *strBinaryKey = [strBinary substringWithRange: NSMakeRange(i, 4)];
        strResult = [NSString stringWithFormat:@"%@%@",strResult,[dictBinToHax valueForKey:strBinaryKey]];
    }
    return  strResult;
}


-(NSString *) hexStrToBinStr
{
    
    NSString * strHex = [self uppercaseString];
    NSString *strResult = @"";
    NSDictionary *dictHexToBin = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"0000",@"0",
                                  @"0001",@"1",
                                  @"0010",@"2",
                                  @"0011",@"3",
                                  @"0100",@"4",
                                  @"0101",@"5",
                                  @"0110",@"6",
                                  @"0111",@"7",
                                  @"1000",@"8",
                                  @"1001",@"9",
                                  @"1010",@"A",
                                  @"1011",@"B",
                                  @"1100",@"C",
                                  @"1101",@"D",
                                  @"1110",@"E",
                                  @"1111",@"F",
                                  nil];
    
    for (int i = 0;i < [strHex length]; i+=1)
    {
        NSString *strHexKey = [strHex substringWithRange: NSMakeRange(i, 1)];
        strResult = [NSString stringWithFormat:@"%@%@",strResult,[dictHexToBin valueForKey:strHexKey]];
    }
    return  strResult;
}



-(unsigned int) hexStrToInt
{
    NSString* pString = self;
    NSScanner* pScanner = [NSScanner scannerWithString: pString];
    
    unsigned int iValue;
    [pScanner scanHexInt: &iValue];
    
    return(iValue);
}


-(unsigned int) binStrToInt
{
    NSString* pString = [self hexStrToBinStr];
    NSScanner* pScanner = [NSScanner scannerWithString: pString];
    
    unsigned int iValue;
    [pScanner scanHexInt: &iValue];
    
    return(iValue);
}





-(NSString *) hexStrToASCIIStr
{
    NSMutableArray * arr_1 = [[NSMutableArray alloc] init];
    NSString * ele;
    int temp;
    NSUInteger selfLen = [self length];
    for (int i = 0; i < selfLen; i=i+2) {
        temp = [[self substringWithRange:NSMakeRange(i, 2)] hexStrToInt];
        ele = [NSString stringWithFormat:@"%c", temp];
        [arr_1 addObject:ele];
    }
    
    NSString * rslt = @"";
    for (int i = 0; i < arr_1.count; i=i+1) {
        rslt = [rslt stringByAppendingString:arr_1[i]];
    }
    
    return(rslt);
}


-(NSString *) ASCIIStrToHexStr
{
    NSMutableArray * arr_1 = [[NSMutableArray alloc] init];
    NSString * ele;
    int asciiCode;
    NSUInteger selfLen = [self length];
    for (int i = 0; i < selfLen; i=i+1) {
        ele = [self substringWithRange:NSMakeRange(i, 1)];
        asciiCode = [ele characterAtIndex:0];
        ele = [NSString stringWithFormat:@"%02X", asciiCode];
        [arr_1 addObject:ele];
    }
    
    NSString * rslt = @"";
    for (int i = 0; i < arr_1.count; i=i+1) {
        rslt = [rslt stringByAppendingString:arr_1[i]];
    }
    
    return(rslt);
}


- (BOOL) containsString: (NSString*) substring
{
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}



-(NSString *)trimLeft:(NSString*)charSetToTrim
{
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *zeros = [NSCharacterSet
                             characterSetWithCharactersInString:charSetToTrim];
    [scanner scanCharactersFromSet:zeros intoString:NULL];
    
    return [self substringFromIndex:[scanner scanLocation]];
}


-(NSString *)trimRight:(NSString*)charSetToTrim
{
    NSUInteger len = [self length];
    unsigned long location = len - 1;
    for (int i = (int)len - 1; i>=0 ; i--) {
        if ( [charSetToTrim containsString:[self substringWithRange:NSMakeRange(i, 1)]] ) {
            location = location - 1;
        } else {
            break;
        }
    }
    return([self substringToIndex:location]);
}


- (NSString *)repeatTimes:(NSUInteger)times
{
    return [@"" stringByPaddingToLength:times * [self length] withString:self startingAtIndex:0];
}





////-dli





@end

@implementation NSString (UVFormat)

+ (NSString *)formattedTimeStringFromSeconds:(NSInteger)seconds
{
    NSInteger min = seconds / 60;
    NSInteger sec = seconds - 60 * min;
    return [NSString stringWithFormat:@"%02li:%02li", (long)min, (long)sec];
}

@end
