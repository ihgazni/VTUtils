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



void printKCMVideoCodecType(CMVideoCodecType cond)
{
    
    
    
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
     kCMVideoCodecType_AppleProRes4444  = 'ap4h',
     kCMVideoCodecType_AppleProRes422HQ = 'apch',
     kCMVideoCodecType_AppleProRes422   = 'apcn',
     kCMVideoCodecType_AppleProRes422LT = 'apcs',
     kCMVideoCodecType_AppleProRes422Proxy = 'apco',
     
     };
     typedef FourCharCode CMVideoCodecType;
     */
    




  
    

    

    
    
    
    
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
    
    if (cond == kCMVideoCodecType_AppleProRes4444) {
        
        NSLog(@"kCMVideoCodecType_AppleProRes4444  = 'ap4h'");
    }
    if (cond == kCMVideoCodecType_AppleProRes422HQ) {
        
        NSLog(@"kCMVideoCodecType_AppleProRes422HQ  = 'apch'");
    }
    if (cond == kCMVideoCodecType_AppleProRes422) {
        
        NSLog(@"kCMVideoCodecType_AppleProRes422  = 'apcn'");
    }
    if (cond == kCMVideoCodecType_AppleProRes4444) {
        
        NSLog(@"kCMVideoCodecType_AppleProRes422LT  = 'apcs'");
    }
    if (cond == kCMVideoCodecType_AppleProRes422Proxy) {
        
        NSLog(@"kCMVideoCodecType_AppleProRes422Proxy  = 'apco'");
    }



    
}



NSString * kCMVideoCodecTypeToString(CMVideoCodecType cond)
{
    
    

    
    if (cond == 846624121) {
        
        return(@"2vuy");
    }
    if (cond == 1919706400) {
        
        return(@"rle");
    }
    if (cond == 1668704612) {
        
        return(@"cvid");
    }
    if (cond == 1785750887) {
        
        return(@"jpeg");
    }
    if (cond == 1684890161 ) {
        
        return(@"dmb1");
    }
    if (cond == 1398165809) {
        
        return(@"SVQ1");
    }
    if (cond == 1398165811 ) {
        
        return(@"SVQ3");
    }
    if (cond == 1748121139) {
        
        return(@"h263");
    }
    if (cond == 1635148593) {
        
        return(@"avc1");
    }
    if (cond == 1836070006) {
        
        return(@"mp4v");
    }
    if (cond == 1836069494) {
        
        return(@"mp2v");
    }
    if (cond == 1836069238) {
        
        return(@"mp1v");
    }
    if (cond == 1685480224) {
        
        return(@"dvc");
    }
    if (cond == 1685480304) {
        
        return(@"dvcp");
    }
    if (cond == 1685483632) {
        
        return(@"dvpp");
    }
    if (cond == 1685468526) {
        
        return(@"dv5n");
    }
    if (cond == 1685468528) {
        
        return(@"dv5p");
    }
    if (cond == 1685481584) {
        
        return(@"dvhp");
    }
    if (cond == 1685481585) {
        
        return(@"dvhq");
    }
    if (cond == 1685481526) {
        
        return(@"dvh6");
    }
    if (cond == 1685481525) {
        
        return(@"dvh5");
    }
    if (cond == 1685481523) {
        
        return(@"dvh3");
    }
    if (cond == 1685481522) {
        
        return(@"dvh2");
    }
    
    if (cond == kCMVideoCodecType_AppleProRes4444) {
        
        return(@"ap4h");
    }
    if (cond == kCMVideoCodecType_AppleProRes422HQ) {
        
        return(@"apch");
    }
    if (cond == kCMVideoCodecType_AppleProRes422) {
        
        return(@"apcn");
    }
    if (cond == kCMVideoCodecType_AppleProRes4444) {
        
        return(@"apcs");
    }
    if (cond == kCMVideoCodecType_AppleProRes422Proxy) {
        
        return(@"apco");
    }
    
    
    return(@"");
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




BOOL isH264IFrame(CMSampleBufferRef sampleBuffer,int which)
{
    // Find out if the sample buffer contains an I-Frame.
    // If so we will write the SPS and PPS NAL units to the elementary stream.
    BOOL isIFrame = NO;
    CFArrayRef attachmentsArray = getAndPrintAllSampleAttachments(sampleBuffer,YES);
    
    
    if (CFArrayGetCount(attachmentsArray)) {
        CFBooleanRef notSync;
        CFDictionaryRef dict = CFArrayGetValueAtIndex(attachmentsArray, which);
        BOOL keyExists = CFDictionaryGetValueIfPresent(dict,
                                                       kCMSampleAttachmentKey_NotSync,
                                                       (const void **)&notSync);
        // An I-Frame is a sync frame
        isIFrame = !keyExists || !CFBooleanGetValue(notSync);
    }
    
    
    attachmentsArray = NULL;
    
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
            
            NSLog(@"    videoWriter.error:%@",videoWriter.error);
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




NSMutableArray * sortCMTArrayViaCMTDuration (NSMutableArray * CMTs)
{
    NSMutableArray *  resortedCMTs = [[NSMutableArray alloc] init];
    resortedCMTs = [CMTs mutableCopy];
    [resortedCMTs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        CMTime o1 = [obj1 CMTimeValue];
        CMTime o2 = [obj2 CMTimeValue];
        CMTime  pt1 = o1;
        CMTime  pt2 = o2;
        return( CMTimeCompare(pt1, pt2) );
    }];
    return(resortedCMTs);
}

CMTime getMaxCMTDurationCMTFromArray(NSMutableArray * CMTs)
{
    NSMutableArray * sorted = sortCMTArrayViaCMTDuration (CMTs);
    
    return([sorted[sorted.count -1] CMTimeValue]);
    
}
CMTime getMinCMTDurationCMTFromArray(NSMutableArray * CMTs)
{
    NSMutableArray * sorted = sortCMTArrayViaCMTDuration (CMTs);
    
    return([sorted[0] CMTimeValue]);
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
    free(pInfo);
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

NSMutableArray * selectAllVideoTracksFromAVAssetNoCopyItem(AVAsset* asset)
{
    ////---tested
    NSMutableArray * videoTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeVideo] copyItems:NO];
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



NSMutableArray * splitVideoCMTimeViaAverageIntervalFromAVAsset(AVAsset * asset,int whichTrack,float intervalSeconds)
{
    NSMutableArray * videoTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeVideo] copyItems:YES];
    AVAssetTrack *videoTrack = [videoTracks objectAtIndex:whichTrack];
    CMTime start = videoTrack.timeRange.start;
    CMTime duration = videoTrack.timeRange.duration;
    NSMutableArray * cmtrs = [[NSMutableArray alloc] init];
    int si = (int)start.value;
    int dv = (int)duration.value;
    int iv = (int)(intervalSeconds * duration.timescale);
    int cursor = 0;
    while (cursor < dv) {
        CMTime s = CMTimeMake((si+cursor), duration.timescale);
        CMTime d = kCMTimeZero;
        if ((cursor + iv) <= dv) {
            d = CMTimeMake(iv, duration.timescale);
            CMTimeRange r = CMTimeRangeMake(s, d);
            [cmtrs addObject:[NSValue valueWithCMTimeRange:r]];
            cursor = cursor+iv;
        } else {
            d = CMTimeMake((dv - cursor), duration.timescale);
            CMTimeRange r = CMTimeRangeMake(s, d);
            [cmtrs addObject:[NSValue valueWithCMTimeRange:r]];
            cursor = dv;
        }
    }
    return(cmtrs);
  
}


NSMutableArray * splitVideoCMTimeViaAverageIntervalFromMovieURL(NSURL*sourceMovieURL,int whichTrack,float intervalSeconds)
{
    AVAsset *asset = [AVAsset assetWithURL:sourceMovieURL];
    return(splitVideoCMTimeViaAverageIntervalFromAVAsset(asset, whichTrack, intervalSeconds));
}



NSMutableArray * splitVideoToAssetsAndPTsViaAverageIntervalFromAVAsset(AVAsset * asset,int whichTrack,float intervalSeconds)
{
    NSMutableArray * videoTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeVideo] copyItems:YES];
    AVAssetTrack *videoTrack = [videoTracks objectAtIndex:whichTrack];
    CMTime start = videoTrack.timeRange.start;
    CMTime duration = videoTrack.timeRange.duration;
    NSMutableArray * cmtrs = [[NSMutableArray alloc] init];
    int si = (int)start.value;
    int dv = (int)duration.value;
    int iv = (int)(intervalSeconds * duration.timescale);
    int cursor = 0;
    while (cursor < dv) {
        CMTime s = CMTimeMake((si+cursor), duration.timescale);
        CMTime d = kCMTimeZero;
        if ((cursor + iv) <= dv) {
            d = CMTimeMake(iv, duration.timescale);
            CMTimeRange r = CMTimeRangeMake(s, d);
            [cmtrs addObject:[NSValue valueWithCMTimeRange:r]];
            cursor = cursor+iv;
        } else {
            d = CMTimeMake((dv - cursor), duration.timescale);
            CMTimeRange r = CMTimeRangeMake(s, d);
            [cmtrs addObject:[NSValue valueWithCMTimeRange:r]];
            cursor = dv;
        }
    }
    
    
    

    NSMutableArray * assetAndPTs = [[NSMutableArray alloc] init];
    
    for (int i =0; i < cmtrs.count; i++) {
        CMTimeRange r = [cmtrs[i] CMTimeRangeValue];
        
        
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compTrack insertTimeRange:r ofTrack:videoTrack atTime:kCMTimeZero error:nil];
        
        
        
        
        
        
        [compTrack removeTimeRange:kCMTimeRangeInvalid];
        
        
        
       
        
        
        
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setValue:mixComposition forKey:@"asset"];
        [dict setValue:[NSValue valueWithCGAffineTransform:videoTrack.preferredTransform]  forKey:@"preferredTransform"];
        [assetAndPTs addObject:dict];
    }
    
    return(assetAndPTs);
    
}
NSMutableArray * splitVideoToAssetsAndPTsViaAverageIntervalFromMovieURL(NSURL*sourceMovieURL,int whichTrack,float intervalSeconds)
{
    AVAsset *asset = [AVAsset assetWithURL:sourceMovieURL];
    return(splitVideoToAssetsAndPTsViaAverageIntervalFromAVAsset(asset,whichTrack,intervalSeconds));
}



NSMutableArray * splitVideoToVideosViaAverageIntervalFromAVAsset(AVAsset * asset,int whichTrack,float intervalSeconds,NSString * destinationRelativeDir)
{
    NSMutableArray * videoTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeVideo] copyItems:YES];
    AVAssetTrack *videoTrack = [videoTracks objectAtIndex:whichTrack];
    CMTime start = videoTrack.timeRange.start;
    CMTime duration = videoTrack.timeRange.duration;
    NSMutableArray * cmtrs = [[NSMutableArray alloc] init];
    int si = (int)start.value;
    int dv = (int)duration.value;
    int iv = (int)(intervalSeconds * duration.timescale);
    int cursor = 0;
    while (cursor < dv) {
        CMTime s = CMTimeMake((si+cursor), duration.timescale);
        CMTime d = kCMTimeZero;
        if ((cursor + iv) <= dv) {
            d = CMTimeMake(iv, duration.timescale);
            CMTimeRange r = CMTimeRangeMake(s, d);
            [cmtrs addObject:[NSValue valueWithCMTimeRange:r]];
            cursor = cursor+iv;
        } else {
            d = CMTimeMake((dv - cursor), duration.timescale);
            CMTimeRange r = CMTimeRangeMake(s, d);
            [cmtrs addObject:[NSValue valueWithCMTimeRange:r]];
            cursor = dv;
        }
    }
    
    [FileUitl deleteSubDirOfTmp:destinationRelativeDir];
    [FileUitl creatSubDirOfTmp:destinationRelativeDir];
    
    NSMutableArray * destURLs = [[NSMutableArray alloc] init];
    
    for (int i =0; i<cmtrs.count; i++) {
        NSString * seq = [NSString stringWithFormat:@"%@/split_%d.mov",destinationRelativeDir,i];
        NSString * tempPath = [FileUitl getFullPathOfTmp:seq];
        [FileUitl deleteTmpFile:tempPath];
        NSURL * destinationMovieURL = [NSURL fileURLWithPath:tempPath];
        [destURLs addObject:destinationMovieURL];
    }
    
    
    
    for (int i =0; i < cmtrs.count; i++) {
        
        NSURL * destinationURL = destURLs[i];
        
        CMTimeRange r = [cmtrs[i] CMTimeRangeValue];
        
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compTrack insertTimeRange:r ofTrack:videoTrack atTime:kCMTimeZero error:nil];
        
        AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, r.duration);
        AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
        
        CGAffineTransform t2 = [videoTrack preferredTransform];
        //// if use back camera  , rotate degree is clock wise when using settransform
        //// if use front camera , rotate degree is clock wise when using settransform

        
        
        float width;
        float height;
        
        if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
            width = videoTrack.naturalSize.height;
            height = videoTrack.naturalSize.width;
        } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
            width = videoTrack.naturalSize.height;
            height = videoTrack.naturalSize.width;
        } else {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        }
        
        CGSize size = CGSizeMake(width, height);
        

        [layerInstruction setTransform:t2  atTime:kCMTimeZero];
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
        
        AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
        mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
        mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
        mainVideoComp.renderSize = size;
        
        
        creatMovieFromAVMutableCompositionWithParameters(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp);
    }
    
    return(destURLs);
    
}

NSMutableArray * splitVideoToVideosAndPTsViaAverageIntervalFromMovieURL(NSURL*sourceMovieURL,int whichTrack,float intervalSeconds,NSString * destinationRelativeDir)
{
    AVAsset *asset = [AVAsset assetWithURL:sourceMovieURL];
    return(splitVideoToVideosViaAverageIntervalFromAVAsset(asset, whichTrack, intervalSeconds, destinationRelativeDir));
}



////this is a synced version just for test
NSMutableArray * splitVideoToVideosViaCMTimeRangeArrayFromAVAsset(AVAsset * asset,int whichTrack,NSMutableArray * cmtrs,NSMutableArray * destURLs)
{
    NSMutableArray * videoTracks = [[NSMutableArray alloc] initWithArray:[asset tracksWithMediaType:AVMediaTypeVideo] copyItems:NO];
    AVAssetTrack *videoTrack = [videoTracks objectAtIndex:whichTrack];
    
    ////排序:
    
    
    [cmtrs sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        CMTimeRange  r1 = [obj1 CMTimeRangeValue];
        CMTimeRange  r2 = [obj2 CMTimeRangeValue];
        
        CMTime pt1 = r1.start;
        CMTime pt2 = r2.start;
        
        int rslt =  CMTimeCompare(pt1, pt2);
    
        if (rslt <= 0) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (rslt > 0) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    
    //// 检查无重叠,如果有  修正
    CMTimeRange r = [cmtrs[0] CMTimeRangeValue];
    CMTime prevs = r.start;
    CMTime preve = CMTimeAdd(r.start,r.duration);
    if (CMTimeCompare(preve, prevs) < 0) {
        preve = prevs;
        cmtrs[0] = [NSValue valueWithCMTimeRange:CMTimeRangeMake(prevs, preve)];
    }
    
    for (int i =1; i < cmtrs.count; i++) {
        r = [cmtrs[i] CMTimeRangeValue];
        CMTime currs = r.start;
        CMTime curre = CMTimeAdd(r.start,r.duration);
        if (CMTimeCompare(curre, currs) < 0) {
            curre = currs;
            cmtrs[i] = [NSValue valueWithCMTimeRange:CMTimeRangeMake(currs, curre)];
        }
        
        if (CMTimeCompare(currs, preve) < 0) {
            preve = currs;
            cmtrs[i - 1] = [NSValue valueWithCMTimeRange:CMTimeRangeMake(prevs, preve)];
        }
        
        prevs = currs;
        preve = curre;
        
    }
    
    
    
    
    
    
    for (int i =0; i < cmtrs.count; i++) {
        
        NSURL * destinationURL = destURLs[i];
        
        CMTimeRange r = [cmtrs[i] CMTimeRangeValue];
        
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *compTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compTrack insertTimeRange:r ofTrack:videoTrack atTime:kCMTimeZero error:nil];
        
        AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, r.duration);
        AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compTrack];
        
        CGAffineTransform t2 = [videoTrack preferredTransform];
        //// if use back camera  , rotate degree is clock wise when using settransform
        //// if use front camera , rotate degree is clock wise when using settransform
        
        
        
        float width;
        float height;
        
        if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
            width = videoTrack.naturalSize.height;
            height = videoTrack.naturalSize.width;
        } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
            width = videoTrack.naturalSize.height;
            height = videoTrack.naturalSize.width;
        } else {
            width = videoTrack.naturalSize.width;
            height = videoTrack.naturalSize.height;
        }
        
        CGSize size = CGSizeMake(width, height);
        
        
        [layerInstruction setTransform:t2  atTime:kCMTimeZero];
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
        
        AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
        mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];
        mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
        mainVideoComp.renderSize = size;
        
        dispatch_semaphore_t sema =  dispatch_semaphore_create(0);
        //// this is a synced version just for test
        creatMovieFromAVMutableCompositionWithParametersSema(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp,sema,NO);
    
        while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) {
            ////如果semaConReturn是0 返回非0
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        
        ////--dli--
        compTrack = NULL;
        mixComposition = NULL;
        ////--dli--
        
    }
    
    
    return(destURLs);
    
}

NSMutableArray * splitVideoToVideosViaCMTimeRangeArrayFromMovieURL(NSURL * sourceMovieURL,int whichTrack,NSMutableArray * cmtrs,NSMutableArray * destURLs)
{
    AVAsset *asset = [AVAsset assetWithURL:sourceMovieURL];
    return(splitVideoToVideosViaCMTimeRangeArrayFromAVAsset(asset, whichTrack, cmtrs, destURLs));
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




////////////////======

NSURL * ptVideoFromSourceAssetSema(AVAsset*asset,int whichTrack,NSURL*destinationURL,dispatch_semaphore_t sema,BOOL writeToAlbum,CGAffineTransform t2)
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
    
    
    
    
    float width;
    float height;
    
    if (t2.a==0.0 && t2.b==1.0 && t2.c==-1.0 && t2.d == 0.0) {
        width =  videoTrack.naturalSize.height;
        height =  videoTrack.naturalSize.width;
    } else if (t2.a==1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == 1.0) {
        width =  videoTrack.naturalSize.width;
        height =  videoTrack.naturalSize.height;
    } else if (t2.a==-1.0 && t2.b==0.0 && t2.c==0.0 && t2.d == -1.0) {
        width =  videoTrack.naturalSize.width;
        height =  videoTrack.naturalSize.height;
    } else if (t2.a==0.0 && t2.b==-1.0 && t2.c==1.0 && t2.d == 0.0) {
        width = videoTrack.naturalSize.height;
        height =  videoTrack.naturalSize.width;
    } else {
        width =  videoTrack.naturalSize.width;
        height =  videoTrack.naturalSize.height;
    }
    

    
    [layerInstruction setTransform:t2  atTime:kCMTimeZero];
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction,nil];
    
    AVMutableVideoComposition *mainVideoComp = [AVMutableVideoComposition videoComposition];
    mainVideoComp.instructions = [NSArray arrayWithObject:mainInstruction];

    mainVideoComp.frameDuration = CMTimeMake(1, [videoTrack nominalFrameRate]);
    
    mainVideoComp.renderSize =CGSizeMake(width, height);
    
    
    creatMovieFromAVMutableCompositionWithParametersSema(mixComposition, destinationURL, AVAssetExportPresetHighestQuality, mainVideoComp,sema,writeToAlbum);
    
    return(destinationURL);
}





NSURL * ptVideoFromSourceURLSema(NSURL*sourceURL,int whichTrack,NSURL*destinationURL,dispatch_semaphore_t sema,BOOL writeToAlbum,CGAffineTransform t2)
{
    AVAsset * asset = [AVAsset assetWithURL:sourceURL];
    
    return(ptVideoFromSourceAssetSema(asset,whichTrack,destinationURL,sema,writeToAlbum,t2));
    
}




//////////////======






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
        
        ////----to right orientation, if  pt exist
        
        
        
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





NSURL * creatMovieFromAVMutableCompositionPassThroughSema(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,dispatch_semaphore_t sema,BOOL writeToAlbum)
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
                NSLog(@"Export to sand box complete!");
                if (writeToAlbum) {
                    [FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
                }
                dispatch_semaphore_signal(sema);
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



NSURL * creatRangeOfMovieFromAVAssetSema(AVAsset * asset,CMTimeRange range,NSURL*destinationMovieURL,dispatch_semaphore_t sema,BOOL writeToAlbum)
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
                NSLog(@"Export to sand box complete!");
                if (writeToAlbum) {
                    [FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
                }
                dispatch_semaphore_signal(sema);
                
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





NSURL * creatMovieFromAVMutableCompositionWithPresetSema(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName,dispatch_semaphore_t sema,BOOL writeToAlbum)
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
                NSLog(@"Export to sand box complete!");
                if (writeToAlbum) {
                    [FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
                }
                dispatch_semaphore_signal(sema);
                
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



////


NSURL * creatMovieFromAVMutableCompositionWithParameters(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName,AVVideoComposition* videoComposition)
{
    
    ////----this works , already  tested
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:presetName];
    ////AVAssetExportPresetPassthrough
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    exportSession.outputURL = destinationMovieURL;
    exportSession.shouldOptimizeForNetworkUse = YES;
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
                ////[FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
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


////


NSURL * creatMovieFromAVMutableCompositionWithParametersSema(AVMutableComposition*mixComposition,NSURL*destinationMovieURL,NSString*presetName,AVVideoComposition* videoComposition,dispatch_semaphore_t sema, BOOL writeToAlbum)
{
    
    ////----this works , already  tested
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:presetName];
    ////AVAssetExportPresetPassthrough
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    exportSession.outputURL = destinationMovieURL;
    
    ////NSLog(@"destinationMovieURL:%@",destinationMovieURL);
    
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
                NSLog(@"Export to sand box complete!");
                if (writeToAlbum) {
                    [FileUitl writeVideoToPhotoLibrary:destinationMovieURL];
                }
                dispatch_semaphore_signal(sema);
                
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


////





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
        

        CMTime substract = CMTimeSubtract(mergedVideoDuration, originalTrack.timeRange.duration);
        substract = CMTimeConvertScale(substract,mergedVideoDuration.timescale,kCMTimeRoundingMethod_QuickTime);
        [compositionTrack insertEmptyTimeRange:CMTimeRangeMake(originalTrack.timeRange.duration, substract)];

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


            
        CMTime substract = CMTimeSubtract(mergedVideoDuration, originalTrack.timeRange.duration);
        substract = CMTimeConvertScale(substract,mergedVideoDuration.timescale,kCMTimeRoundingMethod_QuickTime);
        ////写1.0会覆盖
        [layerInstruction setOpacity:0.5 atTime:kCMTimeZero];
        [layerInstruction setOpacity:0.0 atTime:originalTrack.timeRange.duration];
        [layerInstruction setOpacity:0.5 atTime:kCMTimeZero];

        
        
        [layerInstructions addObject:layerInstruction];
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
    
    NSMutableArray * mutableCompAudioTracks = [[NSMutableArray alloc] init];
    NSMutableArray * mutableCompVideoTracks = [[NSMutableArray alloc] init];
    
    
    
    
    
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
             AVMutableCompositionTrack *track =[mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            AVAssetTrack * at = (AVAssetTrack *)audioTracks[i];
            
            [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, at.timeRange.duration) ofTrack:audioTracks[i] atTime:kCMTimeZero error:nil];
            
            [mutableCompAudioTracks addObject:track];
            
        }
        if (count <= videoTracks.count) {
            AVMutableCompositionTrack *track = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            AVAssetTrack * vt = (AVAssetTrack *)videoTracks[i];
            
            [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, vt.timeRange.duration) ofTrack:videoTracks[i] atTime:kCMTimeZero error:nil];
            
            [mutableCompVideoTracks addObject:track];
            
            
            
            
            
        }
    }
    
    
    
    
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mutableCompVideoTracks[0]];
    CGAffineTransform Scale = CGAffineTransformMakeScale(0.6f,0.6f);
    CGAffineTransform Move = CGAffineTransformMakeTranslation(320,320);
    [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
    
    
    
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mutableCompVideoTracks[1]];
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


////

NSURL * creatConcatMovieFromAudioTracksAndVideoTracksSema(NSArray * audioTracks,NSArray * videoTracks,NSURL*destinationMovieURL,dispatch_semaphore_t sema,BOOL writeToAlbum)
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
    
    
    return(creatMovieFromAVMutableCompositionPassThroughSema(mixComposition, destinationMovieURL, sema, writeToAlbum));
    
    
}


////









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
    ////concat 使用一个mutableCompVideoTrack
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
        
        for (int j =0; j< tempVideoTracks.count; j++) {
            [videoTracks addObject:tempVideoTracks[j]];
        }
    }
    
    
    
    
    return(creatConcatMovieFromAudioTracksAndVideoTracks(audioTracks,videoTracks,destinationMovieURL));
}

////
NSURL * concatMoviesFromSourceURLsSema(NSArray*sourceMovieURLs,NSURL*destinationMovieURL,dispatch_semaphore_t sema,BOOL writeToAlbum)
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
        
        for (int j =0; j< tempVideoTracks.count; j++) {
            [videoTracks addObject:tempVideoTracks[j]];
        }
    }
    
    

    
    
    return(creatConcatMovieFromAudioTracksAndVideoTracksSema(audioTracks, videoTracks, destinationMovieURL, sema, writeToAlbum));
}


////


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


CFNumberRef getVTCompressionPropertyKey_NumberOfPendingFrames(VTCompressionSessionRef compressionSession)
{
    NSLog(@"you need to release");
    CFTypeRef propertyValueOut =NULL;
    OSStatus status = VTSessionCopyProperty(compressionSession, kVTCompressionPropertyKey_NumberOfPendingFrames, NULL, &propertyValueOut);
    if(status != noErr)
    {
        CFNumberRef cfn = (CFNumberRef)propertyValueOut;
        NSLog(@"%d",[(__bridge NSNumber*)cfn intValue]);
        return(cfn);
    } else {
        uint32_t v = -1;
        CFNumberRef cfn = CFNumberCreate(NULL, kCFNumberSInt32Type, &v);
        NSLog(@"%d",[(__bridge NSNumber*)cfn intValue]);
        return(cfn);
    }
 
    
}

CFBooleanRef getVTCompressionPropertyKey_PixelBufferPoolIsShared(VTCompressionSessionRef compressionSession)
{
    CFTypeRef propertyValueOut =NULL;
    OSStatus status = VTSessionCopyProperty(compressionSession, kVTCompressionPropertyKey_PixelBufferPoolIsShared, NULL, &propertyValueOut);
    if(status != noErr)
    {
        CFBooleanRef rslt = (CFBooleanRef)propertyValueOut;
        NSString * log = (rslt == kCFBooleanTrue) ? @"YES" : @"NO";
        NSLog(@"%@",log);
        log = NULL;
        CFRelease(propertyValueOut);
        return(rslt);
    } else {
        CFRelease(propertyValueOut);
        return(NULL);
        
    }
    
    
}

CFDictionaryRef getVTCompressionPropertyKey_VideoEncoderPixelBufferAttributes(VTCompressionSessionRef compressionSession)
{
    NSLog(@"you need to release");
    CFTypeRef propertyValueOut =NULL;
    OSStatus status = VTSessionCopyProperty(compressionSession, kVTCompressionPropertyKey_VideoEncoderPixelBufferAttributes, NULL, &propertyValueOut);
    if(status != noErr)
    {
        CFDictionaryRef cfd = (CFDictionaryRef)propertyValueOut;
        NSLog(@"%@",(__bridge NSDictionary *)cfd);
        return(cfd);
    } else {
        return(NULL);
    }
    
    
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


void printKCVPixelFormatType(OSType n)
{
    unsigned int cond = (unsigned int)n;

    if (cond == (unsigned int)kCVPixelFormatType_1Monochrome) {
        NSLog(@"kCVPixelFormatType_1Monochrome    = 0x00000001");
    }
    if (cond == (unsigned int)kCVPixelFormatType_2Indexed) {
        NSLog(@"kCVPixelFormatType_2Indexed       = 0x00000002");
    }
    if (cond == (unsigned int)kCVPixelFormatType_4Indexed) {
        NSLog(@"kCVPixelFormatType_4Indexed       = 0x00000004");
    }
    if (cond == (unsigned int)kCVPixelFormatType_8Indexed) {
        NSLog(@"kCVPixelFormatType_8Indexed       = 0x00000008");
    }
    if (cond == (unsigned int)kCVPixelFormatType_1IndexedGray_WhiteIsZero) {
        NSLog(@"kCVPixelFormatType_1IndexedGray_WhiteIsZero = 0x00000021");
    }
    if (cond == (unsigned int)kCVPixelFormatType_2IndexedGray_WhiteIsZero) {
        NSLog(@"kCVPixelFormatType_2IndexedGray_WhiteIsZero = 0x00000022");
    }
    if (cond == (unsigned int)kCVPixelFormatType_4IndexedGray_WhiteIsZero) {
        NSLog(@"kCVPixelFormatType_4IndexedGray_WhiteIsZero = 0x00000024");
    }
    if (cond == (unsigned int)kCVPixelFormatType_8IndexedGray_WhiteIsZero) {
        NSLog(@"kCVPixelFormatType_8IndexedGray_WhiteIsZero = 0x00000028");
    }
    if (cond == (unsigned int)kCVPixelFormatType_16BE555) {
        NSLog(@"kCVPixelFormatType_16BE555        = 0x00000010");
    }
    if (cond == (unsigned int)kCVPixelFormatType_16LE555) {
        NSLog(@"kCVPixelFormatType_16LE555        = 'L555'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_16LE5551) {
        NSLog(@"kCVPixelFormatType_16LE5551       = '5551'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_16BE565) {
        NSLog(@"kCVPixelFormatType_16BE565        = 'B565'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_16LE565) {
        NSLog(@"kCVPixelFormatType_16LE565        = 'L565'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_24RGB) {
        NSLog(@"kCVPixelFormatType_24RGB          = 0x00000018");
    }
    if (cond == (unsigned int)kCVPixelFormatType_24BGR) {
        NSLog(@"kCVPixelFormatType_24BGR          = '24BG'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_32ARGB) {
        NSLog(@"kCVPixelFormatType_32ARGB         = 0x00000020");
    }
    if (cond == (unsigned int)kCVPixelFormatType_32BGRA) {
        NSLog(@"kCVPixelFormatType_32BGRA         = 'BGRA'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_32ABGR) {
        NSLog(@"kCVPixelFormatType_32ABGR         = 'ABGR'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_32RGBA) {
        NSLog(@"kCVPixelFormatType_32RGBA         = 'RGBA'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_64ARGB) {
        NSLog(@"kCVPixelFormatType_64ARGB         = 'b64a'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_48RGB) {
        NSLog(@"kCVPixelFormatType_48RGB          = 'b48r'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_32AlphaGray) {
        NSLog(@"kCVPixelFormatType_32AlphaGray    = 'b32a'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_16Gray) {
        NSLog(@"kCVPixelFormatType_16Gray         = 'b16g'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_30RGB) {
        NSLog(@"kCVPixelFormatType_30RGB          = 'R10k'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_422YpCbCr8) {
        NSLog(@"kCVPixelFormatType_422YpCbCr8     = '2vuy'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_4444YpCbCrA8) {
        NSLog(@"kCVPixelFormatType_4444YpCbCrA8   = 'v408'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_4444YpCbCrA8R) {
        NSLog(@"kCVPixelFormatType_4444YpCbCrA8R  = 'r408'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_4444AYpCbCr8) {
        NSLog(@"kCVPixelFormatType_4444AYpCbCr8   = 'y408'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_4444AYpCbCr16) {
        NSLog(@"kCVPixelFormatType_4444AYpCbCr16  = 'y416'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_444YpCbCr8) {
        NSLog(@"kCVPixelFormatType_444YpCbCr8     = 'v308'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_422YpCbCr16) {
        NSLog(@"kCVPixelFormatType_422YpCbCr16    = 'v216'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_422YpCbCr10) {
        NSLog(@"kCVPixelFormatType_422YpCbCr10    = 'v210'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_444YpCbCr10) {
        NSLog(@"kCVPixelFormatType_444YpCbCr10    = 'v410'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_420YpCbCr8Planar) {
        NSLog(@"kCVPixelFormatType_420YpCbCr8Planar = 'y420'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_420YpCbCr8PlanarFullRange) {
        NSLog(@"kCVPixelFormatType_420YpCbCr8PlanarFullRange    = 'f420'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_422YpCbCr_4A_8BiPlanar) {
        NSLog(@"kCVPixelFormatType_422YpCbCr_4A_8BiPlanar = 'a2vy'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange = '420v'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarFullRange  = '420f'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_422YpCbCr8_yuvs) {
        NSLog(@"kCVPixelFormatType_422YpCbCr8_yuvs = 'yuvs'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_422YpCbCr8FullRange) {
        NSLog(@"kCVPixelFormatType_422YpCbCr8FullRange = 'yuvf'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_OneComponent8) {
        NSLog(@"kCVPixelFormatType_OneComponent8  = 'L008'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_TwoComponent8) {
        NSLog(@"kCVPixelFormatType_TwoComponent8  = '2C08'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_OneComponent16Half) {
        NSLog(@"kCVPixelFormatType_OneComponent16Half  = 'L00h'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_OneComponent32Float) {
        NSLog(@"kCVPixelFormatType_OneComponent32Float = 'L00f'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_TwoComponent16Half) {
        NSLog(@"kCVPixelFormatType_TwoComponent16Half  = '2C0h'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_TwoComponent32Float) {
        NSLog(@"kCVPixelFormatType_TwoComponent32Float = '2C0f'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_64RGBAHalf) {
        NSLog(@"kCVPixelFormatType_64RGBAHalf          = 'RGhA'");
    }
    if (cond == (unsigned int)kCVPixelFormatType_128RGBAFloat) {
        NSLog(@"kCVPixelFormatType_128RGBAFloat        = 'RGfA'");
    }
}



void printVTError(OSStatus status)
{
    if (status == kVTPropertyNotSupportedErr) {
        NSLog(@"kVTPropertyNotSupportedErr:-12900");
    }
    if (status == kVTPropertyReadOnlyErr) {
        NSLog(@"kVTPropertyReadOnlyErr:-12901");
    }
    if (status == kVTParameterErr) {
        NSLog(@"kVTParameterErr:-12902");
    }
    if (status == kVTInvalidSessionErr) {
        NSLog(@"kVTInvalidSessionErr:-12903");
    }
    if (status == kVTAllocationFailedErr) {
        NSLog(@"kVTAllocationFailedErr:-12904");
    }
    if (status == kVTPixelTransferNotSupportedErr) {
        NSLog(@"kVTPixelTransferNotSupportedErr:-12905:c.f. -8961");
    }
    if (status == kVTCouldNotFindVideoDecoderErr) {
        NSLog(@"kVTCouldNotFindVideoDecoderErr:-12906");
    }
    if (status == kVTCouldNotCreateInstanceErr) {
        NSLog(@"kVTCouldNotCreateInstanceErr:-12907");
    }
    if (status == kVTCouldNotFindVideoEncoderErr) {
        NSLog(@"kVTCouldNotFindVideoEncoderErr:-12908");
    }
    if (status == kVTVideoDecoderBadDataErr) {
        NSLog(@"kVTVideoDecoderBadDataErr:-12909:c.f. -8969");
    }
    if (status == kVTVideoDecoderUnsupportedDataFormatErr) {
        NSLog(@"kVTVideoDecoderUnsupportedDataFormatErr:-12910:c.f. -8970");
    }
    if (status == kVTVideoDecoderMalfunctionErr) {
        NSLog(@"kVTVideoDecoderMalfunctionErr:-12911:c.f. -8960");
    }
    if (status == kVTVideoEncoderMalfunctionErr) {
        NSLog(@"kVTVideoEncoderMalfunctionErr:-12912:");
    }
    if (status == kVTVideoDecoderNotAvailableNowErr) {
        NSLog(@"kVTVideoDecoderNotAvailableNowErr:-12913:");
    }
    if (status == kVTImageRotationNotSupportedErr) {
        NSLog(@"kVTImageRotationNotSupportedErr:-12914");
    }
    if (status == kVTVideoEncoderNotAvailableNowErr) {
        NSLog(@"kVTVideoEncoderNotAvailableNowErr:-12915");
    }
    if (status == kVTFormatDescriptionChangeNotSupportedErr) {
        NSLog(@"kVTFormatDescriptionChangeNotSupportedErr:-12916");
    }
    if (status == kVTInsufficientSourceColorDataErr) {
        NSLog(@"kVTInsufficientSourceColorDataErr:-12917");
    }
    
    /*
    if (status == -12572 ) {
        NSLog(@"imageBuffer有问题,使用0_0_0_255_alpha_premul的纯黑图片开头压缩视频时:-12572");
    }
    if (status == ) {
        NSLog(@":");
    }
    if (status == ) {
        NSLog(@":");
    }
     if (status == ) {
     NSLog(@":");
     }
     if (status == ) {
     NSLog(@":");
     }
     if (status == ) {
     NSLog(@":");
     }
     if (status == ) {
     NSLog(@":");
     }
     if (status == ) {
     NSLog(@":");
     }
     if (status == ) {
     NSLog(@":");
     }
     if (status == ) {
     NSLog(@":");
     }
     */
    if (status == -12633) {
        NSLog(@"InvalidTimestamp:-12633");
    }
    
    /*
     kVTCouldNotCreateColorCorrectionDataErr	= -12918,
     kVTColorSyncTransformConvertFailedErr	= -12919,
     kVTVideoDecoderAuthorizationErr			= -12210,
     kVTVideoEncoderAuthorizationErr			= -12211,
     kVTColorCorrectionPixelTransferFailedErr	= -12212,
     kVTMultiPassStorageIdentifierMismatchErr	= -12213,
     kVTMultiPassStorageInvalidErr			= -12214,
     kVTFrameSiloInvalidTimeStampErr			= -12215,
     kVTFrameSiloInvalidTimeRangeErr			= -12216,
     kVTCouldNotFindTemporalFilterErr		= -12217,
     kVTPixelTransferNotPermittedErr			= -12218,
     */
    
    
}


int printVTEncoderList(CFDictionaryRef options)
{
    
    CFArrayRef listOfVideoEncodersOut = NULL;
    VTCopyVideoEncoderList(options,&listOfVideoEncodersOut);
    NSLog(@"listOfVideoEncodersOut:%@  options:%@",listOfVideoEncodersOut,options);
    
    int length = (int)CFArrayGetCount(listOfVideoEncodersOut);
    CFRelease(listOfVideoEncodersOut);
    /*
     kCMPixelFormat_422YpCbCr8               = '2vuy',
     kCMVideoCodecType_422YpCbCr8       = kCMPixelFormat_422YpCbCr8,
     kCMVideoCodecType_Animation        = 'rle ',
     kCMVideoCodecType_Cinepak          = 'cvid',
     kCMVideoCodecType_JPEG             = 'jpeg',
     kCMVideoCodecType_JPEG_OpenDML     = 'dmb1',
     kCMVideoCodecType_SorensonVideo    = 'SVQ1',
     kCMVideoCodecType_SorensonVideo3   = 'SVQ3',
     kCMVideoCodecType_H263             = 'h263',
     kCMVideoCodecType_H264             = 'avc1',
     kCMVideoCodecType_HEVC             = 'hvc1',
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
     
     kCMVideoCodecType_AppleProRes4444  = 'ap4h',
     kCMVideoCodecType_AppleProRes422HQ = 'apch',
     kCMVideoCodecType_AppleProRes422   = 'apcn',
     kCMVideoCodecType_AppleProRes422LT = 'apcs',
     kCMVideoCodecType_AppleProRes422Proxy = 'apco',
     
     */
    /*
     listOfVideoEncodersOut:(
     {
     CodecName = avc1;
     CodecType = 1635148593;
     DisplayName = avc1;
     EncoderID = "anon-1";
     EncoderName = "Dynamically Registered avc1 Video Encoder";
     },
     {
     CodecName = h263;
     CodecType = 1748121139;
     DisplayName = h263;
     EncoderID = "anon-4";
     EncoderName = "Dynamically Registered h263 Video Encoder";
     },
     {
     CodecName = jpeg;
     CodecType = 1785750887;
     DisplayName = jpeg;
     EncoderID = "anon-2";
     EncoderName = "Dynamically Registered jpeg Video Encoder";
     },
     {
     CodecName = sjpg;
     CodecType = 1936355431;
     DisplayName = sjpg;
     EncoderID = "anon-3";
     EncoderName = "Dynamically Registered sjpg Video Encoder";
     },
     {
     CodecName = slim;
     CodecType = 1936484717;
     DisplayName = slim;
     EncoderID = "anon-5";
     EncoderName = "Dynamically Registered slim Video Encoder";
     }
     )  options:(null)
     
     */
    return(length);
    
}


void printVTEncodeInfoFlags(VTEncodeInfoFlags infoFlags)
{
    if ((infoFlags & 1) == kVTEncodeInfo_Asynchronous) {
        NSLog(@"infoFlags:%u:kVTEncodeInfo_Asynchronous",(unsigned int)infoFlags);
    } else if  ((infoFlags & 2) == kVTEncodeInfo_FrameDropped) {
        NSLog(@"infoFlags:%u:kVTEncodeInfo_FrameDropped",(unsigned int)infoFlags);
    } else {
        NSLog(@"infoFlags:%u",(unsigned int)infoFlags);
    }
}


void printVTDecodeInfoFlags(VTDecodeInfoFlags infoFlags)
{
    if ((infoFlags & 1) == kVTDecodeInfo_Asynchronous) {
        NSLog(@"infoFlags:%u:kVTEncodeInfo_Asynchronous",(unsigned int)infoFlags);
    } else if  ((infoFlags & 2) == kVTDecodeInfo_FrameDropped) {
        NSLog(@"infoFlags:%u:kVTEncodeInfo_FrameDropped",(unsigned int)infoFlags);
    } else if  ((infoFlags & 4) == kVTDecodeInfo_ImageBufferModifiable) {
        NSLog(@"infoFlags:%u:kVTDecodeInfo_ImageBufferModifiable",(unsigned int)infoFlags);
    } else {
        NSLog(@"infoFlags:%u",(unsigned int)infoFlags);
    }
}


NSString * getCallStackPrependForDebugLog(int topLevel, NSString * indent)
{
    int repeat = (int) [NSThread callStackSymbols].count;
    repeat = repeat - topLevel;
    NSString * final = [indent repeatTimes:repeat];
    return(final);
}

CVPixelBufferPoolRef makeCVPixelBufferPool(int minimumBufferCount,int maximumBufferAge,OSType pixelFormatType,int width,int height)
{
    ////kCVPixelFormatType_32BGRA
    ////you need to releat this pool when finished
    
    CVPixelBufferPoolRef pixelBufferPool = NULL;
    
    NSDictionary * poolAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:minimumBufferCount], kCVPixelBufferPoolMinimumBufferCountKey,
                                     [NSNumber numberWithInt:maximumBufferAge], kCVPixelBufferPoolMaximumBufferAgeKey,
                                     nil];
    
    
    NSDictionary * pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:pixelFormatType], kCVPixelBufferPixelFormatTypeKey,
                                            [NSNumber numberWithInt:width], kCVPixelBufferWidthKey,
                                            [NSNumber numberWithInt:height], kCVPixelBufferHeightKey,
                                            nil];
    
    CVPixelBufferPoolCreate(NULL,(__bridge CFDictionaryRef _Nullable)(poolAttributes),(__bridge CFDictionaryRef _Nullable)(pixelBufferAttributes),&pixelBufferPool);
    
    return(pixelBufferPool);
    
}

CVPixelBufferRef copyCVPixelBufferToBufferPoolGeneratedBuffer(CVPixelBufferRef sourceImageBuffer,CVPixelBufferPoolRef pixelBufferPool)
{
    ////参数中的pixelBufferPool 是别的模块creat好的
    
    ////从这个pixelBufferPool 取出一个buffer(内容为空，但大小已经分配好，这个分配是pixelBufferPool自动完成的
    CVPixelBufferRef tempPB = NULL;
    ////should do a copy
    CVReturn status = CVPixelBufferPoolCreatePixelBuffer (NULL, pixelBufferPool, &tempPB);
    
    
    
    if ((tempPB == NULL) || (status != kCVReturnSuccess))
    {
        CVPixelBufferRelease(tempPB);
    }
    else
    {
        ////锁定目的buffer tempPB
        CVPixelBufferLockBaseAddress(tempPB, 0);
        ////锁定源buffer sourceImageBuffer
        CVPixelBufferLockBaseAddress(sourceImageBuffer, 0);
        ////获取源buffer sourceImageBuffer  data部分在内存中的地址 和 size大小
        GLubyte *pixelBufferDataBaseAddrOrig = (GLubyte *)CVPixelBufferGetBaseAddress(sourceImageBuffer);
        size_t pixelBufferDataSizeOrig = CVPixelBufferGetDataSize(sourceImageBuffer);
        ////获取目的buffer tempPB  data部分在内存中的地址 和 size大小
        GLubyte *pixelBufferDataBaseAddr = (GLubyte *)CVPixelBufferGetBaseAddress(tempPB);
        size_t pixelBufferDataSize = CVPixelBufferGetDataSize(tempPB);
        ////把源buffer sourceImageBuffer中的内容 memcpy 到 目的buffer tempPB
        
        if (pixelBufferDataSizeOrig < pixelBufferDataSize) {
            memmove(pixelBufferDataBaseAddr, pixelBufferDataBaseAddrOrig,pixelBufferDataSizeOrig);
        } else {
            memmove(pixelBufferDataBaseAddr, pixelBufferDataBaseAddrOrig,pixelBufferDataSize);
        }
        ////解锁源buffer sourceImageBuffer
        CVPixelBufferUnlockBaseAddress(sourceImageBuffer, 0);
        ////解锁目的buffer tempPB
        CVPixelBufferUnlockBaseAddress(tempPB, 0);
    }
    return(tempPB);
    ////使用完毕后要自己  CVPixelBufferRelease
    ////CVPixelBufferRelease(decoder.eachModifiedCVImage);
    ////decoder.eachModifiedCVImage = NULL;
    ////CVPixelBufferPoolFlush(decoder.pixelBufferPool, kCVPixelBufferPoolFlushExcessBuffers);
}

CVPixelBufferRef copyCVPixelBufferToNewCreatedBuffer(CVPixelBufferRef sourceImageBuffer,NSMutableDictionary * options)
{
    CVPixelBufferRef tempPB = NULL;
    ////should do a copy
    CVPixelBufferLockBaseAddress(sourceImageBuffer , 0);
    unsigned long  width = CVPixelBufferGetWidth(sourceImageBuffer);
    unsigned long  height = CVPixelBufferGetHeight(sourceImageBuffer);
    OSType pixelFormatType = CVPixelBufferGetPixelFormatType(sourceImageBuffer);
    CVPixelBufferUnlockBaseAddress(sourceImageBuffer, 0);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                          height, pixelFormatType, (__bridge CFDictionaryRef) options,
                                          &tempPB);
    
    if ((tempPB == NULL) || (status != kCVReturnSuccess))
    {
        CVPixelBufferRelease(tempPB);
    }
    else
    {
        CVPixelBufferLockBaseAddress(tempPB, 0);
        CVPixelBufferLockBaseAddress(sourceImageBuffer, 0);
        
        
        
        GLubyte *pixelBufferDataBaseAddrOrig = (GLubyte *)CVPixelBufferGetBaseAddress(sourceImageBuffer);
        size_t pixelBufferDataSizeOrig = CVPixelBufferGetDataSize(sourceImageBuffer);
        
        
        GLubyte *pixelBufferDataBaseAddr = (GLubyte *)CVPixelBufferGetBaseAddress(tempPB);
        size_t pixelBufferDataSize = CVPixelBufferGetDataSize(tempPB);
        
        if (pixelBufferDataSizeOrig < pixelBufferDataSize) {
            memcpy(pixelBufferDataBaseAddr, pixelBufferDataBaseAddrOrig,pixelBufferDataSizeOrig);
        } else {
            memcpy(pixelBufferDataBaseAddr, pixelBufferDataBaseAddrOrig,pixelBufferDataSize);
        }
        
        
        
        
        CVPixelBufferUnlockBaseAddress(sourceImageBuffer, 0);
        CVPixelBufferUnlockBaseAddress(tempPB, 0);
        
    }
    
    return(tempPB);
    
}


CVPixelBufferRef copyCVPixelBufferToNewCreatedBufferWithBytes(CVPixelBufferRef sourceImageBuffer,NSMutableDictionary * options)
{
    /*
    Need to pay attention to the performance from image to CVPixelBuffer, 
    If you use context and memcpy have the same properties of expenditure, 
    But the use of CVPixelBufferCreateWithBytes that can in time increase several orders of level, 
    "This is because there is no rendering no memory copy operation energy consumption of
    only the data pointer is modified."
        ----this sentence not sure , maybe it is refered to GPU mem
    */
    
    /*
     http://stackoverflow.com/questions/28102358/fastest-way-on-ios-7-to-get-cvpixelbufferref-from-bgra-bytes
     You have to use CVPixelBufferCreate because CVPixelBufferCreateWithBytes will not allow fast conversion to an OpenGL texture using the Core Video texture cache. I'm not sure why this is the case, but that's the way things are at least as of iOS 8. I tested this with the profiler, and CVPixelBufferCreateWithBytes causes a texSubImage2D call to be made every time a Core Video texture is accessed from the cache.
     
     CVPixelBufferCreate will do funny things if the width is not a multiple of 16, so if you plan on doing CPU operations on CVPixelBufferGetBaseAddress, and you want it to be laid out like a CGImage or CGBitmapContext, you will need to pad your width higher until it is a multiple of 16, or make sure you use the CVPixelBufferGetRowBytes and pass that to any CGBitmapContext you create.
     
     I tested all combinations of dimensions of width and height from 16 to 2048, and as long as they were padded to the next highest multiple of 16, the memory was laid out properly.
     
     + (NSInteger) alignmentForPixelBufferDimension:(NSInteger)dim
     {
         static const NSInteger modValue = 16;
         NSInteger mod = dim % modValue;
         return (mod == 0 ? dim : (dim + (modValue - mod)));
     }
     
     + (NSDictionary*) pixelBufferSurfaceAttributesOfSize:(CGSize)size
     {
     return @{ 
         (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
         (NSString*)kCVPixelBufferWidthKey: @(size.width),
         (NSString*)kCVPixelBufferHeightKey: @(size.height),
         (NSString*)kCVPixelBufferBytesPerRowAlignmentKey: @(size.width * 4),
         (NSString*)kCVPixelBufferExtendedPixelsLeftKey: @(0),
         (NSString*)kCVPixelBufferExtendedPixelsRightKey: @(0),
         (NSString*)kCVPixelBufferExtendedPixelsTopKey: @(0),
         (NSString*)kCVPixelBufferExtendedPixelsBottomKey: @(0),
         (NSString*)kCVPixelBufferPlaneAlignmentKey: @(0),
         (NSString*)kCVPixelBufferCGImageCompatibilityKey: @(YES),
         (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES),
         (NSString*)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
         (NSString*)kCVPixelBufferIOSurfacePropertiesKey: @{ 
             @"IOSurfaceCGBitmapContextCompatibility": @(YES), 
             @"IOSurfaceOpenGLESFBOCompatibility": @(YES), 
             @"IOSurfaceOpenGLESTextureCompatibility": @(YES) } 
         };
     }
     Interestingly enough, if you ask for a texture from the Core Video cache with dimensions smaller than the padded dimensions, it will return a texture immediately. Somehow underneath it is able to reference the original texture, but with a smaller width and height.
     
     To sum up, you cannot wrap existing memory with a CVPixelBufferRef using CVPixelBufferCreateWithBytes and use the Core Video texture cache efficiently. You must use CVPixelBufferCreate and use CVPixelBufferGetBaseAddress.
     
     */
    
    /*
     I'd like to give more hints about this function, I made some tests so far and I can tell you that.
     When you get the base address you are probably getting the address of some shared memory resource. 
     This becomes clear if you print the address of the base address, doing that you can see that base addresses 
     are repeated while getting video frames.
     In my app I take frames at specific intervals and pass the CVImageBufferRef to an NSOperation subclass that 
     converts the buffer in an image and saves it on the phone. I do not lock the pixel buffer until the 
     operation starts to convert the CVImageBufferRef, even if pushing at higher framerates the base address of 
     the pixel and the CVImageBufferRef buffer address are equal before the creation of the NSOperation and 
     inside it. I just retain the CVImageBufferRef. I was expecting to se unmatching references and even if I 
     didn't see it I guess that the best description is that CVPixelBufferLockBaseAddress locks the memory 
     portion where the buffer is located, making it inaccessible from other resources so it will keep the same 
     data, until you unlock it.
     
     */
    
    
    
    CVPixelBufferRef tempPB = NULL;
    ////should do a copy
    CVPixelBufferLockBaseAddress(sourceImageBuffer , 0);
    unsigned long  width = CVPixelBufferGetWidth(sourceImageBuffer);
    unsigned long  height = CVPixelBufferGetHeight(sourceImageBuffer);
    OSType pixelFormatType = CVPixelBufferGetPixelFormatType(sourceImageBuffer);
    unsigned long  bytesPerRow = CVPixelBufferGetBytesPerRow(sourceImageBuffer);
    GLubyte *pixelBufferDataBaseAddrOrig = (GLubyte *)CVPixelBufferGetBaseAddress(sourceImageBuffer);
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,width,height,pixelFormatType,pixelBufferDataBaseAddrOrig,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&tempPB);
    CVPixelBufferUnlockBaseAddress(sourceImageBuffer, 0);

    return(tempPB);
    
}




NSMutableDictionary* pixelBufferAttributesForAVPlayerItemVideoOutputOfSize(CGSize size)
{
    NSMutableDictionary *pixBuffAttributes = [NSMutableDictionary dictionary];
    ////确保不花屏
    [pixBuffAttributes setObject:@(kCVPixelFormatType_32BGRA) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [pixBuffAttributes setObject:[NSNumber numberWithInteger:size.width] forKey:(id)kCVPixelBufferWidthKey];
    [pixBuffAttributes setObject:[NSNumber numberWithInteger:size.height] forKey:(id)kCVPixelBufferHeightKey];
    
    return(pixBuffAttributes);
}





////srt parsers

NSString * getVideoDirPath(NSString* workdir)
{
    NSMutableArray * video_dir_paths = [FileUitl findAllFileNamesWithPattern:workdir withPattern:@"video_dir_[0-9]+"];
    NSInteger seq = -1;
    for (int i = 0; i<video_dir_paths.count; i++) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"video_dir_([0-9]+)"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray * matches1 = [regex matchesInString:video_dir_paths[i]
                                            options:0
                                              range:NSMakeRange(0, [video_dir_paths[i] length])];
        
        NSTextCheckingResult *match1 = matches1[0];
        
        NSString * seq1Str = [video_dir_paths[i] substringWithRange: [match1 rangeAtIndex:1]];
        
        NSInteger seq1 = [seq1Str integerValue];
        
        if (seq < seq1) {
            seq = seq1;
        }
        
    }
    
    
    seq = seq + 1;
    
    NSString * relVideoDir = [NSString stringWithFormat:@"video_dir_%ld",(long)seq];
    NSString * rslt = [workdir stringByAppendingPathComponent:relVideoDir];
    return(rslt);
}






NSArray * parseSrtGetSrtEntries(NSString * string)
{
   
    string = [string  stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
  
    
    
    string = [string  stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
  
    
    NSLog(@"string:%@",string);
    
    {
        NSString *regexString = @"^[\n]*[0-9]+[ ]*\n";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        
        NSRange range = NSMakeRange(0, string.length);
        string = [regex stringByReplacingMatchesInString:string
                                                 options:0
                                                   range:range
                                            withTemplate:@""];
    }
    
    NSLog(@"string:%@",string);
    
    
    
    NSString * seprator;
    
    {
        NSString *regexString = @"\n[0-9]+[ ]*\n";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        
        NSRange range = NSMakeRange(0, string.length);
        seprator = [NSString stringWithFormat:@"%C", 0x00000001];
        string = [regex stringByReplacingMatchesInString:string
                                                 options:0
                                                   range:range
                                            withTemplate:seprator];
    }
    
    
    NSLog(@"string:%@",string);
    
    
    NSArray * srt_entries ;
    
    srt_entries = [string componentsSeparatedByString:seprator];
    
    NSLog(@"srt_entries:%@",srt_entries);
    
    return(srt_entries);
}






float parseSrtTime(NSString * time)
{
    float  rslt = 0.0;
    {
        NSString *regexString = @"([0-9]{2}):([0-9]{2}):([0-9]{2})(\\,([0-9]{3})){0,1}";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        
        NSRange range = NSMakeRange(0, time.length);
        
        NSArray * matches = [regex matchesInString:time
                                           options:0
                                             range:range];
        
        NSTextCheckingResult *match = matches[0];
        
        NSString * h = [time substringWithRange: [match rangeAtIndex:1]];
        NSString * m = [time substringWithRange: [match rangeAtIndex:2]];
        NSString * s = [time substringWithRange: [match rangeAtIndex:3]];
        NSString * cond4 = [time substringWithRange: [match rangeAtIndex:4]];
        NSString * mm = [time substringWithRange: [match rangeAtIndex:5]];
        
        

        
        
        float hour = [h floatValue] * 3600.0;
        float min =  [m floatValue] * 60.0;
        float sec = [s floatValue];
        float mmsec = 0.0;
        if (cond4.length == 0) {
            
        } else {
            mmsec = [mm floatValue]/1000.0;
        }
        
        rslt = hour + min + sec +mmsec;
        
    }
    
    return(rslt);
    
}


NSMutableDictionary * parseSrtPosition(NSString * position)
{
    NSMutableDictionary * rslt = [[NSMutableDictionary alloc] init];
    {
        NSString *regexString = @"X1[ ]*:[ ]*([0-9]+)";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        
        NSRange range = NSMakeRange(0, position.length);
        
        NSArray * matches = [regex matchesInString:position
                                           options:0
                                             range:range];
        
        NSTextCheckingResult *match = matches[0];
        
        NSString * X1 = [position substringWithRange: [match rangeAtIndex:1]];
        [rslt setValue:[NSNumber numberWithInt:[X1 intValue]] forKey:@"X1"];
    }
    {
        NSString *regexString = @"Y1[ ]*:[ ]*([0-9]+)";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        
        NSRange range = NSMakeRange(0, position.length);
        
        NSArray * matches = [regex matchesInString:position
                                           options:0
                                             range:range];
        
        NSTextCheckingResult *match = matches[0];
        
        NSString * Y1 = [position substringWithRange: [match rangeAtIndex:1]];
        [rslt setValue:[NSNumber numberWithInt:[Y1 intValue]] forKey:@"Y1"];
    }
    {
        NSString *regexString = @"X2[ ]*:[ ]*([0-9]+)";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        
        NSRange range = NSMakeRange(0, position.length);
        
        NSArray * matches = [regex matchesInString:position
                                           options:0
                                             range:range];
        
        NSTextCheckingResult *match = matches[0];
        
        NSString * X2 = [position substringWithRange: [match rangeAtIndex:1]];
        [rslt setValue:[NSNumber numberWithInt:[X2 intValue]] forKey:@"X2"];
    }
    {
        NSString *regexString = @"Y2[ ]*:[ ]*([0-9]+)";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        
        NSRange range = NSMakeRange(0, position.length);
        
        NSArray * matches = [regex matchesInString:position
                                           options:0
                                             range:range];
        
        NSTextCheckingResult *match = matches[0];
        
        NSString * Y2 = [position substringWithRange: [match rangeAtIndex:1]];
        [rslt setValue:[NSNumber numberWithInt:[Y2 intValue]] forKey:@"Y2"];
    }
    
    return(rslt);
    
}


NSMutableDictionary * parseSrtTimeAndPosition(NSString * timeAndPosition)
{
    NSMutableDictionary * rslt = [[NSMutableDictionary alloc] init];
    
    
    NSString *regexString = @"(.*?)[ ]*-->[ ]*(.*)([ ]*(.*))";
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:regexString
                                              options:NSRegularExpressionCaseInsensitive
                                                error:nil];
    
    NSRange range = NSMakeRange(0, timeAndPosition.length);
    
    NSArray * matches = [regex matchesInString:timeAndPosition
                                       options:0
                                         range:range];
    
    NSTextCheckingResult *match = matches[0];
    
    NSString * s = [timeAndPosition substringWithRange: [match rangeAtIndex:1]];
    NSString * e = [timeAndPosition substringWithRange: [match rangeAtIndex:2]];
    NSString * cond3 = [timeAndPosition substringWithRange: [match rangeAtIndex:3]];
    NSString * p = [timeAndPosition substringWithRange: [match rangeAtIndex:4]];
    ////NSString * a5 = [timeAndPosition substringWithRange: [match rangeAtIndex:5]];
   
    NSMutableDictionary * position = [[NSMutableDictionary alloc] init];
    
    if (cond3.length == 0) {
        [position setValue:[NSNumber numberWithInt:-1] forKey:@"X1"];
        [position setValue:[NSNumber numberWithInt:-1] forKey:@"Y1"];
        [position setValue:[NSNumber numberWithInt:-1] forKey:@"X2"];
        [position setValue:[NSNumber numberWithInt:-1] forKey:@"Y2"];
    } else {
        position = parseSrtPosition(p);
    }
    
    
    [rslt setValue:position forKey:@"postionOnVideo"];
    [rslt setValue:[NSNumber numberWithFloat:parseSrtTime(s)] forKey:@"startTime"];
    [rslt setValue:[NSNumber numberWithFloat:parseSrtTime(e)] forKey:@"endTime"];

    return(rslt);
    
    
}




NSString * parseSrtToUTF8Words(NSString * words)
{
    
    NSData *data=[words dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return(str);
    
    
}




NSMutableArray * parseSrtInitial(NSArray *elements)
{
    NSMutableArray * sections_1 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < elements.count; i++) {
        
        NSMutableDictionary * each = [[NSMutableDictionary alloc] init];
        
        TFHppleElement *element = [elements objectAtIndex:i];
        NSString * elementRaw = [element raw];
        NSString * elementContent = [element content];
        NSString * elementTag = [element tagName];
        NSDictionary * elementAttr = [element attributes];

        if (elementRaw) {
            [each setValue:elementRaw forKey:@"raw"];
            [each setValue:[NSNumber numberWithInt:0] forKey:@"finished"];
            [each setValue:elementTag forKey:@"tag"];
            if ([elementTag isEqualToString:@"font"]) {
                [each setValue:elementAttr forKey:@"attr"];
            }
        } else {
            [each setValue:elementContent forKey:@"text"];
            [each setValue:[NSNumber numberWithInt:1] forKey:@"finished"];
            [each removeObjectForKey:@"raw"];
            [each removeObjectForKey:@"tag"];
        }
        
        
        [sections_1 addObject:each];
        
    }
    
    return(sections_1);
}

NSMutableArray * parseSrtNext(NSMutableArray * sections_1)
{
    NSMutableArray * sections_2 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i< sections_1.count; i++) {
        NSMutableDictionary * each = sections_1[i];
        int finished = [[each valueForKey:@"finished"] intValue];
        if (finished == 1) {
            [sections_2 addObject:each];
        } else {
            NSData *htmlData=[[each valueForKey:@"raw"] dataUsingEncoding:NSUTF8StringEncoding];
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
            ////save current layer tag  and corresponding attr
            NSString * tag = [each valueForKey:@"tag"];
            NSDictionary * attr;
            if ([tag isEqualToString:@"font"]) {
                attr = [each valueForKey:@"attr"];
            }
            NSNumber * boldface = NULL;
            NSNumber * italics = NULL ;
            NSNumber * underline = NULL ;
            NSString * fontColor = NULL ;
            if ([[each allKeys] containsObject:@"boldface"]) {
                boldface = [each valueForKey:@"boldface"];
            }
            if ([[each allKeys] containsObject:@"italics"]) {
                italics = [each valueForKey:@"italics"];
            }
            if ([[each allKeys] containsObject:@"underline"]) {
                underline = [each valueForKey:@"underline"];
            }
            if ([[each allKeys] containsObject:@"fontColor"]) {
                fontColor = [each valueForKey:@"fontColor"];
            }
            
            
            NSString * xpathQ = [NSString stringWithFormat:@"//%@",tag];
            NSArray *elements = [xpathParser searchWithXPathQuery:xpathQ];
            {
                TFHppleElement *element = [elements objectAtIndex:0];
                NSArray * elements = [element children];
                if(elements.count == 1) {
                    ////NSString * elementRaw = [element raw];
                    NSString * elementContent = [element content];
                    NSString * elementTag = [element tagName];
                    NSDictionary * elementAttr = [element attributes];
                    
                    [each setValue:elementContent forKey:@"text"];
                    [each setValue:[NSNumber numberWithInt:1] forKey:@"finished"];
                    if ([elementTag isEqualToString:@"b"]) {
                        [each setValue:[NSNumber numberWithInt:1] forKey:@"boldface"];
                    }
                    if ([elementTag isEqualToString:@"i"]) {
                        [each setValue:[NSNumber numberWithInt:1] forKey:@"italics"];
                    }
                    if ([elementTag isEqualToString:@"u"]) {
                        [each setValue:[NSNumber numberWithInt:1] forKey:@"underline"];
                    }
                    
                    if ([elementTag isEqualToString:@"font"]) {
                        [each setValue:[elementAttr valueForKey:@"color"] forKey:@"fontColor"];
                    }
                    
                    [each removeObjectForKey:@"raw"];
                    [each removeObjectForKey:@"tag"];
                    [each removeObjectForKey:@"attr"];
                    
                    [sections_2 addObject:each];
                    
                } else {
                    
                    
                    
                    for (int i = 0; i < elements.count; i++) {
                        
                        
                        
                        
                        NSMutableDictionary * each = [[NSMutableDictionary alloc] init];
                        TFHppleElement *element = [elements objectAtIndex:i];
                        NSString * elementRaw = [element raw];
                        NSString * elementContent = [element content];
                        NSString * elementTag = [element tagName];
                        ////NSDictionary * elementAttr = [element attributes];
                        

                       
                        /////inherit parent attr
                        if (boldface) {
                            [each setValue:boldface forKey:@"boldface"];
                        }
                        if (italics) {
                            [each setValue:italics forKey:@"italics"];
                        }
                        if (underline) {
                            [each setValue:underline forKey:@"underline"];
                        }
                        
                        if (fontColor) {
                            [each setValue:fontColor forKey:@"fontColor"];
                        }
                        
                        if ([tag isEqualToString:@"b"]) {
                            [each setValue:[NSNumber numberWithInt:1] forKey:@"boldface"];
                        }
                        if ([tag isEqualToString:@"i"]) {
                            [each setValue:[NSNumber numberWithInt:1] forKey:@"italics"];
                        }
                        if ([tag isEqualToString:@"u"]) {
                            [each setValue:[NSNumber numberWithInt:1] forKey:@"underline"];
                        }
                        
                        if ([tag isEqualToString:@"font"]) {
                            [each setValue:[attr valueForKey:@"color"] forKey:@"fontColor"];
                        }
                        
                        
                        ////
                        
                        
                        if (elementRaw) {
                            [each setValue:elementRaw forKey:@"raw"];
                            [each setValue:[NSNumber numberWithInt:0] forKey:@"finished"];
                            [each setValue:elementTag forKey:@"tag"];
                        } else {
                            [each setValue:elementContent forKey:@"text"];
                            [each setValue:[NSNumber numberWithInt:1] forKey:@"finished"];
                            [each removeObjectForKey:@"raw"];
                            [each removeObjectForKey:@"tag"];
                            [each removeObjectForKey:@"attr"];
                        }
                        
                        [sections_2 addObject:each];
                        
                    }
                    
                    
                }
                
                
                
                
                
            }
            
            
        }
    }
    
    
    return(sections_2);

}


int parseSrtNotAllLeafs(NSMutableArray * currSections)
{
    int notAllLeafs = 1;
    
    for (int i = 0; i < currSections.count; i++) {
        int tempSign = 1;
        int isLeaf = [[currSections[i] valueForKey:@"finished"] intValue];
        if (isLeaf ==1) {
            tempSign = tempSign;
            notAllLeafs = 0;
        } else {
            tempSign = 0;
            notAllLeafs = 1;
            break;
        }
    }
    
    return(notAllLeafs);
    
    
}



NSMutableDictionary * parseSrtWords(NSString * words)
{
    ////words = @"we are champions <font color=\"#00ff00\">Detta handlar om min storebrors</font>\
    ////<b> hahaha <i> lol <u>kriminella beteende och foersvinnade.</u> lol </i></b>we are champions";
    words = [NSString stringWithFormat:@"<p>%@</p>",words];
    NSData *htmlData=[words dataUsingEncoding:NSUTF8StringEncoding];
    ////NSArray * rslt = PerformHTMLXPathQuery(htmlData, @"/");
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//p"];
    {
        TFHppleElement *element = [elements objectAtIndex:0];
        elements = [element children];
    }
    ////level-1
    NSMutableArray * currSections = parseSrtInitial(elements);
    int notAllLeafs = parseSrtNotAllLeafs(currSections);
    NSMutableArray * nextSections ;
    while (notAllLeafs == 1) {
        nextSections = parseSrtNext(currSections);
        notAllLeafs = parseSrtNotAllLeafs(nextSections);
        currSections = nextSections;
        nextSections = NULL;
    }
    NSString * string = @"";
    for (int i = 0; i < currSections.count; i++) {
        NSMutableDictionary * each = currSections[i];
        if ([[each allKeys] containsObject:@"boldface"]) {
            
        } else {
            [each setValue:[NSNumber numberWithInt:0] forKey:@"boldface"];
        }
        if ([[each allKeys] containsObject:@"italics"]) {
            
        } else {
            [each setValue:[NSNumber numberWithInt:0] forKey:@"italics"];
        }
        if ([[each allKeys] containsObject:@"underline"]) {
            
        } else {
            [each setValue:[NSNumber numberWithInt:0] forKey:@"underline"];
        }
        if ([[each allKeys] containsObject:@"fontColor"]) {
           
        } else {
             [each setValue:@"" forKey:@"fontColor"];
        }
        
        [each removeObjectForKey:@"finished"];
        ////不需要 因为是浅copy
        ////currSections[i] = each;
        string = [string stringByAppendingString:[each valueForKey:@"text"]];
        
    }
    NSMutableDictionary *  final = [[NSMutableDictionary alloc] init];
    [final setValue:currSections forKey:@"substrings"];
    [final setValue:string forKey:@"string"];
    return(final);
}


NSMutableDictionary * parseSrtEachEntry(NSString * entry)
{
    NSMutableDictionary * rslt = [[NSMutableDictionary alloc] init];
    
    
    
        NSString *regexString = @"(.*)\n(.*)";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        
        NSRange range = NSMakeRange(0, entry.length);
        
        NSArray * matches = [regex matchesInString:entry
                                            options:0
                                              range:range];
        
        NSTextCheckingResult *match = matches[0];
        
        NSString * timeAndPosition = [entry substringWithRange: [match rangeAtIndex:1]];
        NSString * words = [entry substringWithRange: [match rangeAtIndex:2]];
    
    
        
    NSMutableDictionary * tandp = parseSrtTimeAndPosition(timeAndPosition);
    
    
    [rslt setValue:[tandp valueForKey:@"postionOnVideo"]  forKey:@"postionOnVideo"];
    [rslt setValue:[tandp valueForKey:@"startTime"]  forKey:@"startTime"];
    [rslt setValue:[tandp valueForKey:@"endTime"]  forKey:@"endTime"];
    [rslt setValue:parseSrtWords(words) forKey:@"dialogue"];
    
    
    
    
    return(rslt);


}


void addNewVideoToDataBase(NSString * relativePath,NSString * workdir,NSString * sourceVideoPath,NSString * sourceSrtPath,int fromSupportedEncoder)
{
    
    NSString * each_video_dir = getVideoDirPath(workdir);
    [FileUitl deleteFile:each_video_dir];
    each_video_dir = [FileUitl creatSubDir:each_video_dir];
    
    
    NSString * orig_srt = [each_video_dir stringByAppendingPathComponent:@"orig_srt.srt"];
    [FileUitl copyFileFrom:sourceSrtPath To:orig_srt];
    
    NSString * orig_video = [each_video_dir stringByAppendingPathComponent:@"orig_video.mov"];
    [FileUitl copyFileFrom:sourceVideoPath To:orig_video];
    AVAssetTrack * vt = [selectAllVideoTracksFromMovieURL([NSURL fileURLWithPath: orig_video]) valueForKey:@"tracks"][0];
    CMTimeScale timescale =  vt.timeRange.duration.timescale;
    vt = NULL;
    
    
    
    
    NSMutableDictionary * overall_desc = [[NSMutableDictionary alloc] init];
    NSMutableArray * odsections = [[NSMutableArray alloc] init];
    NSMutableArray * cmtrs = [[NSMutableArray alloc] init];
    NSMutableArray * section_dirs = [[NSMutableArray alloc] init];
    NSMutableArray * destURLs = [[NSMutableArray alloc] init];
    NSMutableDictionary * k_v_path_words = [[NSMutableDictionary alloc] init];
    
    [overall_desc setValue:orig_srt forKey:@"orig_srt_path"];
    [overall_desc setValue:orig_video forKey:@"orig_video_path"];
    

    NSMutableArray * thumbnail_paths = [[NSMutableArray alloc] init];
    
    
    {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:orig_srt]];
        NSURLSession *session = [NSURLSession sharedSession];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSString * string = [[FileUitl getNSStringFromDataViaCFString:data from:fromSupportedEncoder] valueForKey:@"string"];
                
                NSArray * srt_entries = parseSrtGetSrtEntries(string);
                
                for (int i = 0; i<srt_entries.count; i++) {
                    NSString * section_dir = [each_video_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"section_dir_%d",i]];
                    [FileUitl deleteSubDir:section_dir];
                    [FileUitl creatSubDir:section_dir];
                    [section_dirs addObject:section_dir];
                    NSString * section_video_path = [section_dir stringByAppendingPathComponent:@"sec_video.mov"];
                    NSURL * sec_video_url = [NSURL fileURLWithPath:section_video_path];
                    [FileUitl deleteFile:section_video_path];
                    [destURLs addObject:sec_video_url];
                    NSMutableDictionary * each_srt_info = parseSrtEachEntry(srt_entries[i]);
                    NSString * section_srt_info_path = [section_dir stringByAppendingPathComponent:@"srt_info.json"];
                    [FileUitl deleteFile:section_srt_info_path];
                    [FileUitl writeJSONtoFile:each_srt_info filePath:section_srt_info_path];
                    NSString * relativeSecPath = [NSString stringWithFormat:@"./%@",[section_dir trimLeft:relativePath]];
                    NSString * currWords = [[each_srt_info valueForKey:@"dialogue"] valueForKey:@"string"];
                    NSMutableDictionary * section = [[NSMutableDictionary alloc] init];
                    [section setValue:relativeSecPath forKeyPath:@"sec_path"];
                    [section setValue:currWords forKeyPath:@"words"];
                    [odsections addObject:section];
                    [k_v_path_words setValue:currWords forKey:relativeSecPath];
                    float sf = [[each_srt_info valueForKey:@"startTime"] floatValue];
                    float ef = [[each_srt_info valueForKey:@"endTime"] floatValue];
                    float df = ef - sf;
                    CMTime start = CMTimeMakeWithSeconds(sf,timescale) ;
                    CMTime d = CMTimeMakeWithSeconds(df,timescale);
                    [cmtrs addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(start, d)]];
                    
                    
                    NSString * thumbnail = [section_dir stringByAppendingPathComponent:@"thumbnail.png"];
                    [thumbnail_paths addObject:thumbnail];
                    
                }
            }else{
                NSLog(@"error  is  %@",error.localizedDescription);
            }
            
            dispatch_semaphore_signal(semaphore);
            
            
        }];
        // 使用resume方法启动任务
        [dataTask resume];
        
        
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        
        
        
        
    }
    
    [overall_desc setValue:odsections forKey:@"sections"];
    NSString * overall_desc_path = [each_video_dir stringByAppendingPathComponent:@"overall_desc.json"];
    [FileUitl deleteFile:overall_desc_path];
    [FileUitl writeJSONtoFile:overall_desc filePath:overall_desc_path];
    
    NSString * k_v_path = [each_video_dir stringByAppendingPathComponent:@"k_v_path_words.json"];
    [FileUitl deleteFile:k_v_path];
    [FileUitl writeJSONtoFile:k_v_path_words filePath:k_v_path];
    
    NSMutableDictionary * v_k_words_paths = [[NSMutableDictionary alloc] init];
    v_k_words_paths = [FileUitl kv2vks:k_v_path_words];
    
    NSString * v_k_path = [each_video_dir stringByAppendingPathComponent:@"v_k_words_paths.json"];
    [FileUitl deleteFile:v_k_path];
    [FileUitl writeJSONtoFile:v_k_words_paths filePath:v_k_path];
    
    
    
    NSString * flat_table_path  = [workdir stringByAppendingPathComponent:@"flat_table.json"];
    
    NSMutableDictionary * flat_table_words_paths = [[NSMutableDictionary alloc] init];
    
    NSFileManager * fm =[NSFileManager defaultManager];
    if ([fm fileExistsAtPath: flat_table_path]   ) {
        flat_table_words_paths = [[NSMutableDictionary alloc] initWithDictionary: [FileUitl loadJSONfromFile:flat_table_path]];
        [FileUitl addDict:v_k_words_paths toDict:flat_table_words_paths];
    } else {
        flat_table_words_paths = v_k_words_paths;
    }
    
    
    [FileUitl deleteFile:flat_table_path];
    [FileUitl writeJSONtoFile:flat_table_words_paths filePath:flat_table_path];
    
    

    splitVideoToVideosViaCMTimeRangeArrayFromMovieURL([NSURL fileURLWithPath:orig_video], 0, cmtrs, destURLs);
    
    
    for (int i = 0; i<thumbnail_paths.count; i++) {
        
        NSString * section_video_path = [section_dirs[i] stringByAppendingPathComponent:@"sec_video.mov"];
        NSURL * sec_video_url = [NSURL fileURLWithPath:section_video_path];
        
        AVAsset *asset = [[AVURLAsset alloc] initWithURL:sec_video_url options:nil];
        
        AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generate.appliesPreferredTrackTransform = YES;
        generate.requestedTimeToleranceBefore = kCMTimeZero;
        generate.requestedTimeToleranceAfter = kCMTimeZero;
        NSError *err = NULL;
        CMTime d = asset.tracks[0].timeRange.duration ;
        d = CMTimeMultiplyByRatio(d, 1, 2);
        CMTime time = CMTimeAdd(asset.tracks[0].timeRange.start, d);
        CGImageRef oneRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage * selected = [[UIImage alloc] initWithCGImage:oneRef];
        [FileUitl saveUIImageToFile:selected filePath:thumbnail_paths[i] format:@"png" jpegQuality:1.0];
        
        CGImageRelease(oneRef);
        
        asset = NULL;
        generate = NULL;
    }
    
}


////-audio

void printAudioFormat(AudioFormatID afid)
{
    if (afid == kAudioFormatLinearPCM) {
        NSLog(@"lpcm");
    }
    if (afid == kAudioFormatAC3) {
        NSLog(@"ac-3");
    }
    if (afid == kAudioFormat60958AC3) {
        NSLog(@"cac3");
    }
    if (afid == kAudioFormatAppleIMA4) {
        NSLog(@"ima4");
    }
    if (afid == kAudioFormatMPEG4AAC) {
        NSLog(@"aac ");
    }
    if (afid == kAudioFormatMPEG4CELP) {
        NSLog(@"celp");
    }
    if (afid == kAudioFormatMPEG4HVXC) {
        NSLog(@"hvxc");
    }
/*
    kAudioFormatMPEG4TwinVQ             = 'twvq',
    kAudioFormatMACE3                   = 'MAC3',
    kAudioFormatMACE6                   = 'MAC6',
    kAudioFormatULaw                    = 'ulaw',
    kAudioFormatALaw                    = 'alaw',
    kAudioFormatQDesign                 = 'QDMC',
    kAudioFormatQDesign2                = 'QDM2',
    kAudioFormatQUALCOMM                = 'Qclp',
    kAudioFormatMPEGLayer1              = '.mp1',
    kAudioFormatMPEGLayer2              = '.mp2',
    kAudioFormatMPEGLayer3              = '.mp3',
    kAudioFormatTimeCode                = 'time',
    kAudioFormatMIDIStream              = 'midi',
    kAudioFormatParameterValueStream    = 'apvs',
    kAudioFormatAppleLossless           = 'alac',
    kAudioFormatMPEG4AAC_HE             = 'aach',
    kAudioFormatMPEG4AAC_LD             = 'aacl',
    kAudioFormatMPEG4AAC_ELD            = 'aace',
    kAudioFormatMPEG4AAC_ELD_SBR        = 'aacf',
    kAudioFormatMPEG4AAC_ELD_V2         = 'aacg',
    kAudioFormatMPEG4AAC_HE_V2          = 'aacp',
    kAudioFormatMPEG4AAC_Spatial        = 'aacs',
    kAudioFormatAMR                     = 'samr',
    kAudioFormatAMR_WB                  = 'sawb',
    kAudioFormatAudible                 = 'AUDB',
    kAudioFormatiLBC                    = 'ilbc',
    kAudioFormatDVIIntelIMA             = 0x6D730011,
    kAudioFormatMicrosoftGSM            = 0x6D730031,
    kAudioFormatAES3                    = 'aes3',
    kAudioFormatEnhancedAC3             = 'ec-3'
 */
}


void printAudioFormatFlags(AudioFormatFlags i)
{
    NSLog(@"the AudioFormatFlags value is:%u",(unsigned int)i);
    
    if (i & kAudioFormatFlagIsFloat ) {
        NSLog(@"kAudioFormatFlagIsFloat");
    }
    if (i& kAudioFormatFlagIsBigEndian) {
        NSLog(@"kAudioFormatFlagIsBigEndian");
    }
    if (i& kAudioFormatFlagIsSignedInteger) {
        NSLog(@"kAudioFormatFlagIsSignedInteger");
    }
    if (i& kAudioFormatFlagIsPacked) {
        NSLog(@"kAudioFormatFlagIsPacked");
    }
    if (i& kAudioFormatFlagIsAlignedHigh) {
        NSLog(@"kAudioFormatFlagIsAlignedHigh");
    }
    if (i& kAudioFormatFlagIsNonInterleaved) {
        NSLog(@"kAudioFormatFlagIsNonInterleaved");
    }
    if (i& kAudioFormatFlagIsNonMixable) {
        NSLog(@"kAudioFormatFlagIsNonMixable");
    }
    if (i& kAudioFormatFlagsAreAllClear) {
        NSLog(@"kAudioFormatFlagsAreAllClear");
    }
    if (i& kLinearPCMFormatFlagIsFloat) {
        NSLog(@"kLinearPCMFormatFlagIsFloat");
    }
    if (i== kLinearPCMFormatFlagIsBigEndian) {
        NSLog(@"kLinearPCMFormatFlagIsBigEndian");
    }
    if (i& kLinearPCMFormatFlagIsSignedInteger) {
        NSLog(@"kLinearPCMFormatFlagIsSignedInteger");
    }
    if (i& kLinearPCMFormatFlagIsPacked) {
        NSLog(@"kLinearPCMFormatFlagIsPacked");
    }
    if (i& kLinearPCMFormatFlagIsAlignedHigh) {
        NSLog(@"kLinearPCMFormatFlagIsAlignedHigh");
    }
    if (i& kLinearPCMFormatFlagIsNonInterleaved) {
        NSLog(@"kLinearPCMFormatFlagIsNonInterleaved");
    }
    if (i& kLinearPCMFormatFlagIsNonMixable) {
        NSLog(@"kLinearPCMFormatFlagIsNonMixable");
    }
    if (i& kLinearPCMFormatFlagsSampleFractionShift) {
        NSLog(@"kLinearPCMFormatFlagsSampleFractionShift");
    }
    if (i& kLinearPCMFormatFlagsSampleFractionMask) {
        NSLog(@"kLinearPCMFormatFlagsSampleFractionMask");
    }
    if (i& kLinearPCMFormatFlagsAreAllClear) {
        NSLog(@"kLinearPCMFormatFlagsAreAllClear");
    }
    if (i& kAppleLosslessFormatFlag_16BitSourceData) {
        NSLog(@"kAppleLosslessFormatFlag_16BitSourceData");
    }
    if (i& kAppleLosslessFormatFlag_20BitSourceData) {
        NSLog(@"kAppleLosslessFormatFlag_20BitSourceData");
    }
    if (i& kAppleLosslessFormatFlag_24BitSourceData) {
        NSLog(@"kAppleLosslessFormatFlag_24BitSourceData");
    }
    if (i& kAppleLosslessFormatFlag_32BitSourceData) {
        NSLog(@"kAppleLosslessFormatFlag_32BitSourceData");
    }

}

void printAudioStreamBasicDescription(AudioStreamBasicDescription mASBD)
{
    
    ////mBitsPerChannel/8   *  mChannelsPerFrame =  mBytesPerFrame;
    ////mBytesPerFrame *  mBytesPerPacket = mFramesPerPacket;
    
    NSLog(@"mBitsPerChannel:%d",mASBD.mBitsPerChannel);
    NSLog(@"mChannelsPerFrame:%d",mASBD.mChannelsPerFrame);
    NSLog(@"mFramesPerPacket:%d",mASBD.mFramesPerPacket);
    NSLog(@"mBytesPerFrame:%d",mASBD.mBytesPerFrame);
    NSLog(@"mBytesPerPacket:%d",mASBD.mBytesPerPacket);
    NSLog(@"mSampleRate:%f",mASBD.mSampleRate);
    printAudioFormatFlags(mASBD.mFormatFlags);
    printAudioFormat(mASBD.mFormatID);
    NSLog(@"mReserved:%d",mASBD.mReserved);
   
    
}

void printAudioChannelLayoutTag(AudioChannelLayoutTag i)
{
    if (i==kAudioChannelLayoutTag_UseChannelDescriptions) {
        NSLog(@"kAudioChannelLayoutTag_UseChannelDescriptions");
    }
    if (i==kAudioChannelLayoutTag_UseChannelBitmap) {
        NSLog(@"kAudioChannelLayoutTag_UseChannelBitmap");
    }
    if (i==kAudioChannelLayoutTag_Mono) {
        NSLog(@"kAudioChannelLayoutTag_Mono");
    }
    if (i==kAudioChannelLayoutTag_Stereo) {
        NSLog(@"kAudioChannelLayoutTag_Stereo");
    }
    if (i==kAudioChannelLayoutTag_StereoHeadphones) {
        NSLog(@"kAudioChannelLayoutTag_StereoHeadphones");
    }
    
    
     
    /*
     
     kAudioChannelLayoutTag_MatrixStereo             = (103U<<16) | 2,   // a matrix encoded stereo stream (Lt, Rt)
     kAudioChannelLayoutTag_MidSide                  = (104U<<16) | 2,   // mid/side recording
     kAudioChannelLayoutTag_XY                       = (105U<<16) | 2,   // coincident mic pair (often 2 figure 8's)
     kAudioChannelLayoutTag_Binaural                 = (106U<<16) | 2,   // binaural stereo (left, right)
     kAudioChannelLayoutTag_Ambisonic_B_Format       = (107U<<16) | 4,   // W, X, Y, Z
     
     kAudioChannelLayoutTag_Quadraphonic             = (108U<<16) | 4,   // L R Ls Rs  -- 90 degree speaker separation
     kAudioChannelLayoutTag_Pentagonal               = (109U<<16) | 5,   // L R Ls Rs C  -- 72 degree speaker separation
     kAudioChannelLayoutTag_Hexagonal                = (110U<<16) | 6,   // L R Ls Rs C Cs  -- 60 degree speaker separation
     kAudioChannelLayoutTag_Octagonal                = (111U<<16) | 8,   // L R Ls Rs C Cs Lw Rw  -- 45 degree speaker separation
     kAudioChannelLayoutTag_Cube                     = (112U<<16) | 8,   // left, right, rear left, rear right
     // top left, top right, top rear left, top rear right
     
     //  MPEG defined layouts
     kAudioChannelLayoutTag_MPEG_1_0                 = kAudioChannelLayoutTag_Mono,         //  C
     kAudioChannelLayoutTag_MPEG_2_0                 = kAudioChannelLayoutTag_Stereo,       //  L R
     kAudioChannelLayoutTag_MPEG_3_0_A               = (113U<<16) | 3,                       //  L R C
     kAudioChannelLayoutTag_MPEG_3_0_B               = (114U<<16) | 3,                       //  C L R
     kAudioChannelLayoutTag_MPEG_4_0_A               = (115U<<16) | 4,                       //  L R C Cs
     kAudioChannelLayoutTag_MPEG_4_0_B               = (116U<<16) | 4,                       //  C L R Cs
     kAudioChannelLayoutTag_MPEG_5_0_A               = (117U<<16) | 5,                       //  L R C Ls Rs
     kAudioChannelLayoutTag_MPEG_5_0_B               = (118U<<16) | 5,                       //  L R Ls Rs C
     kAudioChannelLayoutTag_MPEG_5_0_C               = (119U<<16) | 5,                       //  L C R Ls Rs
     kAudioChannelLayoutTag_MPEG_5_0_D               = (120U<<16) | 5,                       //  C L R Ls Rs
     kAudioChannelLayoutTag_MPEG_5_1_A               = (121U<<16) | 6,                       //  L R C LFE Ls Rs
     kAudioChannelLayoutTag_MPEG_5_1_B               = (122U<<16) | 6,                       //  L R Ls Rs C LFE
     kAudioChannelLayoutTag_MPEG_5_1_C               = (123U<<16) | 6,                       //  L C R Ls Rs LFE
     kAudioChannelLayoutTag_MPEG_5_1_D               = (124U<<16) | 6,                       //  C L R Ls Rs LFE
     kAudioChannelLayoutTag_MPEG_6_1_A               = (125U<<16) | 7,                       //  L R C LFE Ls Rs Cs
     kAudioChannelLayoutTag_MPEG_7_1_A               = (126U<<16) | 8,                       //  L R C LFE Ls Rs Lc Rc
     kAudioChannelLayoutTag_MPEG_7_1_B               = (127U<<16) | 8,                       //  C Lc Rc L R Ls Rs LFE    (doc: IS-13818-7 MPEG2-AAC Table 3.1)
     kAudioChannelLayoutTag_MPEG_7_1_C               = (128U<<16) | 8,                       //  L R C LFE Ls Rs Rls Rrs
     kAudioChannelLayoutTag_Emagic_Default_7_1       = (129U<<16) | 8,                       //  L R Ls Rs C LFE Lc Rc
     kAudioChannelLayoutTag_SMPTE_DTV                = (130U<<16) | 8,                       //  L R C LFE Ls Rs Lt Rt
     //      (kAudioChannelLayoutTag_ITU_5_1 plus a matrix encoded stereo mix)
     
     //  ITU defined layouts
     kAudioChannelLayoutTag_ITU_1_0                  = kAudioChannelLayoutTag_Mono,         //  C
     kAudioChannelLayoutTag_ITU_2_0                  = kAudioChannelLayoutTag_Stereo,       //  L R
     
     kAudioChannelLayoutTag_ITU_2_1                  = (131U<<16) | 3,                       //  L R Cs
     kAudioChannelLayoutTag_ITU_2_2                  = (132U<<16) | 4,                       //  L R Ls Rs
     kAudioChannelLayoutTag_ITU_3_0                  = kAudioChannelLayoutTag_MPEG_3_0_A,   //  L R C
     kAudioChannelLayoutTag_ITU_3_1                  = kAudioChannelLayoutTag_MPEG_4_0_A,   //  L R C Cs
     
     kAudioChannelLayoutTag_ITU_3_2                  = kAudioChannelLayoutTag_MPEG_5_0_A,   //  L R C Ls Rs
     kAudioChannelLayoutTag_ITU_3_2_1                = kAudioChannelLayoutTag_MPEG_5_1_A,   //  L R C LFE Ls Rs
     kAudioChannelLayoutTag_ITU_3_4_1                = kAudioChannelLayoutTag_MPEG_7_1_C,   //  L R C LFE Ls Rs Rls Rrs
     
     // DVD defined layouts
     kAudioChannelLayoutTag_DVD_0                    = kAudioChannelLayoutTag_Mono,         // C (mono)
     kAudioChannelLayoutTag_DVD_1                    = kAudioChannelLayoutTag_Stereo,       // L R
     kAudioChannelLayoutTag_DVD_2                    = kAudioChannelLayoutTag_ITU_2_1,      // L R Cs
     kAudioChannelLayoutTag_DVD_3                    = kAudioChannelLayoutTag_ITU_2_2,      // L R Ls Rs
     kAudioChannelLayoutTag_DVD_4                    = (133U<<16) | 3,                       // L R LFE
     kAudioChannelLayoutTag_DVD_5                    = (134U<<16) | 4,                       // L R LFE Cs
     kAudioChannelLayoutTag_DVD_6                    = (135U<<16) | 5,                       // L R LFE Ls Rs
     kAudioChannelLayoutTag_DVD_7                    = kAudioChannelLayoutTag_MPEG_3_0_A,   // L R C
     kAudioChannelLayoutTag_DVD_8                    = kAudioChannelLayoutTag_MPEG_4_0_A,   // L R C Cs
     kAudioChannelLayoutTag_DVD_9                    = kAudioChannelLayoutTag_MPEG_5_0_A,   // L R C Ls Rs
     kAudioChannelLayoutTag_DVD_10                   = (136U<<16) | 4,                       // L R C LFE
     kAudioChannelLayoutTag_DVD_11                   = (137U<<16) | 5,                       // L R C LFE Cs
     kAudioChannelLayoutTag_DVD_12                   = kAudioChannelLayoutTag_MPEG_5_1_A,   // L R C LFE Ls Rs
     // 13 through 17 are duplicates of 8 through 12.
     kAudioChannelLayoutTag_DVD_13                   = kAudioChannelLayoutTag_DVD_8,        // L R C Cs
     kAudioChannelLayoutTag_DVD_14                   = kAudioChannelLayoutTag_DVD_9,        // L R C Ls Rs
     kAudioChannelLayoutTag_DVD_15                   = kAudioChannelLayoutTag_DVD_10,       // L R C LFE
     kAudioChannelLayoutTag_DVD_16                   = kAudioChannelLayoutTag_DVD_11,       // L R C LFE Cs
     kAudioChannelLayoutTag_DVD_17                   = kAudioChannelLayoutTag_DVD_12,       // L R C LFE Ls Rs
     kAudioChannelLayoutTag_DVD_18                   = (138U<<16) | 5,                       // L R Ls Rs LFE
     kAudioChannelLayoutTag_DVD_19                   = kAudioChannelLayoutTag_MPEG_5_0_B,   // L R Ls Rs C
     kAudioChannelLayoutTag_DVD_20                   = kAudioChannelLayoutTag_MPEG_5_1_B,   // L R Ls Rs C LFE
     
     // These layouts are recommended for AudioUnit usage
     // These are the symmetrical layouts
     kAudioChannelLayoutTag_AudioUnit_4              = kAudioChannelLayoutTag_Quadraphonic,
     kAudioChannelLayoutTag_AudioUnit_5              = kAudioChannelLayoutTag_Pentagonal,
     kAudioChannelLayoutTag_AudioUnit_6              = kAudioChannelLayoutTag_Hexagonal,
     kAudioChannelLayoutTag_AudioUnit_8              = kAudioChannelLayoutTag_Octagonal,
     // These are the surround-based layouts
     kAudioChannelLayoutTag_AudioUnit_5_0            = kAudioChannelLayoutTag_MPEG_5_0_B,   // L R Ls Rs C
     kAudioChannelLayoutTag_AudioUnit_6_0            = (139U<<16) | 6,                       // L R Ls Rs C Cs
     kAudioChannelLayoutTag_AudioUnit_7_0            = (140U<<16) | 7,                       // L R Ls Rs C Rls Rrs
     kAudioChannelLayoutTag_AudioUnit_7_0_Front      = (148U<<16) | 7,                       // L R Ls Rs C Lc Rc
     kAudioChannelLayoutTag_AudioUnit_5_1            = kAudioChannelLayoutTag_MPEG_5_1_A,   // L R C LFE Ls Rs
     kAudioChannelLayoutTag_AudioUnit_6_1            = kAudioChannelLayoutTag_MPEG_6_1_A,   // L R C LFE Ls Rs Cs
     kAudioChannelLayoutTag_AudioUnit_7_1            = kAudioChannelLayoutTag_MPEG_7_1_C,   // L R C LFE Ls Rs Rls Rrs
     kAudioChannelLayoutTag_AudioUnit_7_1_Front      = kAudioChannelLayoutTag_MPEG_7_1_A,   // L R C LFE Ls Rs Lc Rc
     
     kAudioChannelLayoutTag_AAC_3_0                  = kAudioChannelLayoutTag_MPEG_3_0_B,   // C L R
     kAudioChannelLayoutTag_AAC_Quadraphonic         = kAudioChannelLayoutTag_Quadraphonic, // L R Ls Rs
     kAudioChannelLayoutTag_AAC_4_0                  = kAudioChannelLayoutTag_MPEG_4_0_B,   // C L R Cs
     kAudioChannelLayoutTag_AAC_5_0                  = kAudioChannelLayoutTag_MPEG_5_0_D,   // C L R Ls Rs
     kAudioChannelLayoutTag_AAC_5_1                  = kAudioChannelLayoutTag_MPEG_5_1_D,   // C L R Ls Rs Lfe
     kAudioChannelLayoutTag_AAC_6_0                  = (141U<<16) | 6,                       // C L R Ls Rs Cs
     kAudioChannelLayoutTag_AAC_6_1                  = (142U<<16) | 7,                       // C L R Ls Rs Cs Lfe
     kAudioChannelLayoutTag_AAC_7_0                  = (143U<<16) | 7,                       // C L R Ls Rs Rls Rrs
     kAudioChannelLayoutTag_AAC_7_1                  = kAudioChannelLayoutTag_MPEG_7_1_B,   // C Lc Rc L R Ls Rs Lfe
     kAudioChannelLayoutTag_AAC_7_1_B                = (183U<<16) | 8,                       // C L R Ls Rs Rls Rrs LFE
     kAudioChannelLayoutTag_AAC_7_1_C                = (184U<<16) | 8,                       // C L R Ls Rs LFE Vhl Vhr
     kAudioChannelLayoutTag_AAC_Octagonal            = (144U<<16) | 8,                       // C L R Ls Rs Rls Rrs Cs
     
     kAudioChannelLayoutTag_TMH_10_2_std             = (145U<<16) | 16,                      // L R C Vhc Lsd Rsd Ls Rs Vhl Vhr Lw Rw Csd Cs LFE1 LFE2
     kAudioChannelLayoutTag_TMH_10_2_full            = (146U<<16) | 21,                      // TMH_10_2_std plus: Lc Rc HI VI Haptic
     
     kAudioChannelLayoutTag_AC3_1_0_1                = (149U<<16) | 2,                       // C LFE
     kAudioChannelLayoutTag_AC3_3_0                  = (150U<<16) | 3,                       // L C R
     kAudioChannelLayoutTag_AC3_3_1                  = (151U<<16) | 4,                       // L C R Cs
     kAudioChannelLayoutTag_AC3_3_0_1                = (152U<<16) | 4,                       // L C R LFE
     kAudioChannelLayoutTag_AC3_2_1_1                = (153U<<16) | 4,                       // L R Cs LFE
     kAudioChannelLayoutTag_AC3_3_1_1                = (154U<<16) | 5,                       // L C R Cs LFE
     
     kAudioChannelLayoutTag_EAC_6_0_A                = (155U<<16) | 6,                       // L C R Ls Rs Cs
     kAudioChannelLayoutTag_EAC_7_0_A                = (156U<<16) | 7,                       // L C R Ls Rs Rls Rrs
     
     kAudioChannelLayoutTag_EAC3_6_1_A               = (157U<<16) | 7,                       // L C R Ls Rs LFE Cs
     kAudioChannelLayoutTag_EAC3_6_1_B               = (158U<<16) | 7,                       // L C R Ls Rs LFE Ts
     kAudioChannelLayoutTag_EAC3_6_1_C               = (159U<<16) | 7,                       // L C R Ls Rs LFE Vhc
     kAudioChannelLayoutTag_EAC3_7_1_A               = (160U<<16) | 8,                       // L C R Ls Rs LFE Rls Rrs
     kAudioChannelLayoutTag_EAC3_7_1_B               = (161U<<16) | 8,                       // L C R Ls Rs LFE Lc Rc
     kAudioChannelLayoutTag_EAC3_7_1_C               = (162U<<16) | 8,                       // L C R Ls Rs LFE Lsd Rsd
     kAudioChannelLayoutTag_EAC3_7_1_D               = (163U<<16) | 8,                       // L C R Ls Rs LFE Lw Rw
     kAudioChannelLayoutTag_EAC3_7_1_E               = (164U<<16) | 8,                       // L C R Ls Rs LFE Vhl Vhr
     
     kAudioChannelLayoutTag_EAC3_7_1_F               = (165U<<16) | 8,                        // L C R Ls Rs LFE Cs Ts
     kAudioChannelLayoutTag_EAC3_7_1_G               = (166U<<16) | 8,                        // L C R Ls Rs LFE Cs Vhc
     kAudioChannelLayoutTag_EAC3_7_1_H               = (167U<<16) | 8,                        // L C R Ls Rs LFE Ts Vhc
     
     kAudioChannelLayoutTag_DTS_3_1                  = (168U<<16) | 4,                        // C L R LFE
     kAudioChannelLayoutTag_DTS_4_1                  = (169U<<16) | 5,                        // C L R Cs LFE
     kAudioChannelLayoutTag_DTS_6_0_A                = (170U<<16) | 6,                        // Lc Rc L R Ls Rs
     kAudioChannelLayoutTag_DTS_6_0_B                = (171U<<16) | 6,                        // C L R Rls Rrs Ts
     kAudioChannelLayoutTag_DTS_6_0_C                = (172U<<16) | 6,                        // C Cs L R Rls Rrs
     kAudioChannelLayoutTag_DTS_6_1_A                = (173U<<16) | 7,                        // Lc Rc L R Ls Rs LFE
     kAudioChannelLayoutTag_DTS_6_1_B                = (174U<<16) | 7,                        // C L R Rls Rrs Ts LFE
     kAudioChannelLayoutTag_DTS_6_1_C                = (175U<<16) | 7,                        // C Cs L R Rls Rrs LFE
     kAudioChannelLayoutTag_DTS_7_0                  = (176U<<16) | 7,                        // Lc C Rc L R Ls Rs
     kAudioChannelLayoutTag_DTS_7_1                  = (177U<<16) | 8,                        // Lc C Rc L R Ls Rs LFE
     kAudioChannelLayoutTag_DTS_8_0_A                = (178U<<16) | 8,                        // Lc Rc L R Ls Rs Rls Rrs
     kAudioChannelLayoutTag_DTS_8_0_B                = (179U<<16) | 8,                        // Lc C Rc L R Ls Cs Rs
     kAudioChannelLayoutTag_DTS_8_1_A                = (180U<<16) | 9,                        // Lc Rc L R Ls Rs Rls Rrs LFE
     kAudioChannelLayoutTag_DTS_8_1_B                = (181U<<16) | 9,                        // Lc C Rc L R Ls Cs Rs LFE
     kAudioChannelLayoutTag_DTS_6_1_D                = (182U<<16) | 7,                        // C L R Ls Rs LFE Cs
     
     kAudioChannelLayoutTag_DiscreteInOrder          = (147U<<16) | 0,                        // needs to be ORed with the actual number of channels
     kAudioChannelLayoutTag_Unknown                  = 0xFFFF0000                            // needs to be ORed with the actual number of channels

     */
}

void printAudioChannelFlags(AudioChannelFlags i)
{
    
    if (i == kAudioChannelFlags_AllOff) {
        NSLog(@"kAudioChannelFlags_AllOff");
    }
    if (i == kAudioChannelFlags_RectangularCoordinates) {
        NSLog(@"kAudioChannelFlags_RectangularCoordinates");
    }
    if (i == kAudioChannelFlags_SphericalCoordinates) {
        NSLog(@"kAudioChannelFlags_SphericalCoordinates");
    }
    if (i == kAudioChannelFlags_Meters) {
        NSLog(@"kAudioChannelFlags_Meters");
    }

}

void printAudioChannelLabel(AudioChannelLabel i)
{
    /*
    kAudioChannelLabel_Unknown                  = 0xFFFFFFFF,   // unknown or unspecified other use
    kAudioChannelLabel_Unused                   = 0,            // channel is present, but has no intended use or destination
    kAudioChannelLabel_UseCoordinates           = 100,          // channel is described by the mCoordinates fields.
    
    kAudioChannelLabel_Left                     = 1,
    kAudioChannelLabel_Right                    = 2,
    kAudioChannelLabel_Center                   = 3,
    kAudioChannelLabel_LFEScreen                = 4,
    kAudioChannelLabel_LeftSurround             = 5,            // WAVE: "Back Left"
    kAudioChannelLabel_RightSurround            = 6,            // WAVE: "Back Right"
    kAudioChannelLabel_LeftCenter               = 7,
    kAudioChannelLabel_RightCenter              = 8,
    kAudioChannelLabel_CenterSurround           = 9,            // WAVE: "Back Center" or plain "Rear Surround"
    kAudioChannelLabel_LeftSurroundDirect       = 10,           // WAVE: "Side Left"
    kAudioChannelLabel_RightSurroundDirect      = 11,           // WAVE: "Side Right"
    kAudioChannelLabel_TopCenterSurround        = 12,
    kAudioChannelLabel_VerticalHeightLeft       = 13,           // WAVE: "Top Front Left"
    kAudioChannelLabel_VerticalHeightCenter     = 14,           // WAVE: "Top Front Center"
    kAudioChannelLabel_VerticalHeightRight      = 15,           // WAVE: "Top Front Right"
    
    kAudioChannelLabel_TopBackLeft              = 16,
    kAudioChannelLabel_TopBackCenter            = 17,
    kAudioChannelLabel_TopBackRight             = 18,
    
    kAudioChannelLabel_RearSurroundLeft         = 33,
    kAudioChannelLabel_RearSurroundRight        = 34,
    kAudioChannelLabel_LeftWide                 = 35,
    kAudioChannelLabel_RightWide                = 36,
    kAudioChannelLabel_LFE2                     = 37,
    kAudioChannelLabel_LeftTotal                = 38,           // matrix encoded 4 channels
    kAudioChannelLabel_RightTotal               = 39,           // matrix encoded 4 channels
    kAudioChannelLabel_HearingImpaired          = 40,
    kAudioChannelLabel_Narration                = 41,
    kAudioChannelLabel_Mono                     = 42,
    kAudioChannelLabel_DialogCentricMix         = 43,
    
    kAudioChannelLabel_CenterSurroundDirect     = 44,           // back center, non diffuse
    
    kAudioChannelLabel_Haptic                   = 45,
    
    // first order ambisonic channels
    kAudioChannelLabel_Ambisonic_W              = 200,
    kAudioChannelLabel_Ambisonic_X              = 201,
    kAudioChannelLabel_Ambisonic_Y              = 202,
    kAudioChannelLabel_Ambisonic_Z              = 203,
    
    // Mid/Side Recording
    kAudioChannelLabel_MS_Mid                   = 204,
    kAudioChannelLabel_MS_Side                  = 205,
    
    // X-Y Recording
    kAudioChannelLabel_XY_X                     = 206,
    kAudioChannelLabel_XY_Y                     = 207,
    
    // other
    kAudioChannelLabel_HeadphonesLeft           = 301,
    kAudioChannelLabel_HeadphonesRight          = 302,
    kAudioChannelLabel_ClickTrack               = 304,
    kAudioChannelLabel_ForeignLanguage          = 305,
    
    // generic discrete channel
    kAudioChannelLabel_Discrete                 = 400,
    
    // numbered discrete channel
    kAudioChannelLabel_Discrete_0               = (1U<<16) | 0,
    kAudioChannelLabel_Discrete_1               = (1U<<16) | 1,
    kAudioChannelLabel_Discrete_2               = (1U<<16) | 2,
    kAudioChannelLabel_Discrete_3               = (1U<<16) | 3,
    kAudioChannelLabel_Discrete_4               = (1U<<16) | 4,
    kAudioChannelLabel_Discrete_5               = (1U<<16) | 5,
    kAudioChannelLabel_Discrete_6               = (1U<<16) | 6,
    kAudioChannelLabel_Discrete_7               = (1U<<16) | 7,
    kAudioChannelLabel_Discrete_8               = (1U<<16) | 8,
    kAudioChannelLabel_Discrete_9               = (1U<<16) | 9,
    kAudioChannelLabel_Discrete_10              = (1U<<16) | 10,
    kAudioChannelLabel_Discrete_11              = (1U<<16) | 11,
    kAudioChannelLabel_Discrete_12              = (1U<<16) | 12,
    kAudioChannelLabel_Discrete_13              = (1U<<16) | 13,
    kAudioChannelLabel_Discrete_14              = (1U<<16) | 14,
    kAudioChannelLabel_Discrete_15              = (1U<<16) | 15,
    kAudioChannelLabel_Discrete_65535           = (1U<<16) | 65535
    */
}

void printAudioChannelDescription(AudioChannelDescription acd)
{
    NSLog(@"mChannelFlags value = %d",acd.mChannelFlags);
    printAudioChannelFlags(acd.mChannelFlags);
    NSLog(@"mChannelLabel value = %d",acd.mChannelLabel);
    printAudioChannelLabel(acd.mChannelLabel);
    NSLog(@"mCoordinates[0]:%f",acd.mCoordinates[0]);
    NSLog(@"mCoordinates[1]:%f",acd.mCoordinates[1]);
    NSLog(@"mCoordinates[2]:%f",acd.mCoordinates[2]);
}

void printAudioChannelBitmap(AudioChannelBitmap i)
{
    if(i == kAudioChannelBit_Left) {
        NSLog(@"kAudioChannelBit_Left");
    }
    if(i == kAudioChannelBit_Right) {
        NSLog(@"kAudioChannelBit_Right");
    }
    if(i == kAudioChannelBit_Center) {
        NSLog(@"kAudioChannelBit_Center");
    }
    /*
 kAudioChannelBit_LFEScreen                  = (1U<<3),
 kAudioChannelBit_LeftSurround               = (1U<<4),      // WAVE: "Back Left"
 kAudioChannelBit_RightSurround              = (1U<<5),      // WAVE: "Back Right"
 kAudioChannelBit_LeftCenter                 = (1U<<6),
 kAudioChannelBit_RightCenter                = (1U<<7),
 kAudioChannelBit_CenterSurround             = (1U<<8),      // WAVE: "Back Center"
 kAudioChannelBit_LeftSurroundDirect         = (1U<<9),      // WAVE: "Side Left"
 kAudioChannelBit_RightSurroundDirect        = (1U<<10),     // WAVE: "Side Right"
 kAudioChannelBit_TopCenterSurround          = (1U<<11),
 kAudioChannelBit_VerticalHeightLeft         = (1U<<12),     // WAVE: "Top Front Left"
 kAudioChannelBit_VerticalHeightCenter       = (1U<<13),     // WAVE: "Top Front Center"
 kAudioChannelBit_VerticalHeightRight        = (1U<<14),     // WAVE: "Top Front Right"
 kAudioChannelBit_TopBackLeft                = (1U<<15),
 kAudioChannelBit_TopBackCenter              = (1U<<16),
 kAudioChannelBit_TopBackRight               = (1U<<17)
*/
}



void printCMAudioFormatDescription(CMAudioFormatDescriptionRef fDesc)
{
    ////MediaType
    printMediaType(fDesc);
    ////MediaSubType
    printAudioFormat(CMFormatDescriptionGetMediaSubType(fDesc));
    ////----extensions
    CFDictionaryRef dict = CMFormatDescriptionGetExtensions(fDesc);
    printCFDictionaryRef(dict, CFDictionaryGetCount(dict));
    ////ChannelLayout
    size_t layoutSize = 0;
    const AudioChannelLayout *layout = CMAudioFormatDescriptionGetChannelLayout(fDesc, &layoutSize);
    AudioChannelLayout lo = (*layout);
    printAudioChannelLayoutTag(lo.mChannelLayoutTag);
    NSLog(@"mNumberChannelDescriptions:%d",lo.mNumberChannelDescriptions);
    for (int i = 0; i<lo.mNumberChannelDescriptions; i++) {
        NSLog(@"mChannelDescriptions[%d]",i);
        printAudioChannelDescription(lo.mChannelDescriptions[i]);
    }
    NSLog(@"lo.mChannelBitmap value:%d",lo.mChannelBitmap);
    printAudioChannelBitmap(lo.mChannelBitmap);
    
    
    
    CFStringRef layoutSimpleName = nil;
    UInt32 layoutSimpleNameSize = sizeof(layoutSimpleName);
    AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutSimpleName, (unsigned int)layoutSize, layout, &layoutSimpleNameSize, &layoutSimpleName);
    NSLog(@"layoutSimpleName:%@",layoutSimpleName);
    if (layoutSimpleName) {
        CFRelease(layoutSimpleName);
    }
    
    
    CFStringRef layoutName = nil;
    UInt32 layoutNameSize = sizeof(layoutName);
    AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutName, (unsigned int)layoutSize, layout, &layoutNameSize, &layoutName);
    NSLog(@"layoutName:%@",layoutName);
    if (layoutName) {
        CFRelease(layoutName);
    }
    
    
    
    CFStringRef layoutForBitmap = nil;
    UInt32 layoutForBitmapSize = sizeof(layoutForBitmap);
    AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutForBitmap, (unsigned int)layoutSize, layout, &layoutForBitmapSize, &layoutForBitmap);
    NSLog(@"layoutForBitmap:%@",layoutForBitmap);
    if (layoutForBitmap) {
        CFRelease(layoutForBitmap);
    }
    

    
    CFStringRef layoutForTag = nil;
    UInt32 layoutForTagSize = sizeof(layoutForTag);
    AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutForTag, (unsigned int)layoutSize, layout, &layoutForTagSize, &layoutForTag);
    NSLog(@"layoutForTag:%@",layoutForTag);
    if (layoutForTag) {
        CFRelease(layoutForTag);
    }
    
    
    CFStringRef layoutFromESDS = nil;
    UInt32 layoutFromESDSSize = sizeof(layoutFromESDS);
    AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutFromESDS, (unsigned int)layoutSize, layout, &layoutFromESDSSize, &layoutFromESDS);
    NSLog(@"layoutFromESDS:%@",layoutFromESDS);
    if (layoutFromESDS) {
        CFRelease(layoutFromESDS);
    }
    
    
    CFStringRef layoutHash = nil;
    UInt32 layoutHashSize = sizeof(layoutHash);
    AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutHash, (unsigned int)layoutSize, layout, &layoutHashSize, &layoutHash);
    NSLog(@"layoutHash:%@",layoutHash);
    if (layoutHash) {
        CFRelease(layoutHash);
    }
    

    
    
    ////
    
    ////formatList
    size_t formatListSize = 0;
    const AudioFormatListItem *formatList = CMAudioFormatDescriptionGetFormatList(fDesc, &formatListSize);
    {
        AudioFormatListItem fl = (*formatList);
        AudioStreamBasicDescription mASBD = fl.mASBD;
        AudioChannelLayoutTag mChannelLayoutTag =  fl.mChannelLayoutTag;
        printAudioStreamBasicDescription(mASBD);
        printAudioChannelLayoutTag(mChannelLayoutTag);
    }

    
    
    ////streamBasicDescription
    const AudioStreamBasicDescription *streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(fDesc);
    printAudioStreamBasicDescription(*streamBasicDescription);
    
    
    ////richestDecodable
    const AudioFormatListItem *richestDecodable = CMAudioFormatDescriptionGetRichestDecodableFormat(fDesc);
    {
        AudioFormatListItem rd = (*richestDecodable);
        AudioStreamBasicDescription mASBD = rd.mASBD;
        AudioChannelLayoutTag mChannelLayoutTag =  rd.mChannelLayoutTag;
        printAudioStreamBasicDescription(mASBD);
        printAudioChannelLayoutTag(mChannelLayoutTag);
    }
    
    ////mostCompatible
    const AudioFormatListItem *mostCompatible = CMAudioFormatDescriptionGetMostCompatibleFormat(fDesc);
    {
        AudioFormatListItem mc = (*mostCompatible);
        AudioStreamBasicDescription mASBD = mc.mASBD;
        AudioChannelLayoutTag mChannelLayoutTag =  mc.mChannelLayoutTag;
        printAudioStreamBasicDescription(mASBD);
        printAudioChannelLayoutTag(mChannelLayoutTag);
    }

    ////magicCookie
    size_t magicCookieSize = 0;
    const void * magicCookie = CMAudioFormatDescriptionGetMagicCookie(fDesc, &magicCookieSize);
    NSLog(@"magicCookie:%@",[NSData dataWithBytes:magicCookie length:magicCookieSize]);
    
    
    ////kAudioFormatProperty_AvailableEncodeBitRates
    
}


NSMutableDictionary * getAudioWriterInputOutputSettingsFromCMAudioFormatDescription(CMAudioFormatDescriptionRef fDesc,int defaultBitDepth)
{
    
    size_t layoutSize = 0;
    const AudioChannelLayout *layout = CMAudioFormatDescriptionGetChannelLayout(fDesc, &layoutSize);
    AudioChannelLayout audioChannelLayout = (*layout);
    // Convert the channel layout object to an NSData object.
    NSData *channelLayoutAsData = [NSData dataWithBytes:&audioChannelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
    
    
    
    
    size_t formatListSize = 0;
    const AudioFormatListItem *formatList = CMAudioFormatDescriptionGetFormatList(fDesc, &formatListSize);
    AudioFormatListItem fl = (*formatList);
    AudioStreamBasicDescription mASBD = fl.mASBD;
   
    uint32_t sampleRate = mASBD.mSampleRate;
    uint16_t bitDepth = mASBD.mBitsPerChannel == 0 ? defaultBitDepth : mASBD.mBitsPerChannel;
    uint16_t channels = mASBD.mChannelsPerFrame;
    uint32_t byteRate = bitDepth * sampleRate * channels / 8;

    
    
    

    NSMutableDictionary *audioWriterInputOutputSettings = [NSMutableDictionary dictionaryWithDictionary:
                                                           [NSDictionary dictionaryWithObjectsAndKeys:
                                                            [NSNumber numberWithInt: mASBD.mFormatID], AVFormatIDKey,
                                                            [NSNumber numberWithFloat:mASBD.mSampleRate], AVSampleRateKey,
                                                            [NSNumber numberWithInt:mASBD.mChannelsPerFrame], AVNumberOfChannelsKey,
                                                            [NSNumber numberWithInt:byteRate], AVEncoderBitRateKey,
                                                            channelLayoutAsData, AVChannelLayoutKey,
                                                            nil]] ;

    return(audioWriterInputOutputSettings);
    
}

NSMutableDictionary * getAudioReaderOutputSettingsFromCMAudioFormatDescription(CMAudioFormatDescriptionRef fDesc,int defaultBitDepth)
{

    size_t formatListSize = 0;
    const AudioFormatListItem *formatList = CMAudioFormatDescriptionGetFormatList(fDesc, &formatListSize);
    AudioFormatListItem fl = (*formatList);
    AudioStreamBasicDescription mASBD = fl.mASBD;
    
    uint16_t bitDepth = mASBD.mBitsPerChannel == 0 ? defaultBitDepth : mASBD.mBitsPerChannel;
    uint16_t channels = mASBD.mChannelsPerFrame;

    NSMutableDictionary *audioReaderOutputSettings = [NSMutableDictionary dictionaryWithDictionary:
                                                        [NSDictionary  dictionaryWithObjectsAndKeys:
                                                            [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                                            [NSNumber numberWithFloat:mASBD.mSampleRate], AVSampleRateKey,
                                                            [NSNumber numberWithInt:bitDepth], AVLinearPCMBitDepthKey,
                                                            [NSNumber numberWithInt:channels], AVNumberOfChannelsKey,
                                                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                                            [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                                            [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                                            nil]] ;
    
    return(audioReaderOutputSettings);
    
}

NSMutableDictionary * creatMonoAudioWriterInputOutputSettingsFromCMAudioFormatDescription(CMAudioFormatDescriptionRef fDesc,int defaultBitDepth)
{
    
    AudioChannelLayout audioChannelLayout = {
        .mChannelBitmap = 0,
        .mChannelLayoutTag = kAudioChannelLayoutTag_Mono,
        .mNumberChannelDescriptions = 0
    };
    // Convert the channel layout object to an NSData object.
    NSData *channelLayoutAsData = [NSData dataWithBytes:&audioChannelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
    
    
    
    
    size_t formatListSize = 0;
    const AudioFormatListItem *formatList = CMAudioFormatDescriptionGetFormatList(fDesc, &formatListSize);
    AudioFormatListItem fl = (*formatList);
    AudioStreamBasicDescription mASBD = fl.mASBD;
    
    uint32_t sampleRate = mASBD.mSampleRate;
    uint16_t bitDepth = mASBD.mBitsPerChannel == 0 ? defaultBitDepth : mASBD.mBitsPerChannel;
    ////因为要变单轨道
    uint32_t byteRate = bitDepth * sampleRate / 8;

    NSMutableDictionary *audioWriterInputOutputSettings = [NSMutableDictionary dictionaryWithDictionary:
                                                           [NSDictionary dictionaryWithObjectsAndKeys:
                                                            [NSNumber numberWithInt: mASBD.mFormatID], AVFormatIDKey,
                                                            [NSNumber numberWithFloat:mASBD.mSampleRate], AVSampleRateKey,
                                                            [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                                            [NSNumber numberWithInt:byteRate], AVEncoderBitRateKey,
                                                            channelLayoutAsData, AVChannelLayoutKey,
                                                            nil]] ;
    
    return(audioWriterInputOutputSettings);
    
}

void printAudioBufferList(AudioBufferList bufferList)
{
    NSLog(@"bufferList.mNumberBuffers:%u",(unsigned int)bufferList.mNumberBuffers);
    for(UInt32 bufferIndex = 0; bufferIndex < bufferList.mNumberBuffers; ++bufferIndex) {
        NSLog(@"mBuffers[%d].mDataByteSize:%d",bufferIndex,bufferList.mBuffers[bufferIndex].mDataByteSize);
        NSLog(@"mBuffers[%d].mNumberChannels:%d",bufferIndex,bufferList.mBuffers[bufferIndex].mNumberChannels);
        
        /*
        for (int y=0; y<bufferList.mNumberBuffers; y++) {
            NSMutableData * bufferMono = [NSMutableData new];
            AudioBuffer audioBuffer = bufferList.mBuffers[y];
            [bufferMono appendBytes:audioBuffer.mData length:audioBuffer.mDataByteSize];
            NSLog(@"mBuffers[%d].mNumberChannels:%@",bufferIndex,bufferMono);
            bufferMono = NULL;
        }
        */
        
    }
}

AudioBufferList * allocateNewAudioBufferList(UInt32 mNumberBuffers,UInt32 mNumberChannels, UInt32 bitDepth, bool interleaved,UInt32 framesNumber)
{
    ////channels存到frame frame存到buffer(frames,这里的buffer就是frames),
    ////UInt32 mNumberBuffers: 包含几个mBuffer(AudioBuffer)
    ////UInt32 mNumberChannels:每个mBuffer(AudioBuffer)包含几个channel
    ////UInt32 bitDepth 每个channel 占多少位
    ////UInt32 framesNumber 是每个sampleBuffer里面有多少sample CMSampleBufferGetNumSamples(sampleBuffer)
    ////
    AudioBufferList * bufferList = NULL;
    if (mNumberBuffers == 0) {
        mNumberBuffers = interleaved ? 1 : mNumberChannels;
        ////如果不指定mNumberBuffers
        ////默认情况，如果是interleave,那么所有channel 都用一个mBuffer(AudioBuffer)
        ////如果不是interleave,那么每个channel用一个mBuffer(AudioBuffer)
    }
    UInt32 channelsPerBuffer = interleaved ? mNumberChannels : 1;
    UInt32 bytesPerChannel = bitDepth / 8;
    UInt32 bytesPerFrame = bytesPerChannel * channelsPerBuffer;
    
    ////分配好bufferList
    bufferList = (AudioBufferList *)(calloc(1, offsetof(AudioBufferList, mBuffers) + (sizeof(AudioBuffer) * mNumberBuffers)));
    bufferList->mNumberBuffers = mNumberBuffers;
    ////分配每个mBuffer(AudioBuffer)成员
    for(UInt32 bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; ++bufferIndex) {
        bufferList->mBuffers[bufferIndex].mData = (void *)(calloc(framesNumber, bytesPerFrame));
        bufferList->mBuffers[bufferIndex].mDataByteSize = bytesPerFrame * framesNumber;
        bufferList->mBuffers[bufferIndex].mNumberChannels = channelsPerBuffer;
    }
    
    
    return(bufferList);
}

void freeAudioBufferList(AudioBufferList * bufferList)
{
    for(UInt32 bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; ++bufferIndex) {
        free(bufferList->mBuffers[bufferIndex].mData);
    }
    free(bufferList);
    
}


CMFormatDescriptionRef creatMonoAudioFormatDescFromOrigLinePCMSampleBuffer(CMSampleBufferRef sampleBuffer,int bitDepth)
{
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    size_t formatListSize = 0;
    const AudioFormatListItem *formatList = CMAudioFormatDescriptionGetFormatList(formatDesc, &formatListSize);
    AudioFormatListItem fl = (*formatList);
    AudioStreamBasicDescription mASBD = fl.mASBD;
    // Create a CMSampleBufferRef from the list of samples, which we'll own
    AudioStreamBasicDescription monoStreamFormat;
    memset(&monoStreamFormat, 0, sizeof(monoStreamFormat));
    monoStreamFormat.mSampleRate = mASBD.mSampleRate;
    monoStreamFormat.mFormatID = mASBD.mFormatID;
    monoStreamFormat.mFormatFlags = mASBD.mFormatFlags;
    monoStreamFormat.mBytesPerPacket = bitDepth/8;
    monoStreamFormat.mFramesPerPacket = 1;
    monoStreamFormat.mBytesPerFrame = bitDepth/8;
    monoStreamFormat.mChannelsPerFrame = 1;
    monoStreamFormat.mBitsPerChannel = bitDepth;
    CMFormatDescriptionRef format = NULL;
    formatDesc = NULL;
    OSStatus status = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &monoStreamFormat, 0, NULL, 0, NULL, NULL, &format);
    if (status != noErr) {
        // really shouldn't happen
        CFRelease(format);
        format = NULL;
        return(NULL);
    }
    return(format);
}

@end