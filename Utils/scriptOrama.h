//
//  scriptOrama.h
//  UView
//
//  Created by dli on 1/27/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#ifndef scriptOrama_h
#define scriptOrama_h


#endif /* scriptOrama_h */
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "AVUser.h"

////==========
////某些结构不能存在NSMutableArray / NSMutableDictionary中
////例如CGPoint
////此时存入 [NSValue valueWithCGPoint:(CGPoint)]
////读出    [(NSMutableArray[i]) CGPointValue]
////==========

////==========
////NS2LC:  xcode  to leancloud parser
////LC2NS:  leancloud to xcode parser
////NS2JS:  xcode to json parser
////JS2NS:  json to xcode parser
////JS2LC:  json to leancloud parser
////LC2JS:  leancloud to json parser
////refer_1: http://www.raywenderlich.com/5492/working-with-json-in-ios-5
////==========


////====================================================================================
//每个包含overlay的结构都使用
@interface videoOverlay : NSObject
@property BOOL exist;//是否使用overlay
@property NSURL* URL;//已经在沙盒中的URL
                     //json配置中URL是用字符串格式存储的，所以此处需要
                     //在NS2JS, JS2NS两个parser中转换
@property NSString * type;//取值 image  or  GIF  or video
@property NSNumber * startTime;//overlay开始的时间,单位秒，在NS2JS, JS2NS两个parser中转换
@property NSNumber * duration;//overlay持续时间，单位秒，在NS2JS, JS2NS两个parser中转换
//下面这两个参数指示时间temporal维度的填充 和截取 方法
@property NSString * timeFillingMode; //取值 当前只有repeat
@property NSString * timeTrimingMode; //取值 当前只有 tailTrim
/*
 1. 当videooverlayType 为 image 时 , image 在 videoOverlayStartTime 开始出现 ，持续显示videoOverlayDuration
 2. 当videooverlayType 为 GIF/video 时 , image 在 videoOverlayStartTime 开始出现
 假如持续显示videoOverlayDuration 大于 GIF/video 本身时长，则会根据videoOverlayTimeFillingMode扩充至整个videoOverlayDuration
 假如持续显示videoOverlayDuration 小于 GIF/video 本身时长，则会根据videoOverlayTimeTrimmingMode截取至个videoOverlayDuration
 */
//处理完时间维度的 填充或截取后，调整size
@property CGSize size;//在NS2JS, JS2NS两个parser中转换

//下面这两个参数指示空间spatial维度的填充 和 动画化移动 方法
@property NSMutableArray * movingPath; // 数组中的元素是[NSValue valueWithCGPoint:<#(CGPoint)#>], 整个轨迹是多条直线链接成的折线，数组中的元素表示每个折点
                                       // 数组中的元素在NS2JS, JS2NS两个parser中转换
@property NSMutableArray * movingSectionDurations; // 数组中的元素是NSNumber 单位是秒, 整个轨迹是多条直线链接成的折线，数组中的元素表示每个折点
                                                //数组个数比videoOverlayMovingPath 少1，表示从对应折点到下一个折点 动画移动所需要的时间
                                                   // 数组中的元素在NS2JS, JS2NS两个parser中转换
@property NSString * blendMode;//当前仅有normal

@end

//corresponding JS
/*
 overlay = {
 'URL': 'file:///sandbox/...',
 'timeFillingMode': 'repeat',
 'movingPath': [{'y': 0.0,'x': 0.0}, {'y': 100.0,'x': 100.0}, {'y': 0.0,'x': 200.0}, {'y': 100.0,'x': 100.0}, {'y': 1000.0,'x': 1000.0}],
 'movingSectionDurations': [0.5, 0.3, 0.5, 0.6],
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'blendMode': 'normal',
 'startTime': 1.85,
 'duration': 6.0,
 'type': 'image',
 'size': {'width': 1920,'height': 720}
 }
*/

////====================================================================================



////====================================================================================
//singleVideoMaterialRenderInfo 是针对单个素材的,客户选取的每段素材video
//都会应用自己的singleVideoMaterialRenderInfo
@interface singleVideoMaterialRenderInfo : NSObject
@property AVUser * owner;//info of leancloud storage：在NS2JS, JS2NS两个parser中转换
@property NSURL* URL;//已经在沙盒中的URL
//下面这两个参数同样作用于Audio截取
//这两个数值发生在选取视频singleVideoMaterial片段之后
//因为选取视频片段并不发生真正的截取，只是标注时间点
//这两个数值时选取动作的函数传过来的结果，仅仅内部使用
//所以保留xcode AVFoundation 便于使用的CMT格式
@property CMTime startTime;//针对单个素材video开始的时间,在NS2JS, JS2NS两个parser中转换，在AVFoundation中使用时要转换为CMTime 格式
@property CMTimeRange duration;//针对单个素材video持续时间，在NS2JS, JS2NS两个parser中转换，在AVFoundation中使用时要转换为CMTimeRange 格式
@property NSString * filter;//当前取值 仅有beauty

@property CGPoint cropPositionOnOriginalMaterial;//
@property CGSize cropSize;//

@property videoOverlay * videoOverlay;//overlay
@property CGSize postRenderSize;//当前固定为1280 * 720,处理完overlay等singleVideoMaterialRenderInfo中的效果后需要调整到的大小

//保存之前合需要并截取后的Audio
@property NSURL * postRenderTempSavingURL;//根据针对单个素材video的singleVideoMaterialRenderInfo
                                                   //处理完针对单个素材video 要在沙盒中缓存一个中间视频
                                                   //此时videoURL处的沙盒视频可以删除了
@end


/*correponding JS
AVUser = {
 'localData': {
 'avatarUri': 'http://ac-VBYKw7su.clouddn.com/1aed999f83baa02f.png',
 'emailVerified': 0,
 'sex': '\\U4fdd\\U5bc6',
 'signature': '\\U6211\\U597d\\U50cf\\U5fd8\\U5199\\U7b7e\\U540d\\U4e86....',
 'petName': 'dli',
 'geo': '\\U5317\\U4eac'
 },
 'relationData': {},
 'estimatedData': {}
 }

CMTime = {
 'value': 4900,
 'epoch': '',
 'flag': '',
 'timescale': 600
 }

CMTimeRange = {
 'duration': {
 'value': 4900,
 'epoch': '',
 'flag': '',
 'timescale': 600
 },
 'start': {
 'value': 9000,
 'epoch': '',
 'flag': '',
 'timescale': 600
 }
 }
 
 
singleVideoMaterialRenderInfo = {
 'postRenderTempSavingURL': 'file:///sandbox/2/...',
 'URL': 'file:///sandbox/...',
 'filter': 'beauty',
 'duration': {
 'duration': {
 'epoch': '',
 'timescale': 600,
 'flag': '',
 'value': 4900
 },
 'start': {
 'epoch': '',
 'timescale': 600,
 'flag': '',
 'value': 9000
 }
 },
 'startTime': {
 'value': 4900,
 'epoch': '',
 'flag': '',
 'timescale': 600
 },
 'videoOverlay': {
 'timeFillingMode': 'repeat',
 'movingPath': [{
 'y': 0.0,
 'x': 0.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 0.0,
 'x': 200.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 1000.0,
 'x': 1000.0
 }],
 'URL': 'http://www.leancloud.cn',
 'movingSectionDurations': [0.5, 0.3, 0.5, 0.6],
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'blendMode': 'normal',
 'startTime': 1.85,
 'duration': 6.0,
 'type': 'image',
 'size': {
 'width': 1920,
 'height': 720
 }
 },
 'owner': {
 'localData': {
 'avatarUri': 'http://ac-VBYKw7su.clouddn.com/1aed999f83baa02f.png',
 'emailVerified': 0,
 'sex': '\\U4fdd\\U5bc6',
 'signature': '\\U6211\\U597d\\U50cf\\U5fd8\\U5199\\U7b7e\\U540d\\U4e86....',
 'petName': 'dli',
 'geo': '\\U5317\\U4eac'
 },
 'relationData': {},
 'estimatedData': {}
 },
 'postRenderSize': {
 'width': 1280,
 'height': 720
 },
 
 'cropPositionOnOriginalMaterial': {
 'y': 50.0,
 'x': 50.0
 },
 'cropSize': {
 'width': 500.0,
 'height': 400.0
 }
 
 }
 */
////====================================================================================





////====================================================================================
//用于interleaveMode的参数
@interface interleaveModeParameters : NSObject
@property NSString * mode; // @"mode"  值为NSString 可取值 sequential(按照素材顺序interleave片段)
                           //                             random(随机生成每一轮的顺序)
@property NSNumber * interval;  // @"interval"  slice片段的持续时间
@end
/* correspoding JS
 {
 'interval': 0.2,
 'mode': 'sequential'
 }
 */
////====================================================================================


////====================================================================================
//处理完每段视频各自的singleVideoMaterialRenderInfo 之后进入sceneMaterialsUnifiedRender
@interface sceneMaterialsUnifiedRender : NSObject
@property NSString * editMode;//当前取值为manual或auto
@property NSNumber * duration;//如果是手动manual模式，这个参数用于视频选取步骤，视频选取发生在videoRenderInfo之前，如果所有素材duration之和大于此数值，那么选取失败
                                    //如果是自动auto模式，这个参数会被传给auto处理的函数
@property NSString * compositionMode;//当前取值为concat或interleave或merge
@property interleaveModeParameters * interleaveModeParameters;
@property NSMutableArray * transitionModes;//singleVideoMaterial 之间的转场模式  数组成员为NSString
                                                                //当前仅取值为normal,没有转场效果
@property NSMutableArray * transitionSectionDurations;//singleVideoMaterial 之间的转场持续时长  数组成员NSNumber 单位是秒
@end
/*coressponding JS

sceneMaterialsUnifiedRender = {
 'editMode': 'manual',
 'compositionMode': 'concat',
 'transitionModes': ['normal', 'fadeIn', 'rotate'],
 'transitionSectionDurations': [0.5, 0.3, 1.0],
 'interleaveModeParameters': {
 'interval': 0.2,
 'mode': 'sequential'
 },
 'duration': 30.0
 }
*/
////====================================================================================


////=====
////上述所有与time range duration想关处理
////声音都会做相应处理
////concat 声音会concat
////merge 声音会mix
////interleave声音会interleave
////但是 volume  frequence 等声音特有属性不会变化
////=====




////===================================================================================
//处理完sceneMaterialsUnifiedRender 操作后 加滤镜sceneFilterPostUnifiedRender
@interface sceneFilterPostUnifiedRender : NSObject
@property BOOL exist;
@property NSString * name;
//开始应用滤镜sceneFilterPostUnifiedRender的时间
//和滤镜sceneFilterPostUnifiedRender持续时间
//参照物是UnifiedRender 处理后Video 时间
@property NSNumber * startTime;
@property NSNumber * duration;
@end
/*coressponding JS
sceneFilterPostUnifiedRender = {
 'duration': 40.0,
 'statTime': 2.0,
 'exist': True,
 'name': 'Amaro'
 }
 */
////===================================================================================


////====================================================================================
//然后会给处理完sceneMaterialsUnifiedRender 操作后 加完滤镜sceneFilterPostUnifiedRender
//添加 sceneOverlayPostUnifiedFilter
////====================================================================================


////
@interface colorDescDict :NSObject
@property NSNumber * R;
@property NSNumber * G;
@property NSNumber * B;
@property NSNumber * A;
@end
/* corresponding JS

colorDescDict = {
 'B': 100.0, 
 'R': 200.0, 
 'G': 200.0
}
*/
////


////===================================
@interface lowerThirdTemplate : NSObject
@property CGSize size;//全部文字整体所在Rect Size
@property NSString * fontFamily;
@property colorDescDict * fontColor;
@property NSNumber * fontSize;
@property NSURL * backgroundImageURL;//内置图片在沙盒中的URL
@end
/*corresponding JS
lowerThirdTemplate = {
 'fontColor': {
 'B': 100.0,
 'R': 200.0,
 'G': 200.0
 },
 'fontFamily': 'Times New Roman',
 'fontSize': 16.0,
 'backgroundImageURL': 'file:///sandbox_3/...',
 'size': {
 'width': 200.0,
 'height': 100.0
 }
 }
 */
////===================================


////====================================================================================
//然后会给处理完sceneMaterialsUnifiedRender-->sceneFilterPostUnifiedRender
//--->sceneOverlay, 添加sceneLowerThirdPostUnifiedOverlay(下三分之一处用户ID)
@interface sceneLowerThirdPostUnifiedOverlay : NSObject
@property BOOL exist;
@property CGPoint position;//位置坐标针对UnifiedVideo的
//开始应用sceneLowerThirdPostUnifiedOverlay的时间  和sceneLowerThirdPostUnifiedOverlay持续时间
@property NSNumber * startTime;
@property NSNumber *  duration;
@property lowerThirdTemplate * lowerThirdTemplate;
@property NSString * petName; // 格式为@ + AVUser.petName
@end
/* corresponding JS
 sceneLowerThirdPostUnifiedOverlay = {
 
 'lowerThirdTemplate': {
 'fontColor': {
 'B': 100.0,
 'R': 200.0,
 'G': 200.0
 },
 'fontFamily': 'Times New Roman',
 'fontSize': 16.0,
 'backgroundImageURL': 'file:///sandbox_3/...',
 'size': {
 'width': 200.0,
 'height': 100.0
 }
 },
 'exist': True,
 'startTime': 0.0,
 'petName': 'dli',
 'duration': 5.0,
 'position': {
 'y': 200.0,
 'x': 200.0
 }
 }
 */
////====================================================================================


////====================================================================================
//处理完sceneLowerThirdPostUnifiedOverlay 操作后调整几何参数
@interface sceneGeomTransformPostUnifiedLowerThird : NSObject
@property CGSize size;
@property CGPoint positionOnbackground;//位置参数针对于sceneBackground画布的(parent CALayer size == sceneBackgroundSize)
@property CGPoint anchorOnSelf;//位置参数针对于scenePostMaterialsRenderVideo自己的, 2D旋转时候的圆心位置
                               //因为此处旋转是绕自身，为了方便处理 参照物是postUnifiedVideo
@property NSNumber * rotationDegree;
@end
/* corresponding JS
 sceneGeomTransformPostUnifiedLowerThird = {
 'rotationDegree': 180.0,
 'anchorOnSelf': {
 'y': 60.0,
 'x': 60.0
 },
 'positionOnBackground': {
 'y': 60.0,
 'x': 60.0
 },
 'size': {
 'width': 1280.0,
 'height': 720.0
 }
 }
 */
////====================================================================================




////===========================================
//sceneTextOverBackGround
@interface sceneTextOverBackground : NSObject
@property BOOL exist;
@property NSString * content;
@property NSString * fontFamily;
@property colorDescDict * color;
@property NSNumber * fontSize;
@property CGPoint positionOnBackground;//位置坐标针对sceneBackground的
@property CGSize size;//全部文字整体所在Rect Size
//开始应用sceneTextOverBackground的时间  和sceneTextOverBackground持续时间
@property NSString * showStage;//取值可以是before (sceneVideoPostUnifiedLowerThird) 或者 after (sceneVideoPostUnifiedLowerThird)
@property NSNumber * duration;
@property CMTime startTime;//根据sceneTextOverBackgroundShowStage算出
                           //如果before kCMTimeZero
                           //如果after CMTimeAdd(sceneVideoPostUnifiedLowerThirdDuration,sceneTextOverBackgroundDuration)
                           //程序内部使用
@property NSString * animationMode;//取值可以是typing(逐字显现),normal(全部同时显示)，fadeIn, fadeOut, fadeInfadeOut
@end
/*
corresponding JS
sceneTextOverBackground = {
 'positionOnBackground': {
 'y': 250.0,
 'x': 178.0
 },
 'color': {
 'B': 100.0,
 'R': 200.0,
 'G': 200.0
 },
 'animationMode': 'typing',
 'content': 'ok ok ok',
 'fontFamily': 'Times New Roman',
 'showStage': 'before',
 'fontSize': 14.0,
 'startTime': {
 'epoch': '',
 'timescale': 600,
 'flag': '',
 'value': 0
 },
 'duration': '3.0',
 'exist': True,
 'size': {
 'width': 100.0,
 'height': 100.0
 }
 }
 */
////============================================


////====================================================================================
//sceneBackground
//parent CALayer size == sceneBackgroundSize
//先在parent CALayer 上放上sceneBackground
@interface sceneBackground : NSObject
@property CGSize size;//接下来的操作画布大小就是sceneBackgroundSize
@property NSURL * URL;//已经在沙盒中的URL

//保存之前合并unified后的Audio
@property NSURL * postBackgroundIntergrationTempSavingURL;//将scenetextOverbackground 和 sceneGeomPostUnifiedLowerThirdVideo
                                           //放到sceneBackground之后的中间缓存视频
@end

/* corresponding JS
 sceneBackground = {
 'URL': 'file:///sandbox/4/...',
 'postBackgroundIntergrationTempSavingURL': 'file:///sandbox/5/...',
 'size': {
 'width': 1280.0,
 'height': 720.0
 }
 }
*/
////====================================================================================







////====================
@interface sceneMusicPostBackgroundIntergration :NSObject
@property BOOL exist;
@property NSURL * URL;//已经在沙盒中的URL
//开始应用sceneMusicPostBackgroundIntergration的时间  和sceneMusicPostBackgroundIntergration持续时间
//相对于scenePostBackgroundIntergrationVideo 来说的
@property NSNumber * startTime;
@property NSNumber * duration;
//下面这两个参数指示时间temporal维度的填充 和截取 方法
@property NSString * timeFillingMode; //取值 当前只有repeat
@property NSString * timeTrimingMode; //取值 当前只有 tailTrim
/*

 假如音频文件 大于 sceneMusicPostBackgroundIntergrationDuration 本身时长，则会根据timeFillingMode扩充至整个sceneMusicPostBackgroundIntergrationDuration
 假如音频文件 小于 sceneMusicPostBackgroundIntergrationDuration 本身时长，则会根据timeTrimmingMode截取至个sceneMusicPostBackgroundIntergrationDuration
 */
@property NSNumber * volumeRatio;//1- 100, 意思是1% － 100%
@property NSNumber * volumeSumWithOriginalVolume;  //音量上限，绝对值  sceneMusicVolume + originalVolume
@property NSNumber * animationDuration;
@property NSString * animationMode;//fadeIn fadeOut fadeInfadeOut
@property NSString * mixMode;//指原声和sceneMusic的混合模式
                             //originalOnly :保留原声
                             //sceneMusicOnly:
                             // mix:
@end
/*
 sceneMusicPostBackgroundIntergration = {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/6/...',
 'animationMode': 'fadeIn',
 'timeTrimingMode': 'tailTrim',
 'volumeRatio': 80.0,
 'mixMode': 'sceneMusicOnly',
 'exist': True,
 'startTime': 10.0,
 'animationDuration': 25.0,
 'duration': 30.0,
 'volumeSumWithOriginalVolume': 200.0
 }
 */
////====================


////==============================================
@interface titles : NSObject
@property BOOL exist;//是否使用titles片头
@property NSURL * URL;//已经在沙盒中的URL
@property NSString * type;//当前取值  image GIF video
@property NSNumber * duration;//titles持续时间，单位秒
//下面这两个参数指示时间temporal维度的填充 和截取 方法
@property NSString * timeFillingMode; //取值 当前只有repeat
@property NSString * timeTrimingMode; //取值 当前只有 tailTrim
/*
 1. 当titlesType 为 image 时 , image 在 titlesStartTime 开始出现 ，持续显示titlesDuration
 2. 当titlesType 为 GIF/video 时 , image 在 titlesStartTime 开始出现
 假如持续显示titlesDuration 大于 GIF/video 本身时长，则会根据titlesTimeFillingMode扩充至整个titlesDuration
 假如持续显示titlesDuration 小于 GIF/video 本身时长，则会根据titlesTimeTrimmingMode截取至个titlesDuration
 */
@property CGSize postDurationRegulationSize;//当前固定为1280 * 720,调整完duration后需要调整到的大小，调整到和sceneBackGroundSize一致
@end

/*corresponding JS
 titles = {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/7/....',
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'postDurationRegulationSize': {
 'width': 1280.0,
 'height': 720.0
 },
 'duration': 10.0,
 'type': 'image'
 }
 */
////=====================================================


////===
@interface tailTemplate : NSObject
@end
/*
tailTemplate = {}
 */
////===


////===========================================
@interface tail : NSObject
@property BOOL exist;//是否使用tail片尾
@property tailTemplate * tailTemplate; //当前不支持, normal 提取所有参与者AVUser.petName
@property NSString * mode;//当前取值  manual  auto， 当前不支持auto
                              //如果是auto ,会读区tailTemplate中的参数自动生成，当前不支持
                             //如果是manual 读取后面的参数
@property NSURL * URL;//已经在沙盒中的URL
@property NSString * type;//当前取值  image GIF video
@property NSNumber * duration;//tail持续时间，单位秒
//下面这两个参数指示时间temporal维度的填充 和截取 方法
@property NSString * timeFillingMode; //取值 当前只有repeat
@property NSString * timeTrimingMode; //取值 当前只有 tailTrim
/*
 1. 当tailType 为 image 时 , image 在 tailStartTime 开始出现 ，持续显示tailDuration
 2. 当tailType 为 GIF/video 时 , image 在 tailStartTime 开始出现
 假如持续显示tailDuration 大于 GIF/video 本身时长，则会根据tailTimeFillingMode扩充至整个tailDuration
 假如持续显示tailDuration 小于 GIF/video 本身时长，则会根据tailTimeTrimmingMode截取至个tailDuration
 */
@property CGSize postDurationRegulatioSize;//当前固定为1280 * 720,调整完duration后需要调整到的大小，调整到和sceneBackGroundSize一致
@end
/*
 tail = {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/8/...',
 'timeTrimingMode': 'tailTrim',
 'postDurationRegulatioSize': {
 'width': 1280.0,
 'height': 720.0
 },
 'tailTemplate': {},
 'exist': True,
 'mode': 'manual',
 'duration': 5.0,
 'type': 'video'
 }
*/
////===========================================



////===============
////合并titles+ unifiedVideoPostBackgroundIntergration + tail
////           sceneMusicPostBackgroundIntergration
////===============

@interface finalOutputOverallRenderSettings :NSObject
@property CGSize size;//最终输出video的大小
@property NSNumber * averageBitRateForCompressing;//传递给VT压缩的参数，H.264再次压缩后的码率
@end
/* corresponding JS
 finalOutputOverallRenderSettings = {
 'averageBitRateForCompressing': 1024000.0,
 'size': {
 'width': 1920.0,
 'height': 1080.0
 }
 }
 */
////===========


@interface scene: NSObject
@property NSString * name;
@property sceneMaterialsUnifiedRender * sceneMaterialsUnifiedRender;
@property sceneFilterPostUnifiedRender * sceneFilterPostUnifiedRender;
@property videoOverlay * sceneOverlayPostUnifiedFilter;
@property sceneLowerThirdPostUnifiedOverlay * sceneLowerThirdPostUnifiedOverlay;
@property sceneGeomTransformPostUnifiedLowerThird * sceneGeomTransformPostUnifiedLowerThird;
@property sceneTextOverBackground * sceneTextOverBackground;
@property sceneBackground * sceneBackground;
@property sceneMusicPostBackgroundIntergration * sceneMusicPostBackgroundIntergration;
@property titles * titles;
@property tail * tail;
@property finalOutputOverallRenderSettings * finalOutputOverallRenderSettings;
@end
/* corresponding JS
 scene = {
 'finalOutputOverallRenderSettings': {
 'averageBitRateForCompressing': 1024000.0,
 'size': {
 'width': 1920.0,
 'height': 1080.0
 }
 },
 'titles': {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/7/....',
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'postDurationRegulationSize': {
 'width': 1280.0,
 'height': 720.0
 },
 'duration': 10.0,
 'type': 'image'
 },
 'name': 'zephyr',
 'sceneTextOverBackground': {
 'color': {
 'R': 200.0,
 'B': 100.0,
 'G': 200.0
 },
 'animationMode': 'typing',
 'fontFamily': 'Times New Roman',
 'exist': True,
 'startTime': {
 'value': 0,
 'epoch': '',
 'flag': '',
 'timescale': 600
 },
 'duration': '3.0',
 'size': {
 'width': 100.0,
 'height': 100.0
 },
 'positionOnBackground': {
 'y': 250.0,
 'x': 178.0
 },
 'content': 'ok ok ok',
 'showStage': 'before',
 'fontSize': 14.0
 },
 'sceneGeomTransformPostUnifiedLowerThird': {
 'rotationDegree': 180.0,
 'anchorOnSelf': {
 'y': 60.0,
 'x': 60.0
 },
 
 
 
 'positionOnBackground': {
 'y': 60.0,
 'x': 60.0
 },
 'size': {
 'width': 1280.0,
 'height': 720.0
 }
 },
 'tail': {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/8/...',
 'timeTrimingMode': 'tailTrim',
 'postDurationRegulatioSize': {
 'width': 1280.0,
 'height': 720.0
 },
 'tailTemplate': {},
 'exist': True,
 'mode': 'manual',
 'duration': 5.0,
 'type': 'video'
 },
 'sceneMusicPostBackgroundIntergration': {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/6/...',
 'animationMode': 'fadeIn',
 'timeTrimingMode': 'tailTrim',
 'volumeRatio': 80.0,
 'mixMode': 'sceneMusicOnly',
 'exist': True,
 'startTime': 10.0,
 'animationDuration': 25.0,
 'duration': 30.0,
 'volumeSumWithOriginalVolume': 200.0
 },
 'sceneMaterialsUnifiedRender': {
 'transitionSectionDurations': [0.5, 0.3, 1.0],
 'editMode': 'manual',
 'compositionMode': 'concat',
 'transitionModes': ['normal', 'fadeIn', 'rotate'],
 'interleaveModeParameters': {
 'interval': 0.2,
 'mode': 'sequential'
 },
 'duration': 30.0
 },
 'sceneFilterPostUnifiedRender': {
 'duration': 40.0,
 'statTime': 2.0,
 'exist': True,
 'name': 'Amaro'
 },
 'sceneBackground': {
 'URL': 'file:///sandbox/4/...',
 'postBackgroundIntergrationTempSavingURL': 'file:///sandbox/5/...',
 'size': {
 'width': 1280.0,
 'height': 720.0
 }
 },
 
 'sceneOverlayPostUnifiedFilter': {
 'timeFillingMode': 'repeat',
 'movingPath': [{
 'y': 0.0,
 'x': 0.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 0.0,
 'x': 200.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 1000.0,
 'x': 1000.0
 }],
 'URL': 'http://www.leancloud.cn',
 'movingSectionDurations': [0.5, 0.3, 0.5, 0.6],
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'blendMode': 'normal',
 'startTime': 1.85,
 'duration': 6.0,
 'type': 'image',
 'size': {
 'width': 1920,
 'height': 720
 }
 },
 'sceneLowerThirdPostUnifiedOverlay': {
 'lowerThirdTemplate': {
 'fontColor': {
 'B': 100.0,
 'R': 200.0,
 'G': 200.0
 },
 'fontFamily': 'Times New Roman',
 'fontSize': 16.0,
 'backgroundImageURL': 'file:///sandbox_3/...',
 'size': {
 'width': 200.0,
 'height': 100.0
 }
 },
 'exist': True,
 'startTime': 0.0,
 'petName': 'dli',
 'duration': 5.0,
 'position': {
 'y': 200.0,
 'x': 200.0
 }
 }
 }
*/

@interface scriptOrama : NSObject
@property scene * scene;
@property NSMutableArray * materials;//数组元素为 singleVideoMaterialRenderInfo * singleVideoMaterialRenderInfo;
@end
/*
scriptOrama = {
 'materials':[
 'singleVideoMaterialRenderInfo': {
 'filter': 'beauty',
 'URL': 'file:///sandbox/...',
 'startTime': {
 'epoch': '',
 'timescale': 600,
 'flag': '',
 'value': 4900
 },
 'videoOverlay': {
 'movingPath': [{
 'y': 0.0,
 'x': 0.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 0.0,
 'x': 200.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 1000.0,
 'x': 1000.0
 }],
 'URL': 'http://www.leancloud.cn',
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'startTime': 1.85,
 'duration': 6.0,
 'movingSectionDurations': [0.5, 0.3, 0.5, 0.6],
 'size': {
 'width': 1920,
 'height': 720
 },
 'timeFillingMode': 'repeat',
 'blendMode': 'normal',
 'type': 'image'
 },
 'postRenderTempSavingURL': 'file:///sandbox/2/...',
 'duration': {
 'duration': {
 'value': 4900,
 'epoch': '',
 'flag': '',
 'timescale': 600
 },
 'start': {
 'value': 9000,
 'epoch': '',
 'flag': '',
 'timescale': 600
 }
 },
 'postRenderSize': {
 'width': 1280,
 'height': 720
 },
 'cropPositionOnOriginalMaterial': {
 'y': 50.0,
 'x': 50.0
 },
 'owner': {
 'localData': {
 'avatarUri': 'http://ac-VBYKw7su.clouddn.com/1aed999f83baa02f.png',
 'emailVerified': 0,
 'sex': '\\U4fdd\\U5bc6',
 'signature': '\\U6211\\U597d\\U50cf\\U5fd8\\U5199\\U7b7e\\U540d\\U4e86....',
 'petName': 'dli',
 'geo': '\\U5317\\U4eac'
 },
 'relationData': {},
 'estimatedData': {}
 },
 'cropSize': {
 'width': 500.0,
 'height': 400.0
 }
 },
 'singleVideoMaterialRenderInfo': {
 'filter': 'beauty',
 'URL': 'file:///sandbox/...',
 'startTime': {
 'epoch': '',
 'timescale': 600,
 'flag': '',
 'value': 4900
 },
 'videoOverlay': {
 'movingPath': [{
 'y': 0.0,
 'x': 0.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 0.0,
 'x': 200.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 1000.0,
 'x': 1000.0
 }],
 'URL': 'http://www.leancloud.cn',
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'startTime': 1.85,
 'duration': 6.0,
 'movingSectionDurations': [0.5, 0.3, 0.5, 0.6],
 'size': {
 'width': 1920,
 'height': 720
 },
 'timeFillingMode': 'repeat',
 'blendMode': 'normal',
 'type': 'image'
 },
 'postRenderTempSavingURL': 'file:///sandbox/2/...',
 'duration': {
 'duration': {
 'value': 4900,
 'epoch': '',
 'flag': '',
 'timescale': 600
 },
 'start': {
 'value': 9000,
 'epoch': '',
 'flag': '',
 'timescale': 600
 }
 },
 'postRenderSize': {
 'width': 1280,
 'height': 720
 },
 'cropPositionOnOriginalMaterial': {
 'y': 50.0,
 'x': 50.0
 },
 'owner': {
 'localData': {
 'avatarUri': 'http://ac-VBYKw7su.clouddn.com/1aed999f83baa02f.png',
 'emailVerified': 0,
 'sex': '\\U4fdd\\U5bc6',
 'signature': '\\U6211\\U597d\\U50cf\\U5fd8\\U5199\\U7b7e\\U540d\\U4e86....',
 'petName': 'dli',
 'geo': '\\U5317\\U4eac'
 },
 'relationData': {},
 'estimatedData': {}
 },
 'cropSize': {
 'width': 500.0,
 'height': 400.0
 }
 },
 'singleVideoMaterialRenderInfo': {
 'filter': 'beauty',
 'URL': 'file:///sandbox/...',
 'startTime': {
 'epoch': '',
 'timescale': 600,
 'flag': '',
 'value': 4900
 },
 'videoOverlay': {
 'movingPath': [{
 'y': 0.0,
 'x': 0.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 0.0,
 'x': 200.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 1000.0,
 'x': 1000.0
 }],
 'URL': 'http://www.leancloud.cn',
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'startTime': 1.85,
 'duration': 6.0,
 'movingSectionDurations': [0.5, 0.3, 0.5, 0.6],
 'size': {
 'width': 1920,
 'height': 720
 },
 'timeFillingMode': 'repeat',
 'blendMode': 'normal',
 'type': 'image'
 },
 'postRenderTempSavingURL': 'file:///sandbox/2/...',
 'duration': {
 'duration': {
 'value': 4900,
 'epoch': '',
 'flag': '',
 'timescale': 600
 },
 'start': {
 'value': 9000,
 'epoch': '',
 'flag': '',
 'timescale': 600
 }
 },
 'postRenderSize': {
 'width': 1280,
 'height': 720
 },
 'cropPositionOnOriginalMaterial': {
 'y': 50.0,
 'x': 50.0
 },
 'owner': {
 'localData': {
 'avatarUri': 'http://ac-VBYKw7su.clouddn.com/1aed999f83baa02f.png',
 'emailVerified': 0,
 'sex': '\\U4fdd\\U5bc6',
 'signature': '\\U6211\\U597d\\U50cf\\U5fd8\\U5199\\U7b7e\\U540d\\U4e86....',
 'petName': 'dli',
 'geo': '\\U5317\\U4eac'
 },
 'relationData': {},
 'estimatedData': {}
 },
 'cropSize': {
 'width': 500.0,
 'height': 400.0
 }
 },
 
 ],
 
 
 'scene': {
 'finalOutputOverallRenderSettings': {
 'averageBitRateForCompressing': 1024000.0,
 'size': {
 'width': 1920.0,
 'height': 1080.0
 }
 },
 'titles': {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/7/....',
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'postDurationRegulationSize': {
 'width': 1280.0,
 'height': 720.0
 },
 'duration': 10.0,
 'type': 'image'
 },
 'name': 'zephyr',
 'sceneTextOverBackground': {
 'color': {
 'R': 200.0,
 'B': 100.0,
 'G': 200.0
 },
 'animationMode': 'typing',
 'fontFamily': 'Times New Roman',
 'exist': True,
 'startTime': {
 'value': 0,
 'epoch': '',
 'flag': '',
 'timescale': 600
 },
 'duration': '3.0',
 'size': {
 'width': 100.0,
 'height': 100.0
 },
 'positionOnBackground': {
 'y': 250.0,
 'x': 178.0
 },
 'content': 'ok ok ok',
 'showStage': 'before',
 'fontSize': 14.0
 },
 
 'sceneOverlayPostUnifiedFilter': {
 'timeFillingMode': 'repeat',
 'movingPath': [{
 'y': 0.0,
 'x': 0.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 0.0,
 'x': 200.0
 }, {
 'y': 100.0,
 'x': 100.0
 }, {
 'y': 1000.0,
 'x': 1000.0
 }],
 'URL': 'http://www.leancloud.cn',
 'movingSectionDurations': [0.5, 0.3, 0.5, 0.6],
 'timeTrimingMode': 'tailTrim',
 'exist': True,
 'blendMode': 'normal',
 'startTime': 1.85,
 'duration': 6.0,
 'type': 'image',
 'size': {
 'width': 1920,
 'height': 720
 }
 },
 'sceneGeomTransformPostUnifiedLowerThird': {
 'rotationDegree': 180.0,
 'anchorOnSelf': {
 'y': 60.0,
 'x': 60.0
 },
 'positionOnBackground': {
 'y': 60.0,
 'x': 60.0
 },
 'size': {
 'width': 1280.0,
 'height': 720.0
 }
 },
 'tail': {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/8/...',
 'timeTrimingMode': 'tailTrim',
 'postDurationRegulatioSize': {
 'width': 1280.0,
 'height': 720.0
 },
 'tailTemplate': {},
 'exist': True,
 'mode': 'manual',
 'duration': 5.0,
 'type': 'video'
 },
 'sceneMusicPostBackgroundIntergration': {
 'timeFillingMode': 'repeat',
 'URL': 'file:///sandbox/6/...',
 'animationMode': 'fadeIn',
 'timeTrimingMode': 'tailTrim',
 'volumeRatio': 80.0,
 'mixMode': 'sceneMusicOnly',
 'exist': True,
 'startTime': 10.0,
 'animationDuration': 25.0,
 'duration': 30.0,
 'volumeSumWithOriginalVolume': 200.0
 },
 'sceneMaterialsUnifiedRender': {
 'transitionSectionDurations': [0.5, 0.3, 1.0],
 'editMode': 'manual',
 'compositionMode': 'concat',
 'transitionModes': ['normal', 'fadeIn', 'rotate'],
 'interleaveModeParameters': {
 'interval': 0.2,
 'mode': 'sequential'
 },
 'duration': 30.0
 },
 'sceneFilterPostUnifiedRender': {
 'duration': 40.0,
 'statTime': 2.0,
 'exist': True,
 'name': 'Amaro'
 },
 'sceneBackground': {
 'URL': 'file:///sandbox/4/...',
 'postBackgroundIntergrationTempSavingURL': 'file:///sandbox/5/...',
 'size': {
 'width': 1280.0,
 'height': 720.0
 }
 },
 'sceneLowerThirdPostUnifiedOverlay': {
 'lowerThirdTemplate': {
 'fontColor': {
 'B': 100.0,
 'R': 200.0,
 'G': 200.0
 },
 'fontFamily': 'Times New Roman',
 'fontSize': 16.0,
 'backgroundImageURL': 'file:///sandbox_3/...',
 'size': {
 'width': 200.0,
 'height': 100.0
 }
 },
 'exist': True,
 'startTime': 0.0,
 'petName': 'dli',
 'duration': 5.0,
 'position': {
 'y': 200.0,
 'x': 200.0
 }
 }
 }
 }
*/