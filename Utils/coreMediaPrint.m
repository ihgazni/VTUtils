//
//  coreMediaPrint.m
//  UView
//
//  Created by dli on 12/26/15.
//  Copyright © 2015 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "coreMediaPrint.h"




@implementation coreMediaPrint


void printCMTime(CMTime t,NSString*indent)
{
    NSLog(@"%@epoch:%lld",indent,t.epoch);
    NSLog(@"%@flags:%u",indent,t.flags);
    NSLog(@"%@timescale:%d",indent,t.timescale);
    NSLog(@"%@value:%lld",indent,t.value);
    
}


void printTimeRange(CMTimeRange tr,NSString*indent)
{
    NSString* subindent = [indent stringByAppendingString:indent];
    NSLog(@"%@start:----",indent);
    printCMTime(tr.start,subindent);
    NSLog(@"%@duration:----",indent);
    printCMTime(tr.duration  ,subindent);
}


void printTimeMapping(CMTimeMapping tm,NSString*indent)
{
    NSLog(@"source:");
    printTimeRange(tm.source,indent);
    NSLog(@"target:");
    printTimeRange(tm.target,indent);
    
}







void printEachSampleTimeInfo(CMSampleBufferRef sampleBuffer)
{
    CMItemCount  samplesNum = CMSampleBufferGetNumSamples(sampleBuffer);
    for (int i=0;i<samplesNum;i++) {
        size_t eachSampleSize = CMSampleBufferGetSampleSize(sampleBuffer, i);
        NSLog(@"eachSampleSize:%zu",eachSampleSize);
        CMSampleTimingInfo * timingInfoOut = (CMSampleTimingInfo *) malloc(sizeof(CMSampleTimingInfo));
        CMSampleBufferGetSampleTimingInfo (sampleBuffer, i, timingInfoOut);
        
        CMSampleTimingInfo sti = * timingInfoOut;
        printCMTime(sti.decodeTimeStamp,@"    ");
        printCMTime(sti.presentationTimeStamp,@"    ");
        printCMTime(sti.duration,@"    ");
        
        free(timingInfoOut);
        
    }
    
}



void printCFDictionaryRef(CFDictionaryRef formDict,CFIndex formDictCount)
{
    
    CFTypeRef * keysTypeRef = (CFTypeRef *) malloc( formDictCount * sizeof(CFTypeRef) );
    CFTypeRef * valuesTypeRef = (CFTypeRef *) malloc( formDictCount * sizeof(CFTypeRef) );
    
    
    ////CFTypeRef       是一个指向 const void    的指针
    //// typedef const void * CFTypeRef
    const void ** keysPointer = (const void **) keysTypeRef;
    const void ** valuesPointer = (const void **) valuesTypeRef;
    
    CFDictionaryGetKeysAndValues(formDict, keysPointer, valuesPointer);
    
    CFTypeRef ** keys =  (CFTypeRef ** ) keysPointer;
    CFTypeRef ** values =  (CFTypeRef ** ) valuesPointer;
    
    for (int i = 0; i<formDictCount ; i++ ) {
        ////CFShow(keys[i]);
        ////CFShow(values[i]);
        CFStringRef keyStr = (CFStringRef)keys[i];
        CFStringRef valueStr = (CFStringRef)values[i];
        NSLog(@"%@ = %@", keyStr, valueStr);
    }
    
    
    free(keysTypeRef);
    free(valuesTypeRef);
}







CFArrayRef getAndPrintAllSampleAttachments(CMSampleBufferRef sampleBuffer, BOOL noprint)
{
    //// this maybe a bug :  createIfNecessary
    //// Specifies whether an empty array should be created (if there are no sample attachments yet).
    //// not work
    CFArrayRef  sbufAttachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    
    if(sbufAttachments == NULL) {
        NSArray * tempArr = [[NSArray alloc] init];
        sbufAttachments = (__bridge CFArrayRef)tempArr;
    }
    
    
    CFIndex attachmentsCount = CFArrayGetCount(sbufAttachments);
    
    
    
    for (int i = 0; i< attachmentsCount; i++) {
        CFMutableDictionaryRef samples = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(sbufAttachments, i);
        CFIndex mdRefCount = CFDictionaryGetCount(samples);
        if (noprint) {
            
        } else {
            printCFDictionaryRef(samples,mdRefCount);
        }
    }
    
    return(sbufAttachments);
}



NSString * hexFromNSData(NSData* nsData)
{
    
    const unsigned char * data = [nsData bytes];
    NSUInteger len = nsData.length;
    NSMutableString * hex = [[NSMutableString alloc] init ];
    for(int i = 0; i < len; ++i) {
        [hex appendFormat:@"%02X", data[i]];
    }
    
    return [hex lowercaseString];
}


NSData * getH264Para (CMFormatDescriptionRef formDesc,int i)
{
    NSData *data;
    
    const uint8_t * paramenterSetPointerOut =  NULL;
    size_t parameterSetSizeOut,parameterSizeCountOut;
    int nalUnitHeaderLengthOut;
    
    
    CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formDesc, i, &paramenterSetPointerOut,&parameterSetSizeOut, &parameterSizeCountOut, &nalUnitHeaderLengthOut);
    
    data = [NSData dataWithBytes:paramenterSetPointerOut length:parameterSetSizeOut];
    
    
    NSLog(@"paramenterSetPointerOut:%@",hexFromNSData(data));
    NSLog(@"parameterSetSizeOut:%zu",parameterSetSizeOut);
    NSLog(@"parameterSizeCountOut:%zu",parameterSizeCountOut);
    NSLog(@"nalUnitHeaderLengthOut:%d",nalUnitHeaderLengthOut);
    
    return(data);
    
}









void printParameterSets(CMSampleBufferRef sampleBuffer)
{
    
    
    CMFormatDescriptionRef description = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    // Find out how many parameter sets there are
    size_t numberOfParameterSets;
    CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description,
                                                       0, NULL, NULL,
                                                       &numberOfParameterSets,
                                                       NULL);
    
    NSLog(@"numberOfParameterSets:%zu",numberOfParameterSets);
    NSLog(@"description:%@",description);
    
    // Write each parameter set to the elementary stream
    for (int i = 0; i < numberOfParameterSets; i++) {
        const uint8_t *parameterSetPointer;
        size_t parameterSetLength;
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description,
                                                           i,
                                                           &parameterSetPointer,
                                                           &parameterSetLength,
                                                           NULL, NULL);
        
        NSLog(@"---------------------------------------------");
        getH264Para(description,i);
        NSLog(@"---------------------------------------------");
        
    }
}



CMFormatDescriptionRef getVideoTrack_I_Descs(NSArray * videoTracks,int i)
{
    NSArray * videoTracksDescs = [videoTracks[i] formatDescriptions];
    
    CMFormatDescriptionRef formDesc = (__bridge CMFormatDescriptionRef)(videoTracksDescs[i]);
    
    ////CFDictionaryRef extensions = CMFormatDescriptionGetExtensions(formDesc);
    
    ////CMVideoCodecType codecType = CMFormatDescriptionGetMediaSubType(formDesc);
    
    ////CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formDesc);
    
    ////CMVideoFormatDescriptionCreate(kCFAllocatorDefault, codecType, dimensions.width, dimensions.height, extensions, &formDesc);
    
    return(formDesc);
    
    
}




void printVideoMediaSubType(CMFormatDescriptionRef formDesc)
{
    
    
    /*
     proc to_fourCharCode { str } {
     binary scan  $str c*  x
     set new {}
     append new [format %02x [lindex $x 0]]
     append new [format %02x [lindex $x 1]]
     append new [format %02x [lindex $x 2]]
     append new [format %02x [lindex $x 3]]
     set rslt [format %d 0x$new]
     return $rslt
     }
     
     proc hex2ascii { hex } {
     set new {}
     set hex_len [string length $hex]
     for {set i 0 } { $i < $hex_len } { incr i 2 } {
     append new [binary format c 0x[string range $hex $i [expr $i + 1]]]
     }
     return $new
     }
     
     */
    
    /*
     enum {
     kCMVideoCodecType_422YpCbCr8       = kCMPixelFormat_422YpCbCr8,
     846624121                        '2vuy'
     kCMVideoCodecType_Animation        = 'rle ',
     kCMVideoCodecType_Cinepak          = 'cvid',
     kCMVideoCodecType_JPEG             = 'jpeg',
     kCMVideoCodecType_JPEG_OpenDML     = 'dmb1',
     kCMVideoCodecType_SorensonVideo    = 'SVQ1',
     
     kCMVideoCodecType_SorensonVideo3   = 'SVQ3',
     kCMVideoCodecType_H263             = 'h263',
     kCMVideoCodecType_H264             = 'avc1',
     kCMVideoCodecType_MPEG4Video       = 'mp4v',
     kCMVideoCodecType_MPEG2Video       = 'mp2v',
     kCMVideoCodecType_MPEG1Video       = 'mp1v',
     
     kCMVideoCodecType_DVCNTSC          = 'dvc ',
     kCMVideoCodecType_DVCPAL           = 'dvcp',
     kCMVideoCodecType_DVCProPAL        = 'dvpp',
     kCMVideoCodecType_DVCPro50NTSC     = 'dv5n',
     kCMVideoCodecType_DVCPro50PAL      = 'dv5p',
     kCMVideoCodecType_DVCPROHD720p60   = 'dvhp',
     kCMVideoCodecType_DVCPROHD720p50   = 'dvhq',
     kCMVideoCodecType_DVCPROHD1080i60  = 'dvh6',
     kCMVideoCodecType_DVCPROHD1080i50  = 'dvh5',
     kCMVideoCodecType_DVCPROHD1080p30  = 'dvh3',
     kCMVideoCodecType_DVCPROHD1080p25  = 'dvh2',
     };
     typedef FourCharCode CMVideoCodecType;
     */
    unsigned int cond = (unsigned int)CMFormatDescriptionGetMediaSubType(formDesc);
    if (cond == 846624121) {
        
        NSLog(@"kCMVideoCodecType_422YpCbCr8       = kCMPixelFormat_422YpCbCr8('2vuy')");
    }
    if (cond == 1919706400) {
        
        NSLog(@"kCMVideoCodecType_Animation        = 'rle '");
    }
    if (cond == 1668704612) {
        
        NSLog(@"kCMVideoCodecType_Cinepak          = 'cvid'");
    }
    if (cond == 1785750887) {
        
        NSLog(@"kCMVideoCodecType_JPEG             = 'jpeg'");
    }
    if (cond == 1684890161 ) {
        
        NSLog(@"kCMVideoCodecType_JPEG_OpenDML     = 'dmb1'");
    }
    if (cond == 1398165809) {
        
        NSLog(@"kCMVideoCodecType_SorensonVideo    = 'SVQ1'");
    }
    if (cond == 1398165811 ) {
        
        NSLog(@"kCMVideoCodecType_SorensonVideo3   = 'SVQ3'");
    }
    if (cond == 1748121139) {
        
        NSLog(@"kCMVideoCodecType_H263             = 'h263'");
    }
    if (cond == 1635148593) {
        
        NSLog(@"kCMVideoCodecType_H264             = 'avc1'");
    }
    if (cond == 1836070006) {
        
        NSLog(@"kCMVideoCodecType_MPEG4Video       = 'mp4v'");
    }
    if (cond == 1836069494) {
        
        NSLog(@"kCMVideoCodecType_MPEG2Video       = 'mp2v'");
    }
    if (cond == 1836069238) {
        
        NSLog(@"kCMVideoCodecType_MPEG1Video       = 'mp1v'");
    }
    if (cond == 1685480224) {
        
        NSLog(@"kCMVideoCodecType_DVCNTSC          = 'dvc '");
    }
    if (cond == 1685480304) {
        
        NSLog(@"kCMVideoCodecType_DVCPAL           = 'dvcp'");
    }
    if (cond == 1685483632) {
        
        NSLog(@"kCMVideoCodecType_DVCProPAL        = 'dvpp'");
    }
    if (cond == 1685468526) {
        
        NSLog(@"kCMVideoCodecType_DVCPro50NTSC     = 'dv5n'");
    }
    if (cond == 1685468528) {
        
        NSLog(@"kCMVideoCodecType_DVCPro50PAL      = 'dv5p'");
    }
    if (cond == 1685481584) {
        
        NSLog(@"kCMVideoCodecType_DVCPROHD720p60   = 'dvhp'");
    }
    if (cond == 1685481585) {
        
        NSLog(@"kCMVideoCodecType_DVCPROHD720p50   = 'dvhq'");
    }
    if (cond == 1685481526) {
        
        NSLog(@"kCMVideoCodecType_DVCPROHD1080i60  = 'dvh6'");
    }
    if (cond == 1685481525) {
        
        NSLog(@"kCMVideoCodecType_DVCPROHD1080i60  = 'dvh5'");
    }
    if (cond == 1685481523) {
        
        NSLog(@"kCMVideoCodecType_DVCPROHD1080i60  = 'dvh3'");
    }
    if (cond == 1685481522) {
        
        NSLog(@"kCMVideoCodecType_DVCPROHD1080i60  = 'dvh2'");
    }
    
}





void printMediaType(CMFormatDescriptionRef formDesc)
{
    
    
    /*
     enum {
     kCMMediaType_Video               = 'vide',
     kCMMediaType_Audio               = 'soun',
     kCMMediaType_Muxed               = 'muxx',
     kCMMediaType_Text                = 'text',
     kCMMediaType_ClosedCaption       = 'clcp',
     kCMMediaType_Subtitle            = 'sbtl',
     kCMMediaType_TimeCode            = 'tmcd',
     kCMMediaType_TimedMetadata       = 'tmet',
     kCMMediaType_Metadata            = 'meta'
     };
     typedef FourCharCode CMMediaType;
     
     
     +	{
     +		Video         = 1986618469, // 'vide'
     ////1986618469 = 0x76696465  ASCII 'vide'
     +		Audio         = 1936684398, // 'soun'
     ////1936684398 = 0x736f756e  ASCII 'soun'
     +		Muxed         = 1836415096, // 'muxx'
     
     +		Text          = 1952807028, // 'text'
     +		ClosedCaption = 1668047728, // 'clcp'
     +		Subtitle      = 1935832172, // 'sbtl'
     +		TimeCode      = 1953325924, // 'tmcd'
     +		TimedMetadata = 1953326452, // 'tmet'
     +	}
     
     
     
     */
    
    
    
    unsigned int cond = (unsigned int)CMFormatDescriptionGetMediaType(formDesc);
    
    
    if (cond == 1986618469) {
        
        NSLog(@"kCMMediaType_Video               = 'vide'");
    }
    if (cond == 1936684398) {
        
        NSLog(@"kCMMediaType_Audio               = 'soun'");
    }
    if (cond == 1836415096) {
        
        NSLog(@"kCMMediaType_Muxed               = 'muxx'");
    }
    if (cond == 1952807028) {
        
        NSLog(@"kCMMediaType_Text                = 'text'");
    }
    if (cond == 1668047728) {
        
        NSLog(@"kCMMediaType_ClosedCaption       = 'clcp'");
    }
    if (cond == 1935832172) {
        
        NSLog(@"kCMMediaType_Subtitle            = 'sbtl'");
    }
    if (cond == 1953325924) {
        
        NSLog(@"kCMMediaType_TimeCode            = 'tmcd'");
    }
    if (cond == 1953326452) {
        
        NSLog(@"kCMMediaType_TimedMetadata       = 'tmet'");
    }
    if (cond == 1835365473) {
        
        NSLog(@"kCMMediaType_Metadata            = 'meta'");
    }
}




BOOL isH264IFrame(CMSampleBufferRef sampleBuffer)
{
    // Find out if the sample buffer contains an I-Frame.
    // If so we will write the SPS and PPS NAL units to the elementary stream.
    BOOL isIFrame = NO;
    CFArrayRef attachmentsArray = getAndPrintAllSampleAttachments(sampleBuffer,YES);
    
    
    if (CFArrayGetCount(attachmentsArray)) {
        CFBooleanRef notSync;
        CFDictionaryRef dict = CFArrayGetValueAtIndex(attachmentsArray, 0);
        BOOL keyExists = CFDictionaryGetValueIfPresent(dict,
                                                       kCMSampleAttachmentKey_NotSync,
                                                       (const void **)&notSync);
        // An I-Frame is a sync frame
        isIFrame = !keyExists || !CFBooleanGetValue(notSync);
    }
    
    ////NSLog(@"isIFrame:%d",isIFrame);
    return(isIFrame);
}







NSData * copyDataFromBlock(CMSampleBufferRef sampleBuffer)
{
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t size = CMBlockBufferGetDataLength(blockBuffer);
    void *sampleData = malloc(size);
    CMBlockBufferCopyDataBytes(blockBuffer, 0, size, sampleData);
    NSData * data = [NSData dataWithBytes:sampleData length:size];
    
    ////avoid potential leak of sampleData
    free(sampleData);
    
    return(data);
}

CFMutableDictionaryRef  getBlockTimingInfo(CMSampleBufferRef sampleBuffer)
{
    CMItemCount timingCount;
    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &timingCount);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * timingCount);
    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, timingCount, pInfo, &timingCount);
    
    CFMutableDictionaryRef theDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    const void *key1 = @"count";
    const void *key2 = @"pInfo";
    
    CFDictionaryAddValue(theDict, key1, &timingCount);
    CFDictionaryAddValue(theDict, key2, pInfo);
    
    return(theDict);
    
}



CFMutableDictionaryRef  getBlocksizeArrayOut(CMSampleBufferRef sampleBuffer)
{
    ////sizeArrayOut 包括 4 字节 长度指示
    CMItemCount sizeArrayEntries;
    CMSampleBufferGetSampleSizeArray(sampleBuffer, 0, nil, &sizeArrayEntries);
    size_t * sizeArrayOut = malloc(sizeof(size_t) * sizeArrayEntries);
    CMSampleBufferGetSampleSizeArray(sampleBuffer, sizeArrayEntries, sizeArrayOut, &sizeArrayEntries);
    
    CFMutableDictionaryRef theDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    const void *key1 = @"count";
    const void *key2 = @"sizeArrayOut";
    
    CFDictionaryAddValue(theDict, key1, &sizeArrayEntries);
    CFDictionaryAddValue(theDict, key2, sizeArrayOut);
    
    return(theDict);
    
}



int roundSecondsToCorrespondingCMTUnit(float seconds,CMTime cmt)
{
    float durationSeconds = cmt.value/cmt.timescale;
    int realInterval = (int)(cmt.value * seconds/durationSeconds);
    return(realInterval);
}

float roundCMTUnitToCorrespondingSeconds(int unit,CMTime cmt)
{
    float durationSeconds = cmt.value/cmt.timescale;
    float seconds = (float)(durationSeconds * unit/cmt.value);
    return(seconds);
}




BOOL CMTimeDurationLT(CMTime cmt1,CMTime cmt2)
{
    return(cmt1.value * cmt2.timescale < cmt2.value * cmt1.timescale);
}
BOOL CMTimeDurationLE(CMTime cmt1,CMTime cmt2)
{
    return(cmt1.value * cmt2.timescale <= cmt2.value * cmt1.timescale);
}
BOOL CMTimeDurationEQ(CMTime cmt1,CMTime cmt2)
{
    return(cmt1.value * cmt2.timescale == cmt2.value * cmt1.timescale);
}
BOOL CMTimeDurationGE(CMTime cmt1,CMTime cmt2)
{
    return(cmt1.value * cmt2.timescale >= cmt2.value * cmt1.timescale);
}
BOOL CMTimeDurationGT(CMTime cmt1,CMTime cmt2)
{
    return(cmt1.value * cmt2.timescale > cmt2.value * cmt1.timescale);
}


int getNominalFrameRate(AVAsset *someAsset, int seq)
{
    NSError *outError;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:someAsset error:&outError];
    
    
    
    NSArray * videoTracks = [assetReader.asset tracksWithMediaType:AVMediaTypeVideo];
    
    
    AVAssetTrack * vt = (AVAssetTrack *) videoTracks[seq];
    
    float result = vt.nominalFrameRate;
    
    return((int) result);
    
    
}


CGSize getNaturalSize(AVAsset *someAsset, int seq)
{
    NSError *outError;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:someAsset error:&outError];
    
    
    
    NSArray * videoTracks = [assetReader.asset tracksWithMediaType:AVMediaTypeVideo];
    
    
    AVAssetTrack * vt = (AVAssetTrack *) videoTracks[seq];
    
    CGSize result = vt.naturalSize;
    
    return(result);
    
    
}



void checkAVAssetWriterStatus(AVAssetWriter * videoWriter)
{
    switch (videoWriter.status) {
        case AVAssetWriterStatusUnknown:
        {
            NSLog(@"encoder->videoWriter.status:AVAssetWriterStatusUnknown:%ld",(long)videoWriter.status);
            break;
        }
        case AVAssetWriterStatusWriting:
        {
            NSLog(@"encoder->videoWriter.status:AVAssetWriterStatusWriting:%ld",(long)videoWriter.status);
            break;
        }
        case AVAssetWriterStatusCompleted:
        {
            NSLog(@"encoder->videoWriter.status:AVAssetWriterStatusCompleted:%ld",(long)videoWriter.status);
            break;
        }
        case AVAssetWriterStatusFailed:
        {
            NSLog(@"encoder->videoWriter.status:AVAssetWriterStatusFailed:%ld",(long)videoWriter.status);
            break;
        }
            
        case AVAssetWriterStatusCancelled:
        {
            NSLog(@"encoder->videoWriter.status:AVAssetWriterStatusCancelled:%ld",(long)videoWriter.status);
            break;
        }
        default:
        {
            NSLog(@"encoder->videoWriter.status:AVAssetWriterStatus:%ld",(long)videoWriter.status);
            break;
        }
    }
}




NSMutableArray * generateIndicationImagesFromAVAssetWithSecondsInterval(AVAsset * asset ,float interval,float width,float height)
{
    ////--dont USE this directly in viewDidLoad
    /*
    @implementation
    UIImage * interTempImage;
    @end
     -(void) test
    {
        UIImage * testImg = concatImagesWithWidth(generateIndicationImagesFromAVAssetWithSecondsInterval(self.asset1 ,secondsInterval,30.0,30.0),CGSizeMake(400,30.0))
        interTempImage = testImg;
    }
    
    -(void)viewDidLoad
    {
        [self test];
        
    }
    */
    
    CMTime cmtDuration = asset.duration;
    
    
    int realInterval = roundSecondsToCorrespondingCMTUnit(interval,cmtDuration);
    
    
    return(generateIndicationImagesFromAVAssetWithCMTUnitInterval(asset ,realInterval,width,height));
    
    
    
}




NSMutableArray * generateIndicationImagesFromAVAssetWithCMTUnitInterval(AVAsset * asset ,int realInterval,float width,float height)
{
    ////--dont USE this directly in viewDidLoad
    
    CMTime cmtDuration = asset.duration;
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    
    NSMutableArray * indicationImgsCMTime =  [[NSMutableArray  alloc]init];
    NSMutableArray * indicationImgsArray = [[NSMutableArray  alloc]init];
    
    
    
    
    int currSeq = 1;
    
    while ( currSeq < cmtDuration.value) {
        currSeq = currSeq + realInterval;
        
        NSError *err = NULL;
        CMTime time = CMTimeMake(currSeq, cmtDuration.timescale);
        
        [indicationImgsCMTime addObject:[NSValue valueWithCMTime:time]];
        
        
        CGImageRef oneRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage * img = [[UIImage alloc] initWithCGImage:oneRef];
        CGImageRelease(oneRef);
        
        
        if (img == NULL) {
            
        } else {
            
            img = imageResize(img, CGSizeMake(width, height));
            if (img == NULL) {
                
            } else {
                [indicationImgsArray addObject:img];
                
            }
        }
        
        
    }
    
    
    return(indicationImgsArray);
    
    
}



int getAVGRealInterval(AVAsset*asset,float totalLength,float eachLength)
{
    CMTime dura = asset.duration;
    int count = (int) (totalLength / eachLength);
    int rslt = (int) (dura.value/count);
    return(rslt);
}

float getAVGSecondsInterval(AVAsset*asset,float totalLength,float eachLength)
{
    CMTime dura = asset.duration;
    float count = totalLength / eachLength;
    float rslt = dura.value/count;
    float seconds = rslt / dura.timescale;
    return(seconds);
}




NSMutableArray * sortTracksArrayViaCMTDuration (NSMutableArray * tracks)
{
    NSMutableArray *  resortedTracks = [[NSMutableArray alloc] init];
    
    resortedTracks = [tracks mutableCopy];
    
    [resortedTracks sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        AVAssetTrack * o1 = (AVAssetTrack *) obj1;
        AVAssetTrack * o2 = (AVAssetTrack *) obj2;
        
        CMTime  pt1 = o1.timeRange.duration ;
        CMTime  pt2 = o2.timeRange.duration ;
        
        
        return( CMTimeCompare(pt1, pt2) );
    }];
    
    
    
    
    NSLog(@"tracks.count:%lu",(unsigned long)tracks.count);
    
    
    for (int i =0 ; i<tracks.count; i++) {
        
        NSLog(@"tracks[%d]:%@",i,tracks[i]);
        AVAssetTrack * tempTrack = (AVAssetTrack *)tracks[i];
        CMTimeShow(tempTrack.timeRange.duration);
    }
    
    NSLog(@"resortedTracks.count:%lu",(unsigned long)resortedTracks.count);
    
    
    for (int i =0 ; i<resortedTracks.count; i++) {
        
        NSLog(@"resortedTracks[%d]:%@",i,resortedTracks[i]);
        AVAssetTrack * tempTrack = (AVAssetTrack *)resortedTracks[i];
        CMTimeShow(tempTrack.timeRange.duration);
    }
    
    return(resortedTracks);
    
}



AVAssetTrack * getMaxCMTDurationTrackFromTracksArray(NSMutableArray * tracks)
{
    NSMutableArray * sorted = sortTracksArrayViaCMTDuration (tracks);
    
    return(sorted[sorted.count -1]);
    
}
AVAssetTrack * getMinCMTDurationTrackFromTracksArray(NSMutableArray * tracks)
{
    NSMutableArray * sorted = sortTracksArrayViaCMTDuration (tracks);
    
    return(sorted[0]);
}



void printCGAffineTransform(CGAffineTransform  transform)
{
    
    NSLog(@" a:%1f, b:%1f,0",transform.a,transform.b);
    NSLog(@" c:%1f, d:%1f,0",transform.c,transform.d);
    NSLog(@"tx:%lf ty:%1f 1",transform.tx,transform.ty);
}


NSMutableArray * addCMTimeRangeToNSMutableArray(NSMutableArray * ma ,CMTimeRange timerange)
{
    [ma addObject:[NSValue valueWithCMTimeRange:timerange]];
    return(ma);
}

NSMutableArray * addCMTimeToNSMutableArray(NSMutableArray * ma ,CMTime time)
{
    [ma addObject:[NSValue valueWithCMTime:time]];
    return(ma);
}


NSMutableArray * addCMTimeMappingToNSMutableArray(NSMutableArray * ma ,CMTimeMapping timemapping)
{
    [ma addObject:[NSValue valueWithCMTimeMapping:timemapping]];
    return(ma);
}

NSMutableArray * addCGSizeToNSMutableArray(NSMutableArray * ma ,CGSize size)
{
    [ma addObject:[NSValue valueWithCGSize:size]];
    return(ma);
}
NSMutableArray * addCGPointToNSMutableArray(NSMutableArray * ma ,CGPoint point)
{
    [ma addObject:[NSValue valueWithCGPoint:point]];
    return(ma);
}


NSMutableArray * sortTracksArrayViaNominalFrameRate (NSMutableArray * tracks)
{
    NSMutableArray *  resortedTracks = [[NSMutableArray alloc] init];
    
    resortedTracks = [tracks mutableCopy];
    
    [resortedTracks sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        AVAssetTrack * o1 = (AVAssetTrack *) obj1;
        AVAssetTrack * o2 = (AVAssetTrack *) obj2;
        
        
        
        float  pt1 = [o1 nominalFrameRate] ;
        float  pt2 = [o2 nominalFrameRate] ;
        
        if (pt1 > pt2) {
            return(1);
        } else if (pt1 == pt2) {
            return(0);
        } else {
            return(-1);
        }

    }];
    
    
    
    
    NSLog(@"tracks.count:%lu",(unsigned long)tracks.count);
    
    
    for (int i =0 ; i<tracks.count; i++) {
        
        NSLog(@"tracks[%d]:%@",i,tracks[i]);
        AVAssetTrack * tempTrack = (AVAssetTrack *)tracks[i];
        CMTimeShow(tempTrack.timeRange.duration);
        
    }
    
    NSLog(@"resortedTracks.count:%lu",(unsigned long)resortedTracks.count);
    
    
    for (int i =0 ; i<resortedTracks.count; i++) {
        
        NSLog(@"resortedTracks[%d]:%@",i,resortedTracks[i]);
        AVAssetTrack * tempTrack = (AVAssetTrack *)resortedTracks[i];
        CMTimeShow(tempTrack.timeRange.duration);
    }
    
    return(resortedTracks);
}


AVAssetTrack * getMaxNominalFrameRateTrackFromTracksArray(NSMutableArray * tracks)
{
    NSMutableArray * sorted = sortTracksArrayViaNominalFrameRate (tracks);
    
    return(sorted[sorted.count -1]);
 
}
AVAssetTrack * getMinNominalFrameRateTrackFromTracksArray(NSMutableArray * tracks)
{
    NSMutableArray * sorted = sortTracksArrayViaNominalFrameRate (tracks);
    
    return(sorted[0]);
}

void CMSampleTimeInfoShow(CMSampleBufferRef sampleBuffer)
{
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, count, pInfo, &count);
    for (int i = 0 ; i < (int)count; i++) {
        NSLog(@"begin---------------%d------------begin",i);
        CMTimeShow(pInfo[i].presentationTimeStamp);
        CMTimeShow(pInfo[i].decodeTimeStamp);
        CMTimeShow(pInfo[i].duration);
        NSLog(@"end---------------%d------------end",i);
        NSLog(@"");
        
    }
}




NSMutableArray * selectAudioTracksFromAVAssetWithTracksSelection(AVAsset* asset,NSMutableArray*indexes)
{
    NSError *outError;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&outError];
    NSMutableArray * audioTracks = [[NSMutableArray alloc] initWithArray:[assetReader.asset tracksWithMediaType:AVMediaTypeAudio] copyItems:YES];
    
    NSMutableArray * selectedAudioTracks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)audioTracks[index];
        
        [selectedAudioTracks addObject:track];
        
    }
    
    return(selectedAudioTracks);
}


NSMutableArray  * selectVideoTracksFromAVAssetWithTracksSelection(AVAsset* asset,NSMutableArray*indexes)
{
    NSError *outError;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&outError];
    NSMutableArray * videoTracks = [[NSMutableArray alloc] initWithArray:[assetReader.asset tracksWithMediaType:AVMediaTypeVideo] copyItems:YES];
    
    NSMutableArray * selectedVideoTracks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)videoTracks[index];
        
        [selectedVideoTracks addObject:track];
        
    }
    
    return(selectedVideoTracks);
    
    
}




NSMutableArray * selectAllAudioTracksFromAVAsset(AVAsset* asset)
{
    ////---tested
    
    NSMutableArray * audioTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeAudio] copyItems:YES];
    return(audioTracks);
    
    
}


NSMutableArray * selectAllVideoTracksFromAVAsset(AVAsset* asset)
{
    ////---tested
    NSMutableArray * videoTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeVideo] copyItems:YES];
    return(videoTracks);
}




NSDictionary * selectAudioTracksFromMovieURLTracksSelection(NSURL*sourceMovieURL,NSMutableArray*indexes)
{
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:sourceMovieURL options:nil];
    
    NSDictionary * rslt = [NSDictionary dictionaryWithObjectsAndKeys:selectAudioTracksFromAVAssetWithTracksSelection(asset, indexes),@"tracks",asset,@"asset",nil];
    
    return(rslt);
}


NSDictionary  * selectVideoTracksFromMovieURLTracksSelection(NSURL*sourceMovieURL,NSMutableArray*indexes)
{
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:sourceMovieURL options:nil];
    
    
    NSDictionary * rslt = [NSDictionary dictionaryWithObjectsAndKeys:selectVideoTracksFromAVAssetWithTracksSelection(asset, indexes),@"tracks",asset,@"asset",nil];
    
    return(rslt);
    
}






NSDictionary * selectAllAudioTracksFromMovieURL(NSURL*sourceMovieURL)
{
    
    ////---this function has already been tested its OK
    AVAsset *asset = [AVAsset assetWithURL:sourceMovieURL] ;
    
    
    NSDictionary * rslt = [NSDictionary dictionaryWithObjectsAndKeys:selectAllAudioTracksFromAVAsset(asset),@"tracks",asset,@"asset",nil];
    
    return(rslt);
    
}


NSDictionary * selectAllVideoTracksFromMovieURL(NSURL*sourceMovieURL)
{
    
    ////---this function has already been tested its OK
    AVAsset *asset = [AVAsset assetWithURL:sourceMovieURL];
    
    NSDictionary * rslt = [NSDictionary dictionaryWithObjectsAndKeys:selectAllVideoTracksFromAVAsset(asset),@"tracks",asset,@"asset",nil];
    
    return(rslt);
}




////--part2: puts selected tracks into array

NSMutableArray * putsAllAudioTracksIntoTracksArrayFromAssets(NSMutableArray * assets)
{
    ////--tested
    NSMutableArray * audioTracks = [[NSMutableArray alloc] init];
    
    for (int i =0; i<assets.count; i++) {
        
        NSMutableArray * tempAudioTracks = [[NSMutableArray alloc] init];
        tempAudioTracks = selectAllAudioTracksFromAVAsset(assets[i]);
        
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            [audioTracks addObject:tempAudioTracks[j]];
        }
    }
    
    return(audioTracks);
    
}

NSMutableArray * putsAllVideoTracksIntoTracksArrayFromAssets(NSMutableArray * assets)
{
    ////-tested
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    
    for (int i =0; i<assets.count; i++) {
        
        
        NSMutableArray * tempVideoTracks = [[NSMutableArray alloc] init];
        
        tempVideoTracks = selectAllVideoTracksFromAVAsset(assets[i]);
        
        for (int j =0; j< tempVideoTracks.count; j++) {
            [videoTracks addObject:tempVideoTracks[j]];
        }
    }
    
    return(videoTracks);
}



NSMutableArray * putsAllAudioTracksIntoTracksWithAssetArrayFromSourceURLs(NSMutableArray * sourceMovieURLs)
{
    NSMutableArray * audioTracksWithAsset = [[NSMutableArray alloc] init];
    
    for (int i =0; i<sourceMovieURLs.count; i++) {
        
        NSDictionary * tempTracksAssetDict = selectAllAudioTracksFromMovieURL(sourceMovieURLs[i]);
        
        AVAsset * tempAsset = [tempTracksAssetDict valueForKey:@"asset"];
        NSMutableArray * tempAudioTracks = [[NSMutableArray alloc] init];
        tempAudioTracks = [tempTracksAssetDict valueForKey:@"tracks"];
        
        
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            
            NSDictionary * rslt = [NSDictionary dictionaryWithObjectsAndKeys:tempAudioTracks[j],@"track",tempAsset,@"asset",nil];
            
            [audioTracksWithAsset addObject:rslt];
        }
    }
    
    return(audioTracksWithAsset);
}


NSMutableArray * putsAllVideoTracksIntoTracksWithAssetArrayFromSourceURLs(NSMutableArray * sourceMovieURLs)
{
    NSMutableArray * videoTracksWithAsset = [[NSMutableArray alloc] init];
    
    for (int i =0; i<sourceMovieURLs.count; i++) {
        
        
        
        NSDictionary * tempTracksAssetDict = selectAllVideoTracksFromMovieURL(sourceMovieURLs[i]);
        
        
        AVAsset * tempAsset = [tempTracksAssetDict valueForKey:@"asset"];
        NSMutableArray * tempVideoTracks = [[NSMutableArray alloc] init];
        tempVideoTracks = [tempTracksAssetDict valueForKey:@"tracks"];
        
        
        
        for (int j =0; j< tempVideoTracks.count; j++) {
            
            NSDictionary * rslt = [NSDictionary dictionaryWithObjectsAndKeys:tempVideoTracks[j],@"track",tempAsset,@"asset",nil];
            
            [videoTracksWithAsset addObject:rslt];
        }
    }
    
    return(videoTracksWithAsset);
}



NSMutableArray * getAllTracksFromTracksWithAssetArray(NSMutableArray* tracksWithAsset)
{
    NSMutableArray * tracks = [[NSMutableArray alloc] init];
    for (int i =0; i<tracksWithAsset.count; i++) {
        [tracks addObject:[tracksWithAsset[i] valueForKey:@"track"]];
    }
    return(tracks);
}






////-part3.1

NSNumber * whichPT(CGAffineTransform t2)
{
    NSNumber * rslt = [[NSNumber alloc] init];
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        rslt = [NSNumber numberWithInt:HomeButtonAtBottom];
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        rslt = [NSNumber numberWithInt:HomeButtonAtRight];
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        rslt = [NSNumber numberWithInt:HomeButtonAtLeft];
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        rslt = [NSNumber numberWithInt:HomeButtonAtTop];
    } else {
        rslt = [NSNumber numberWithInt:HomeButtonAtRight];
    }
    
    return(rslt);
}


CGSize acturalSizeToInternalSize(CGSize acturalSize,CGAffineTransform t2)
{
    CGSize rslt = CGSizeMake(0.0, 0.0);
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        rslt.width = acturalSize.height;
        rslt.height = acturalSize.width;
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        rslt.width = acturalSize.width;
        rslt.height = acturalSize.height;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        rslt.width = acturalSize.width;
        rslt.height = acturalSize.height;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        rslt.width = acturalSize.height;
        rslt.height = acturalSize.width;
    } else {
        rslt.width = acturalSize.width;
        rslt.height = acturalSize.height;
    }
    
    return(rslt);
}
CGSize internalSizeToActuralSize(CGSize internalSize,CGAffineTransform t2)
{
    CGSize rslt = CGSizeMake(0.0, 0.0);
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        rslt.width = internalSize.height;
        rslt.height = internalSize.width;
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        rslt.width = internalSize.width;
        rslt.height = internalSize.height;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        rslt.width = internalSize.width;
        rslt.height = internalSize.height;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        rslt.width = internalSize.height;
        rslt.height = internalSize.width;
    } else {
        rslt.width = internalSize.width;
        rslt.height = internalSize.height;
    }
    
    return(rslt);
}











CGAffineTransform getUIImageOrientationUpToDownPT(float width,float height)
{
    //// rotate clockwise 180 deg
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = -1.0;
    t2.b = 0.0;
    t2.c = 0.0;
    t2.d = -1.0;
    t2.tx = width;
    t2.ty = height;
    
    return(t2);
}


CGAffineTransform getUIImageOrientationUpToLeftPT(float width,float height)
{
    ////rotate clockwise 90 deg
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = 0.0;
    t2.b = 1.0;
    t2.c = -1.0;
    t2.d = 0.0;
    t2.tx = height;
    t2.ty = 0.0;
    
    return(t2);
}
CGAffineTransform getUIImageOrientationUpToRightPT(float width,float height)
{
    
    ////rotate clockwise 270 deg
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = 0.0;
    t2.b = -1.0;
    t2.c = 1.0;
    t2.d = 0.0;
    t2.tx = 0.0;
    t2.ty = width;
    
    return(t2);
}

CGAffineTransform getUIImageOrientationDownToUpPT(float width,float height)
{
    
    //// rotate clockwise 180 deg
    //// shift x width
    //// shift y height
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = -1.0;
    t2.b = 0.0;
    t2.c = 0.0;
    t2.d = -1.0;
    t2.tx = width;
    t2.ty = height;
    
    return(t2);
}
CGAffineTransform getUIImageOrientationDownToLeftPT(float width,float height)
{
    //// rotate clockwise 270 deg
    //// shift x 0
    //// shift y width
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = 0.0;
    t2.b = -1.0;
    t2.c = 1.0;
    t2.d = 0.0;
    t2.tx = 0.0;
    t2.ty = width;
    
    return(t2);
}
CGAffineTransform getUIImageOrientationDownToRightPT(float width,float height)
{
    
    //// rotate clockwise 90 deg
    //// shift x height
    //// shift y 0
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = 0.0;
    t2.b = 1.0;
    t2.c = -1.0;
    t2.d = 0.0;
    t2.tx = height;
    t2.ty = 0.0;
    
    return(t2);
}


CGAffineTransform getUIImageOrientationLeftToUpPT(float width,float height)
{
    //// rotate clockwise 270 deg
    //// shift x 0
    //// shift y width
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = 0.0;
    t2.b = -1.0;
    t2.c = 1.0;
    t2.d = 0.0;
    t2.tx = 0.0;
    t2.ty = width;
    
    return(t2);
}


CGAffineTransform getUIImageOrientationLeftToDownPT(float width,float height)
{
    //// rotate clockwise 90 deg
    //// shift x height
    //// shift y 0
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = 0.0;
    t2.b = 1.0;
    t2.c = -1.0;
    t2.d = 0.0;
    t2.tx = height;
    t2.ty = 0.0;
    
    return(t2);
}
CGAffineTransform getUIImageOrientationLeftToRightPT(float width,float height)
{
    
    //// rotate clockwise 180 deg
    //// shift x width
    //// shift y height
    
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = -1.0;
    t2.b = 0.0;
    t2.c = 0.0;
    t2.d = -1.0;
    t2.tx = width;
    t2.ty = height;
    
    return(t2);
}

CGAffineTransform getUIImageOrientationRightToUpPT(float width,float height)
{
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = 0.0;
    t2.b = 1.0;
    t2.c = -1.0;
    t2.d = 0.0;
    t2.tx = height;
    t2.ty = 0.0;
    
    return(t2);
}
CGAffineTransform getUIImageOrientationRightToDownPT(float width,float height)
{
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = 0.0;
    t2.b = -1.0;
    t2.c = 1.0;
    t2.d = 0.0;
    t2.tx = 0.0;
    t2.ty = width;
    
    return(t2);
}
CGAffineTransform getUIImageOrientationRightToLeftPT(float width,float height)
{
    CGAffineTransform t2 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    t2.a = -1.0;
    t2.b = 0.0;
    t2.c = 0.0;
    t2.d = -1.0;
    t2.tx = width;
    t2.ty = height;
    
    return(t2);
}




CGPoint acturalPositionToInternalPosition(CGSize acturalSize,CGPoint acturalPoint,CGAffineTransform t2)
{
    
    float acturalWidth = acturalSize.width;
    float acturalHeight = acturalSize.height;
    
    
    CGPoint rslt = CGPointMake(0.0, 0.0);
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        //l2u
        CGAffineTransform l2u = getUIImageOrientationLeftToUpPT(acturalWidth, acturalHeight);
        rslt.x = l2u.a * acturalPoint.x + l2u.c * acturalPoint.y + l2u.tx;
        rslt.y = l2u.b * acturalPoint.x + l2u.d * acturalPoint.y + l2u.ty;
        
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        rslt.x = acturalPoint.x;
        rslt.y = acturalPoint.y;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        //d2u
        CGAffineTransform d2u = getUIImageOrientationDownToUpPT(acturalWidth, acturalHeight);
        rslt.x = d2u.a * acturalPoint.x + d2u.c * acturalPoint.y + d2u.tx;
        rslt.y = d2u.b * acturalPoint.x + d2u.d * acturalPoint.y + d2u.ty;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        //r2u
        CGAffineTransform r2u = getUIImageOrientationRightToUpPT(acturalWidth, acturalHeight);
        rslt.x = r2u.a * acturalPoint.x + r2u.c * acturalPoint.y + r2u.tx;
        rslt.y = r2u.b * acturalPoint.x + r2u.d * acturalPoint.y + r2u.ty;
        
    } else {
        rslt.x = acturalPoint.x;
        rslt.y = acturalPoint.y;
    }
    
    return(rslt);
}

CGPoint internalPositionToActuralPosition(CGPoint internalPoint,CGAffineTransform t2)
{
    CGPoint rslt = CGPointMake(0.0, 0.0);
    rslt.x = t2.a * internalPoint.x + t2.c * internalPoint.y + t2.tx;
    rslt.y = t2.b * internalPoint.x + t2.d * internalPoint.y + t2.ty;
    return(rslt);
}







NSMutableDictionary * getVideoRecordingOrientationFromSourceAsset(AVAsset*asset,int whichTrack)
{
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    CGAffineTransform t2 = [videoTrack preferredTransform];
    NSMutableDictionary * rslt = [[NSMutableDictionary alloc] initWithCapacity:6];
    
    
    
    
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        NSNumber * enumV = [NSNumber numberWithInt:2];
        [rslt setObject:enumV forKey:@"HumanOrientation"];
        [rslt setObject:enumV forKey:@"HomeButtonOrientation"];
        [rslt setObject:enumV forKey:@"UIImageOrientation"];
        [rslt setObject:@"HumanUp" forKey:@"HumanOrientationDescription"];
        [rslt setObject:@"HomeButtonAtBottom" forKey:@"HomeButtonOrientationDescription"];
        [rslt setObject:@"UIImageOrientationLeft" forKey:@"UIImageOrientationDescription"];
        
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        NSNumber * enumV = [NSNumber numberWithInt:0];
        [rslt setObject:enumV forKey:@"HumanOrientation"];
        [rslt setObject:enumV forKey:@"HomeButtonOrientation"];
        [rslt setObject:enumV forKey:@"UIImageOrientation"];
        [rslt setObject:@"HumanRight" forKey:@"HumanOrientationDescription"];
        [rslt setObject:@"HomeButtonAtRight" forKey:@"HomeButtonOrientationDescription"];
        [rslt setObject:@"UIImageOrientationUp" forKey:@"UIImageOrientationDescription"];
        
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        
        NSNumber * enumV = [NSNumber numberWithInt:1];
        [rslt setObject:enumV forKey:@"HumanOrientation"];
        [rslt setObject:enumV forKey:@"HomeButtonOrientation"];
        [rslt setObject:enumV forKey:@"UIImageOrientation"];
        [rslt setObject:@"HumanLeft" forKey:@"HumanOrientationDescription"];
        [rslt setObject:@"HomeButtonAtLeft" forKey:@"HomeButtonOrientationDescription"];
        [rslt setObject:@"UIImageOrientationDown" forKey:@"UIImageOrientationDescription"];
        
        
        
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        
        NSNumber * enumV = [NSNumber numberWithInt:3];
        [rslt setObject:enumV forKey:@"HumanOrientation"];
        [rslt setObject:enumV forKey:@"HomeButtonOrientation"];
        [rslt setObject:enumV forKey:@"UIImageOrientation"];
        [rslt setObject:@"HumanDown" forKey:@"HumanOrientationDescription"];
        [rslt setObject:@"HomeButtonAtTop" forKey:@"HomeButtonOrientationDescription"];
        [rslt setObject:@"UIImageOrientationRight" forKey:@"UIImageOrientationDescription"];
        
        
    } else {
        
    }
    
    NSLog(@"if  preferedTransform  info  is losted ,the orientaion  is UIImageOrientationUp:which means HomeButtonAtRight / HumanRight");
    NSLog(@"%@",rslt);
    
    return(rslt);
    
}

NSMutableDictionary * getVideoRecordingOrientationFromSourceURL(NSURL*sourceURL,int whichTrack)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(getVideoRecordingOrientationFromSourceAsset(asset,whichTrack));
}



NSURL * getInternalVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL)
{
    NSString * tempPath = [destinationURL path];
    
    [FileUitl deleteTmpFile:tempPath];
    
    
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    mainVideoComp.renderSize = videoTrack.naturalSize;
    
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    return(destinationURL);
}

NSURL * getInternalVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(getInternalVideoFromSourceAsset(asset,whichTrack,destinationURL));
}



NSURL * resizeVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,CGSize size)
{
    NSString * tempPath = [destinationURL path];
    
    [FileUitl deleteTmpFile:tempPath];
    
    
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    CGAffineTransform t2 = [videoTrack preferredTransform];
    //// if use back camera  , rotate degree is clock wise when using settransform
    //// if use front camera , rotate degree is clock wise when using settransform
    NSLog(@"---------------------");
    printCGAffineTransform(t2);
    NSLog(@"---------------------");
    
    
    float widthScale;
    float heightScale;
    
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        widthScale = size.width / videoTrack.naturalSize.height;
        heightScale = size.height / videoTrack.naturalSize.width;
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        widthScale = size.width / videoTrack.naturalSize.width;
        heightScale = size.height / videoTrack.naturalSize.height;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        widthScale = size.width / videoTrack.naturalSize.width;
        heightScale = size.height / videoTrack.naturalSize.height;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        widthScale = size.width / videoTrack.naturalSize.height;
        heightScale = size.height / videoTrack.naturalSize.width;
    } else {
        widthScale = size.width / videoTrack.naturalSize.width;
        heightScale = size.height / videoTrack.naturalSize.height;
    }
    
    
    
    CGAffineTransform scale = CGAffineTransformMakeScale(widthScale,heightScale);
    
    
    [layerInstruction setTransform:CGAffineTransformConcat(t2, scale)  atTime:kCMTimeZero];
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    mainVideoComp.renderSize = size;
    
    
    
    
    
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    return(destinationURL);
}



NSURL * resizeVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,CGSize size)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(resizeVideoFromSourceAsset(asset,whichTrack,destinationURL,size));
    
}



NSURL * cropVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,CGSize size,CGPoint topLeftPosition)
{
    NSString * tempPath = [destinationURL path];
    
    [FileUitl deleteTmpFile:tempPath];
    
    
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    CGAffineTransform t2 = [videoTrack preferredTransform];
    //// if use back camera  , rotate degree is clock wise when using settransform
    //// if use front camera , rotate degree is clock wise when using settransform
    NSLog(@"---------------------");
    printCGAffineTransform(t2);
    NSLog(@"---------------------");
    
    
    float coodOrigXshift ;
    float coodOrigYshift ;
    
    
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
        
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
        
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
        
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
        
    } else {
        
        coodOrigXshift = -topLeftPosition.x;
        coodOrigYshift = -topLeftPosition.y;
    }
    
    
    
    
    
    CGAffineTransform move = CGAffineTransformMakeTranslation(coodOrigXshift,coodOrigYshift);
    [layerInstruction setTransform:CGAffineTransformConcat(t2, move) atTime:kCMTimeZero];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    
    
    mainVideoComp.renderSize = size;
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    return(destinationURL);
}




NSURL * cropVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,CGSize size,CGPoint topLeftPosition)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(cropVideoFromSourceAsset(asset,whichTrack,destinationURL,size,topLeftPosition));
}




NSURL * setVideoOpacityFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,float opacity)
{
    NSString * tempPath = [destinationURL path];
    
    [FileUitl deleteTmpFile:tempPath];
    
    
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    
    
    
    CGAffineTransform t2 = [videoTrack preferredTransform];
    //// if use back camera  , rotate degree is clock wise when using settransform
    //// if use front camera , rotate degree is clock wise when using settransform
    NSLog(@"---------------------");
    printCGAffineTransform(t2);
    NSLog(@"---------------------");
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    
    
    
    
    
    
    
    [layerInstruction setTransform:t2 atTime:kCMTimeZero];
    [layerInstruction setOpacity:opacity  atTime:kCMTimeZero];
    
    
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    
    
    
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        mainVideoComp.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        mainVideoComp.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
    } else {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    }
    
    
    
    
    
    NSLog(@"naturalSize:%lf:%lf",videoTrack.naturalSize.width,videoTrack.naturalSize.height);
    NSLog(@"renderSize:%lf:%lf",mainVideoComp.renderSize.width,mainVideoComp.renderSize.height);
    NSLog(@"renderScale:%lf",mainVideoComp.renderScale);
    
    
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    
    
    
    return(destinationURL);
}

NSURL * setVideoOpacityFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,float opacity)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(setVideoOpacityFromSourceAsset(asset,whichTrack,destinationURL,opacity));
}



NSURL * rotateVideoAroundTopLeftClockwiseFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,float rotateDegree)
{
    NSString * tempPath = [destinationURL path];
    
    [FileUitl deleteTmpFile:tempPath];
    
    
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    
    
    
    CGAffineTransform t2 = [videoTrack preferredTransform];
    //// if use back camera  , rotate degree is clock wise when using settransform
    //// if use front camera , rotate degree is clock wise when using settransform
    NSLog(@"---------------------");
    printCGAffineTransform(t2);
    NSLog(@"---------------------");
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    
    
    CGAffineTransform t3 =CGAffineTransformMakeRotation(2.0f * M_PI *(rotateDegree / 360.0));
    
    
    [layerInstruction setTransform:CGAffineTransformConcat(t2,t3) atTime:kCMTimeZero];
    
    
    
    
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    
    
    
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        mainVideoComp.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        mainVideoComp.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
    } else {
        mainVideoComp.renderSize = videoTrack.naturalSize;
    }
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    
    
    
    return(destinationURL);
}

NSURL * rotateVideoAroundTopLeftClockwiseFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,float rotateDegree)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(rotateVideoAroundTopLeftClockwiseFromSourceAsset(asset,whichTrack,destinationURL,rotateDegree));
}



NSURL * changeVideoAbsoluteOrientationFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,extUIImageOrientation orientation)
{
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    
    
    ////CGAffineTransform t2 = [videoTrack preferredTransform];
    
    
    ////NSNumber * orienPT = whichPT(t2);
    
    
    float width = videoTrack.naturalSize.width;
    float height = videoTrack.naturalSize.height;
    
    
    
    
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    CGAffineTransform t3 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    CGSize renderSize = CGSizeMake(0.0, 0.0);
    
    switch (orientation) {
        case extUIImageOrientationUp:
        {
            //// already ready,the internal format  is alwaysUP   UP--t2-->actural format
            //// so justdirectly output internal format
            
            renderSize = videoTrack.naturalSize;
            break;
        }
        case extUIImageOrientationDown:
        {
            
            t3 = getUIImageOrientationUpToDownPT(width, height);
            renderSize = videoTrack.naturalSize;
            break;
        }
        case extUIImageOrientationLeft:
        {
            t3 = getUIImageOrientationUpToLeftPT(width, height);
            renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            break;
        }
        case extUIImageOrientationRight:
        {
            t3 = getUIImageOrientationUpToRightPT(width, height);
            renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            break;
        }
            
        case extUIImageOrientationUpMirrored:
        {
            renderSize = videoTrack.naturalSize;
            break;
        }
        case extUIImageOrientationDownMirrored:
        {
            t3 = getUIImageOrientationUpToDownPT(width, height);
            renderSize = videoTrack.naturalSize;
            break;
        }
        case extUIImageOrientationLeftMirrored:
        {
            t3 = getUIImageOrientationUpToLeftPT(width, height);
            renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            break;
        }
        case extUIImageOrientationRightMirrored:
        {
            t3 = getUIImageOrientationUpToRightPT(width, height);
            renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            break;
        }
            
            
        case extUIImageOrientationUpXMirrored:
        {
            renderSize = videoTrack.naturalSize;
            break;
        }
        case extUIImageOrientationDownXMirrored:
        {
            t3 = getUIImageOrientationUpToDownPT(width, height);
            renderSize = videoTrack.naturalSize;
            break;
        }
        case extUIImageOrientationLeftXMirrored:
        {
            t3 = getUIImageOrientationUpToLeftPT(width, height);
            renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            break;
        }
        case extUIImageOrientationRightXMirrored:
        {
            t3 = getUIImageOrientationUpToRightPT(width, height);
            renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            break;
        }
            
            
        default:
        {
            //// already ready,the internal format  is alwaysUP   UP--t2-->actural format
            //// so justdirectly output internal format
            renderSize = videoTrack.naturalSize;
            break;
        }
    }
    
    
    [layerInstruction setTransform:t3 atTime:kCMTimeZero];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    mainVideoComp.renderSize = renderSize;
    
    
    
    //// when process videolayer the default anChorPoint is at 0.5,0.5
    
    
    switch (orientation) {
        case extUIImageOrientationUpMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            
            
            
            CATransform3D identityTransform = CATransform3DIdentity;
            identityTransform.m34 = -1.0/1000.0;
            CATransform3D rotateY_CCW_180 = CATransform3DRotate(identityTransform,1.0f * M_PI, 0.0f, 1.0f, 0.0f);
            
            
            videoLayer.transform =  rotateY_CCW_180;
            
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            
            break;
        }
        case extUIImageOrientationDownMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 0.0f, 1.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
        case extUIImageOrientationLeftMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 0.0f, 1.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
        case extUIImageOrientationRightMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 0.0f, 1.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
            
            
        case extUIImageOrientationUpXMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            
            
            
            CATransform3D identityTransform = CATransform3DIdentity;
            identityTransform.m34 = -1.0/1000.0;
            CATransform3D rotateY_CCW_180 = CATransform3DRotate(identityTransform,1.0f * M_PI, 1.0f, 0.0f, 0.0f);
            
            
            videoLayer.transform =  rotateY_CCW_180;
            
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            
            break;
        }
        case extUIImageOrientationDownXMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 1.0f, 0.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
        case extUIImageOrientationLeftXMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 1.0f, 0.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
        case extUIImageOrientationRightXMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 1.0f, 0.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
            
            
            
            
            
        default:
        {
            
            break;
        }
    }
    
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    
    
    
    return(destinationURL);
    
}
NSURL * changeVideoAbsoluteOrientationFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,extUIImageOrientation orientation)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(changeVideoAbsoluteOrientationFromSourceAsset(asset,whichTrack,destinationURL,orientation));
}





NSURL * changeVideoRelativeOrientationFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,extUIImageOrientation orientation)
{
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    
    
    CGAffineTransform t2 = [videoTrack preferredTransform];
    
    
    NSNumber * orienPT = whichPT(t2);
    
    
    float width;
    float height;
    
    if ([orienPT intValue]== UIImageOrientationUp) {
        width = videoTrack.naturalSize.width;
        height = videoTrack.naturalSize.height;
    } else if ([orienPT intValue]== UIImageOrientationDown) {
        width = videoTrack.naturalSize.width;
        height = videoTrack.naturalSize.height;
    } else if ([orienPT intValue]== UIImageOrientationLeft) {
        width = videoTrack.naturalSize.height;
        height = videoTrack.naturalSize.width;
    } else if ([orienPT intValue]== UIImageOrientationRight) {
        width = videoTrack.naturalSize.height;
        height = videoTrack.naturalSize.width;
    } else {
        width = videoTrack.naturalSize.width;
        height = videoTrack.naturalSize.height;
    }
    
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    CGAffineTransform t3 = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    CGSize renderSize = CGSizeMake(0.0, 0.0);
    
    switch (orientation) {
        case extUIImageOrientationUp:
        {
            //// already ready,the internal format  is alwaysUP   UP--t2-->actural format
            //// so justdirectly output internal format
            renderSize = CGSizeMake(width, height);
            break;
        }
        case extUIImageOrientationDown:
        {
            
            t3 = getUIImageOrientationUpToDownPT(width, height);
            renderSize = CGSizeMake(width, height);
            break;
        }
        case extUIImageOrientationLeft:
        {
            t3 = getUIImageOrientationUpToLeftPT(width, height);
            renderSize = CGSizeMake(height, width);
            break;
        }
        case extUIImageOrientationRight:
        {
            t3 = getUIImageOrientationUpToRightPT(width, height);
            renderSize = CGSizeMake(height, width);
            break;
        }
            
        case extUIImageOrientationUpMirrored:
        {
            renderSize = CGSizeMake(width, height);
            break;
        }
        case extUIImageOrientationDownMirrored:
        {
            t3 = getUIImageOrientationUpToDownPT(width, height);
            renderSize = CGSizeMake(width, height);
            break;
        }
        case extUIImageOrientationLeftMirrored:
        {
            t3 = getUIImageOrientationUpToLeftPT(width, height);
            renderSize = CGSizeMake(height, width);
            break;
        }
        case extUIImageOrientationRightMirrored:
        {
            t3 = getUIImageOrientationUpToRightPT(width, height);
            renderSize = CGSizeMake(height, width);
            break;
        }
            
            
        case extUIImageOrientationUpXMirrored:
        {
            renderSize = CGSizeMake(width, height);
            break;
        }
        case extUIImageOrientationDownXMirrored:
        {
            t3 = getUIImageOrientationUpToDownPT(width, height);
            renderSize = CGSizeMake(width, height);
            break;
        }
        case extUIImageOrientationLeftXMirrored:
        {
            t3 = getUIImageOrientationUpToLeftPT(width, height);
            renderSize = CGSizeMake(height, width);
            break;
        }
        case extUIImageOrientationRightXMirrored:
        {
            t3 = getUIImageOrientationUpToRightPT(width, height);
            renderSize = CGSizeMake(height, width);
            break;
        }
            
            
        default:
        {
            //// already ready,the internal format  is alwaysUP   UP--t2-->actural format
            //// so justdirectly output internal format
            break;
        }
    }
    
    
    
    
    [layerInstruction setTransform:CGAffineTransformConcat(t2,t3) atTime:kCMTimeZero];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    mainVideoComp.renderSize = renderSize;
    
    
    
    //// when process videolayer the default anChorPoint is at 0.5,0.5
    
    
    switch (orientation) {
        case extUIImageOrientationUpMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            
            
            CATransform3D identityTransform = CATransform3DIdentity;
            identityTransform.m34 = -1.0/1000.0;
            CATransform3D rotateY_CCW_180 = CATransform3DRotate(identityTransform,1.0f * M_PI, 0.0f, 1.0f, 0.0f);
            
            
            videoLayer.transform =  rotateY_CCW_180;
            
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            
            break;
        }
        case extUIImageOrientationDownMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 0.0f, 1.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
        case extUIImageOrientationLeftMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 0.0f, 1.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
        case extUIImageOrientationRightMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 0.0f, 1.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
            
            
        case extUIImageOrientationUpXMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            
            
            CATransform3D identityTransform = CATransform3DIdentity;
            identityTransform.m34 = -1.0/1000.0;
            CATransform3D rotateY_CCW_180 = CATransform3DRotate(identityTransform,1.0f * M_PI, 1.0f, 0.0f, 0.0f);
            
            
            videoLayer.transform =  rotateY_CCW_180;
            
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            
            break;
        }
        case extUIImageOrientationDownXMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 1.0f, 0.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
        case extUIImageOrientationLeftXMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 1.0f, 0.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
        case extUIImageOrientationRightXMirrored:
        {
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            
            
            
            CATransform3D rotateY_CCW_180 = CATransform3DMakeRotation(1.0f * M_PI, 1.0f, 0.0f, 0.0f);
            
            videoLayer.transform =  rotateY_CCW_180;
            
            [parentLayer addSublayer:videoLayer];
            
            mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            break;
        }
            
            
            
            
            
        default:
        {
            
            break;
        }
    }
    
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    
    
    
    return(destinationURL);
    
}
NSURL * changeVideoRelativeOrientationFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,extUIImageOrientation orientation)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(changeVideoRelativeOrientationFromSourceAsset(asset,whichTrack,destinationURL,orientation));
}









NSURL * geomePlaceVideosIntoOneFromSourceAssets(NSMutableArray * assets,NSMutableArray* whichTracks,NSMutableArray*positions,NSMutableArray*sizes,CGSize renderSize,NSURL*destinationURL)
{
    ////-----each original track
    NSMutableArray * videoTracks =   [[NSMutableArray alloc] init];
    for (int i = 0; i< assets.count; i++) {
        [videoTracks addObject:[selectAllVideoTracksFromAVAsset(assets[i]) objectAtIndex:[(NSNumber *)whichTracks[i] integerValue]]];
    }
    
    
    ////-----final mixComposition
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    ////----get max duration videotrack
    AVAssetTrack * maxDurationVideoTrack= getMaxCMTDurationTrackFromTracksArray(videoTracks);
    
    ////CMTime maxDUration = maxDurationVideoTrack.timeRange.duration;
    
    
    ////-----each composition track corresponding to each orig track
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    for (int i = 0; i< assets.count; i++) {
        
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
        ////[compTrack insertEmptyTimeRange:CMTimeRangeFromTimeToTime(videoTrack.timeRange.duration, maxDUration)];
        [compTracks addObject:compTrack];
    }
    
    
    
    
    
    
    
    
    
    ////------get each LayerInstruction
    NSMutableArray * layerInstructions = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i< assets.count; i++) {
        
        AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTracks[i]];
        
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        CGSize size = [sizes[i] CGSizeValue];
        CGPoint position = [positions[i] CGPointValue];
        
        ////----to right oritation, if  pt exist
        
        
        
        CGAffineTransform pt = [videoTrack preferredTransform];
        
        NSNumber * orienPT = whichPT(pt);
        
        float width;
        float height;
        
        if ([orienPT intValue]== UIImageOrientationUp) {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        } else if ([orienPT intValue]== UIImageOrientationDown) {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        } else if ([orienPT intValue]== UIImageOrientationLeft) {
            width = videoTrack.naturalSize.height;
            height = videoTrack.naturalSize.width;
        } else if ([orienPT intValue]== UIImageOrientationRight) {
            width = videoTrack.naturalSize.height;
            height = videoTrack.naturalSize.width;
        } else {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        }
        
        
        float widthScale = size.width/width;
        float heightScale = size.height/height;
        
        CGAffineTransform st = CGAffineTransformMakeScale(widthScale, heightScale);
        CGAffineTransform tt = CGAffineTransformMakeTranslation(position.x, position.y);
        
        CGAffineTransform ptst = CGAffineTransformConcat(pt,st);
        CGAffineTransform ptsttt = CGAffineTransformConcat(ptst,tt);
        
        
        [layerInstruction setTransform:ptsttt atTime:kCMTimeZero];
        [layerInstructions addObject:layerInstruction];
    }
    
    
    
    ////----fill mainInstrction timerange and layerinstructions
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, maxDurationVideoTrack.timeRange.duration);
    mainInstruction.layerInstructions = layerInstructions;
    
    
    ////----get min frame rate videotrack
    AVAssetTrack * minNominalFrameDurationVideoTrack= getMinNominalFrameRateTrackFromTracksArray(videoTracks);
    ////----fill mainVideoComp instrcutions, frameDuration, renderSize
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    ////----For the first instruction in the array, timeRange.
    ////start must be less than or equal to the earliest time for which playback or other processing will be attempted (typically kCMTimeZero).
    ////For subsequent instructions, timeRange.start must be equal to the prior instruction's end time.
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [minNominalFrameDurationVideoTrack nominalFrameRate]);
    mainVideoComp.renderSize = renderSize;
    
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    
    
    return(destinationURL);
}
NSURL * geomePlaceVideosIntoOneFromSourceSourceURLs(NSMutableArray * sourceURLs,NSMutableArray* whichTracks,NSMutableArray*positions,NSMutableArray*sizes,CGSize renderSize,NSURL*destinationURL)
{
    
    NSMutableArray * assets = [[NSMutableArray alloc] init  ];
    for (int i = 0; i< sourceURLs.count; i++) {
        [assets addObject:[AVAsset assetWithURL:sourceURLs[i]]];
    }
    
    geomePlaceVideosIntoOneFromSourceAssets(assets, whichTracks, positions, sizes, renderSize, destinationURL);
    
    return(destinationURL);
}







NSURL * interleaveVideosAtCMTimeLevelFromSourceAssets(NSMutableArray * assets,NSMutableArray* whichTracks,NSMutableArray*intervals,CGSize renderSize,NSURL*destinationURL)
{
    ////-----each original track
    NSMutableArray * videoTracks =   [[NSMutableArray alloc] init];
    for (int i = 0; i< assets.count; i++) {
        [videoTracks addObject:[selectAllVideoTracksFromAVAsset(assets[i]) objectAtIndex:[(NSNumber *)whichTracks[i] integerValue]]];
    }
    
    
    NSMutableArray * sliceIndications = [[NSMutableArray alloc] init];
    
    for (int i = 0; i< assets.count; i++) {
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        
        NSMutableArray * sliceIndication = [[NSMutableArray alloc] init];
        CMTime cmtInterval = CMTimeMake([intervals[i] floatValue]*600.0, 600);
        CMTime curr = cmtInterval;
        while (CMTimeCompare (curr ,videoTrack.timeRange.duration) <=0 ) {
            [sliceIndication addObject:[NSValue valueWithCMTime: cmtInterval] ];
            curr = CMTimeAdd(curr, cmtInterval);
        }
        
        if (CMTimeCompare (curr ,videoTrack.timeRange.duration) ==1 ) {
            curr = CMTimeSubtract(curr, cmtInterval);
            [sliceIndication addObject:[NSValue valueWithCMTime:CMTimeSubtract(videoTrack.timeRange.duration, curr)] ];
        }
        
        [sliceIndications addObject:sliceIndication];
    }
    
    
    int maxCursors = 0;
    for (int i = 0; i< assets.count; i++) {
        maxCursors = (int)MAX(maxCursors, ((NSMutableArray * )sliceIndications[i]).count);
    }
    
    
    
    
    ////-----final mixComposition
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    
    
    ////-----each composition track corresponding to each orig track
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i< assets.count; i++) {
        
        AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compTracks addObject:compTrack];
    }
    
    
    NSLog(@"%@",sliceIndications);
    
    
    ////防止最短视频最后一Frame覆盖其他
    NSMutableArray * dimOpacityAtTimes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i< assets.count; i++) {
        [dimOpacityAtTimes addObject:[NSValue valueWithCMTime:kCMTimeZero]];
    }
    
    NSLog(@"dimOpacityAtTimes:%@",dimOpacityAtTimes);
    
    
    
    
    
    
    
    
    
    NSMutableArray * uniformSliceIndications = [[NSMutableArray alloc] init];
    
    int cursor = 0;
    CMTime AT = kCMTimeZero;
    
    while (cursor < maxCursors) {
        
        
        
        
        
        for (int i = 0; i< assets.count; i++) {
            
            CMTimeShow(AT);
            
            NSMutableDictionary * uniformSliceIndication =  [[NSMutableDictionary alloc] init];
            NSNumber * notEmpty = [NSNumber numberWithInt:-1];
            NSMutableArray * sliceIndication = [[NSMutableArray alloc] init];
            sliceIndication = (NSMutableArray * )sliceIndications[i];
            
            if (cursor < sliceIndication.count) {
                notEmpty = [NSNumber numberWithInt:i];
                [uniformSliceIndication setValue:sliceIndication[cursor] forKey:@"cmt"];
                [uniformSliceIndication setValue:notEmpty forKey:@"notEmpty"];
                [uniformSliceIndications addObject:uniformSliceIndication];
                AT = CMTimeAdd(AT, [sliceIndication[cursor] CMTimeValue]);
                
                if (cursor == sliceIndication.count - 1) {
                    dimOpacityAtTimes[i] = [NSValue valueWithCMTime:AT];
                }
                
            } else {
                
            }
            
            
        }
        cursor = cursor + 1;
        
    }
    
    
    
    NSLog(@"%@",uniformSliceIndications);
    NSLog(@"dimOpacityAtTimes:%@",dimOpacityAtTimes);
    
    CMTime curr = kCMTimeZero;
    
    NSMutableArray * origCurrs = [[NSMutableArray alloc] init];
    for (int j = 0; j< assets.count; j++) {
        [origCurrs addObject:[NSValue valueWithCMTime:kCMTimeZero]];
    }
    
    NSMutableArray * SIIs = [[NSMutableArray alloc] init];
    for (int j = 0; j< assets.count; j++) {
        [SIIs addObject:[NSNumber numberWithInt:0]];
    }
    
    
    for (int i = 0; i< uniformSliceIndications.count; i++) {
        
        for (int j = 0; j< assets.count; j++) {
            AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[j];
            AVMutableCompositionTrack *compTrack = compTracks[j];
            NSMutableArray * sliceIndication = [[NSMutableArray alloc] init];
            sliceIndication = (NSMutableArray * )sliceIndications[j];
            CMTime origCurr = [origCurrs[j] CMTimeValue];
            
            if ([[uniformSliceIndications[i] valueForKey:@"notEmpty"] intValue] == j) {
                
                int sii = [SIIs[j] intValue];
                
                NSLog(@"i:%d   j:%d   sii:%d",i,j,sii) ;
                [compTrack insertTimeRange:CMTimeRangeMake(origCurr,[sliceIndication[sii] CMTimeValue])  ofTrack:videoTrack atTime:curr error:nil];
                origCurr = CMTimeAdd(origCurr, [sliceIndication[sii] CMTimeValue]);
                origCurrs[j] = [NSValue valueWithCMTime:origCurr];
                sii = sii + 1;
                SIIs[j] = [NSNumber numberWithInt:sii];
            } else {
                
                
                [compTrack insertEmptyTimeRange:CMTimeRangeMake(curr, [[uniformSliceIndications[i] valueForKey:@"cmt"] CMTimeValue])];
            }
            
            
            
        }
        
        curr = CMTimeAdd(curr, [[uniformSliceIndications[i] valueForKey:@"cmt"] CMTimeValue]);
        
        
    }
    
    
    
    
    
    CMTimeShow(curr);
    
    for (int j = 0; j< assets.count; j++) {
        AVMutableCompositionTrack *compTrack = compTracks[j];
        CMTimeShow(compTrack.timeRange.duration);
    }
    
    
    
    NSLog(@"mixComposition:%@",mixComposition);
    
    
    
    
    ////------get each LayerInstruction
    
    NSMutableArray * layerInstructions = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i< assets.count; i++) {
        
        AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTracks[i]];
        
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        CGSize size = renderSize;
        
        
        ////----to right oritation, if  pt exist
        
        
        
        CGAffineTransform pt = [videoTrack preferredTransform];
        
        NSNumber * orienPT = whichPT(pt);
        
        float width;
        float height;
        
        if ([orienPT intValue]== UIImageOrientationUp) {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        } else if ([orienPT intValue]== UIImageOrientationDown) {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        } else if ([orienPT intValue]== UIImageOrientationLeft) {
            width = videoTrack.naturalSize.height;
            height = videoTrack.naturalSize.width;
        } else if ([orienPT intValue]== UIImageOrientationRight) {
            width = videoTrack.naturalSize.height;
            height = videoTrack.naturalSize.width;
        } else {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        }
        
        
        float widthScale = size.width/width;
        float heightScale = size.height/height;
        
        CGAffineTransform st = CGAffineTransformMakeScale(widthScale, heightScale);
        
        
        CGAffineTransform ptst = CGAffineTransformConcat(pt,st);
        
        
        
        [layerInstruction setTransform:ptst atTime:kCMTimeZero];
        ////this is necessary, or else the shotest movie will cover all when it ended
        [layerInstruction setOpacity:0.0 atTime:[dimOpacityAtTimes[i] CMTimeValue]];
        [layerInstructions addObject:layerInstruction];
    }
    
    NSLog(@"<===========>");
    
    ////----fill mainInstrction timerange and layerinstructions
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    
    ////----get max duration videotrack
    
    ////CMTime 未初始化会导致奇怪错误
    CMTime finalDUration = kCMTimeZero ;
    
    for (int i = 0; i< assets.count; i++) {
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        finalDUration = CMTimeAdd(finalDUration, videoTrack.timeRange.duration);
    }
    
    CMTimeShow(finalDUration);
    
    NSLog(@"<===========>");
    
    
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, finalDUration);
    mainInstruction.layerInstructions = layerInstructions;
    
    
    ////----get min frame rate videotrack
    AVAssetTrack * minNominalFrameDurationVideoTrack= getMinNominalFrameRateTrackFromTracksArray(videoTracks);
    ////----fill mainVideoComp instrcutions, frameDuration, renderSize
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    ////----For the first instruction in the array, timeRange.
    ////start must be less than or equal to the earliest time for which playback or other processing will be attempted (typically kCMTimeZero).
    ////For subsequent instructions, timeRange.start must be equal to the prior instruction's end time.
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [minNominalFrameDurationVideoTrack nominalFrameRate]);
    mainVideoComp.renderSize = renderSize;
    
    
    CMTimeShow(mainVideoComp.frameDuration);
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    
    
    return(destinationURL);
}
NSURL * interleaveVideosAtCMTimeLevelFromSourceSourceURLs(NSMutableArray * sourceURLs,NSMutableArray* whichTracks,NSMutableArray*intervals,CGSize renderSize,NSURL*destinationURL)
{
    NSMutableArray * assets = [[NSMutableArray alloc] init  ];
    for (int i = 0; i< sourceURLs.count; i++) {
        [assets addObject:[AVAsset assetWithURL:sourceURLs[i]]];
    }
    
    interleaveVideosAtCMTimeLevelFromSourceAssets(assets, whichTracks, intervals, renderSize, destinationURL);
    
    return(destinationURL);
}




NSURL * rotateOn2DVideoCounterClockwiseFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,float rotateDegree,CGPoint anchorCood)
{
    
    ////need_to_be_displayed_as ----preferedTransform---->landscapup(home button at right)
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];
    
    
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    
    
    
    
    
    ////因为在内部存储时总是landscape ,所以 origWidth 总是 长 的 边
    float origWidth = videoTrack.naturalSize.width;
    float origHeight = videoTrack.naturalSize.height;
    
    //输入的anchor是针对pt还原之后的矩形的
    float x = anchorCood.x;
    float y = anchorCood.y;
    
    CGAffineTransform pt = [videoTrack preferredTransform];
    if (pt.a==0.0 && pt.b==1.0 && pt.c==-1.0 && pt.d == 0.0) {
        origWidth = videoTrack.naturalSize.height;
        origHeight = videoTrack.naturalSize.width;
    } else if (pt.a==1.0 && pt.b==0.0 && pt.c==0.0 && pt.d == 1.0) {
        
    } else if (pt.a==-1.0 && pt.b==0.0 && pt.c==0.0 && pt.d == -1.0) {
        
    } else if (pt.a==0.0 && pt.b==-1.0 && pt.c==1.0 && pt.d == 0.0) {
        origWidth = videoTrack.naturalSize.height;
        origHeight = videoTrack.naturalSize.width;
    } else {
        
    }
    
    //求出能包含整个旋转角度的最小圆形，进而求出能包含这个圆的最小正方形区域，这个是实际render区域
    float r1 = sqrtf(x*x + y*y);
    float r2 = sqrtf(x*x + (origHeight - y)*(origHeight -y ));
    float r3 = sqrtf((origWidth -x)*(origWidth -x) + y*y);
    float r4 = sqrtf((origWidth -x)*(origWidth -x)  + (origHeight - y)*(origHeight -y));
    float parentDiameter = MAX(r1, r2);
    parentDiameter = MAX(parentDiameter,r3);
    parentDiameter = MAX(parentDiameter,r4);
    parentDiameter = 2 * parentDiameter;
    
    
    ////--- this step is necessary if the output is not the original
    ////--- when the videoLayer frame is small than renderSize
    ////--- the real video will be shrinked  in videoLayer corresponding  to the ratio  of  (videoLayer frame) / (renderSize)
    ////---
    ////float widthScale = parentDiameter / origWidth;
    ////float heightScale = parentDiameter / origHeight;
    ////CGAffineTransform st = CGAffineTransformMakeScale(widthScale,heightScale);
    ////- concat  是矩阵乘法 所以有先后次序
    ////CGAffineTransform ptst = CGAffineTransformConcat(pt,st);
    
    
    //pt 还原为所见即所得
    [layerInstruction setTransform:pt atTime:kCMTimeZero];
    ////[layerInstruction setTransform:ptst atTime:kCMTimeZero];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, parentDiameter, parentDiameter);
    parentLayer.backgroundColor = [[UIColor greenColor] CGColor];
    //parentLayer所处的坐标系是 标准坐标系 parentFrame的左下角是原点 x向右是正 y向上为正
    ////parentLayer position 此处会是 (parentDiameter/2,parentDiameter/2)
    
    ////default anchor point  is at 0.5,0.5
    ////so the position  is at center
    ////position is the absolute cood  of anchor
    ////anchorPoint is the relative ratio of anchor
    ////frame is the absolute coord
    ////bounds is the relative of self
    
    //videoLayer所处的坐标系是 标准坐标系 video的左下角是原点 x向右是正 y向上为正
    CALayer *videoLayer = [CALayer layer];
    videoLayer.bounds = CGRectMake(0,0 ,origWidth,origHeight);
    ////因为坐标系变换
    float origY = y;
    y = origHeight - y ;
    videoLayer.anchorPoint =  CGPointMake(x/origWidth, y/origHeight);
    ////让videolayer的anchorPoint的绝对位置和parentLayer的anchorPoint的绝对位置(parentLayer中心)重合
    videoLayer.position = parentLayer.position;
    
    
    /*
     CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath: @"transform"];
     CATransform3D transformFrom = CATransform3DMakeRotation (2.0f * M_PI *(rotateDegree / 360.0), 0.0f, 0.0f, 1.0f);
     CATransform3D transformTo = CATransform3DMakeRotation (2.0f * M_PI *(rotateDegree /360.0), 0.0f, 0.0f, 1.0f);
     
     animation.fromValue = [NSValue valueWithCATransform3D: transformFrom];
     animation.toValue = [NSValue valueWithCATransform3D: transformTo];
     
     animation.beginTime = AVCoreAnimationBeginTimeAtZero;
     animation.duration = CMTimeGetSeconds(videoTrack.timeRange.duration);
     animation.cumulative = YES;
     animation.repeatCount = 1;
     animation.removedOnCompletion = NO;
     animation.autoreverses = NO;
     animation.fillMode = kCAFillModeForwards;
     animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
     [videoLayer addAnimation:animation forKey:@"rotationAnimation"];
     */
    
    CATransform3D rotation = CATransform3DMakeRotation (2.0f * M_PI *(rotateDegree / 360.0), 0.0f, 0.0f, 1.0f);
    CATransform3D move = CATransform3DMakeTranslation( x - parentDiameter/2.0,  parentDiameter/2.0 - origY -parentDiameter + origHeight, 0.0);
    CATransform3D rtmt = CATransform3DConcat(rotation, move);
    
    
    videoLayer.transform = rtmt;
    
    [parentLayer addSublayer:videoLayer];
    
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    
    ////mainVideoComp.renderSize = CGSizeMake(parentDiameter,parentDiameter);
    mainVideoComp.renderSize = CGSizeMake(origWidth  ,origHeight);
    mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    return(destinationURL);
}



NSURL * rotateOn2DVideoCounterClockwiseFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,float rotateDegree,CGPoint anchorCood)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];;
    
    return(rotateOn2DVideoCounterClockwiseFromSourceAsset(asset,whichTrack,destinationURL,rotateDegree,anchorCood));
}



////==================
NSURL * rotateOn3DVideoCounterClockwiseFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,float rotateDegree,CGPoint anchorCoodZ,float axisX,float axisY, float axisZ,float m34)
{
    ////need_to_be_displayed_as ----preferedTransform---->landscapup(home button at right)
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];
    
    
    AVAssetTrack * videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
    
    
    
    
    
    
    ////因为在内部存储时总是landscape ,所以 origWidth 总是 长 的 边
    float origWidth = videoTrack.naturalSize.width;
    float origHeight = videoTrack.naturalSize.height;
    
    //输入的anchor是针对pt还原之后的矩形的
    float x = anchorCoodZ.x;
    float y = anchorCoodZ.y;
    
    CGAffineTransform pt = [videoTrack preferredTransform];
    if (pt.a==0.0 && pt.b==1.0 && pt.c==-1.0 && pt.d == 0.0) {
        origWidth = videoTrack.naturalSize.height;
        origHeight = videoTrack.naturalSize.width;
    } else if (pt.a==1.0 && pt.b==0.0 && pt.c==0.0 && pt.d == 1.0) {
        
    } else if (pt.a==-1.0 && pt.b==0.0 && pt.c==0.0 && pt.d == -1.0) {
        
    } else if (pt.a==0.0 && pt.b==-1.0 && pt.c==1.0 && pt.d == 0.0) {
        origWidth = videoTrack.naturalSize.height;
        origHeight = videoTrack.naturalSize.width;
    } else {
        
    }
    
    //求出能包含整个旋转角度的最小圆形，进而求出能包含这个圆的最小正方形区域，这个是实际render区域
    float r1 = sqrtf(x*x + y*y);
    float r2 = sqrtf(x*x + (origHeight - y)*(origHeight -y ));
    float r3 = sqrtf((origWidth -x)*(origWidth -x) + y*y);
    float r4 = sqrtf((origWidth -x)*(origWidth -x)  + (origHeight - y)*(origHeight -y));
    float parentDiameter = MAX(r1, r2);
    parentDiameter = MAX(parentDiameter,r3);
    parentDiameter = MAX(parentDiameter,r4);
    parentDiameter = 2 * parentDiameter;
    
    
    ////--- this step is necessary if the output is not the original
    ////--- when the videoLayer frame is small than renderSize
    ////--- the real video will be shrinked  in videoLayer corresponding  to the ratio  of  (videoLayer frame) / (renderSize)
    ////---
    ////float widthScale = parentDiameter / origWidth;
    ////float heightScale = parentDiameter / origHeight;
    ////CGAffineTransform st = CGAffineTransformMakeScale(widthScale,heightScale);
    ////- concat  是矩阵乘法 所以有先后次序
    ////CGAffineTransform ptst = CGAffineTransformConcat(pt,st);
    
    
    //pt 还原为所见即所得
    [layerInstruction setTransform:pt atTime:kCMTimeZero];
    ////[layerInstruction setTransform:ptst atTime:kCMTimeZero];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, parentDiameter, parentDiameter);
    parentLayer.backgroundColor = [[UIColor greenColor] CGColor];
    //parentLayer所处的坐标系是 标准坐标系 parentFrame的左下角是原点 x向右是正 y向上为正
    ////parentLayer position 此处会是 (parentDiameter/2,parentDiameter/2)
    
    ////default anchor point  is at 0.5,0.5
    ////so the position  is at center
    ////position is the absolute cood  of anchor
    ////anchorPoint is the relative ratio of anchor
    ////frame is the absolute coord
    ////bounds is the relative of self
    
    //videoLayer所处的坐标系是 标准坐标系 video的左下角是原点 x向右是正 y向上为正
    CALayer *videoLayer = [CALayer layer];
    videoLayer.bounds = CGRectMake(0,0 ,origWidth,origHeight);
    ////因为坐标系变换
    float origY = y;
    y = origHeight - y ;
    videoLayer.anchorPoint =  CGPointMake(x/origWidth, y/origHeight);
    ////让videolayer的anchorPoint的绝对位置和parentLayer的anchorPoint的绝对位置(parentLayer中心)重合
    videoLayer.position = parentLayer.position;
    
    
    /*
     CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath: @"transform"];
     CATransform3D transformFrom = CATransform3DMakeRotation (2.0f * M_PI *(rotateDegree / 360.0), 0.0f, 0.0f, 1.0f);
     CATransform3D transformTo = CATransform3DMakeRotation (2.0f * M_PI *(rotateDegree /360.0), 0.0f, 0.0f, 1.0f);
     
     animation.fromValue = [NSValue valueWithCATransform3D: transformFrom];
     animation.toValue = [NSValue valueWithCATransform3D: transformTo];
     
     animation.beginTime = AVCoreAnimationBeginTimeAtZero;
     animation.duration = CMTimeGetSeconds(videoTrack.timeRange.duration);
     animation.cumulative = YES;
     animation.repeatCount = 1;
     animation.removedOnCompletion = NO;
     animation.autoreverses = NO;
     animation.fillMode = kCAFillModeForwards;
     animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
     [videoLayer addAnimation:animation forKey:@"rotationAnimation"];
     */
    
    CATransform3D identityTransform = CATransform3DIdentity;
    identityTransform.m34 = m34;
    
    CATransform3D rotation = CATransform3DRotate (identityTransform,2.0f * M_PI *(rotateDegree / 360.0), axisX, axisY, axisZ);
    CATransform3D move = CATransform3DMakeTranslation( x - parentDiameter/2.0,  parentDiameter/2.0 - origY -parentDiameter + origHeight, 0.0);
    CATransform3D rtmt = CATransform3DConcat(rotation, move);
    
    
    videoLayer.transform = rtmt;
    
    [parentLayer addSublayer:videoLayer];
    
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    
    ////mainVideoComp.renderSize = CGSizeMake(parentDiameter,parentDiameter);
    mainVideoComp.renderSize = CGSizeMake(origWidth  ,origHeight);
    mainVideoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    return(destinationURL);
}
NSURL * rotateOn3DVideoCounterClockwiseFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,float rotateDegree,CGPoint anchorCoodZ,float axisX,float axisY, float axisZ,float m34)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];
    
    return(rotateOn3DVideoCounterClockwiseFromSourceAsset(asset,whichTrack,destinationURL,rotateDegree,anchorCoodZ,axisX,axisY,axisZ,m34));
    
}

////==================

NSURL * FForSlowDownVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL,NSMutableArray * sectionStarts,NSMutableArray * sectionEnds,NSMutableArray * ratios)
{
    
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];
    
    int sectionsCount = (int)sectionStarts.count ;
    // 假如手势选取在一段原始视频上选了 4个 片段， sectionsCount = 4
    // [s1,e1],[s2,e2],[s3,e3],[s4,e4]
    // |----|----|----|----|----|----|----|----|----|
    //      s1   e1   s2   e2   s3   e3   s4   e4
    // 如上图，实际区间被划分为 9 个原始区间,
    // |-o1-|-o2-|-o3-|-o4-|-o5-|-o6-|-o7-|-o8-|-o9-|   #时间参照为 原始视频的时间线 preHandle
    //ct1  ct2  ct3  ct4  ct5  ct6  ct7  ct8  ct9
    // 对应的要做9个compTrack ct1-ct9
    //  o2 = [s1,e1] 延长或缩短至 o2 * r1
    //  o4 = [s2,e2] 延长或缩短至 o4 * r2
    //  o6 = [s3,e3] 延长或缩短至 o6 * r3
    //  o8 = [s4,e4] 延长或缩短至 o8 * r4
    // 处理后
    // |-o1-|-o2*r1-|-o3-|-o4*r2-|-o5-|-o6*r3-|-o7-|-o8*r4-|-o9-|  #时间参照为 片段被处理后的时间线 postHandle
    //at1  at2     at3  at4     at5  at6     at7  at8     at9
    //at1 = kCMTimeZero(视频起始时间)
    //ct1 insertTimeRange o1(preHandle) atTime at1(postHandle)
    //at2 = o1
    //ct2 insertTimeRange o2(preHandle) atTime at2(postHandle)
    //ct2 scaleTimeRange from o2  to o2*r1
    //at3 = at2 + o2*r1
    //ct3 insertTimeRange o3(preHandle) atTime at3(postHandle)
    //at4 = at3 + o3
    //ct4 insertTimeRange o4(preHandle) atTime at4(postHandle)
    //ct4 scaleTimeRange from o4 to o4*r2
    //at5 = at4 + o4*r2
    //.......
    //at9 = at8 +o8 *r4
    //ct9 insertTimeRange o9(preHandle) atTime at9(postHandle)
    
    
    
    int realSecsCount = sectionsCount * 2 + 1;
    
    NSMutableArray * videoTracks =   [[NSMutableArray alloc] init];
    for (int i = 0; i< realSecsCount; i++) {
        [videoTracks addObject:[selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack]];
    }
    
    NSLog(@"%@",videoTracks);
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i< realSecsCount; i++) {
        
        AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compTracks addObject:compTrack];
    }
    
    NSLog(@"%@",compTracks);
    
    NSMutableArray * preHandleCMTimePoints = [[NSMutableArray alloc] init];
    [preHandleCMTimePoints addObject:[NSValue valueWithCMTime:kCMTimeZero]];
    for (int i = 1; i< realSecsCount; i++) {
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        int q = i / 2 ;
        int r = i % 2 ;
        if (r == 0) {
            CMTime cmtE = CMTimeMakeWithSeconds([sectionEnds[q-1] floatValue], videoTrack.timeRange.duration.timescale);
            [preHandleCMTimePoints addObject:[NSValue valueWithCMTime:cmtE]];
        } else {
            CMTime cmtS = CMTimeMakeWithSeconds([sectionStarts[q] floatValue], videoTrack.timeRange.duration.timescale);
            [preHandleCMTimePoints addObject:[NSValue valueWithCMTime:cmtS]];
        }
    }
    
    
    NSLog(@"--------preHandleCMTimePoints---------");
    NSLog(@"%@",preHandleCMTimePoints);
    NSLog(@"--------preHandleCMTimePoints---------");
    
    
    CMTime postHandleAtTimeCurr=kCMTimeZero;
    NSMutableArray * postHandleAtTimePoints = [[NSMutableArray alloc] init];
    [postHandleAtTimePoints addObject:[NSValue valueWithCMTime:kCMTimeZero]];
    for (int i = 1; i< realSecsCount; i++) {
        int q = i / 2 ;
        int r = i % 2 ;
        CMTime sub = CMTimeSubtract([preHandleCMTimePoints[i] CMTimeValue], [preHandleCMTimePoints[i-1] CMTimeValue]);
        if (r == 0) {
            AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
            float videoScaleFactor = [ratios[q-1] floatValue];
            CMTime realSub = CMTimeMake(sub.value*videoScaleFactor, videoTrack.timeRange.duration.timescale);
            postHandleAtTimeCurr = CMTimeAdd(postHandleAtTimeCurr, realSub);
        } else {
            postHandleAtTimeCurr = CMTimeAdd(postHandleAtTimeCurr, sub);
        }
        [postHandleAtTimePoints addObject:[NSValue valueWithCMTime:postHandleAtTimeCurr]];
    }
    
    
    NSLog(@"--------postHandleAtTimePoints---------");
    NSLog(@"%@",postHandleAtTimePoints);
    NSLog(@"--------postHandleAtTimePoints---------");
    
    
    AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[0];
    CMTime finalDUration = kCMTimeZero;
    CMTime finalAt = [postHandleAtTimePoints[realSecsCount - 1] CMTimeValue];
    CMTime finalPre = [preHandleCMTimePoints[realSecsCount - 1] CMTimeValue];
    CMTime finalSec = CMTimeSubtract(videoTrack.timeRange.duration, finalPre);
    finalDUration = CMTimeAdd(finalAt, finalSec);
    
    NSLog(@"--------finalDUration---------");
    CMTimeShow(finalDUration);
    NSLog(@"--------finalDUration---------");
    
    NSMutableArray * layerInstructions = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i< realSecsCount; i++) {
        
        AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTracks[i]];
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        
        
        CGAffineTransform pt = [videoTrack preferredTransform];
        
        [layerInstruction setTransform:pt atTime:kCMTimeZero];
        [layerInstructions addObject:layerInstruction];
    }
    
    
    
    for (int i = 0; i< realSecsCount-1; i++) {
        int r = i % 2 ;
        int q = i / 2 ;
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[i];
        AVMutableCompositionTrack *compTrack = compTracks[i];
        CMTime cmtS = [preHandleCMTimePoints[i] CMTimeValue];
        CMTime cmtE = [preHandleCMTimePoints[i+1] CMTimeValue];
        CMTime cmtD = CMTimeSubtract(cmtE, cmtS);
        CMTime atTime = [postHandleAtTimePoints[i] CMTimeValue];
        CMTime nextAt = [postHandleAtTimePoints[i+1] CMTimeValue];
        CMTime tailEmptyDuration = CMTimeSubtract(finalDUration, nextAt);
        
        AVMutableVideoCompositionLayerInstruction * layerInstruction = layerInstructions[i];
        if (r == 0) {
            [compTrack insertEmptyTimeRange:CMTimeRangeMake(kCMTimeZero, atTime)];
            [compTrack insertTimeRange:CMTimeRangeMake(cmtS, cmtD) ofTrack:videoTrack atTime:atTime error:nil];
            [compTrack insertEmptyTimeRange:CMTimeRangeMake(nextAt,tailEmptyDuration)];
            ////this is necessary, or else the shotest movie will cover all when it ended
            [layerInstruction setOpacity:0.0 atTime:nextAt];
        } else {
            [compTrack insertEmptyTimeRange:CMTimeRangeMake(kCMTimeZero, atTime)];
            [compTrack insertTimeRange:CMTimeRangeMake(cmtS, cmtD) ofTrack:videoTrack atTime:atTime error:nil];
            
            float videoScaleFactor = [ratios[q] floatValue];
            ////注意scale的时间计算的基准  要以compTrack为参照
            [compTrack scaleTimeRange:CMTimeRangeMake(atTime, cmtD) toDuration:CMTimeMake(cmtD.value*videoScaleFactor, videoTrack.timeRange.duration.timescale)];
            [compTrack insertEmptyTimeRange:CMTimeRangeMake(nextAt,tailEmptyDuration)];
            ////this is necessary, or else the shotest movie will cover all when it ended
            [layerInstruction setOpacity:0.0 atTime:nextAt];
        }
    }
    
    {
        AVAssetTrack * videoTrack = (AVAssetTrack *)videoTracks[realSecsCount-1];
        AVMutableCompositionTrack *compTrack = compTracks[realSecsCount-1];
        CMTime cmtS = [preHandleCMTimePoints[realSecsCount-1] CMTimeValue];
        CMTime cmtE = videoTrack.timeRange.duration;
        CMTime cmtD = CMTimeSubtract(cmtE, cmtS);
        CMTime atTime = [postHandleAtTimePoints[realSecsCount-1] CMTimeValue];
        CMTimeShow(atTime);
        [compTrack insertEmptyTimeRange:CMTimeRangeMake(kCMTimeZero, atTime)];
        [compTrack insertTimeRange:CMTimeRangeMake(cmtS, cmtD) ofTrack:videoTrack atTime:atTime error:nil];
    }
    
    
    NSLog(@"--------compTracks---------");
    for (int i = 0; i< realSecsCount; i++) {
        AVMutableCompositionTrack *compTrack = compTracks[i];
        CMTimeRangeShow(compTrack.timeRange);
    }
    NSLog(@"--------compTracks---------");
    
    
    
    
    
    videoTrack = (AVAssetTrack *)videoTracks[0];
    CGAffineTransform pt = [videoTrack preferredTransform];
    float origWidth;
    float origHeight;
    origWidth = videoTrack.naturalSize.width;
    origHeight = videoTrack.naturalSize.height;
    
    if (pt.a==0.0 && pt.b==1.0 && pt.c==-1.0 && pt.d == 0.0) {
        origWidth = videoTrack.naturalSize.height;
        origHeight = videoTrack.naturalSize.width;
    } else if (pt.a==1.0 && pt.b==0.0 && pt.c==0.0 && pt.d == 1.0) {
        
    } else if (pt.a==-1.0 && pt.b==0.0 && pt.c==0.0 && pt.d == -1.0) {
        
    } else if (pt.a==0.0 && pt.b==-1.0 && pt.c==1.0 && pt.d == 0.0) {
        origWidth = videoTrack.naturalSize.height;
        origHeight = videoTrack.naturalSize.width;
    } else {
        
    }
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    
    NSLog(@"%@",layerInstructions);
    
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, finalDUration);
    mainInstruction.layerInstructions = layerInstructions;
    
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    
    mainVideoComp.renderSize = CGSizeMake(origWidth ,origHeight);
    
    creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    
    
    
    return(destinationURL);;
    
    
}
NSURL * FForSlowDownVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,NSMutableArray * sectionStarts,NSMutableArray * sectionEnds,NSMutableArray * ratios)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];
    
    return(FForSlowDownVideoFromSourceAsset(asset,whichTrack,destinationURL,sectionStarts,sectionEnds,ratios));
    
    
}
////---###
NSMutableArray * creatTimeInfoForReversingVideoFromSourceAsset(AVAsset*asset,int whichTrack)
{
    
    NSError * error ;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack *videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    
    
    AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:nil];
    [reader addOutput:readerOutput];
    [reader startReading];
    
    
    NSMutableArray *presentationTimeStamps = [[NSMutableArray alloc] init];
    NSMutableArray *decodeTimeStamps = [[NSMutableArray alloc] init];
    NSMutableArray *reOrderReferenceTimeStamps = [[NSMutableArray alloc] init];
    NSMutableArray *parallelArray = [[NSMutableArray alloc] init];
    
    BOOL done = NO;
    int samCounts = 0;
    while (!done)
    {
        
        
        
        CMSampleBufferRef sampleBuffer = [readerOutput copyNextSampleBuffer];
        
        if (sampleBuffer)
        {
            CMItemCount numOfsamplesInSampleBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
            if ((int)numOfsamplesInSampleBuffer == 0) {
                
            } else {
                CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                [presentationTimeStamps addObject:[NSValue valueWithCMTime:presentationTimeStamp]];
                CMTime decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer);
                [decodeTimeStamps addObject:[NSValue valueWithCMTime:decodeTimeStamp]];
                
                NSMutableDictionary * parallel =[[NSMutableDictionary alloc] init];
                if (CMTIME_IS_INVALID(decodeTimeStamp)) {
                    [reOrderReferenceTimeStamps addObject:[NSValue valueWithCMTime:presentationTimeStamp]];
                    [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                    [parallel setValue:(__bridge id)sampleBuffer forKey:@"sampleBuffer"];
                    [parallelArray addObject:parallel];
                    
                } else {
                    [reOrderReferenceTimeStamps addObject:[NSValue valueWithCMTime:decodeTimeStamp]];
                    [parallel setValue:[NSValue valueWithCMTime:decodeTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                    [parallel setValue:(__bridge id)sampleBuffer forKey:@"sampleBuffer"];
                    [parallelArray addObject:parallel];
                }
                
                CFRelease(sampleBuffer);
                sampleBuffer = NULL;
                samCounts ++;
            }
            
        } else {
            // Find out why the asset reader output couldn't copy another sample buffer.
            if (reader.status == AVAssetReaderStatusFailed)
            {
                NSError *failureError = reader.error;
                // Handle the error here.
                NSLog(@"failureError:%@",failureError.description);
                [reader cancelReading];
                break;
            }
            else
            {
                // The asset reader output has read all of its samples.
                done = YES;
                [reader cancelReading];
                break;
            }
        }
        
    }
    
    
    
    
    
    
    ////根据reOrderReferenceTimeStamp排序
    
    [parallelArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        NSDictionary * o1 = (NSDictionary *) obj1;
        NSDictionary * o2 = (NSDictionary *) obj2;
        
        CMTime pt1 = [[o1 valueForKey:@"reOrderReferenceTimeStamp"] CMTimeValue];
        CMTime pt2 = [[o2 valueForKey:@"reOrderReferenceTimeStamp"] CMTimeValue];
        
        
        
        if (pt1.value <= pt2.value) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (pt1.value > pt2.value) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    
    
    CMTime cursor = kCMTimeZero;
    NSMutableArray *eachSampleTimeInfoArray = [[NSMutableArray alloc] init];
    
    
    for(NSInteger h = parallelArray.count-1; h >=0 ; h--) {
        
        CMSampleBufferRef sampleBuffer = (__bridge CMSampleBufferRef)[parallelArray[h] valueForKey:@"sampleBuffer"];
        
        CFRetain(sampleBuffer);
        
        
        CMItemCount numOfsamplesInSampleBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
        CMItemCount count;
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
        CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, count, pInfo, &count);
        
        NSMutableArray * samplesParallelArray = [[NSMutableArray alloc] init];
        
        for (CMItemCount i = 0; i < count; i++)
        {
            NSMutableDictionary * parallel =[[NSMutableDictionary alloc] init];
            if (count == numOfsamplesInSampleBuffer) {
                [parallel setValue:[NSValue valueWithCMTime:pInfo[i].presentationTimeStamp] forKey:@"pts"];
                [parallel setValue:[NSValue valueWithCMTime:pInfo[i].decodeTimeStamp] forKey:@"dts"];
                [parallel setValue:[NSValue valueWithCMTime:pInfo[i].duration] forKey:@"dur"];
                [parallel setValue:[NSNumber numberWithInt:(int)i] forKey:@"origSampleSeq"];
                [parallel setValue:[NSNumber numberWithInt:(int)h] forKey:@"origSampleBufferSeq"];
                if (CMTIME_IS_INVALID(pInfo[i].decodeTimeStamp)) {
                    [parallel setValue:[NSValue valueWithCMTime:pInfo[i].presentationTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                } else {
                    [parallel setValue:[NSValue valueWithCMTime:pInfo[i].decodeTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                }
            } else {
                CMTime base;
                if (CMTIME_IS_INVALID(pInfo[0].decodeTimeStamp)) {
                    base = pInfo[0].presentationTimeStamp;
                } else {
                    base = pInfo[0].decodeTimeStamp;
                }
                CMTime interval = pInfo[0].duration;
                [parallel setValue:[NSValue valueWithCMTime:interval] forKey:@"dur"];
                CMTime npts = CMTimeAdd(base, CMTimeMultiply(interval, (int)i));
                
                [parallel setValue:[NSValue valueWithCMTime:npts] forKey:@"pts"];
                [parallel setValue:[NSValue valueWithCMTime:kCMTimeInvalid] forKey:@"dts"];
                [parallel setValue:[NSNumber numberWithInt:(int)i] forKey:@"origSampleSeq"];
                [parallel setValue:[NSNumber numberWithInt:(int)h] forKey:@"origSampleBufferSeq"];
                [parallel setValue:[NSValue valueWithCMTime:pInfo[0].presentationTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                
            }
            [samplesParallelArray addObject:parallel];
        }
        
        ////根据reOrderReferenceTimeStamp排序
        
        [samplesParallelArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            NSDictionary * o1 = (NSDictionary *) obj1;
            NSDictionary * o2 = (NSDictionary *) obj2;
            
            CMTime pt1 = [[o1 valueForKey:@"reOrderReferenceTimeStamp"] CMTimeValue];
            CMTime pt2 = [[o2 valueForKey:@"reOrderReferenceTimeStamp"] CMTimeValue];
            
            
            
            if (pt1.value <= pt2.value) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (pt1.value > pt2.value) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        
        
        
        
        
        for (int i = (int)(samplesParallelArray.count-1); i >=0 ; i--){
            [samplesParallelArray[i] setValue:[NSValue valueWithCMTime:cursor] forKey:@"npts"];
            [eachSampleTimeInfoArray addObject:samplesParallelArray[i]];
            cursor = CMTimeAdd(cursor, [[samplesParallelArray[i] valueForKey:@"dur"] CMTimeValue]);
            
        }
        
        [parallelArray insertObject:[NSNull null] atIndex:h];
        CFRelease(sampleBuffer);
        
    }
    
    
    NSLog(@"%@",eachSampleTimeInfoArray);
    return(eachSampleTimeInfoArray);
}


NSMutableArray * creatTimeInfoForReversingVideoFromSourceURL(NSURL*sourceURL,int whichTrack)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];
    return creatTimeInfoForReversingVideoFromSourceAsset(asset, whichTrack);
}


////---###
NSURL * noisingOrRecoverVideoFromSourceAsset(AVAsset*asset,int whichTrack,NSURL*destinationURL)
{
    NSString * tempPath = [destinationURL path];
    [FileUitl deleteTmpFile:tempPath];
    
    
    
    NSError * error ;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack *videoTrack = [selectAllVideoTracksFromAVAsset(asset) objectAtIndex:whichTrack];
    
    
    
    
    AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:nil];
    [reader addOutput:readerOutput];
    [reader startReading];
    
    
    NSMutableArray *presentationTimeStamps = [[NSMutableArray alloc] init];
    ////For in-presentation-order samples, this is the presentation timestamp of the first sample.
    ////For out-of-presentation-order samples, this is the presentation timestamp of the sample
    ////that will be presented first, which is not necessarily the first sample in the buffer.
    NSMutableArray *decodeTimeStamps = [[NSMutableArray alloc] init];
    ////如果decodeTimeStamp = kCMTimeInvalid,那么使用presentationTimeStamp
    ////否则使用decodeTimeStamp
    NSMutableArray *reOrderReferenceTimeStamps = [[NSMutableArray alloc] init];
    NSMutableArray *parallelArray = [[NSMutableArray alloc] init];
    
    BOOL done = NO;
    int samCounts = 0;
    while (!done)
    {
        
        
        
        CMSampleBufferRef sampleBuffer = [readerOutput copyNextSampleBuffer];
        
        if (sampleBuffer)
        {
            CMItemCount numOfsamplesInSampleBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
            if ((int)numOfsamplesInSampleBuffer == 0) {
                //这一步时必须的，因为真实视频中经常有内容为空的sampleBuffer
                /*
                 #===================================================
                 {
                 reOrderReferenceTimeStamp = "CMTime: {INVALID}";
                 CMSampleBuffer 0x154597c60
                 retainCount: 1
                 allocator: 0x1981a1f50
                 invalid = NO
                 dataReady = YES
                 makeDataReadyCallback = 0x0
                 makeDataReadyRefcon = 0x0
                 buffer-level attachments:
                 DrainAfterDecoding(P) = true
                 formatDescription = <CMVideoFormatDescription 0x174247980 [0x1981a1f50]> {
                 mediaType:'vide'
                 mediaSubType:'avc1'
                 mediaSpecific: {
                 codecType: 'avc1'		dimensions: 1920 x 1080
                 }
                 extensions: {<CFBasicHash 0x17446a480 [0x1981a1f50]>{type = immutable dict, count = 15,
                 entries =>
                 0 : <CFString 0x198309620 [0x1981a1f50]>{contents = "CVImageBufferColorPrimaries"} = <CFString 0x174224fe0 [0x1981a1f50]>{contents = "ITU_R_709_2"}
                 2 : <CFString 0x19829f5b8 [0x1981a1f50]>{contents = "FormatName"} = <CFString 0x174224ba0 [0x1981a1f50]>{contents = "H.264"}
                 3 : <CFString 0x19829f738 [0x1981a1f50]>{contents = "SpatialQuality"} = <CFNumber 0xb000000000002002 [0x1981a1f50]>{value = +512, type = kCFNumberSInt32Type}
                 4 : <CFString 0x19829f758 [0x1981a1f50]>{contents = "Version"} = <CFNumber 0xb000000000000001 [0x1981a1f50]>{value = +0, type = kCFNumberSInt16Type}
                 5 : <CFString 0x19829f578 [0x1981a1f50]>{contents = "VerbatimSampleDescription"} = <CFData 0x1743a2bc0 [0x1981a1f50]>{length = 152, capacity = 152, bytes = 0x00000098617663310000000000000001 ... 0001000100000000}
                 6 : <CFString 0x1983096a0 [0x1981a1f50]>{contents = "CVImageBufferTransferFunction"} = <CFString 0x174225280 [0x1981a1f50]>{contents = "ITU_R_709_2"}
                 7 : <CFString 0x198309700 [0x1981a1f50]>{contents = "CVImageBufferChromaLocationBottomField"} = <CFString 0x174224f40 [0x1981a1f50]>{contents = "Left"}
                 11 : <CFString 0x19829f718 [0x1981a1f50]>{contents = "TemporalQuality"} = <CFNumber 0xb000000000002002 [0x1981a1f50]>{value = +512, type = kCFNumberSInt32Type}
                 12 : <CFString 0x19829f778 [0x1981a1f50]>{contents = "RevisionLevel"} = <CFNumber 0xb000000000000001 [0x1981a1f50]>{value = +0, type = kCFNumberSInt16Type}
                 14 : <CFString 0x1983095a0 [0x1981a1f50]>{contents = "CVImageBufferYCbCrMatrix"} = <CFString 0x1742255a0 [0x1981a1f50]>{contents = "ITU_R_709_2"}
                 16 : <CFString 0x1983096e0 [0x1981a1f50]>{contents = "CVImageBufferChromaLocationTopField"} = <CFString 0x174223d40 [0x1981a1f50]>{contents = "Left"}
                 18 : <CFString 0x19829f558 [0x1981a1f50]>{contents = "SampleDescriptionExtensionAtoms"} = <CFBasicHash 0x17446a3c0 [0x1981a1f50]>{type = immutable dict, count = 1,
                 entries =>
                 2 : <CFString 0x1982a35f8 [0x1981a1f50]>{contents = "avcC"} = <CFData 0x1742ca480 [0x1981a1f50]>{length = 36, capacity = 36, bytes = 0x01640029ffe1001067640029ac568078 ... ee04f2c0fdf8f800}
                 }
                 
                 19 : <CFString 0x19829f698 [0x1981a1f50]>{contents = "FullRangeVideo"} = <CFBoolean 0x1981a2300 [0x1981a1f50]>{value = false}
                 20 : <CFString 0x198309420 [0x1981a1f50]>{contents = "CVFieldCount"} = <CFNumber 0xb000000000000012 [0x1981a1f50]>{value = +1, type = kCFNumberSInt32Type}
                 22 : <CFString 0x19829f5d8 [0x1981a1f50]>{contents = "Depth"} = <CFNumber 0xb000000000000181 [0x1981a1f50]>{value = +24, type = kCFNumberSInt16Type}
                 }
                 }
                 }
                 sbufToTrackReadiness = 0x0
                 numSamples = 0================================>这类sampleBuffer尽量移除
                 dataBuffer = 0x0
                 },
                 #===================================================
                 */
            } else {
                CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                [presentationTimeStamps addObject:[NSValue valueWithCMTime:presentationTimeStamp]];
                CMTime decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer);
                [decodeTimeStamps addObject:[NSValue valueWithCMTime:decodeTimeStamp]];
                
                NSMutableDictionary * parallel =[[NSMutableDictionary alloc] init];
                if (CMTIME_IS_INVALID(decodeTimeStamp)) {
                    [reOrderReferenceTimeStamps addObject:[NSValue valueWithCMTime:presentationTimeStamp]];
                    [parallel setValue:[NSValue valueWithCMTime:presentationTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                    [parallel setValue:(__bridge id)sampleBuffer forKey:@"sampleBuffer"];
                    [parallelArray addObject:parallel];
                    
                } else {
                    [reOrderReferenceTimeStamps addObject:[NSValue valueWithCMTime:decodeTimeStamp]];
                    [parallel setValue:[NSValue valueWithCMTime:decodeTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                    [parallel setValue:(__bridge id)sampleBuffer forKey:@"sampleBuffer"];
                    [parallelArray addObject:parallel];
                }
                
                CFRelease(sampleBuffer);
                sampleBuffer = NULL;
                samCounts ++;
            }
            
        } else {
            // Find out why the asset reader output couldn't copy another sample buffer.
            if (reader.status == AVAssetReaderStatusFailed)
            {
                NSError *failureError = reader.error;
                // Handle the error here.
                NSLog(@"failureError:%@",failureError.description);
                [reader cancelReading];
                break;
            }
            else
            {
                // The asset reader output has read all of its samples.
                done = YES;
                [reader cancelReading];
                break;
            }
        }
        
    }
    
    
    
    
    
    
    ////根据reOrderReferenceTimeStamp排序
    
    [parallelArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        NSDictionary * o1 = (NSDictionary *) obj1;
        NSDictionary * o2 = (NSDictionary *) obj2;
        
        CMTime pt1 = [[o1 valueForKey:@"reOrderReferenceTimeStamp"] CMTimeValue];
        CMTime pt2 = [[o2 valueForKey:@"reOrderReferenceTimeStamp"] CMTimeValue];
        
        
        
        if (pt1.value <= pt2.value) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (pt1.value > pt2.value) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    
    
    
    
    
    
    
    
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:destinationURL
                                                      fileType:AVFileTypeQuickTimeMovie
                                                         error:&error];
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:nil];
    [writerInput setExpectsMediaDataInRealTime:NO];
    writerInput.transform = [videoTrack preferredTransform];
    [writer addInput:writerInput];
    [writer startWriting];
    [writer startSessionAtSourceTime:kCMTimeZero];
    
    
    CMTime cursor = kCMTimeZero;
    
    
    for(NSInteger h = parallelArray.count-1; h >=0 ; h--) {
        
        CMSampleBufferRef sampleBuffer = (__bridge CMSampleBufferRef)[parallelArray[h] valueForKey:@"sampleBuffer"];
        
        CFRetain(sampleBuffer);
        
        while (!writerInput.readyForMoreMediaData) {
            NSLog(@"start wait");
            [NSThread sleepForTimeInterval:0.1f];
            NSLog(@"did wait");
            
        }
        
        
        
        CMItemCount numOfsamplesInSampleBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
        CMItemCount count;
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
        CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, count, pInfo, &count);
        
        NSMutableArray * samplesParallelArray = [[NSMutableArray alloc] init];
        
        for (CMItemCount i = 0; i < count; i++)
        {
            NSMutableDictionary * parallel =[[NSMutableDictionary alloc] init];
            if (count == numOfsamplesInSampleBuffer) {
                [parallel setValue:[NSValue valueWithCMTime:pInfo[i].presentationTimeStamp] forKey:@"pts"];
                [parallel setValue:[NSValue valueWithCMTime:pInfo[i].decodeTimeStamp] forKey:@"dts"];
                [parallel setValue:[NSValue valueWithCMTime:pInfo[i].duration] forKey:@"dur"];
                [parallel setValue:[NSNumber numberWithInt:(int)i] forKey:@"origSampleSeq"];
                if (CMTIME_IS_INVALID(pInfo[i].decodeTimeStamp)) {
                    [parallel setValue:[NSValue valueWithCMTime:pInfo[i].presentationTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                } else {
                    [parallel setValue:[NSValue valueWithCMTime:pInfo[i].decodeTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                }
            } else {
                CMTime base;
                if (CMTIME_IS_INVALID(pInfo[0].decodeTimeStamp)) {
                    base = pInfo[0].presentationTimeStamp;
                } else {
                    base = pInfo[0].decodeTimeStamp;
                }
                CMTime interval = pInfo[0].duration;
                [parallel setValue:[NSValue valueWithCMTime:interval] forKey:@"dur"];
                CMTime npts = CMTimeAdd(base, CMTimeMultiply(interval, (int)i));
                
                [parallel setValue:[NSValue valueWithCMTime:npts] forKey:@"pts"];
                [parallel setValue:[NSValue valueWithCMTime:kCMTimeInvalid] forKey:@"dts"];
                [parallel setValue:[NSNumber numberWithInt:(int)i] forKey:@"origSampleSeq"];
                [parallel setValue:[NSValue valueWithCMTime:pInfo[0].presentationTimeStamp] forKey:@"reOrderReferenceTimeStamp"];
                
            }
            [samplesParallelArray addObject:parallel];
        }
        
        ////根据reOrderReferenceTimeStamp排序
        
        [samplesParallelArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            NSDictionary * o1 = (NSDictionary *) obj1;
            NSDictionary * o2 = (NSDictionary *) obj2;
            
            CMTime pt1 = [[o1 valueForKey:@"reOrderReferenceTimeStamp"] CMTimeValue];
            CMTime pt2 = [[o2 valueForKey:@"reOrderReferenceTimeStamp"] CMTimeValue];
            
            
            
            if (pt1.value <= pt2.value) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (pt1.value > pt2.value) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        
        
        /*
         for (int i = 0; i < samplesParallelArray.count; i++)
         {
         [samplesParallelArray[i] setValue:[NSValue valueWithCMTime:cursor] forKey:@"npts"];
         cursor = CMTimeAdd(cursor, [[samplesParallelArray[i] valueForKey:@"dur"] CMTimeValue]);
         
         }
         */
        
        for (int i = (int) samplesParallelArray.count - 1; i >= 0 ; i--)
        {
            [samplesParallelArray[i] setValue:[NSValue valueWithCMTime:cursor] forKey:@"npts"];
            cursor = CMTimeAdd(cursor, [[samplesParallelArray[i] valueForKey:@"dur"] CMTimeValue]);
            
        }
        
        
        
        
        ////根据origSeq排序
        
        [samplesParallelArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            NSDictionary * o1 = (NSDictionary *) obj1;
            NSDictionary * o2 = (NSDictionary *) obj2;
            
            NSNumber * pt1 = [o1 valueForKey:@"origSeq"] ;
            NSNumber * pt2 = [o2 valueForKey:@"origSeq"] ;
            
            
            
            if ([pt1 intValue] <= [pt2 intValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ([pt1 intValue]  > [pt2 intValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        
        
        for (CMItemCount i = 0; i < count; i++)
        {
            pInfo[i].presentationTimeStamp = [[samplesParallelArray[i] valueForKey:@"npts"] CMTimeValue];
            pInfo[i].decodeTimeStamp = kCMTimeInvalid;
            ////[[samplesParallelArray[i] valueForKey:@"npts"] CMTimeValue];
            //// kCMTimeInvalid if in sequence
            /*
             ! @field duration
             The duration of the sample. If a single struct applies to
             each of the samples, they all will have this duration.
             ! @field presentationTimeStamp
             The time at which the sample will be presented. If a single
             struct applies to each of the samples, this is the presentationTime of the
             first sample. The presentationTime of subsequent samples will be derived by
             repeatedly adding the sample duration.
             ! @field decodeTimeStamp
             The time at which the sample will be decoded. If the samples
             are in presentation order, this must be set to kCMTimeInvalid.
             */
            
        }
        CMSampleBufferRef sout;
        CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, sampleBuffer, count, pInfo, &sout);
        free(pInfo);
        
        [writerInput appendSampleBuffer:sout];
        
        
        
        [parallelArray insertObject:[NSNull null] atIndex:h];
        CFRelease(sampleBuffer);
        CFRelease(sout);
        
    }
    
    
    
    checkAVAssetWriterStatus(writer);
    [writerInput markAsFinished];
    ////this is necessary to make sure the finishWritingWithCompletionHandler be excuted
    [writer endSessionAtSourceTime:cursor];
    checkAVAssetWriterStatus(writer);
    
    [writer finishWritingWithCompletionHandler:^{
        checkAVAssetWriterStatus(writer);
        NSLog(@"begin Export!");
        [FileUitl writeVideoToPhotoLibrary:destinationURL];
        NSLog(@"Export complete!");
    }];
    
    return(destinationURL);
    
}
NSURL * noisingOrRecoverVideoFromSourceURL(NSURL*sourceURL,int whichTrack,NSURL*destinationURL)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];
    
    return(noisingOrRecoverVideoFromSourceAsset(asset, whichTrack,destinationURL));
    
}
////---###




///---###


////-part3.2


AVMutableCompositionTrack  * creatConcatedVideoCompTrackWithTracksSelection(NSMutableArray*videoTracks,NSMutableArray*indexes,AVMutableComposition *mixComposition)
{
    ////-tested
    
    AVMutableCompositionTrack * mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)videoTracks[index];
        
        [mutableCompVideoTrack insertTimeRange:CMTimeRangeMake(track.timeRange.start, track.timeRange.duration) ofTrack:videoTracks[i] atTime:currentCMTime error:nil];
        
        currentCMTime = CMTimeAdd(currentCMTime, track.timeRange.duration);
        
    }
    return(mutableCompVideoTrack);
}


AVMutableCompositionTrack  * creatConcatedAudioCompTrackWithTracksSelection(NSMutableArray*audioTracks, NSMutableArray*indexes,AVMutableComposition *mixComposition)
{
    
    
    AVMutableCompositionTrack * mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)audioTracks[index];
        
        [mutableCompAudioTrack insertTimeRange:CMTimeRangeMake(track.timeRange.start, track.timeRange.duration) ofTrack:audioTracks[i] atTime:currentCMTime error:nil];
        
        
        currentCMTime = CMTimeAdd(currentCMTime, track.timeRange.duration);
        
    }
    
    return(mutableCompAudioTrack);
}





AVMutableCompositionTrack  * creatConcatedAudioCompTrackWithTracksSelectionWithCMTimeRangeSelection(NSMutableArray*audioTracks, NSMutableArray*indexes,NSMutableArray*timeRanges,AVMutableComposition *mixComposition)
{
    AVMutableCompositionTrack * mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)audioTracks[index];
        
        
        [mutableCompAudioTrack insertTimeRange:[timeRanges[i] CMTimeRangeValue] ofTrack:track atTime:currentCMTime error:nil];
        
        currentCMTime = CMTimeAdd(currentCMTime, track.timeRange.duration);
        
    }
    
    return(mutableCompAudioTrack);
    
}

AVMutableCompositionTrack  * creatConcatedAudioCompTrackWithAllTracksWithCMTimeRangeSelection(NSMutableArray * audioTracks,NSMutableArray*timeRanges,AVMutableComposition *mixComposition)
{
    AVMutableCompositionTrack * mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < audioTracks.count; i++) {
        
        
        AVAssetTrack * track = (AVAssetTrack *)audioTracks[i];
        
        [mutableCompAudioTrack insertTimeRange:[timeRanges[i] CMTimeRangeValue] ofTrack:track atTime:currentCMTime error:nil];
        
        currentCMTime = CMTimeAdd(currentCMTime, track.timeRange.duration);
    }
    
    return(mutableCompAudioTrack);
}





AVMutableCompositionTrack  * creatConcatedVideoCompTrackWithTracksSelectionWithCMTimeRangeSelection(NSMutableArray*videoTracks, NSMutableArray*indexes,NSMutableArray*timeRanges,AVMutableComposition *mixComposition)
{
    AVMutableCompositionTrack * mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)videoTracks[index];
        
        
        [mutableCompVideoTrack insertTimeRange:[timeRanges[i] CMTimeRangeValue] ofTrack:track atTime:currentCMTime error:nil];
        
        currentCMTime = CMTimeAdd(currentCMTime, track.timeRange.duration);
        
    }
    
    return(mutableCompVideoTrack);
    
}


AVMutableCompositionTrack  * creatConcatedVideoCompTrackWithAllTracksWithCMTimeRangeSelection(NSMutableArray * videoTracks,NSMutableArray*timeRanges,AVMutableComposition *mixComposition)
{
    AVMutableCompositionTrack * mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < videoTracks.count; i++) {
        
        
        AVAssetTrack * track = (AVAssetTrack *)videoTracks[i];
        
        [mutableCompVideoTrack insertTimeRange:[timeRanges[i] CMTimeRangeValue] ofTrack:track atTime:currentCMTime error:nil];
        
        
        currentCMTime = CMTimeAdd(currentCMTime, track.timeRange.duration);
    }
    
    return(mutableCompVideoTrack);
}












AVMutableCompositionTrack * creatConcatedVideoCompTrackWithAllTracks(NSMutableArray * videoTracks,AVMutableComposition *mixComposition)
{
    ////----tested
    NSMutableArray * indexes = [[NSMutableArray alloc] init];
    for (int i = 0; i< videoTracks.count; i++) {
        NSNumber * num = [NSNumber numberWithInt:i];
        [indexes addObject:num];
    }
    
    AVMutableCompositionTrack * rslt= creatConcatedVideoCompTrackWithTracksSelection(videoTracks, indexes,mixComposition);
    return(rslt);
}


AVMutableCompositionTrack * creatConcatedAudioCompTrackWithAllTracks(NSMutableArray * audioTracks,AVMutableComposition *mixComposition)
{
    NSMutableArray * indexes = [[NSMutableArray alloc] init];
    for (int i = 0; i< audioTracks.count; i++) {
        NSNumber * num = [NSNumber numberWithInt:i];
        [indexes addObject:num];
    }
    
    AVMutableCompositionTrack * rslt= creatConcatedAudioCompTrackWithTracksSelection(audioTracks, indexes,mixComposition);
    return(rslt);
}



NSMutableArray  * creatMergedAudioCompTracksWithTracksSelection(NSMutableArray*audioTracks, NSMutableArray*indexes,AVMutableComposition *mixComposition)
{
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)audioTracks[index];
        
        AVMutableCompositionTrack * mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [mutableCompAudioTrack insertTimeRange:CMTimeRangeMake(track.timeRange.start, track.timeRange.duration) ofTrack:audioTracks[i] atTime:currentCMTime error:nil];
        
        [compTracks addObject:mutableCompAudioTrack];
        
        
    }
    
    return(compTracks);
}


NSMutableArray  * creatMergedAudioCompTracksWithAllTracks(NSMutableArray * audioTracks,AVMutableComposition *mixComposition)
{
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < audioTracks.count; i++) {
        
        
        AVAssetTrack * track = (AVAssetTrack *)audioTracks[i];
        
        AVMutableCompositionTrack * mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [mutableCompAudioTrack insertTimeRange:CMTimeRangeMake(track.timeRange.start, track.timeRange.duration) ofTrack:audioTracks[i] atTime:currentCMTime error:nil];
        
        [compTracks addObject:mutableCompAudioTrack];
        
        
    }
    
    return(compTracks);
}

NSMutableArray  * creatMergedAudioCompTracksWithTracksSelectionWithCMTimeRangeSelection(NSMutableArray*audioTracks, NSMutableArray*indexes,NSMutableArray*timeRanges,AVMutableComposition *mixComposition)
{
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)audioTracks[index];
        
        AVMutableCompositionTrack * mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [mutableCompAudioTrack insertTimeRange:[timeRanges[i] CMTimeRangeValue] ofTrack:track atTime:currentCMTime error:nil];
        
        [compTracks addObject:mutableCompAudioTrack];
        
        
    }
    
    return(compTracks);
}



NSMutableArray  * creatMergedAudioCompTracksWithAllTracksWithCMTimeRangeSelection(NSMutableArray * audioTracks,NSMutableArray*timeRanges,AVMutableComposition *mixComposition)
{
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < audioTracks.count; i++) {
        
        AVAssetTrack * track = (AVAssetTrack *)audioTracks[i];
        
        AVMutableCompositionTrack * mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [mutableCompAudioTrack insertTimeRange:[timeRanges[i] CMTimeRangeValue] ofTrack:track atTime:currentCMTime error:nil];
        
        [compTracks addObject:mutableCompAudioTrack];
        
        
    }
    
    return(compTracks);
}



NSMutableArray  * creatMergedVideoCompTracksWithTracksSelection(NSMutableArray*videoTracks,NSMutableArray*indexes,AVMutableComposition *mixComposition)
{
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)videoTracks[index];
        
        AVMutableCompositionTrack * mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [mutableCompVideoTrack insertTimeRange:CMTimeRangeMake(track.timeRange.start, track.timeRange.duration) ofTrack:videoTracks[i] atTime:currentCMTime error:nil];
        
        [compTracks addObject:mutableCompVideoTrack];
        
        
    }
    
    return(compTracks);
}


NSMutableArray  * creatMergedVideoCompTracksWithAllTracks(NSMutableArray * videoTracks,AVMutableComposition *mixComposition)
{
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < videoTracks.count; i++) {
        
        
        AVAssetTrack * track = (AVAssetTrack *)videoTracks[i];
        
        AVMutableCompositionTrack * mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [mutableCompVideoTrack insertTimeRange:CMTimeRangeMake(track.timeRange.start, track.timeRange.duration) ofTrack:videoTracks[i] atTime:currentCMTime error:nil];
        
        [compTracks addObject:mutableCompVideoTrack];
        
        
    }
    
    return(compTracks);
}


NSMutableArray  * creatMergedVideoCompTracksWithTracksSelectionWithCMTimeRangeSelection(NSMutableArray*videoTracks, NSMutableArray*indexes,NSMutableArray*timeRanges,AVMutableComposition *mixComposition)
{
    
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < indexes.count; i++) {
        
        int index = (int)[(NSNumber *)indexes[i] integerValue];
        
        AVAssetTrack * track = (AVAssetTrack *)videoTracks[index];
        
        AVMutableCompositionTrack * mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [mutableCompVideoTrack insertTimeRange:[timeRanges[i] CMTimeRangeValue] ofTrack:track atTime:currentCMTime error:nil];
        
        [compTracks addObject:mutableCompVideoTrack];
        
        
    }
    
    return(compTracks);
    
}



NSMutableArray  * creatMergedVideoCompTracksWithAllTracksWithCMTimeRangeSelection(NSMutableArray * videoTracks,NSMutableArray*timeRanges,AVMutableComposition *mixComposition)
{
    NSMutableArray * compTracks = [[NSMutableArray alloc] init];
    
    CMTime currentCMTime = kCMTimeZero;
    
    for (int i = 0; i < videoTracks.count; i++) {
        
        AVAssetTrack * track = (AVAssetTrack *)videoTracks[i];
        
        AVMutableCompositionTrack * mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [mutableCompVideoTrack insertTimeRange:[timeRanges[i] CMTimeRangeValue] ofTrack:track atTime:currentCMTime error:nil];
        
        [compTracks addObject:mutableCompVideoTrack];
        
        
    }
    
    return(compTracks);
}



////part-4















NSURL * creatMovieFromAVMutableCompositionPassThrough(AVMutableComposition*mixComposition,NSURL*destinationMovieURL)
{
    
    ////----tested
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    exportSession.outputURL = destinationMovieURL;
    
    NSLog(@"destinationMovieURL:%@",destinationMovieURL);
    
    CMTimeShow(mixComposition.duration);
    
    printCMTime(mixComposition.duration, @"    ");
    
    CMTimeValue val = mixComposition.duration.value;
    CMTime start = CMTimeMake(0, mixComposition.duration.timescale);
    CMTime duration = CMTimeMake(val, mixComposition.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error]debugDescription]);
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Export canceled");
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                NSLog(@"Export complete!");
                [FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
                break;
            }
            default:
            {
                NSLog(@"default");
                break;
            }
        }
    }];
    return(destinationMovieURL);
}



NSURL * creatRangeOfMovieFromAVAsset(AVAsset * asset,CMTimeRange range,NSURL*destinationMovieURL)
{
    
    ////----this works , already  tested
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    
    
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    exportSession.outputURL = destinationMovieURL;
    
    NSLog(@"destinationMovieURL:%@",destinationMovieURL);
    
    
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error]debugDescription]);
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Export canceled");
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                NSLog(@"Export complete!");
                [FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
                break;
                
            }
            default:
            {
                NSLog(@"default");
                break;
            }
        }
    }];
    return(destinationMovieURL);
}





NSURL * creatMovieFromAVMutableCompositionWithPreset(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName)
{
    
    ////----this works , already  tested
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:presetName];
    ////AVAssetExportPresetPassthrough
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    exportSession.outputURL = destinationMovieURL;
    
    NSLog(@"destinationMovieURL:%@",destinationMovieURL);
    
    CMTimeValue val = mixComposition.duration.value;
    CMTime start = CMTimeMake(0, mixComposition.duration.timescale);
    CMTime duration = CMTimeMake(val, mixComposition.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error]debugDescription]);
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Export canceled");
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                NSLog(@"Export complete!");
                [FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
                break;
            }
            default:
            {
                NSLog(@"default");
                break;
            }
        }
    }];
    return(destinationMovieURL);
}




NSURL * creatMovieFromAVMutableCompositionWithParameters(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName,AVVideoComposition* videoComposition)
{
    
    ////----this works , already  tested
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:presetName];
    ////AVAssetExportPresetPassthrough
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    exportSession.outputURL = destinationMovieURL;
    
    NSLog(@"destinationMovieURL:%@",destinationMovieURL);
    
    CMTimeValue val = mixComposition.duration.value;
    CMTime start = CMTimeMake(0, mixComposition.duration.timescale);
    CMTime duration = CMTimeMake(val, mixComposition.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    exportSession.videoComposition = videoComposition;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error]debugDescription]);
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Export canceled");
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                [FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
                NSLog(@"Export complete!");
                break;
            }
            default:
            {
                NSLog(@"default");
                break;
            }
        }
    }];
    return(destinationMovieURL);
}




NSURL * creatMergeVideoOnlyMovieFromTracks(NSMutableArray * videoTracks,NSURL*destinationMovieURL)
{
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    CMTime mergedVideoDuration = getMaxCMTDurationTrackFromTracksArray(videoTracks).timeRange.duration;
    
    CMTimeShow(mergedVideoDuration);
    
    
    NSMutableArray * compositionTracks = [[NSMutableArray alloc] init];
    
    int count = (int)videoTracks.count;
    
    AVAssetTrack * originalTrack;
    AVMutableCompositionTrack * compositionTrack;
    
    
    // 为每段视频生成compositionTrack
    
    for (int i = 0; i < count; i++) {
        
        originalTrack = (AVAssetTrack *)videoTracks[i];
        compositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionTracks addObject:compositionTrack];
        
    }
    
    
    // 给每段视频填充空白padding
    
    for (int i = 0; i < count; i++) {
        
        originalTrack = (AVAssetTrack *)videoTracks[i];
        compositionTrack =  (AVMutableCompositionTrack * )compositionTracks[i];
        
        [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, originalTrack.timeRange.duration) ofTrack:originalTrack atTime:kCMTimeZero error:nil];
        
        if (CMTimeCompare(originalTrack.timeRange.duration, mergedVideoDuration) <= 0) {
            
            
            
        } else {
            
            CMTime substract = CMTimeSubtract(mergedVideoDuration, originalTrack.timeRange.duration);
            
            /*
             kCMTimeRoundingMethod_RoundHalfAwayFromZero = 1,
             kCMTimeRoundingMethod_RoundTowardZero = 2,
             kCMTimeRoundingMethod_RoundAwayFromZero = 3,
             kCMTimeRoundingMethod_QuickTime = 4,
             kCMTimeRoundingMethod_RoundTowardPositiveInfinity = 5,
             kCMTimeRoundingMethod_RoundTowardNegativeInfinity = 6,
             kCMTimeRoundingMethod_Default = kCMTimeRoundingMethod_RoundHalfAwayFromZero
             */
            
            
            
            substract = CMTimeConvertScale(substract,mergedVideoDuration.timescale,kCMTimeRoundingMethod_QuickTime);
            
            [compositionTrack insertEmptyTimeRange:CMTimeRangeMake(originalTrack.timeRange.duration, substract)];
            
        }
    }
    
    
    
    //创建main instruction layer
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mergedVideoDuration);
    
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction;
    
    // 每个 compositionTrack 创建 layer,并且不显示空白段padding视频
    // 进行这一步的原因是：
    // 假如视频总时长是 10， 原始视频时长只有8 ，那么需要插入时长为2的空白视频
    // 此时在原始视频播放完毕之后视频将会永远显示 原始视频的最后一副画面
    NSMutableArray * layerInstructions = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++) {
        
        originalTrack = (AVAssetTrack *)videoTracks[i];
        compositionTrack =  (AVMutableCompositionTrack * )compositionTracks[i];
        layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack];
        
        [layerInstructions addObject:layerInstruction];
        
        
        if (CMTimeCompare(originalTrack.timeRange.duration, mergedVideoDuration) <= 0) {
            
        } else {
            
            CMTime substract = CMTimeSubtract(mergedVideoDuration, originalTrack.timeRange.duration);
            
            /*
             kCMTimeRoundingMethod_RoundHalfAwayFromZero = 1,
             kCMTimeRoundingMethod_RoundTowardZero = 2,
             kCMTimeRoundingMethod_RoundAwayFromZero = 3,
             kCMTimeRoundingMethod_QuickTime = 4,
             kCMTimeRoundingMethod_RoundTowardPositiveInfinity = 5,
             kCMTimeRoundingMethod_RoundTowardNegativeInfinity = 6,
             kCMTimeRoundingMethod_Default = kCMTimeRoundingMethod_RoundHalfAwayFromZero
             */
            
            
            
            substract = CMTimeConvertScale(substract,mergedVideoDuration.timescale,kCMTimeRoundingMethod_QuickTime);
            
            [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
            [layerInstruction setOpacity:0.0 atTime:originalTrack.timeRange.duration];
            
            
            
        }
    }
    
    
    mainInstruction.layerInstructions = layerInstructions;
    
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    mainComposition.frameDuration = CMTimeMake(1, [videoTracks[0] nominalFrameRate]);
    mainComposition.renderSize = [videoTracks[0] naturalSize];
    
    
    return(creatMovieFromAVMutableCompositionWithParameters(mixComposition,destinationMovieURL,AVAssetExportPresetHighestQuality,mainComposition));
    
}



NSURL * creatMergeVideoOnlyMovieFromAssets(NSMutableArray * assets,NSURL*destinationMovieURL)
{
    
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    
    videoTracks = putsAllVideoTracksIntoTracksArrayFromAssets(assets);
    
    return(creatMergeVideoOnlyMovieFromTracks(assets,destinationMovieURL));
    
}



NSURL * creatMergeVideoOnlyMovieFromSourceURLs(NSMutableArray *sourceMovieURLs,NSURL*destinationMovieURL)
{
    
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    
    NSMutableArray * videoTracksWithAsset = putsAllVideoTracksIntoTracksWithAssetArrayFromSourceURLs(sourceMovieURLs);
    videoTracks = getAllTracksFromTracksWithAssetArray(videoTracksWithAsset);
    
    
    return(creatMergeVideoOnlyMovieFromTracks(videoTracks,destinationMovieURL));
    
}








NSURL * creatMergeMovieFromAudioTracksAndVideoTracks(NSArray * audioTracks,NSArray * videoTracks,NSURL*destinationMovieURL)
{
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    ////NSMutableArray * mutableCompAudioTracks = [[NSMutableArray alloc] init];
    ////NSMutableArray * mutableCompVideoTracks = [[NSMutableArray alloc] init];
    
    
    
    
    
    AVAssetTrack * vt = (AVAssetTrack *)videoTracks[0];
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, vt.timeRange.duration);
    
    int count;
    
    if (audioTracks.count >= videoTracks.count) {
        count = (int)audioTracks.count;
    } else {
        count = (int)videoTracks.count;
    }
    
    
    for (int i = 0; i < count; i++) {
        if (count <= audioTracks.count) {
            ////[mutableCompAudioTracks addObject:[mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid]];
        }
        if (count <= videoTracks.count) {
            ////[mutableCompVideoTracks addObject:[mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid]];
            AVMutableCompositionTrack *track = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            AVAssetTrack * vt = (AVAssetTrack *)videoTracks[i];
            
            [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, vt.timeRange.duration) ofTrack:videoTracks[i] atTime:kCMTimeZero error:nil];
            
            
            
            
            
            
        }
    }
    
    
    
    
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:(AVAssetTrack *)videoTracks[0]];
    CGAffineTransform Scale = CGAffineTransformMakeScale(0.6f,0.6f);
    CGAffineTransform Move = CGAffineTransformMakeTranslation(320,320);
    [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
    
    
    
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:(AVAssetTrack *)videoTracks[1]];
    CGAffineTransform SecondScale = CGAffineTransformMakeScale(0.9f,0.9f);
    CGAffineTransform SecondMove = CGAffineTransformMakeTranslation(0,0);
    [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondScale,SecondMove) atTime:kCMTimeZero];
    
    
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(1280, 720);
    
    
    /*
     AVAssetTrack * track;
     CMTime durationAudio;
     CMTime durationVideo;
     
     for (int i = 0; i < count; i++) {
     if (count <= audioTracks.count) {
     
     
     
     
     track = (AVAssetTrack *)audioTracks[i];
     durationAudio = track.timeRange.duration;
     [mutableCompAudioTracks[i] insertTimeRange:CMTimeRangeMake(kCMTimeZero, durationAudio) ofTrack:track atTime:kCMTimeZero error:nil];
     }
     if (count <= videoTracks.count) {
     
     
     
     track = (AVAssetTrack *)videoTracks[i];
     durationVideo = track.timeRange.duration;
     [mutableCompVideoTracks[i] insertTimeRange:CMTimeRangeMake(kCMTimeZero,durationVideo) ofTrack:track atTime:kCMTimeZero error:nil];
     }
     
     
     
     }
     
     */
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    
    
    
    
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    exportSession.outputURL = destinationMovieURL;
    
    NSLog(@"destinationMovieURL:%@",destinationMovieURL);
    
    
    
    
    CMTime start = kCMTimeZero;
    CMTime tduration = mixComposition.duration;
    CMTimeRange range = CMTimeRangeMake(start, tduration);
    
    
    
    
    [exportSession setVideoComposition:MainCompositionInst];
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error]debugDescription]);
            }
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Export canceled");
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                NSLog(@"Export complete!");
                
            }
            default:
            {
                NSLog(@"default");
            }
        }
    }];
    return(destinationMovieURL);
    
}



NSURL * creatConcatMovieFromAudioTracksAndVideoTracks(NSArray * audioTracks,NSArray * videoTracks,NSURL*destinationMovieURL)
{
    
    
    
    
    
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack * mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack * mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    
    
    
    
    
    
    
    int count;
    
    if (audioTracks.count >= videoTracks.count) {
        count = (int)audioTracks.count;
    } else {
        count = (int)videoTracks.count;
    }
    
    
    
    
    CMTime currentCMTimeAudio = kCMTimeZero;
    CMTime currentCMTimeVideo = kCMTimeZero;
    
    AVAssetTrack * track;
    CMTime durationAudio;
    CMTime durationVideo;
    
    
    NSLog(@"audio tracks count:%lu",(unsigned long)audioTracks.count);
    NSLog(@"video tracks count:%lu",(unsigned long)videoTracks.count);
    
    
    
    for (int i = 0; i < count; i++) {
        if (count <= audioTracks.count) {
            
            NSLog(@"audio tracks:%d",i);
            
            track = (AVAssetTrack *)audioTracks[i];
            durationAudio = track.timeRange.duration;
            [mutableCompAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, durationAudio) ofTrack:track atTime:currentCMTimeAudio error:nil];
            currentCMTimeAudio = CMTimeAdd(currentCMTimeAudio, durationAudio);
        }
        if (count <= videoTracks.count) {
            
            NSLog(@"video tracks:%d",i);
            
            track = (AVAssetTrack *)videoTracks[i];
            durationVideo = track.timeRange.duration;
            [mutableCompVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,durationVideo) ofTrack:track atTime:currentCMTimeVideo error:nil];
            currentCMTimeVideo = CMTimeAdd(currentCMTimeVideo, durationVideo);
        }
        
        
        
    }
    
    
    return(creatMovieFromAVMutableCompositionPassThrough(mixComposition, destinationMovieURL));
    
    
}




NSURL * creatMergeAudioOnlyMovieFromTracks(NSArray * audioTracks,NSURL*destinationMovieURL)
{
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    int count = (int)audioTracks.count;
    
    
    
    AVAssetTrack * track;
    CMTime durationAudio;
    
    for (int i = 0; i < count; i++) {
        
        track = (AVAssetTrack *)audioTracks[i];
        durationAudio = track.timeRange.duration;
        [mutableCompAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, durationAudio) ofTrack:track atTime:kCMTimeZero error:nil];
        
    }
    
    return(creatMovieFromAVMutableCompositionPassThrough(mixComposition,destinationMovieURL));
    
}




NSURL * creatConcatAudioOnlyMovieFromTracks(NSArray * audioTracks,NSURL*destinationMovieURL)
{
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    int count = (int)audioTracks.count;
    
    
    
    CMTime currentCMTime = kCMTimeZero;
    
    AVAssetTrack * track;
    CMTime durationAudio;
    
    for (int i = 0; i < count; i++) {
        
        track = (AVAssetTrack *)audioTracks[i];
        durationAudio = track.timeRange.duration;
        [mutableCompAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, durationAudio) ofTrack:track atTime:currentCMTime error:nil];
        currentCMTime = CMTimeAdd(currentCMTime, durationAudio);
        
    }
    
    return(creatMovieFromAVMutableCompositionPassThrough(mixComposition,destinationMovieURL));
    
}







NSURL * creatConcatVideoOnlyMovieFromTracks(NSArray * videoTracks,NSURL*destinationMovieURL)
{
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    int count = (int)videoTracks.count;
    
    
    
    CMTime currentCMTime = kCMTimeZero;
    
    AVAssetTrack * track;
    CMTime durationVideo;
    
    for (int i = 0; i < count; i++) {
        
        
        track = (AVAssetTrack *)videoTracks[i];
        durationVideo = track.timeRange.duration;
        [mutableCompVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,durationVideo) ofTrack:track atTime:currentCMTime error:nil];
        currentCMTime = CMTimeAdd(currentCMTime, durationVideo);
        
    }
    
    return(creatMovieFromAVMutableCompositionPassThrough(mixComposition,destinationMovieURL));
    
}





NSURL * creatMovieFromAudioOnlyFileAndVideoOnlyFile(NSURL*audioOnlyFileURL,NSURL*videoOnlyFileURL,NSURL*destinationMovieURL)
{
    NSArray * audioTracks = [selectAllAudioTracksFromMovieURL(audioOnlyFileURL) valueForKey:@"tracks"];
    NSArray * videoTracks = [selectAllVideoTracksFromMovieURL(videoOnlyFileURL) valueForKey:@"tracks"];
    return(creatMergeMovieFromAudioTracksAndVideoTracks(audioTracks,videoTracks,destinationMovieURL));
    
}



NSURL * concatMoviesFromSourcesAssets(NSMutableArray*sourceAssets,NSURL*destinationMovieURL)
{
    
    NSLog(@"source assets count:%lu",(unsigned long)sourceAssets.count);
    
    
    
    //// -------this has already been tested
    NSMutableArray * audioTracks = [[NSMutableArray alloc] init];
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    
    for (int i =0; i<sourceAssets.count; i++) {
        
        
        NSArray * tempAudioTracks = selectAllAudioTracksFromAVAsset(sourceAssets[i]);
        NSArray * tempVideoTracks = selectAllVideoTracksFromAVAsset(sourceAssets[i]);
        
        NSLog(@"tempAudioTracks count:%lu",(unsigned long)tempAudioTracks.count);
        NSLog(@"tempVideoTracks count:%lu",(unsigned long)tempVideoTracks.count);
        
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            NSLog(@"tempAudioTracks[j]:%@",tempAudioTracks[j]);
            [audioTracks addObject:tempAudioTracks[j]];
        }
        
        for (int j =0; j< tempVideoTracks.count; j++) {
            NSLog(@"tempVideoTracks[j]:%@",tempVideoTracks[j]);
            [videoTracks addObject:tempVideoTracks[j]];
        }
    }
    
    NSLog(@"audio tracks count:%lu",(unsigned long)audioTracks.count);
    NSLog(@"video tracks count:%lu",(unsigned long)videoTracks.count);
    
    
    
    return(creatConcatMovieFromAudioTracksAndVideoTracks(audioTracks,videoTracks,destinationMovieURL));
    
}


NSURL * concatMoviesFromSourceURLs(NSArray*sourceMovieURLs,NSURL*destinationMovieURL)
{
    //// -------this has already been tested
    NSMutableArray * audioTracks = [[NSMutableArray alloc] init];
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    
    for (int i =0; i<sourceMovieURLs.count; i++) {
        
        
        NSArray * tempAudioTracks = [selectAllAudioTracksFromMovieURL(sourceMovieURLs[i]) valueForKey:@"tracks"];
        
        NSArray * tempVideoTracks = [selectAllVideoTracksFromMovieURL(sourceMovieURLs[i]) valueForKey:@"tracks"];
        
        
        
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            [audioTracks addObject:tempAudioTracks[j]];
        }
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            [videoTracks addObject:tempVideoTracks[j]];
        }
    }
    
    
    
    
    return(creatConcatMovieFromAudioTracksAndVideoTracks(audioTracks,videoTracks,destinationMovieURL));
}




NSURL * mergeMoviesFromSourceAssets(NSArray*sourceAssets,NSURL*destinationMovieURL)
{
    
    
    NSMutableArray * audioTracks = [[NSMutableArray alloc] init];
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    
    for (int i =0; i<sourceAssets.count; i++) {
        NSArray * tempAudioTracks = selectAllAudioTracksFromAVAsset(sourceAssets[i]);
        NSArray * tempVideoTracks = selectAllVideoTracksFromAVAsset(sourceAssets[i]);
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            [audioTracks addObject:tempAudioTracks[j]];
        }
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            [videoTracks addObject:tempVideoTracks[j]];
        }
    }
    
    return(creatMergeMovieFromAudioTracksAndVideoTracks(audioTracks,videoTracks,destinationMovieURL));
    
}




NSURL * mergeMoviesFromSourceURLs(NSArray*sourceMovieURLs,NSURL*destinationMovieURL)
{
    
    
    NSMutableArray * audioTracks = [[NSMutableArray alloc] init];
    NSMutableArray * videoTracks = [[NSMutableArray alloc] init];
    
    for (int i =0; i<sourceMovieURLs.count; i++) {
        NSArray * tempAudioTracks = [selectAllAudioTracksFromMovieURL(sourceMovieURLs[i]) valueForKey:@"tracks"];
        NSArray * tempVideoTracks = [selectAllVideoTracksFromMovieURL(sourceMovieURLs[i]) valueForKey:@"tracks"];
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            [audioTracks addObject:tempAudioTracks[j]];
        }
        
        for (int j =0; j< tempAudioTracks.count; j++) {
            [videoTracks addObject:tempVideoTracks[j]];
        }
    }
    
    return(creatMergeMovieFromAudioTracksAndVideoTracks(audioTracks,videoTracks,destinationMovieURL));
    
}


CMTime getCMTimeFromInfoFile(NSString*key,NSString*sourceInfoPath)
{
    NSError * error;
    NSString * info = [[NSString alloc] initWithContentsOfFile:sourceInfoPath encoding:NSUTF8StringEncoding error:&error];
    
    
    NSString * pattern = key;
    pattern = [pattern stringByAppendingString:@"[ ]+=[ ]+\\\"CMTime:[ ]+\\\{([0-9]+)/([0-9]+)[ ]+="];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray * matches = [regex matchesInString:info
                                       options:0
                                         range:NSMakeRange(0, [info length])];
    
    
    NSTextCheckingResult *match = matches[0];
    NSString * valueStr = [info substringWithRange: [match rangeAtIndex:1]];
    NSString * timescaleStr = [info substringWithRange: [match rangeAtIndex:2]];
    NSInteger value = [valueStr integerValue];
    NSInteger timescale = [timescaleStr integerValue];
    
    CMTime timeStamp = CMTimeMake(value, (int)timescale);
    return(timeStamp);
}



void printVTCompressionSessionPropertyValue(VTCompressionSessionRef compressionSession, CFStringRef propertyKey)
{
    NSLog(@"key:%@",(__bridge NSString *)propertyKey);
    CFTypeRef propertyValueOut =NULL;
    OSStatus status = VTSessionCopyProperty(compressionSession, propertyKey, NULL, &propertyValueOut);
    if(status != noErr)
    {
        NSLog(@"error:%d",(int)status);
    } else {
        NSLog(@"value:%@",(__bridge NSString *)propertyValueOut);
    }
    CFRelease(propertyValueOut);
}


void printVTCompressionSessionSupportedProperties(VTCompressionSessionRef compressionSession)
{
    CFDictionaryRef supportedPropertyDictionaryOut = NULL;
    OSStatus status = VTSessionCopySupportedPropertyDictionary(compressionSession, &supportedPropertyDictionaryOut);
    if(status != noErr)
    {
        NSLog(@"error:%d",(int)status);
    } else {
        NSMutableDictionary * nsDict = [[NSMutableDictionary alloc] init];
        nsDict = (__bridge NSMutableDictionary *)supportedPropertyDictionaryOut;
        NSLog(@"supportedProperties:%@",nsDict);
    }
    CFRelease(supportedPropertyDictionaryOut);
}


void VTSessionSetCleanApertureFromValues(VTCompressionSessionRef compressionSession,int cleanApertureWidth,int cleanApertureHeight,int cleanApertureHorizontalOffset,int cleanApertureVerticalOffset)
{
    
    CFDictionaryRef CFCleanAperture =NULL;
    
    CFNumberRef CFCleanApertureWidth = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(cleanApertureWidth)));
    CFNumberRef CFCleanApertureHeight = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(cleanApertureHeight)));
    CFNumberRef CFCleanApertureHorizontalOffset = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(cleanApertureHorizontalOffset)));
    CFNumberRef CFCleanApertureVerticalOffset = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, (const void*)(&(cleanApertureVerticalOffset)));
    
    const void *cleanApertureDictKeys[] = {
        kCMFormatDescriptionKey_CleanApertureWidth,
        kCMFormatDescriptionKey_CleanApertureHeight,
        kCMFormatDescriptionKey_CleanApertureHorizontalOffset,
        kCMFormatDescriptionKey_CleanApertureVerticalOffset
    };
    
    const void *cleanApertureDictValues[] = {
        CFCleanApertureWidth,
        CFCleanApertureHeight,
        CFCleanApertureHorizontalOffset,
        CFCleanApertureVerticalOffset
        
    };
    CFCleanAperture = CFDictionaryCreate(kCFAllocatorDefault, cleanApertureDictKeys, cleanApertureDictValues, 4, nil, nil);
    
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_CleanAperture,CFCleanAperture);
    
    CFRelease(CFCleanApertureWidth);
    CFRelease(CFCleanApertureHeight);
    CFRelease(CFCleanApertureHorizontalOffset);
    CFRelease(CFCleanApertureVerticalOffset);
    CFRelease(CFCleanAperture);
}


void VTSessionSetCleanApertureFromCFDict(VTCompressionSessionRef compressionSession,CFDictionaryRef CFCleanAperture)
{
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_CleanAperture,CFCleanAperture);
}

void VTSessionSetCleanApertureFromNSDict(VTCompressionSessionRef compressionSession,NSDictionary * NSCleanAperture)
{
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_CleanAperture,(__bridge CFDictionaryRef)NSCleanAperture);
}


int usingWhichP(CMTime n, CMTime p1,int k1,CMTime d1,CMTime p2,CMTime d2,int k2)
{
    
    /*
     
     
     ---p1------------(p1+d1)-----p2----(p2+d2)---
         n<p1:       k1-1
     p1=<n<=p1+d1:   k1
     p1+d1<n<=p2+d2: k2
         n>p2+d2:    k2+1
     */
    
    CMTime sum1 = CMTimeAdd(p1, d1);
    CMTime sum2 = CMTimeAdd(p2, d2);

    if (CMTimeDurationLT(n, p1)) {
        return(k1-1);
    } else if (CMTimeDurationGT(n, sum2)) {
        return(k2+1);
    } else {
        if (CMTimeDurationLE(n, sum1)) {
            return(k1);
        } else {
            return(k2);
        }
    }
    
}


int selectNearestFromCMTimeArray(CMTime n,NSMutableArray * presentations,NSMutableArray * durations)
{

    int count = (int)presentations.count;
    
    for (int i = 0; i< count; i++) {
        CMTime p1 = [presentations[i] CMTimeValue];
        CMTime d1 = [durations[i] CMTimeValue];
        CMTime sum1 = CMTimeAdd(p1, d1);
        if (CMTimeDurationLT(n, p1)) {
            return(i-1);
        } else if(CMTimeDurationLE(n, sum1)) {
            return(i);
        } else  {
            
        }
    }
    
    CMTime p = [presentations[count -1] CMTimeValue];
    CMTime d = [durations[count -1] CMTimeValue];
    CMTime sum = CMTimeAdd(p, d);
    
    if (CMTimeDurationGT(n, sum)) {
        return(count);
    } else {
        return(count - 1);
    }
    
}

@end