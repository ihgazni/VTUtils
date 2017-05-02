//
//  FileUtil.h
//  UView
//
//  Created by dli on 12/23/15.
//  Copyright © 2015 YesView. All rights reserved.
//

#ifndef FileUtil_h
#define FileUtil_h


#endif /* FileUtil_h */


#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface FileUitl : NSObject

+(NSString *)bundlePath:(NSString *)fileName;
+(NSString *)documentsPath:(NSString *)fileName;

+(NSString*)getFullPathOfDocs:(NSString*)path;
+(NSString*)getFullPathOfTmp:(NSString*)path;







+(NSURL*)getFullPathURLOfDocs:(NSString*)path;
+(NSURL*)getFullPathURLOfTmp:(NSString*)path;


+(NSString*)deleteSubDirOfDocs:(NSString*)dirName;
+(NSString*)deleteSubDirOfTmp:(NSString*)dirName;
+(NSString*)creatSubDirOfDocs:(NSString*)dirName;
+(NSString*)creatSubDirOfTmp:(NSString*)dirName;









+(NSString*)deleteSpecificFilesOfSubDirOfDocs:(NSString*)fileNamePattern dirName:(NSString*)dirName;
+(NSString*)deleteSpecificFilesOfSubDirOfTmp:(NSString*)fileNamePattern dirName:(NSString*)dirName;





+(NSString*)saveUIImageToDocsFile:(UIImage*)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality;
+(NSString*)saveUIImageToTmpFile:(UIImage*)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality;

+(void)deleteTmpFile:(NSString*)tmpFullPath;
+(void)deleteDocFile:(NSString*)docFullPath;
+(void)deleteFile:(NSString*)fullPath;

+ (NSString *)saveImageFromALAssetUrlToDocsFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName;
+ (NSString *)saveImageFromALAssetUrlToTmpFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName;


+ (NSString *)saveVideoFromALAssetUrlToDocsFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName;
+ (NSString *)saveVideoFromALAssetUrlToTmpFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName;


+(NSMutableArray *) getAllFileABSPathsOfAlbumSortedViaDate;

+(void)writeVideoToPhotoLibrary:(NSURL *)url;

+(NSURL *)creatSandboxTmpURLForPhotoLibrary:(NSString *)dirName ALAssetDict:(NSMutableDictionary *)ALAssetDict;


+(NSMutableArray*)getSpecificFilePathsOfSubDirOfDocs:(NSString*)fileNamePattern dirName:(NSString*)dirName;
+(NSMutableArray*)getSpecificFilePathsOfSubDirOfTmp:(NSString *)fileNamePattern dirName:(NSString *)dirName;


+(void) printNSRange:(NSRange )range;
+(void) printNSTextCheckingResult:(NSTextCheckingResult * )match;
+(void) printNSRegularExpressionMatchesInString:(NSArray *)matches;

+(NSString*)syncedSaveUIImageToTmpFile:(UIImage*)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality;
+(NSString*)saveCGImageToTmpFile:(CGImageRef)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality;

+ (void)copyFileFrom:(NSString*)resourcePath To:(NSString*)destPath;

+(NSString *)getFullPathUnderResource:(NSString*)filename;
+(NSString *)getFullPathUnderCache:(NSString*)filename;


+(NSString*)deleteSubDir:(NSString*)myDirectory;
+(NSString*)creatSubDir:(NSString*)myDirectory;

+(NSMutableDictionary *)getNSStringFromFile:(NSString *)filePath from:(int)from;
+(NSMutableDictionary *)getNSStringFromDataViaCFString:(NSData *)data from:(int)from;
+(void)writeJSONtoFile:(id)userDetails filePath:(NSString *)filePath;
+(id)loadJSONfromFile:(NSString *)filePath;

+(NSMutableDictionary *)kv2vks:(NSMutableDictionary *)kv;
+(void)addDict:(NSMutableDictionary *)dict1 toDict:(NSMutableDictionary *)dict2;
+(float)strSimilarRatio:(NSString*)str1 toStr:(NSString*)str2;
+(NSMutableArray *)findAllFileNamesWithPattern:(NSString*)dirPath withPattern:(NSString*)pattern;

+(NSString*)saveUIImageToFile:(UIImage*)image filePath:(NSString*)filePath  format:(NSString*)format jpegQuality:(float)quality;

+(NSMutableDictionary * )gcd:(NSMutableArray * )nums;

+(void)showNSManagedObject:(NSManagedObject *)obj;

+(NSString*)deleteSpecificFilesOfSubDir:(NSString *)fileNamePattern dirName:(NSString *)dirName;
+(NSMutableArray*)findSpecificFileURLsOfSubDir:(NSString *)fileNamePattern dirName:(NSString *)dirName;
+(Byte *) copyNSDataToByteData:(NSData * )bufferMono;


NSString * getCurrAPPIDInPath();
void printNSUserDefaults(NSUserDefaults*defaults);
@end