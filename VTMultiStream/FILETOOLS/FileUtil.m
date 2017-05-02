//
//  FileUtil.m
//  UView
//
//  Created by dli on 12/23/15.
//  Copyright © 2015 YesView. All rights reserved.
//


#import "FileUtil.h"


@implementation FileUitl    

+(NSString *)bundlePath:(NSString *)fileName
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

+(NSString *)documentsPath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}




+(NSString*)getFullPathOfDocs:(NSString*)path
{


    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];

    return(fullPath);
}


+(NSString*)getFullPathOfTmp:(NSString*)path
{

    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSString *fullPath = [tmpPath stringByAppendingPathComponent:path];
    return(fullPath);
}


+(NSURL*)getFullPathURLOfDocs:(NSString*)path
{

    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
    return([NSURL fileURLWithPath:fullPath]);
}


+(NSURL*)getFullPathURLOfTmp:(NSString*)path
{
    
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSString *fullPath = [tmpPath stringByAppendingPathComponent:path];
    return([NSURL fileURLWithPath:fullPath]);
}


+(NSString *)getFullPathUnderResource:(NSString*)filename
{
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    return(defaultDBPath);
}

+(NSString *)getFullPathUnderCache:(NSString*)filename
{
    NSArray *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cache objectAtIndex:0] ;
    
    NSString *name = [cachePath stringByAppendingPathComponent:filename];
    return(name);

}





+(NSString*)deleteSubDirOfDocs:(NSString*)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        [fileManager removeItemAtPath:myDirectory error:nil];
    }
    return(myDirectory);
}


+(NSString*)deleteSubDirOfTmp:(NSString*)dirName
{
    NSLog(@"dir deleted:%@",dirName);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpPath = NSTemporaryDirectory(); 
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        [fileManager removeItemAtPath:myDirectory error:nil];
    }
    return(myDirectory);
}

+(NSString*)deleteSubDir:(NSString*)myDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSLog(@"dir are recursively removed :%@",myDirectory);
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        [fileManager removeItemAtPath:myDirectory error:nil];
    }
    return(myDirectory);
}



+(NSString*)creatSubDirOfDocs:(NSString*)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        
    } else {
        [fileManager createDirectoryAtPath:myDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return(myDirectory);
}



+(NSString*)creatSubDirOfTmp:(NSString*)dirName
{
    NSLog(@"dirCreated:%@",dirName);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    if ([fileManager fileExistsAtPath:myDirectory])
    {
    } else {
        [fileManager createDirectoryAtPath:myDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return(myDirectory);
}
+(NSString*)creatSubDir:(NSString*)myDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:myDirectory])
    {
    } else {
        [fileManager createDirectoryAtPath:myDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return(myDirectory);
}











+(NSString*)deleteSpecificFilesOfSubDirOfDocs:(NSString*)fileNamePattern dirName:(NSString*)dirName
{
    ////dirName = @"extractedImages";
    ////fileNamePattern = @"UIImage[0-9]+";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    

    if ([fileManager fileExistsAtPath:myDirectory])
    {
        
        
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:myDirectory error:&error];
        for (int i =0; i< fileList.count; i++) {
            NSString *yourSoundPath = [myDirectory stringByAppendingPathComponent:fileList[i]];
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:fileNamePattern
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray * matches = [regex matchesInString:yourSoundPath
                                               options:0
                                                 range:NSMakeRange(0, [yourSoundPath length])];
            
            
            if (matches.count > 0) {
                
                NSURL *url = [NSURL fileURLWithPath:yourSoundPath];
                NSFileManager *fm = [NSFileManager defaultManager];
                BOOL exist = [fm fileExistsAtPath:url.path];
                NSError *err;
                if (exist) {
                    [fm removeItemAtURL:url error:&err];
                    NSLog(@"file deleted");
                    if (err) {
                        NSLog(@"file remove error, %@", err.localizedDescription );
                    }
                } else {
                    NSLog(@"no file by that name");
                }
                
            }
            
        }
        
        
        
    } else {
        
    }
    
    
    return(myDirectory);
}

+(NSString*)deleteSpecificFilesOfSubDirOfTmp:(NSString *)fileNamePattern dirName:(NSString *)dirName
{
    ////dirName = @"extractedImages";
    ////fileNamePattern = @"UIImage[0-9]+";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录

    
    
    //
    
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    

    if ([fileManager fileExistsAtPath:myDirectory])
    {
        
        
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:myDirectory error:&error];
        for (int i =0; i< fileList.count; i++) {
            NSString *yourSoundPath = [myDirectory stringByAppendingPathComponent:fileList[i]];
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:fileNamePattern
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray * matches = [regex matchesInString:yourSoundPath
                                               options:0
                                                 range:NSMakeRange(0, [yourSoundPath length])];
            
            
            if (matches.count > 0) {
                
                NSURL *url = [NSURL fileURLWithPath:yourSoundPath];
                NSFileManager *fm = [NSFileManager defaultManager];
                BOOL exist = [fm fileExistsAtPath:url.path];
                NSError *err;
                if (exist) {
                    [fm removeItemAtURL:url error:&err];
                    NSLog(@"file deleted");
                    if (err) {
                        NSLog(@"file remove error, %@", err.localizedDescription );
                    }
                } else {
                    NSLog(@"no file by that name");
                }
                
            }
            
        }
        
        
        
       
        
        
    } else {
        
    }
    
    
    return(myDirectory);
}


+(NSString*)deleteSpecificFilesOfSubDir:(NSString *)fileNamePattern dirName:(NSString *)dirName
{
    ////dirName = @"extractedImages";
    ////fileNamePattern = @"UIImage[0-9]+";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];


    
    //
    
    NSString *myDirectory = dirName;
    
    
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        
        
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:myDirectory error:&error];
        
        
        
        for (int i =0; i< fileList.count; i++) {
            NSString *yourSoundPath = [myDirectory stringByAppendingPathComponent:fileList[i]];
            
            NSLog(@"fileNamePattern:%@",fileNamePattern);
            NSLog(@"yourSoundPath:%@",yourSoundPath);
            
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:fileNamePattern
                                                                                   options:NSRegularExpressionDotMatchesLineSeparators
                                                                                     error:&error];
            NSArray * matches = [regex matchesInString:yourSoundPath
                                               options:0
                                                 range:NSMakeRange(0, [yourSoundPath length])];
            
            if (matches.count > 0) {
                
                NSURL *url = [NSURL fileURLWithPath:yourSoundPath];
                NSFileManager *fm = [NSFileManager defaultManager];
                BOOL exist = [fm fileExistsAtPath:url.path];
                NSError *err;
                if (exist) {
                    [fm removeItemAtURL:url error:&err];
                    NSLog(@"file deleted");
                    if (err) {
                        NSLog(@"file remove error, %@", err.localizedDescription );
                    }
                } else {
                    NSLog(@"no file by that name");
                }
                
            }
            
        }
        
        
        
        
        
        
    } else {
        
    }
    
    
    return(myDirectory);
}


+(NSMutableArray*)findSpecificFileURLsOfSubDir:(NSString *)fileNamePattern dirName:(NSString *)dirName
{
    ////dirName = @"extractedImages";
    ////fileNamePattern = @"UIImage[0-9]+";
    
    NSMutableArray * rslt = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //
    
    NSString *myDirectory = dirName;
    
    
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        
        
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:myDirectory error:&error];
        for (int i =0; i< fileList.count; i++) {
            NSString *yourSoundPath = [myDirectory stringByAppendingPathComponent:fileList[i]];
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:fileNamePattern
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray * matches = [regex matchesInString:yourSoundPath
                                               options:0
                                                 range:NSMakeRange(0, [yourSoundPath length])];
            
            
            if (matches.count > 0) {
                
                NSURL *url = [NSURL fileURLWithPath:yourSoundPath];
                NSFileManager *fm = [NSFileManager defaultManager];
                BOOL exist = [fm fileExistsAtPath:url.path];
                NSError *err;
                if (exist) {
                    [rslt addObject:url];
                    if (err) {
                        NSLog(@"file remove error, %@", err.localizedDescription );
                    }
                } else {
                    NSLog(@"no file by that name");
                }
                
            }
            
        }
        
        
    } else {
        
    }
    
    
    return(rslt);
}


////




+(NSString*)saveUIImageToDocsFile:(UIImage*)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality
{
    ////dirName = @"extractedImages";
    

     //
     NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
     NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
     NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    
    NSData * data;
    
    //PNG format doesnot have image orientation information
    //JPEG format has
    
    if ([format isEqualToString:@"png"]) {
        data = UIImagePNGRepresentation(image);
    } else {
        data = UIImageJPEGRepresentation(image, quality);
    }
    
    [data writeToFile:filePath atomically:YES];
    
    
    return(filePath);
}






+(NSString*)saveUIImageToFile:(UIImage*)image filePath:(NSString*)filePath  format:(NSString*)format jpegQuality:(float)quality
{
 
    @autoreleasepool {

        
        
        NSData * data;
        //PNG format doesnot have image orientation information
        //JPEG format has
        
        ////after using these two  function  , there will be about 5-6 M memory always
        ////in memory. but this is not memory leak , because when you rerun these two functions
        ////no more memory increasing
        
        if ([format isEqualToString:@"png"]) {
            data = UIImagePNGRepresentation(image);
        } else {
            data = UIImageJPEGRepresentation(image, quality);
        }
        
        
        [data writeToFile:filePath atomically:NO];
        
        data = NULL;
        
        //atomically
        //If YES, the data is written to a backup file,
        //and then—assuming no errors occur—the backup file is renamed
        //to the name specified by path; otherwise, the data is written directly to path.
        
        /*
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         // Generate the file path
         [data writeToFile:filePath atomically:NO];
         dispatch_async(dispatch_get_main_queue(), ^{
         data = NULL;
         });
         });
         */
        
        
    }
    
    return(filePath);
}







+(NSString*)saveUIImageToTmpFile:(UIImage*)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality
{
    ////dirName = @"extractedImages";
    
    NSString *filePath;
    
    @autoreleasepool {
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
        filePath = [myDirectory stringByAppendingPathComponent:fileName];
        
        
        NSData * data;
        //PNG format doesnot have image orientation information
        //JPEG format has
        
        ////after using these two  function  , there will be about 5-6 M memory always
        ////in memory. but this is not memory leak , because when you rerun these two functions
        ////no more memory increasing
        
        if ([format isEqualToString:@"png"]) {
            data = UIImagePNGRepresentation(image);
        } else {
            data = UIImageJPEGRepresentation(image, quality);
        }
        

        [data writeToFile:filePath atomically:NO];

        data = NULL;
        
        //atomically
        //If YES, the data is written to a backup file,
        //and then—assuming no errors occur—the backup file is renamed
        //to the name specified by path; otherwise, the data is written directly to path.
        
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // Generate the file path
            [data writeToFile:filePath atomically:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                data = NULL;
            });
        });
       */
        
        
    }
    
    return(filePath);
}








+ (void)saveImageFromCGIMageRef:(CGImageRef)imageRef path:(NSString *)path type:(CFStringRef)type
{
    //// this method will decrease the size  than  UIImagePNGRepresentation
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    CGImageDestinationRef dr = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, type , 1, NULL);
    
    CGImageDestinationAddImage(dr, imageRef, NULL);
    CGImageDestinationFinalize(dr);
    
    CFRelease(dr);
    
    
    
}


+(NSString*)saveCGImageToTmpFile:(CGImageRef)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality
{
    ////dirName = @"extractedImages";
    
    
    
    NSString *filePath;
    
    
    @autoreleasepool {
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
        filePath = [myDirectory stringByAppendingPathComponent:fileName];
        
        
        if ([format isEqualToString:@"png"]) {
            [self saveImageFromCGIMageRef:image path:filePath type:kUTTypePNG];
        } else {
            [self saveImageFromCGIMageRef:image path:filePath type:kUTTypeJPEG];
        }
        
    }
    
    return(filePath);
}



+(NSString *)syncedSaveUIImageToTmpFile:(UIImage*)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality
{
        ////dirName = @"extractedImages";
        
        NSString *filePath;
    @autoreleasepool {
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
        filePath = [myDirectory stringByAppendingPathComponent:fileName];
        
        
        __block NSData * data;
        
        //PNG format doesnot have image orientation information
        //JPEG format has
        
        ////after using these two  function  , there will be about 5-6 M memory always
        ////in memory. but this is not memory leak , because when you rerun these two functions
        ////no more memory increasing
        
        if ([format isEqualToString:@"png"]) {
            data = UIImagePNGRepresentation(image);
            
        } else {
            data = UIImageJPEGRepresentation(image, quality);
        }
        
        //atomically
        //If YES, the data is written to a backup file,
        //and then—assuming no errors occur—the backup file is renamed
        //to the name specified by path; otherwise, the data is written directly to path.
        
        [data writeToFile:filePath atomically:NO];
        data = NULL;
        
        
    }
        return(filePath);
}










+ (NSString *)saveImageFromALAssetUrlToDocsFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName
{

    
    ////dirName = @"extractedImages";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];


    
    
    //
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    
    __block dispatch_semaphore_t semaCanReturn = dispatch_semaphore_create(0);
    
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
   
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:myDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    ////dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            // 主要方法
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                NSString * imagePath = filePath;
                [data writeToFile:imagePath atomically:YES];
                
                dispatch_semaphore_signal(semaCanReturn);
                
            } failureBlock:nil];
        }
    ////});
    
    
    while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    return(filePath);
}




+ (NSString *)saveImageFromALAssetUrlToTmpFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName
{
    
    
    ////dirName = @"extractedImages";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
        
    //
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    
    __block dispatch_semaphore_t semaCanReturn = dispatch_semaphore_create(0);
    
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:myDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    ////dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            // 主要方法
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                NSString * imagePath = filePath;
                [data writeToFile:imagePath atomically:YES];
                
                dispatch_semaphore_signal(semaCanReturn);
                
                
            } failureBlock:nil];
        }
    ////});
    
    while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    
    return(filePath);
}





+ (NSString *)saveVideoFromALAssetUrlToDocsFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName
{
    
    
    ////dirName = @"extractedImages";
    

    //
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    
    
    __block dispatch_semaphore_t semaCanReturn = dispatch_semaphore_create(0);
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    ////dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSString * videoPath = filePath;
                char  const *cvideoPath = [videoPath UTF8String];
                FILE *file = fopen(cvideoPath, "a+");
                if (file) {
                    const int bufferSize = 11024 * 1024;
                    // 初始化一个1M的buffer
                    Byte *buffer = (Byte*)malloc(bufferSize);
                    NSUInteger read = 0, offset = 0, written = 0;
                    NSError* err = nil;
                    if (rep.size != 0)
                    {
                        do {
                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                            written = fwrite(buffer, sizeof(char), read, file);
                            offset += read;
                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
                    }
                    // 释放缓冲区，关闭文件
                    free(buffer);
                    buffer = NULL;
                    fclose(file);
                    file = NULL;
                    
                    dispatch_semaphore_signal(semaCanReturn);
                }
            } failureBlock:nil];
        }
    ////});
    
    while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    return(filePath);
}




+ (NSString *)saveVideoFromALAssetUrlToTmpFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName
{
    
    
    ////dirName = @"extractedImages";

    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录

    
    
    //
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    
    
    __block dispatch_semaphore_t semaCanReturn = dispatch_semaphore_create(0);
    
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    ////dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSString * videoPath = filePath;
                char  const *cvideoPath = [videoPath UTF8String];
                FILE *file = fopen(cvideoPath, "a+");
                if (file) {
                    const int bufferSize = 11024 * 1024;
                    // 初始化一个1M的buffer
                    Byte *buffer = (Byte*)malloc(bufferSize);
                    NSUInteger read = 0, offset = 0, written = 0;
                    NSError* err = nil;
                    if (rep.size != 0)
                    {
                        do {
                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                            written = fwrite(buffer, sizeof(char), read, file);
                            offset += read;
                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
                    }
                    // 释放缓冲区，关闭文件
                    free(buffer);
                    buffer = NULL;
                    fclose(file);
                    file = NULL;
                    
                    dispatch_semaphore_signal(semaCanReturn);
                    
                    
                }
            } failureBlock:nil];
        }
    ////});
    
    
    
    while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    return(filePath);
}





+ (void)deleteFile:(NSString*)fullPath
{
    NSURL *url = [NSURL fileURLWithPath:fullPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}





+ (void)deleteTmpFile:(NSString*)tmpFullPath
{
    NSURL *url = [NSURL fileURLWithPath:tmpFullPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}


+ (void)deleteDocFile:(NSString*)docFullPath
{
   

    NSURL *url = [NSURL fileURLWithPath:docFullPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}




+ (NSMutableArray *) getAllFileABSPathsOfAlbumSortedViaDate
{
    __block NSMutableArray *  allFileABSPathsOfAlbum = [[NSMutableArray alloc] init];
    __block NSDictionary * element = [[NSDictionary alloc] init];
    
    __block dispatch_semaphore_t semaCanReturn = dispatch_semaphore_create(0);
    
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
    
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            
            
            
            ////NSLog(@"group:%@",group.description);
            
            if ([result thumbnail]==nil) {
                
            } else {
                

                ////UIImage * assetThumNailImg = [[UIImage alloc] initWithCGImage:[result thumbnail]];

                ////NSLog(@"assetThumNailImg:%@",assetThumNailImg);
                
            }
            
            
            NSString* assetType = [result valueForProperty:ALAssetPropertyType];
            /*
            if ([assetType isEqualToString:ALAssetTypePhoto]) {
                NSLog(@"Photo:%@",assetType);
            }else if([assetType isEqualToString:ALAssetTypeVideo]){
                NSLog(@"Video:%@",assetType);
            }else if([assetType isEqualToString:ALAssetTypeUnknown]){
                NSLog(@"Unknow:%@",assetType);
            }
             */
            
            
            
            NSDate *date= [result valueForProperty:ALAssetPropertyDate];
            ////CLLocation * location= [result valueForProperty:ALAssetPropertyLocation];
            NSNumber * duration = [result valueForProperty:ALAssetPropertyDuration];
            ////NSNumber * orientation = [result  valueForProperty: ALAssetPropertyOrientation];
            NSURL * surl = [result valueForProperty:ALAssetPropertyAssetURL];
            ////NSDictionary * urld = [result valueForProperty:ALAssetPropertyURLs];
            
            ////NSArray * props = [result valueForProperty:ALAssetPropertyRepresentations];
            
            NSString *fileName = [[result defaultRepresentation] filename];
            ////NSURL *url = [[result defaultRepresentation] url];
            int64_t fileSize = [[result defaultRepresentation] size];
            NSNumber * NSNFileSize = @(fileSize);
            
            /*
            NSLog(@"date = %@",date);
            NSLog(@"location = %@",location);
            NSLog(@"duration = %@",duration);
            NSLog(@"orientation = %@",orientation);
            NSLog(@"surl = %@",surl);
            NSLog(@"urld = %@",urld);
            for (int j =0 ; j<props.count; j++) {
                NSLog(@"props[%d]= %@",j,props[j]);
            }
            
            
            NSLog(@"fileName = %@",fileName);
            NSLog(@"url = %@",url);
            NSLog(@"fileSize = %lld",fileSize);
            */
            
            
            
          
    
            
            
            
             element = [NSDictionary dictionaryWithObjectsAndKeys: date,@"ALAssetPropertyDate",
                                                                                 fileName,@"fileName",
                                                                                 surl,@"ALAssetPropertyAssetURL",
                                                                                 assetType,@"ALAssetPropertyType",
                                                                                 NSNFileSize,@"fileSize",
                                                                                 duration,@"duration",
                                                                                 nil];
            
            
            if (result) {
                ////NSLog(@"result:%@",result);
                [allFileABSPathsOfAlbum addObject:element];
             } else {
                 [allFileABSPathsOfAlbum sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
                     NSDictionary * o1 = (NSDictionary *) obj1;
                     NSDictionary * o2 = (NSDictionary *) obj2;
                     
                     NSDate * pt1 = [o1 valueForKey:@"ALAssetPropertyDate"] ;
                     NSDate * pt2 = [o2 valueForKey:@"ALAssetPropertyDate"] ;
                     
                     
                     return( [pt1 compare:pt2] );
                 }];
                 
                 
                 
                 
                 ////NSLog(@"allFileABSPathsOfAlbum.count:%lu",(unsigned long)allFileABSPathsOfAlbum.count);
                 
                 
                 for (int i =0 ; i<allFileABSPathsOfAlbum.count; i++) {
                     
                     ////NSLog(@"allFileABSPathsOfAlbum[%d]:%@",i,allFileABSPathsOfAlbum[i]);
                 }
                 
                 dispatch_semaphore_signal(semaCanReturn);
                 
             }
            
            
           
            
            
        } ];
        
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Enumerate the asset groups failed.");
        
        NSString *errorMessage = nil;
        
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
                break;
                
            default:
                errorMessage = @"Reason unknown.";
                break;
    }
    }];
    
    
    ////dont use this dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_FOREVER);
    
    
    while (dispatch_semaphore_wait(semaCanReturn, DISPATCH_TIME_NOW)) {
         ////如果semaConReturn是0 返回非0
         [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    
    return(allFileABSPathsOfAlbum);
    

}


+ (void)writeVideoToPhotoLibrary:(NSURL *)url
{
    
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    ////BOOL compatable =
    [library videoAtPathIsCompatibleWithSavedPhotosAlbum:url];
    
    ////NSLog(@"videoAtPathIsCompatibleWithSavedPhotosAlbum:%d",compatable);
    
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error){
        ////NSLog(@"ALAssetURL:%@ to libary",assetURL);
        if (error) {
            NSLog(@"Video could not be saved");
        }
    }];
}


+(NSURL *)creatSandboxTmpURLForPhotoLibrary:(NSString *)dirName ALAssetDict:(NSMutableDictionary *)ALAssetDict
{
    ////NSString * type = [ALAssetDict  valueForKey:@"ALAssetPropertyType"];
    NSURL * alassetURL = [ALAssetDict  valueForKey:@"ALAssetPropertyAssetURL"];
    NSString * fileName = [ALAssetDict  valueForKey:@"fileName"];
    
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    [FileUitl deleteTmpFile:filePath];
    
    [FileUitl saveImageFromALAssetUrlToTmpFile:alassetURL fileName:fileName dirName:dirName];
    
    NSString * seq = [NSString stringWithFormat:@"%@/tmpRslt_%@.mov",dirName,fileName];
    
    NSString * tempPath = [FileUitl getFullPathOfTmp:seq];
    [FileUitl deleteTmpFile:tempPath];
    NSURL * desturl = [NSURL fileURLWithPath:tempPath];
    
    return(desturl);
}


////


+(NSMutableArray*)getSpecificFilePathsOfSubDirOfDocs:(NSString*)fileNamePattern dirName:(NSString*)dirName
{
    
    NSMutableArray * pathsArray = [[NSMutableArray alloc] init];
    ////dirName = @"extractedImages";
    ////fileNamePattern = @"UIImage[0-9]+";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];


    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    

    if ([fileManager fileExistsAtPath:myDirectory])
    {
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];

        fileList = [fileManager contentsOfDirectoryAtPath:myDirectory error:&error];
        for (int i =0; i< fileList.count; i++) {
            NSString *eachPath = [myDirectory stringByAppendingPathComponent:fileList[i]];
          
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:fileNamePattern
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray * matches = [regex matchesInString:eachPath
                                               options:0
                                                 range:NSMakeRange(0, [eachPath length])];
            
            
            if (matches.count > 0) {
                
                BOOL exist = [fileManager fileExistsAtPath:eachPath];
                if (exist) {
                    [pathsArray addObject:eachPath];
                } else {
                    NSLog(@"no file by that name");
                }
                
            }
            
        }
        
        
        
    } else {
        
    }
    
    return(pathsArray);
}





+(NSMutableArray*)getSpecificFilePathsOfSubDirOfTmp:(NSString *)fileNamePattern dirName:(NSString *)dirName
{
    
    NSMutableArray * pathsArray = [[NSMutableArray alloc] init];
    ////dirName = @"ExtractedImages";
    ////fileNamePattern = @"UIImage[0-9]+";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        
        
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        fileList = [fileManager contentsOfDirectoryAtPath:myDirectory error:&error];
        for (int i =0; i< fileList.count; i++) {
            NSString *eachPath = [myDirectory stringByAppendingPathComponent:fileList[i]];
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:fileNamePattern
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray * matches = [regex matchesInString:eachPath
                                               options:0
                                                 range:NSMakeRange(0, [eachPath length])];
            
            
            if (matches.count > 0) {
                BOOL exist = [fileManager fileExistsAtPath:eachPath];
                if (exist) {
                    [pathsArray addObject:eachPath];
                } else {
                    NSLog(@"no file by that name");
                }
                
            }
            
        }
        
        
        
        
        
        
    } else {
        
    }
    
    return(pathsArray);
}


+(void) printNSRange:(NSRange )range
{
    NSLog(@"location:%lu",range.location);
    NSLog(@"length:%lu",range.length);
}

+(void) printNSTextCheckingResult:(NSTextCheckingResult * )match
{
    for (int i = 0; i < [match numberOfRanges]; i++) {
        [self printNSRange:[match rangeAtIndex:i]];
    }
}

+(void) printNSRegularExpressionMatchesInString:(NSArray *)matches
{
    for (int i = 0; i < matches.count; i++) {
        [self printNSTextCheckingResult:(NSTextCheckingResult *)matches[i]];
    }
}


+ (void)copyFileFrom:(NSString*)resourcePath To:(NSString*)destPath
{
    NSFileManager*fileManager =[NSFileManager defaultManager];
    NSError*error;
 
    if([fileManager fileExistsAtPath:destPath]== NO){
        [fileManager copyItemAtPath:resourcePath toPath:destPath error:&error];
    }
    NSLog(@"error:%@",error );
    error =NULL;
    ////Copies the item at the specified path to a new location synchronously.
}






+(NSMutableDictionary *)getNSStringFromFile:(NSString *)filePath from:(int)from
{
    NSMutableArray * supportedEncodings = [[NSMutableArray alloc] init];
    NSMutableArray * supportedEncodingNames = [[NSMutableArray alloc] init];
    
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSASCIIStringEncoding]];
    [supportedEncodingNames addObject:@"NSASCIIStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSNEXTSTEPStringEncoding]];
    [supportedEncodingNames addObject:@"NSNEXTSTEPStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSJapaneseEUCStringEncoding]];
    [supportedEncodingNames addObject:@"NSJapaneseEUCStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSUTF8StringEncoding]];
    [supportedEncodingNames addObject:@"NSUTF8StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSISOLatin1StringEncoding]];
    [supportedEncodingNames addObject:@"NSISOLatin1StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSSymbolStringEncoding]];
    [supportedEncodingNames addObject:@"NSSymbolStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSNonLossyASCIIStringEncoding]];
    [supportedEncodingNames addObject:@"NSNonLossyASCIIStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSShiftJISStringEncoding]];
    [supportedEncodingNames addObject:@"NSShiftJISStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSISOLatin2StringEncoding]];
    [supportedEncodingNames addObject:@"NSISOLatin2StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSUnicodeStringEncoding]];
    [supportedEncodingNames addObject:@"NSUnicodeStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSWindowsCP1251StringEncoding]];
    [supportedEncodingNames addObject:@"NSWindowsCP1251StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSWindowsCP1252StringEncoding]];
    [supportedEncodingNames addObject:@"NSWindowsCP1252StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSWindowsCP1253StringEncoding]];
    [supportedEncodingNames addObject:@"NSWindowsCP1253StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSWindowsCP1254StringEncoding]];
    [supportedEncodingNames addObject:@"NSWindowsCP1254StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSWindowsCP1250StringEncoding]];
    [supportedEncodingNames addObject:@"NSWindowsCP1250StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSISO2022JPStringEncoding]];
    [supportedEncodingNames addObject:@"NSISO2022JPStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSMacOSRomanStringEncoding]];
    [supportedEncodingNames addObject:@"NSMacOSRomanStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSUTF16StringEncoding]];
    [supportedEncodingNames addObject:@"NSUTF16StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSUTF16BigEndianStringEncoding]];
    [supportedEncodingNames addObject:@"NSUTF16BigEndianStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSUTF16LittleEndianStringEncoding]];
    [supportedEncodingNames addObject:@"NSUTF16LittleEndianStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSUTF32StringEncoding]];
    [supportedEncodingNames addObject:@"NSUTF32StringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSUTF32BigEndianStringEncoding]];
    [supportedEncodingNames addObject:@"NSUTF32BigEndianStringEncoding"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:NSUTF32LittleEndianStringEncoding]];
    [supportedEncodingNames addObject:@"NSUTF32LittleEndianStringEncoding"];

    
    /*
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingANSEL)]];
    [supportedEncodingNames addObject:@"kCFStringEncodingANSEL"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)]];
    [supportedEncodingNames addObject:@"kCFStringEncodingASCII"];
    ////
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_E)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingCNS_11643_92_P1)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingCNS_11643_92_P2)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingCNS_11643_92_P3)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSArabic)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSBalticRim)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSCanadianFrench)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseTrad)]];
    [supportedEncodingNames addObject:@""];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSCyrillic)]];
    [supportedEncodingNames addObject:@"kCFStringEncodingDOSCyrillic"];
    */
    
   
    
    
    NSMutableDictionary * rslt = [[NSMutableDictionary  alloc] init];
    
    
    
    for (int i = from; i < supportedEncodings.count; i++) {
        
        NSError * error;
        NSStringEncoding enc = [supportedEncodings[i] unsignedIntValue];
        
        NSString * string = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:enc error:&error];
 
        
        
        
        if (error == NULL && (string.length != 0)) {
            NSLog(@"string :%@%@",@"\n",string);
            NSLog(@"encoding name: %@",supportedEncodingNames[i]);
            NSLog(@"NSStringEncoding :%lu ",(unsigned long)enc);
            [rslt setValue:string forKey:@"string"];
            [rslt setValue:supportedEncodingNames[i] forKey:@"origEncodingName"];
            [rslt setValue:[NSNumber numberWithUnsignedLong:enc] forKey:@"NSStringEncoding"];
            return(rslt);
        } else {
            NSLog(@"error:%@",error);
        }
    }
    
    return(rslt);
    
}



+(NSMutableDictionary *)getNSStringFromDataViaCFString:(NSData *)data from:(int)from
{
    
    
    
    NSMutableArray * supportedEncodings = [[NSMutableArray alloc] init];
    NSMutableArray * supportedEncodingNames = [[NSMutableArray alloc] init];
  
    [supportedEncodings addObject:[NSNumber numberWithUnsignedLong:kCFStringEncodingANSEL]];
    [supportedEncodingNames addObject:@"kCFStringEncodingANSEL"];
    [supportedEncodings addObject:[NSNumber numberWithUnsignedLong:kCFStringEncodingASCII]];
    [supportedEncodingNames addObject:@"kCFStringEncodingASCII"];

    
    [supportedEncodings addObject:[NSNumber numberWithUnsignedLong:kCFStringEncodingGB_18030_2000]];
    [supportedEncodingNames addObject:@"kCFStringEncodingGB_18030_2000"];
    
    [supportedEncodings addObject:[NSNumber numberWithUnsignedLong:kCFStringEncodingUTF8]];
    [supportedEncodingNames addObject:@"kCFStringEncodingUTF8"];
    
    
    [supportedEncodings addObject:[NSNumber numberWithUnsignedLong:kCFStringEncodingUnicode]];
    [supportedEncodingNames addObject:@"kCFStringEncodingUnicode"];
    
    
    /*
     [supportedEncodings addObject:[NSNumber numberWithUnsignedLong:kCFStringEncodingUTF8]];
     [supportedEncodingNames addObject:@"kCFStringEncodingUTF8"];
     
     [supportedEncodings addObject:[NSNumber numberWithUnsignedLong:kCFStringEncoding]];
     [supportedEncodingNames addObject:@""];
     */
    
    
    
    NSMutableDictionary * rslt = [[NSMutableDictionary  alloc] init];
    
    
    
    for (int i = from; i < supportedEncodings.count; i++) {
        
        UInt8 * dataBytes = (UInt8 *)[data bytes];
        CFIndex numBytes = [data length];
        
        CFStringRef string = CFStringCreateWithBytes(NULL, dataBytes, numBytes, (CFStringEncoding)[supportedEncodings[i] unsignedLongValue], true);
        
        NSLog(@"string from encode supportedEncodings[%d]:%@",i,(__bridge NSString*)string);
        
        if (string != NULL && (CFStringGetLength(string) != 0)) {
            
            NSString * nstring = (__bridge_transfer NSString *)string;
            
            
            NSLog(@"nstring :%@%@",@"\n",nstring);
            NSLog(@"original encoding name: %@",supportedEncodingNames[i]);
            NSLog(@"original kCFStringEncoding :%lu ",[supportedEncodings[i] unsignedLongValue]);
            [rslt setValue:nstring forKey:@"string"];
            [rslt setValue:supportedEncodingNames[i] forKey:@"origEncodingName"];
            [rslt setValue:supportedEncodings[i] forKey:@"origKCFStringEncoding"];
            break;
        } else {
            NSLog(@"error: continue find");
            if (string != NULL) {
                CFRelease(string);
            }
        }
    }
    
    
    
    
    return(rslt);
    
}



+(void)writeJSONtoFile:(id)userDetails filePath:(NSString *)filePath
{
    NSError * error;
  
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:userDetails
                                                       options:kNilOptions
                                                         error:&error];
    
    [jsonData writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];

    NSLog(@"error:%@",error);
}


+(id)loadJSONfromFile:(NSString *)filePath
{
    NSError * error;
    
    NSData * data = [[NSData alloc] initWithContentsOfFile:filePath];
    
    NSUInteger jsonReadingOptions = NSJSONReadingAllowFragments | NSJSONReadingMutableContainers;
  
    id jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                            options:jsonReadingOptions
                                                              error:&error];
    
    
    NSLog(@"error:%@",error);
    
    return(jsonResponse);
}


+(NSMutableDictionary *)kv2vks:(NSMutableDictionary *)kv
{
    

    NSMutableDictionary * rslt = [[NSMutableDictionary alloc] init];
    
    for (NSString *value in [kv allValues]) {
        if ([[rslt allKeys] containsObject:value]) {
            
        } else {
            NSMutableArray * nv = [[NSMutableArray alloc] init];
            [rslt setValue:nv forKey:value];
        }
    }

    for (NSString *key in [kv allKeys]) {
        
        NSString * nk = [kv valueForKey:key];
        
        [[rslt valueForKey:nk] addObject:key];
        
    }
    
    return(rslt);

}

+(void)addDict:(NSMutableDictionary *)dict1 toDict:(NSMutableDictionary *)dict2
{
    
    
    
    for (NSString *key in [dict1 allKeys]) {
        
        NSMutableArray * d1v = (NSMutableArray *)[dict1 valueForKey:key];
        if ([[dict2 allKeys] containsObject:key]) {
             NSMutableArray * d2v = (NSMutableArray *)[dict2 valueForKey:key];
            for (int i =0 ; i< d1v.count ; i++) {
                if ([d2v containsObject:d1v[i]]) {
                } else {
                    [d2v addObject:d1v[i]];
                }
            }
        } else {
            [dict2 setValue:d1v forKey:key];
        }
        
   
    }
    
   

    
}


+(float)strSimilarRatio:(NSString*)str1 toStr:(NSString*)str2
{

    ////NSLog(@"str2:%@",str2);
    float  numerator = 0.0;
    float  denominator = (float) str1.length;
    for (int i = 0; i < str1.length; i++) {
        NSString * ch1 = [str1 substringWithRange: NSMakeRange(i,1)];
        if ([str2 containsString:ch1]) {
            numerator = numerator + 1;
        }
    }
    
    ////NSLog(@"%f:%f:%f",numerator,denominator,numerator/denominator);
    return(numerator/denominator);
    
}






+(NSMutableArray *)findAllFileNamesWithPattern:(NSString*)dirPath withPattern:(NSString*)pattern
{
    
    NSMutableArray * allMatched= [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
   
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:dirPath error:&error];
    
    for (int i =0; i< fileList.count; i++) {
        NSString *yourSoundPath = [dirPath stringByAppendingPathComponent:fileList[i]];
        NSLog(@"yourSoundPath:%@",yourSoundPath);
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches = [regex matchesInString:yourSoundPath
                                           options:0
                                             range:NSMakeRange(0, [yourSoundPath length])];
        
        
        if (matches.count > 0) {
            
            [allMatched addObject:fileList[i]];
            
        }
        
    }
    
    
    return(allMatched);
    
    
    
    
}






+(NSMutableDictionary * )gcd:(NSMutableArray * )nums
{
    NSMutableArray * copy = [[NSMutableArray alloc] initWithArray:nums copyItems:YES];
    
    [copy sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
          NSNumber * o1 = (NSNumber *) obj1;
          NSNumber * o2 = (NSNumber *) obj2;
          int pt1 = [o1 intValue];
          int pt2 = [o2 intValue];
          if (pt1 <= pt2) {
              return (NSComparisonResult)NSOrderedAscending;
          } else if (pt1 > pt2) {
              return (NSComparisonResult)NSOrderedDescending;
          }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    int testRange;
    
    for (int i = 0; i<copy.count; i++) {
        if ([copy[0] intValue] == 0) {
            
        } else {
            testRange = [copy[i] intValue];
            break;
        }
    }
    
    
    
    int gcd = 1;
    
    for (int j = 1; j<=testRange; j++) {
        int pass = 1;
        for (int i = 0; i < copy.count; i++) {
            int currValue = [copy[i] intValue];
            if ((currValue % j) == 0) {
                
            } else {
                pass = 0;
                break;
            }
        }
        if (pass == 1) {
            gcd = j;
        }
    }
    
    
    NSMutableArray * divides = [[NSMutableArray alloc] init];
    
    for (int i = 0;  i <nums.count; i++) {
        int currValue = [nums[i] intValue];
        currValue = currValue / gcd;
        [divides addObject:[NSNumber numberWithInt:currValue]];
    }
    
    copy = NULL;
    
    
    NSMutableDictionary * rslt = [[NSMutableDictionary  alloc] init];
    [rslt setValue:nums forKey:@"origNums"];
    [rslt setValue:[NSNumber numberWithInt:gcd] forKey:@"gcd"];
    [rslt setValue:divides forKey:@"divides"];
    
    return(rslt);
    
}

+(void)showNSManagedObject:(NSManagedObject *)obj
{
    NSLog(@"obj.id:%@",(NSString*)obj.objectID);
    NSLog(@"obj.id entity :%@",obj.objectID.entity);
    NSLog(@"obj.id hash :%llu",(unsigned long long)obj.objectID.hash);
    NSLog(@"obj.id debugDescription :%@",obj.objectID.debugDescription);
    NSLog(@"obj.id isTemporaryID:%d",obj.objectID.isTemporaryID);
    NSLog(@"obj.id persistentStore:%@",(NSString*)obj.objectID.persistentStore);
    NSLog(@"obj.id description:%@",obj.objectID.description);
}





+(Byte *) copyNSDataToByteData:(NSData * )bufferMono
{
    NSUInteger len = [bufferMono length];
    Byte * byteData = (Byte*) malloc (len);
    memcpy (byteData, [bufferMono bytes], len);
    return(byteData);
}


NSString * getCurrAPPIDInPath()
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docDir = [paths objectAtIndex:0];
    NSString * temp = [docDir stringByDeletingLastPathComponent];
    return([temp lastPathComponent]);
}

void printNSUserDefaults(NSUserDefaults*defaults)
{
    NSLog(@"defaults all keys:%@", [[defaults dictionaryRepresentation] allKeys]);
    NSLog(@"defaults all :%@", [defaults dictionaryRepresentation]);
}

@end