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


+ (NSString *)saveImageFromALAssetUrlToDocsFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName;
+ (NSString *)saveImageFromALAssetUrlToTmpFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName;


+ (NSString *)saveVideoFromALAssetUrlToDocsFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName;
+ (NSString *)saveVideoFromALAssetUrlToTmpFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName;


+(NSMutableArray *) getAllFileABSPathsOfAlbumSortedViaDate;

+(void)writeVideoToPhotoLibrary:(NSURL *)url;

+(NSURL *)creatSandboxTmpURLForPhotoLibrary:(NSString *)dirName ALAssetDict:(NSMutableDictionary *)ALAssetDict;


+(NSMutableArray*)getSpecificFilePathsOfSubDirOfDocs:(NSString*)fileNamePattern dirName:(NSString*)dirName;
+(NSMutableArray*)getSpecificFilePathsOfSubDirOfTmp:(NSString *)fileNamePattern dirName:(NSString *)dirName;

@end