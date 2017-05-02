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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);

    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];

    return(fullPath);
}


+(NSString*)getFullPathOfTmp:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    NSString *fullPath = [tmpPath stringByAppendingPathComponent:path];
    
    return(fullPath);
}


+(NSURL*)getFullPathURLOfDocs:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
    
    return([NSURL fileURLWithPath:fullPath]);
}


+(NSURL*)getFullPathURLOfTmp:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    NSString *fullPath = [tmpPath stringByAppendingPathComponent:path];
    
    return([NSURL fileURLWithPath:fullPath]);
}






+(NSString*)deleteSubDirOfDocs:(NSString*)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
   
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);

    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        [fileManager removeItemAtPath:myDirectory error:nil];
    }
    return(myDirectory);
}




+(NSString*)creatSubDirOfDocs:(NSString*)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
    
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    

    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
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
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
    //
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    
    NSLog(@"%@",myDirectory);
    
    
    
    
    NSLog(@"---------------------------------------");
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        
        
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:myDirectory error:&error];
        for (int i =0; i< fileList.count; i++) {
            NSString *yourSoundPath = [myDirectory stringByAppendingPathComponent:fileList[i]];
            NSLog(@"yourSoundPath:%@",yourSoundPath);
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
        
        
        
        NSLog(@"---------------------------------------");
        
        
    } else {
        
    }
    
    
    return(myDirectory);
}





+(NSString*)deleteSpecificFilesOfSubDirOfTmp:(NSString *)fileNamePattern dirName:(NSString *)dirName
{
    ////dirName = @"extractedImages";
    ////fileNamePattern = @"UIImage[0-9]+";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
    //
    
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    
    NSLog(@"%@",myDirectory);
    
    
    
    
    NSLog(@"---------------------------------------");
    if ([fileManager fileExistsAtPath:myDirectory])
    {
        
        
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:myDirectory error:&error];
        for (int i =0; i< fileList.count; i++) {
            NSString *yourSoundPath = [myDirectory stringByAppendingPathComponent:fileList[i]];
            NSLog(@"yourSoundPath:%@",yourSoundPath);
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
        
        
        
        NSLog(@"---------------------------------------");
        
        
    } else {
        
    }
    
    
    return(myDirectory);
}







+(NSString*)saveUIImageToDocsFile:(UIImage*)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality
{
    ////dirName = @"extractedImages";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
     //
     NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
     NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
     NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
     NSLog(@"%@",myDirectory);
    
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




+(NSString*)saveUIImageToTmpFile:(UIImage*)image fileName:(NSString*)fileName dirName:(NSString*)dirName format:(NSString*)format jpegQuality:(float)quality
{
    ////dirName = @"extractedImages";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
    //
    
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"%@",myDirectory);
    
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





+ (NSString *)saveImageFromALAssetUrlToDocsFile:(NSURL *)url fileName:(NSString*)fileName dirName:(NSString*)dirName
{

    
    ////dirName = @"extractedImages";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
    //
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"%@",myDirectory);
    
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
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
    //
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"%@",myDirectory);
    
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
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
    //
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];//获取document目录然后将文件名追加进去
    NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"%@",myDirectory);
    
    
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
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *homeDir= NSHomeDirectory();//获取AppHome目录
    NSString *tmpPath = NSTemporaryDirectory(); //获取tmp目录
    NSLog(@"fileManager:%@",fileManager);
    NSLog(@"homeDir:%@",homeDir);
    NSLog(@"tmpPath:%@",tmpPath);
    
    
    //
    NSString *myDirectory = [tmpPath stringByAppendingPathComponent:dirName];
    NSString *filePath = [myDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"%@",myDirectory);
    
    
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












+ (void)deleteTmpFile:(NSString*)tmpFullPath
{
    NSLog(@"tmpPath in deleteTmpFile:%@",tmpFullPath);
    ////self.tmpVideoPath
    NSURL *url = [NSURL fileURLWithPath:tmpFullPath];
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


+ (void)deleteDocFile:(NSString*)docFullPath
{
    NSLog(@"docPath in deleteTmpFile:%@",docFullPath);

    NSURL *url = [NSURL fileURLWithPath:docFullPath];
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
                 
                 
                 
                 
                 NSLog(@"allFileABSPathsOfAlbum.count:%lu",(unsigned long)allFileABSPathsOfAlbum.count);
                 
                 
                 for (int i =0 ; i<allFileABSPathsOfAlbum.count; i++) {
                     
                     NSLog(@"allFileABSPathsOfAlbum[%d]:%@",i,allFileABSPathsOfAlbum[i]);
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
         [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    
    return(allFileABSPathsOfAlbum);
    

}


+ (void)writeVideoToPhotoLibrary:(NSURL *)url
{
    
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    BOOL compatable = [library videoAtPathIsCompatibleWithSavedPhotosAlbum:url];
    
    NSLog(@"videoAtPathIsCompatibleWithSavedPhotosAlbum:%d",compatable);
    
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error){
        NSLog(@"ALAssetURL:%@ to libary",assetURL);
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
        
        
        
        NSLog(@"---------------------------------------");
        
        
    } else {
        
    }
    
    return(pathsArray);
}






@end