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
#import "coreMediaPrint.h"
#import "UIImageTools.h"
#import "movieTools.h"

#import "CDTaskObject.h"
#import "CDUserObject.h"
#import "CDVideoObject.h"
#import "CDVideoLocalRenderObject.h"
#import "CDVideoOverlayObject.h"
#import "CDSceneObject.h"
#import "CDVideoLowerThirdObject.h"
#import "CDVideoTextOverBackGroundObject.h"
#import "CDAudioSceneMusicObject.h"
#import "CDVideoTitlesObject.h"
#import "CDVideoTailObject.h"

typedef enum {
    overlayType_Image,
    overlayType_GIF,
    overlayType_Video
} overlayType;
////currently only support tail
typedef enum {
    timeTrimmingModeType_Tail
} timeTrimmingModeType;
////currently only support repeat
typedef enum {
    timeFillingModeType_Repeat
} timeFillingModeType;
////currently only support normal (overlay 在 视频上面)
typedef enum {
    blendModeType_Normal,
    blendModeType_MSAdd
} blendModeType;

////----dli
typedef enum {
    transitionModeType_FadeIn,
    transitionModeType_FadeOut,
    transitionModeType_FadeInFadeOut,
} transitionModeType;
////----dli

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
@property (nullable, nonatomic, retain) NSNumber * parentHashID;//标识父类
@property BOOL exist;//是否使用overlay
@property (nullable, nonatomic, retain) NSString* absoluteURLstring;//已经在沙盒中的absoluteURLstring,包括http://  file:/// 等部分
@property (nullable, nonatomic, retain) NSString * type;//取值 image  or  GIF  or video
@property (nullable, nonatomic, retain) NSNumber * startTime;//overlay开始的时间,单位秒，在NS2JS, JS2NS两个parser中转换
@property (nullable, nonatomic, retain) NSNumber * duration;//overlay持续时间，单位秒，在NS2JS, JS2NS两个parser中转换
//下面这两个参数指示时间temporal维度的填充 和截取 方法
@property (nullable, nonatomic, retain) NSString * timeFillingMode; //取值 当前只有repeat
@property (nullable, nonatomic, retain) NSString * timeTrimingMode; //取值 当前只有 tailTrim
/*
 1. 当videooverlayType 为 image 时 , image 在 videoOverlayStartTime 开始出现 ，持续显示videoOverlayDuration
 2. 当videooverlayType 为 GIF/video 时 , image 在 videoOverlayStartTime 开始出现
 假如持续显示videoOverlayDuration 大于 GIF/video 本身时长，则会根据videoOverlayTimeFillingMode扩充至整个videoOverlayDuration
 假如持续显示videoOverlayDuration 小于 GIF/video 本身时长，则会根据videoOverlayTimeTrimmingMode截取至个videoOverlayDuration
 */
//处理完时间维度的 填充或截取后，调整size
@property (nullable, nonatomic, retain) NSString * blendMode;//当前仅有normal
@property (nullable, nonatomic, retain) NSNumber * width;//在NS2JS, JS2NS两个parser中转换
@property (nullable, nonatomic, retain) NSNumber * height;//在NS2JS, JS2NS两个parser中转换
/*因为coredata 不支持 CGSize*/
//下面这两个参数指示空间spatial维度的填充 和 动画化移动 方法
@property (nullable, nonatomic, retain) NSMutableArray * movingPathCGPointXs;
@property (nullable, nonatomic, retain) NSMutableArray * movingPathCGPointYs;
/*
 数组中的元素是NSNumber
 因为cordata 处理复合型数据比较麻烦
 所以分开两个数组存放
 */                                      // 数组中的元素在NS2JS, JS2NS两个parser中转换
@property (nullable, nonatomic, retain) NSMutableArray * movingSectionDurations; // 数组中的元素是NSNumber 单位是秒, 整个轨迹是多条直线链接成的折线，数组中的元素表示每个折点
                                                //数组个数比videoOverlayMovingPath 少1，表示从对应折点到下一个折点 动画移动所需要的时间
                                                   // 数组中的元素在NS2JS, JS2NS两个parser中转换
@end
////====================================================================================



////====================================================================================
//singleVideoMaterialRenderInfo 是针对单个素材的,
//客户选取的每段素材video
//都会应用自己的singleVideoMaterialRenderInfo
@interface videoLocalRender : NSObject
////同一个母视频 和片段 全部用 名字 $(ten_bit_time_stamp)-movie.mp4 区分关联
////同一个母视频 和片段 的thumnail 全部用 名字 $(ten_bit_time_stamp)-movie.png 区分关联
/*
 video_source/                          #固定
 └── 206baa6ec5b164e188d4608e3d2c09a4   #针对每次操作随机生成的索引
 ├── MOVIES                             #固定 原始视频存放于此
 │   ├── 1460707809-movie.mp4           #每个视频用 $(ten_bit_time_stamp)-movie.mp4 区分
 │   ├── 1460729127-movie.mp4
 │   ├── 1460729461-movie.mp4
 │   ├── 1460729465-movie.mp4
 │   ├── 1460729467-movie.mp4
 │   └── 1460729471-movie.mp4
 ├── MOVIES_POST_CUTTING                #选择片段 后的视频 可能存放于此(默认不存放)
 │   ├── AUDIO                          #如果后续FEATURE需要音频视频分离 这里是片段音频的 存放目录和workdir
 │   └── VIDEO                          #如果后续FEATURE需要音频视频分离 这里是片段视频的 存放目录和workdir
 ├── MOVIES_POST_FILTERING              #singleVideo 滤镜 后的视频 可能存放于此(默认不存放)
 │   ├── AUDIO                          #如果后续FEATURE需要音频视频分离 这里是片段音频的 存放目录和workdir
 │   └── VIDEO                          #如果后续FEATURE需要音频视频分离 这里是片段视频的 存放目录和workdir
 ├── THUMBNAIL                          #原始视频thumnail存放于此(第一frame)
 │   ├── 1460707809-movie.png
 │   ├── 1460729127-movie.png
 │   ├── 1460729461-movie.png
 │   ├── 1460729465-movie.png
 │   ├── 1460729467-movie.png
 │   └── 1460729471-movie.png
 ├── THUMBNAIL_POST_CUTTING             #选择片段 后视频thumnail存放于此
 └── THUMBNAIL_POST_FILTERING           #singleVideo 滤镜 后的视频thumnail存放于此
 
*/
@property (nullable, nonatomic, retain) NSNumber * parentHashID;//标识父类
@property (nullable, nonatomic, retain)  NSNumber * timeStampInScene;//每个single video 在合成后的scene 中的timestamp
@property (nullable, nonatomic, retain)  NSString * origURLstring;
//已经在沙盒中的URL,没有发生cutting,也没有选择filter之前
//因为coreData不支持NSURL 所以用字符串
/*
此时是固定路径: $index为一个随机索引 对应每次操作 206baa6ec5b164e188d4608e3d2c09a4
/Documents/video_source/$(index)/MOVIES/$(ten_bit_time_stamp)-movie.mp4
/Documents/video_source/$(index)/THUMBNAIL/$(ten_bit_time_stamp)-movie.png
*/
@property (atomic,assign) BOOL savePostCutting ;//默认为NO
@property (nullable, nonatomic, retain)  NSString * postCuttingURLstring;//已经在沙盒中的URL,发生cutting之后,没有选择filter之前
@property (nullable, nonatomic, retain)  NSString * postCuttingAudioWorkDirURLstring;//临时文件夹因为有些滤镜声音和图像要分开处理
@property (nullable, nonatomic, retain)  NSString * postCuttingVideoWorkDirURLstring;//临时文件夹因为有些滤镜声音和图像要分开处理

////注意如果不另保存postCutting之后的movie，只是利用时间戳，那么这个文件夹内容为空，但是文件夹必须
////存在，保证程序流程一致性
/*
 此时是固定路径: $index $(ten_bit_time_stamp) 均和origURL 保持对应
 /Documents/video_source/$(index)/MOVIES_POST_CUTTING/$(ten_bit_time_stamp)-movie.mp4
 /Documents/video_source/$(index)/MOVIES_POST_CUTTING/AUDIO/$(ten_bit_time_stamp)-movie.m4a
 /Documents/video_source/$(index)/MOVIES_POST_CUTTING/VIDEO/$(ten_bit_time_stamp)-movie.mov
 /Documents/video_source/$(index)/THUMBNAIL_POST_CUTTING/$(ten_bit_time_stamp)-movie.png
 */


@property (atomic,assign) BOOL savePostFiltering ;//默认为NO
@property (nullable, nonatomic, retain)  NSString * postFilteringURLstring;//已经在沙盒中的URL,选择filter之后
@property (nullable, nonatomic, retain)  NSString * postFilteringAudioWorkDirURLstring;//临时文件夹因为有些滤镜声音和图像要分开处理
@property (nullable, nonatomic, retain)  NSString * postFilteringVideoWorkDirURLstring;//临时文件夹因为有些滤镜声音和图像要分开处理

////注意如果不另保存postFiltering之后的movie，只是利用时间戳，那么这个文件夹内容为空，但是文件夹必须
////存在，保证程序流程一致性
/*
 此时是固定路径: $index $(ten_bit_time_stamp) 均和origURL 保持对应
 /Documents/video_source/$(index)/MOVIES_POST_FILTERING/$(ten_bit_time_stamp)-movie.mp4
 /Documents/video_source/$(index)/THUMBNAIL_POST_FILTERING/$(ten_bit_time_stamp)-movie.png
 /Documents/video_source/$(index)/MOVIES_POST_FILTERING/AUDIO/$(ten_bit_time_stamp)-movie.m4a
 /Documents/video_source/$(index)/MOVIES_POST_FILTERING/VIDEO/$(ten_bit_time_stamp)-movie.mov
 
*/


//下面这两个参数同样作用于Audio截取
//这两个数值发生在选取视频singleVideoMaterial片段之后
//因为选取视频片段并不发生真正的截取，只是标注时间点
//这两个数值时选取动作的函数传过来的结果，仅仅内部使用
//所以保留xcode AVFoundation 便于使用的CMT格式
@property (nullable, nonatomic, retain) NSNumber * startTime;//针对单个素材video开始的时间,在NS2JS, JS2NS两个parser中转换，在AVFoundation中使用时要转换为CMTime 格式
@property (nullable, nonatomic, retain) NSNumber * duration;//针对单个素材video持续时间，在NS2JS, JS2NS两个parser中转换，在AVFoundation中使用时要转换为CMTimeRange 格式


@property (nullable, nonatomic, retain) NSString * filter;//filter的名字  在改动过的GPUImage框架里 每个框架都有name属性
@property (nullable, nonatomic, retain) NSNumber *  cropPositionOnOriginalMaterialX;//
@property (nullable, nonatomic, retain) NSNumber *  cropPositionOnOriginalMaterialY;//
@property (nullable, nonatomic, retain) NSNumber * cropSizeX;//
@property (nullable, nonatomic, retain) NSNumber * cropSizeY;//
@property (nullable, nonatomic, retain) NSNumber * postRenderSizeX;//当前固定为1280 * 720,处理完overlay等singleVideoMaterialRenderInfo中的效果后需要调整到的大小
@property (nullable, nonatomic, retain) NSNumber * postRenderSizeY;
@property (nullable, nonatomic, retain) NSString * postRenderTempSavingURLstring;//根据针对单个素材video的singleVideoMaterialRenderInfo
//处理完针对单个素材video 要在沙盒中缓存一个中间视频
//此时videoURL处的沙盒视频可以删除了
@property (nullable, nonatomic, retain) videoOverlay * videoOverlay;//overlay
@end

////===================================
@interface lowerThird : NSObject
@property (nullable, nonatomic, retain) NSNumber * parentHashID;
@property (nullable, nonatomic, retain) NSNumber * width;//全部文字整体所在Rect Size
@property (nullable, nonatomic, retain) NSNumber * height;
@property (nullable, nonatomic, retain) NSNumber * xOnVideo;//位置坐标针对postCompositonVideo的 全部文字整体所在Rect 在视频中的位置
@property (nullable, nonatomic, retain) NSNumber * yOnVideo;//位置坐标针对postCompositonVideo的
@property (nullable, nonatomic, retain) NSNumber * startTime;//在scene 整体视频中出现的时间
@property (nullable, nonatomic, retain) NSNumber * duration;
@property (nullable, nonatomic, retain) NSString * petName; // 格式为@ + AVUser.petName
@property (nullable, nonatomic, retain) NSString * fontFamily;
@property (nullable, nonatomic, retain) NSNumber * fontSize;
@property (nullable, nonatomic, retain) NSNumber * fontColorR;
@property (nullable, nonatomic, retain) NSNumber * fontColorG;
@property (nullable, nonatomic, retain) NSNumber * fontColorB;
@property (nullable, nonatomic, retain) NSNumber * fontColorA;
@property (nullable, nonatomic, retain) NSString * bgImageURLstring;//内置图片在沙盒中的URL
@property BOOL temporary;
@end

////===========================================
//textOverBackGround
@interface textOverBackground : NSObject
@property (nullable, nonatomic, retain) NSNumber * parentHashID;
@property (nullable, nonatomic, retain) NSString * content;
@property (nullable, nonatomic, retain) NSString * fontFamily;
@property (nullable, nonatomic, retain) NSNumber * fontColorR;
@property (nullable, nonatomic, retain) NSNumber * fontColorG;
@property (nullable, nonatomic, retain) NSNumber * fontColorB;
@property (nullable, nonatomic, retain) NSNumber * fontColorA;
@property (nullable, nonatomic, retain) NSNumber * fontSize;
@property (nullable, nonatomic, retain) NSNumber * xOnBG;//位置坐标针对sceneBackground的
@property (nullable, nonatomic, retain) NSNumber * yOnBG;//位置坐标针对sceneBackground的
@property (nullable, nonatomic, retain) NSNumber * width;//全部文字整体所在Rect Size
@property (nullable, nonatomic, retain) NSNumber * height;//全部文字整体所在Rect Size
//开始应用sceneTextOverBackground的时间  和sceneTextOverBackground持续时间
@property (nullable, nonatomic, retain) NSString * showStage;//取值可以是before (sceneVideoPostUnifiedLowerThird) 或者 after (sceneVideoPostUnifiedLowerThird)
@property (nullable, nonatomic, retain) NSNumber * duration;
@property (nullable, nonatomic, retain) NSNumber * startTime;//根据sceneTextOverBackgroundShowStage算出
                           //如果before kCMTimeZero
                           //如果after CMTimeAdd(sceneVideoPostUnifiedLowerThirdDuration,sceneTextOverBackgroundDuration)
                           //程序内部使用
@property (nullable, nonatomic, retain) NSString * animationMode;//取值可以是typing(逐字显现),normal(全部同时显示)，fadeIn, fadeOut, fadeInfadeOut
@property BOOL temporary;
@end
////====================================================================================



@interface sceneMusic :NSObject
@property (nullable, nonatomic, retain) NSNumber * parentHashID;
@property (nullable, nonatomic, retain) NSString * musicURLstring;//已经在沙盒中的URL
//开始应用sceneMusicPostBackgroundIntergration的时间  和sceneMusicPostBackgroundIntergration持续时间
//相对于scenePostBackgroundIntergrationVideo 来说的
@property (nullable, nonatomic, retain) NSNumber * startTime;
@property (nullable, nonatomic, retain) NSNumber * duration;
//下面这两个参数指示时间temporal维度的填充 和截取 方法
@property (nullable, nonatomic, retain) NSString * timeFillingMode; //取值 当前只有repeat
@property (nullable, nonatomic, retain) NSString * timeTrimingMode; //取值 当前只有 tailTrim
/*
 
 假如音频文件 大于 sceneMusicPostBackgroundIntergrationDuration 本身时长，则会根据timeFillingMode扩充至整个sceneMusicPostBackgroundIntergrationDuration
 假如音频文件 小于 sceneMusicPostBackgroundIntergrationDuration 本身时长，则会根据timeTrimmingMode截取至个sceneMusicPostBackgroundIntergrationDuration
 */
@property (nullable, nonatomic, retain) NSNumber * volumeRatio;//1- 100, 意思是1% － 100%
@property (nullable, nonatomic, retain) NSNumber * volumeSumWithOriginalVolume;  //音量上限，绝对值  sceneMusicVolume + originalVolume
@property (nullable, nonatomic, retain) NSNumber * animationStartTime;
@property (nullable, nonatomic, retain) NSNumber * animationDuration;
@property (nullable, nonatomic, retain) NSString * animationMode;//fadeIn fadeOut fadeInfadeOut
@property (nullable, nonatomic, retain) NSString * mixMode;//指原声和sceneMusic的混合模式
//originalOnly :保留原声
//sceneMusicOnly:
// mix:
@property BOOL temporary;
@end






////==============================================
@interface titles : NSObject
@property (nullable, nonatomic, retain) NSNumber * parentHashID;
@property (nullable, nonatomic, retain) NSString * titlesURLstring;//已经在沙盒中的URL
@property (nullable, nonatomic, retain) NSString * type;//当前取值  image GIF video
@property (nullable, nonatomic, retain) NSNumber * duration;//titles持续时间，单位秒
//下面这两个参数指示时间temporal维度的填充 和截取 方法
@property (nullable, nonatomic, retain) NSString * timeFillingMode; //取值 当前只有repeat
@property (nullable, nonatomic, retain) NSString * timeTrimingMode; //取值 当前只有 tailTrim
/*
 1. 当titlesType 为 image 时 , image 在 titlesStartTime 开始出现 ，持续显示titlesDuration
 2. 当titlesType 为 GIF/video 时 , image 在 titlesStartTime 开始出现
 假如持续显示titlesDuration 大于 GIF/video 本身时长，则会根据titlesTimeFillingMode扩充至整个titlesDuration
 假如持续显示titlesDuration 小于 GIF/video 本身时长，则会根据titlesTimeTrimmingMode截取至个titlesDuration
 */
@property (nullable, nonatomic, retain) NSNumber * width;//当前固定为1280 * 720,调整完duration后需要调整到的大小，调整到和sceneBackGroundSize一致
@property (nullable, nonatomic, retain) NSNumber * height;//当前固定为1280 * 720,调整完duration后需要调整到的大小，调整到和sceneBackGroundSize一致
@property BOOL temporary;
@end

////=====================================================





////===========================================
@interface tail : NSObject
@property (nullable, nonatomic, retain) NSNumber * parentHashID;
@property (nullable, nonatomic, retain) NSString * mode;//当前取值  manual  auto， 当前不支持auto
                              //如果是auto ,会读区tailTemplate中的参数自动生成，当前不支持
                             //如果是manual 读取后面的参数
@property (nullable, nonatomic, retain) NSString * tailURLstring;//已经在沙盒中的URL
@property (nullable, nonatomic, retain) NSString * type;//当前取值  image GIF video
@property (nullable, nonatomic, retain) NSNumber * duration;//tail持续时间，单位秒
//下面这两个参数指示时间temporal维度的填充 和截取 方法
@property (nullable, nonatomic, retain) NSString * timeFillingMode; //取值 当前只有repeat
@property (nullable, nonatomic, retain) NSString * timeTrimingMode; //取值 当前只有 tailTrim
/*
 1. 当tailType 为 image 时 , image 在 tailStartTime 开始出现 ，持续显示tailDuration
 2. 当tailType 为 GIF/video 时 , image 在 tailStartTime 开始出现
 假如持续显示tailDuration 大于 GIF/video 本身时长，则会根据tailTimeFillingMode扩充至整个tailDuration
 假如持续显示tailDuration 小于 GIF/video 本身时长，则会根据tailTimeTrimmingMode截取至个tailDuration
 */
@property (nullable, nonatomic, retain) NSNumber * width;//当前固定为1280 * 720,调整完duration后需要调整到的大小，调整到和sceneBackGroundSize一致
@property (nullable, nonatomic, retain) NSNumber * height;//当前固定为1280 * 720,调整完duration后需要调整到的大小，调整到和sceneBackGroundSize一致
@property BOOL temporary;
@end

////===========================================



////===============
////合并titles+ unifiedVideoPostBackgroundIntergration + tail
////           sceneMusicPostBackgroundIntergration
////===============
@interface scene : NSObject
@property BOOL temporary;
@property (nullable, nonatomic, retain) NSNumber * parentHashID;
@property (nullable, nonatomic, retain) NSString * name;
@property (nullable, nonatomic, retain) NSString *categoryId;
@property (nullable, nonatomic, retain) NSString *coverImgUrl;
@property (nullable, nonatomic, retain) NSString *creatorId;
@property (nullable, nonatomic, retain) NSString *demoVideoUrl;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber * videoCount;  ////组成这个scene的视频总数
@property (nullable, nonatomic, retain) NSString * interleaveMode; // @"mode"  值为NSString 可取值 sequential(按照素材顺序interleave片段)
//random(随机生成每一轮的顺序)
@property (nullable, nonatomic, retain) NSNumber * interleaveInterval;  // @"interval"  slice片段的持续时间
@property (nullable, nonatomic, retain) NSString * editMode;//当前取值为manual或auto
@property (nullable, nonatomic, retain) NSNumber * expectedTotalDuration;//如果是手动manual模式，这个参数用于视频选取步骤，视频选取发生在videoRenderInfo之前，如果所有素材duration之和大于此数值，那么选取失败
//如果是自动auto模式，这个参数会被传给auto处理的函数
@property (nullable, nonatomic, retain) NSString * compositionMode;//当前取值为concat或interleave或merge
@property (nullable, nonatomic, retain) NSMutableArray * transitionModes;//singleVideoMaterial 之间的转场模式  数组成员为NSString
//当前仅取值为normal,没有转场效果
@property (nullable, nonatomic, retain) NSMutableArray * transitionSectionDurations;//singleVideoMaterial 之间的转场持续时长  数组成员NSNumber 单位是秒
@property BOOL filterPostCompositionExist;
@property (nullable, nonatomic, retain) NSString * filterPostCompositionName;
//开始应用滤镜sceneFilterPostUnifiedRender的时间
//和滤镜sceneFilterPostUnifiedRender持续时间
//参照物是UnifiedRender 处理后Video 时间
@property (nullable, nonatomic, retain) NSNumber * filterPostCompositionStartTime;
@property (nullable, nonatomic, retain) NSNumber * filterPostCompositionDuration;
@property BOOL overlayPostCompositionFilterExist;
@property (nullable, nonatomic, retain) videoOverlay * overlayPostCompositionFilter;
@property BOOL lowerThirdPostOverlayExist;
@property (nullable, nonatomic, retain) lowerThird * lowerThirdPostOverlay;
//处理完sceneLowerThirdPostUnifiedOverlay 操作后调整几何参数
@property BOOL geomTransformPostLowerThirdExist;
@property (nullable, nonatomic, retain) NSNumber * sizeXpostLowerThird;
@property (nullable, nonatomic, retain) NSNumber * sizeYpostLowerThird;
@property (nullable, nonatomic, retain) NSNumber * xOnBGPostLowerThird;//位置参数针对于sceneBackground画布的(parent CALayer size == sceneBackgroundSize)
@property (nullable, nonatomic, retain) NSNumber * yOnBGPostLowerThird;//位置参数针对于sceneBackground画布的(parent CALayer size == sceneBackgroundSize)
@property (nullable, nonatomic, retain) NSNumber * anchorOnSelfXpostLowerThird;//位置参数针对于scenePostMaterialsRenderVideo自己的, 2D旋转时候的圆心位置
@property (nullable, nonatomic, retain) NSNumber * anchorOnSelfYpostLowerThird;//因为此处旋转是绕自身，为了方便处理 参照物是postUnifiedVideo
@property (nullable, nonatomic, retain) NSNumber * rotationDegreePostLowerThird;
@property BOOL textOverBackgroundExist;
@property (nullable, nonatomic, retain) textOverBackground * textOverBG;
////
//sceneBackground
//parent CALayer size == sceneBackgroundSize
//先在parent CALayer 上放上sceneBackground
@property (nullable, nonatomic, retain) NSNumber * backgroundSizeX;//接下来的操作画布大小就是sceneBackgroundSize
@property (nullable, nonatomic, retain) NSNumber * backgroundSizeY;//接下来的操作画布大小就是sceneBackgroundSize
@property (nullable, nonatomic, retain) NSString * bgImageURLstring;//已经在沙盒中的URL
//保存之前合并unified后的Audio
@property (nullable, nonatomic, retain) NSString * postBGTempURLstring;//将scenetextOverbackground 和 sceneGeomPostUnifiedLowerThirdVideo
//放到sceneBackground之后的中间缓存视频
@property BOOL musicPostBackgroundIntergrationExist;
@property (nullable, nonatomic, retain) sceneMusic * musicPostBGIntergration;
@property BOOL titlesExist;//是否使用titles片头
@property (nullable, nonatomic, retain) titles * titles;
@property BOOL tailExist;//是否使用tail片尾
@property (nullable, nonatomic, retain) tail * tail;
@property (nullable, nonatomic, retain) NSNumber * finalOutputCGsizeX;//最终输出video的大小
@property (nullable, nonatomic, retain) NSNumber * finalOutputCGsizeY;//最终输出video的大小
@property (nullable, nonatomic, retain) NSNumber * averageBitRateForCompressing;//传递给VT压缩的参数，H.264再次压缩后的码率
@end




////---------coreData helper
////CDVideoObject
void CDVideoObjectDeleteSelfVideoLocalRender(CDVideoObject * _Nullable obj);
void CDVideoObjectCreatNewWithAllIteratedRelationships(BOOL tempOrNot);
void CDVideoObjectUpdateVideoLocalRender(CDVideoObject * _Nullable obj,CDVideoLocalRenderObject * _Nullable robj);
void CDVideoObjectAddingAllIteratedRelationshipsIfNon(CDVideoObject * _Nullable obj);
NSString * _Nullable  getSourcePathWithTopDirName(NSString * _Nullable topDirName);
NSString*  _Nullable   getMovieFileDir(NSString* _Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getMovieFilePath(NSString * _Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getMovieFromAlbumFileDir(NSString* _Nullable  makerId ,NSString * _Nullable  topDirName);
NSString * _Nullable  getMovieFromAlbumFilePath(NSString* _Nullable  videoId, NSString* _Nullable  makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString * _Nullable  getMovieFromAlbumAudioOnlyFileDir(NSString* _Nullable  makerId ,NSString * _Nullable  topDirName);
NSString * _Nullable  getMovieFromAlbumAudioOnlyFilePath(int whichTrack,NSString* _Nullable  videoId, NSString* _Nullable  makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString * _Nullable  getMovieFromAlbumVideoOnlyFileDir(NSString* _Nullable  makerId ,NSString * _Nullable  topDirName);
NSString * _Nullable  getMovieFromAlbumVideoOnlyFilePath(int whichTrack,NSString* _Nullable  videoId, NSString* _Nullable  makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString * _Nullable  getThumbnailFileDir(NSString* _Nullable  makerId ,NSString * _Nullable  topDirName);
NSString * _Nullable  getThumbnailFilePath(NSString * _Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getPostCuttingMovieFileDir(NSString *_Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getPostCuttingMovieFilePath(NSString * _Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getPostCuttingAudioOnlyFileDir(NSString *_Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getPostCuttingAudioOnlyFilePath(int whichTrack,NSString *_Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getPostCuttingVideoOnlyFileDir(NSString *_Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getPostCuttingVideoOnlyFilePath(int whichTrack,NSString *_Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getPostCuttingThumbnailFileDir(NSString *_Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getPostCuttingThumbnailFilePath(NSString *_Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getPostFilteringMovieFileDir(NSString *_Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getPostFilteringMovieFilePath(NSString *_Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getPostFilteringAudioOnlyFileDir(NSString *_Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getPostFilteringAudioOnlyFilePath(int whichTrack,NSString *_Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getPostFilteringVideoOnlyFileDir(NSString *_Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getPostFilteringVideoOnlyFilePath(int whichTrack,NSString *_Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString * _Nullable  getPostFilteringThumbnailFileDir(NSString *_Nullable makerId ,NSString * _Nullable topDirName);
NSString * _Nullable  getPostFilteringThumbnailFilePath(NSString *_Nullable videoId, NSString *_Nullable makerId ,NSString * _Nullable topDirName, NSString * _Nullable suffix);
NSString* _Nullable getSceneTitlesMovieFileDir(NSString* _Nullable makerId ,NSString * _Nullable topDirName);
NSString* _Nullable getSceneTitlesMovieFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable topDirName,NSString * _Nullable suffix);
NSString* _Nullable getSceneTitlesAudioOnlyFileDir(NSString* _Nullable makerId ,NSString * _Nullable topDirName);
NSString* _Nullable getSceneTitlesAudioOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable topDirName,NSString * _Nullable suffix);
NSString* _Nullable getSceneTitlesVideoOnlyFileDir(NSString* _Nullable makerId ,NSString * _Nullable topDirName);
NSString* _Nullable getSceneTitlesVideoOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable topDirName,NSString * _Nullable suffix);
NSString* _Nullable getSceneTitlesThumbnailFileDir(NSString* _Nullable makerId ,NSString * _Nullable topDirName);
NSString* _Nullable getSceneTitlesThumbnailFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable topDirName,NSString * _Nullable suffix);
NSString* _Nullable getSceneTailMovieFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneTailMovieFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString *  _Nullable suffix);
NSString* _Nullable getSceneTailAudioOnlyFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneTailAudioOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString *  _Nullable suffix);
NSString* _Nullable getSceneTailVideoOnlyFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneTailVideoOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString *  _Nullable suffix);
NSString* _Nullable getSceneTailThumbnailFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneTailThumbnailFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString *  _Nullable suffix);
NSString* _Nullable getSceneOverlayMovieFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneOverlayMovieFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString* _Nullable getSceneOverlayAudioOnlyFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneOverlayAudioOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString* _Nullable getSceneOverlayVideoOnlyFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneOverlayVideoOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString* _Nullable getSceneOverlayThumbnailFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneOverlayThumbnailFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString* _Nullable getMaterialOverlaysMovieFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString* _Nullable getMaterialOverlaysMovieFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);
NSString* _Nullable getMaterialOverlaysAudioOnlyFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getMaterialOverlaysAudioOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString* _Nullable getMaterialOverlaysVideoOnlyFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getMaterialOverlaysVideoOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString* _Nullable getMaterialOverlaysThumbnailFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getMaterialOverlaysThumbnailFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString* _Nullable getSceneBackgroundFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneBackgroundFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);
NSString* _Nullable getSceneMusicFileDir(NSString* _Nullable makerId ,NSString * _Nullable  topDirName);
NSString* _Nullable getSceneMusicFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString * _Nullable  topDirName,NSString * _Nullable  suffix);


NSURL * _Nullable getPostCuttingMovieURLFromMoviePath(NSString * _Nullable moviePath);
NSURL * _Nullable getPostCuttingAudioOnlyURLFromAudioOnlyPath(NSString * _Nullable  moviePath);
NSURL * _Nullable getPostCuttingVideoOnlyURLFromVideoOnlyPath(NSString * _Nullable  moviePath);
NSURL * _Nullable getPostCuttingThumbnailURLFromThumbnailPath(NSString * _Nullable  thumbnailPath,int whichTrack);
NSURL * _Nullable getPostFilteringAudioOnlyURLFromAudioOnlyPath(NSString * _Nullable  moviePath);
NSURL * _Nullable getPostFilteringVideoOnlyURLFromVideoOnlyPath(NSString * _Nullable  moviePath);
NSURL * _Nullable getPostFilteringThumbnailURLFromThumbnailPath(NSString * _Nullable  thumbnailPath,int whichTrack);



NSString*  _Nullable getSceneMovieFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString*  _Nullable getSceneMovieFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);
NSString*  _Nullable getSceneAudioFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString*  _Nullable getSceneAudioFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);
NSString*  _Nullable getSceneVideoFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString*  _Nullable getSceneVideoFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);
NSString*  _Nullable getSceneThumbnailFileDir(NSString* _Nullable makerId ,NSString * _Nullable topDirName);
NSString*  _Nullable getSceneThumbnailFilePath(NSString* _Nullable videoId, NSString * _Nullable makerId ,NSString * _Nullable topDirName,NSString * _Nullable  suffix);
NSString*  _Nullable getSceneTransitionsFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString*  _Nullable getSceneTransitionsFilePath(int seq, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);


NSString*  _Nullable getScenePostTransisionsMovieFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString*  _Nullable getScenePostTransisionsMovieFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);
NSString*  _Nullable getScenePostTransisionsAudioFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString*  _Nullable getScenePostTransisionsAudioFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);
NSString*  _Nullable getScenePostTransisionsAudioOnlyFilePath(int whichTrack,NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);
NSString*  _Nullable getScenePostTransisionsVideoFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString*  _Nullable getScenePostTransisionsVideoFilePath(NSString* _Nullable videoId, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);
NSString*  _Nullable getScenePostTransisionsVideoOnlyFilePath(int whichTrack,NSString*  _Nullable videoId, NSString*  _Nullable makerId ,NSString *   _Nullable topDirName,NSString *   _Nullable suffix);
NSString*  _Nullable getScenePostTransisionsThumbnailFileDir(NSString* _Nullable makerId ,NSString * _Nullable topDirName);
NSString*  _Nullable getScenePostTransisionsThumbnailFilePath(NSString* _Nullable videoId, NSString * _Nullable makerId ,NSString * _Nullable topDirName,NSString * _Nullable  suffix);
NSString*  _Nullable getScenePostTransisionsTransitionsFileDir(NSString* _Nullable makerId ,NSString *  _Nullable topDirName);
NSString*  _Nullable getScenePostTransisionsTransitionsFilePath(int seq, NSString* _Nullable makerId ,NSString *  _Nullable topDirName,NSString *  _Nullable suffix);






NSURL * _Nullable getAudioOnlyDirURLFromMoviePath(NSString * _Nullable moviePath);
NSURL * _Nullable getVideoOnlyDirURLFromMoviePath(NSString * _Nullable moviePath);
NSString * _Nullable getVideoIdFromMoviePath(NSString * _Nullable moviePath);
void deleteCorrespondingAudioFilesOfMoviePath(NSString * _Nullable moviePath);
void deleteCorrespondingVideoFilesOfMoviePath(NSString * _Nullable moviePath);
NSMutableArray * _Nullable findAllCorrespondingAudioFileURLsOfMoviePath(NSString * _Nullable moviePath);
NSMutableArray * _Nullable  findAllCorrespondingVideoFileURLsOfMoviePath(NSString * _Nullable moviePath);
int getWhichTrackFromPath(NSString * _Nullable moviePath);
NSMutableArray * _Nullable  findAllCorrespondingAudioTracksOfMoviePath(NSString * _Nullable moviePath);
NSMutableArray * _Nullable  findAllCorrespondingVideoTracksOfMoviePath(NSString * _Nullable moviePath);

void CDVideoObjectNullifyLocalRenderSizeAndPointParameters(CDVideoObject * _Nullable obj);
void CDVideoObjectFulFillLocalRenderURLs(CDVideoObject * _Nullable obj);
void deleteAllCorrespondingFilesViaVideoObject(CDVideoObject* _Nullable videoObject);
void deleteWorkdirForSingleVideoMaterials(NSString * _Nullable makerId);
void supplementWorkdirForSingleVideoMaterials(NSString * _Nullable makerId);
void resetWorkdirForSingleVideoMaterials(NSString * _Nullable makerId);


////CDVideoLocalRenderObject
void CDVideoLocalRenderObjectDeleteSelfVideoOverlay(CDVideoLocalRenderObject * _Nullable robj);
void CDVideoLocalRenderObjectCreatNewWithVideoOverlay(BOOL tempOrNot);
void CDVideoLocalRenderObjectUpdateVideoOverlay(CDVideoLocalRenderObject * _Nullable robj,CDVideoOverlayObject * _Nullable nvobj);



////CDSceneObject
void CDSceneObjectDeleteAllSelfAttributes(CDSceneObject * _Nullable sobj);
void CDSceneObjectCreatNewWithAllIteratedRelationships(BOOL tempOrNot);
void CDSceneObjectUpdateVideoOverlayObject(CDSceneObject * _Nullable sobj,CDVideoOverlayObject * _Nullable voobj);
void CDSceneObjectUpdateLowerThirdObject(CDSceneObject * _Nullable sobj,CDVideoLowerThirdObject * _Nullable ltobj);
void CDSceneObjectUpdateTextOverBackGroundObject(CDSceneObject * _Nullable sobj,CDVideoTextOverBackGroundObject * _Nullable tobgobj);
void CDSceneObjectUpdateAudioSceneMusicObject(CDSceneObject * _Nullable sobj,CDAudioSceneMusicObject * _Nullable mobj);
void CDSceneObjectUpdateTitlesObject(CDSceneObject * _Nullable sobj,CDVideoTitlesObject * _Nullable titlesobj);
void CDSceneObjectUpdateTailObject(CDSceneObject * _Nullable sobj,CDVideoTitlesObject * _Nullable tailobj);
////----------coreData helper


////-----processing Flow
////CDVideoOverlayObject
int overlayTypeToEnum(NSString * _Nullable type);
NSString * _Nullable enumToOverlayType(int typeNum);
int timeTrimmingTypeToEnum(NSString *  _Nullable type);
NSString *  _Nullable  enumToTimeTrimmingType(int typeNum);
int timeFillingTypeToEnum(NSString *  _Nullable type);
NSString *  _Nullable  enumToTimeFillingType(int typeNum);
int blendTypeToEnum(NSString * _Nullable type);
NSString * _Nullable enumToBlendType(int typeNum);
NSURL * _Nullable  getPostStateOneProcessingVideoOnlyURLFromOverlayPath(NSString * _Nullable overlayPath,int whichTrack);
NSURL * _Nullable  getPostStateOneProcessingAudioOnlyURLFromOverlayPath(NSString * _Nullable overlayPath,int whichTrack);


void CDVideoOverlayObjectStateOneProcessingFlow(CDVideoOverlayObject * _Nullable voobj,BOOL SAVEHERE,BOOL SYNCSAVE);


////-----processing Flow
////CDVideoLocalRenderObject
void CDVideoLocalRenderObjectStateOneProcessingFlow(CDVideoLocalRenderObject * _Nullable vlrobj,BOOL SAVEHERE,BOOL SYNCSAVE);
NSString*  _Nullable  replaceAPPIDInABSURLString(NSString*  _Nullable str,NSString *  _Nullable newAPPIDInPath);




////----GPUImage
#import "GPUImage.h"
GPUImageFilter * _Nonnull installGPUImageFilter(NSString * _Nullable filterName,NSMutableDictionary * _Nullable parameters);
void applySingleInputGPUImageFilterAndWait(AVAsset *  _Nullable asset,AVAssetTrack *  _Nullable  vt,GPUImageFilter *  _Nullable  filter,NSURL *  _Nullable  destVideoURL);
void applyGPUImageFilterToVideoAndWait(NSURL * _Nullable srcVideoURL,NSURL * _Nullable destVideoURL, NSString * _Nullable filterName,NSMutableDictionary * _Nullable parameters);
