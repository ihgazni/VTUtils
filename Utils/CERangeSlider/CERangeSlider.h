//
//  CERangeSlider.h
//  UView
//
//  Created by dli on 11/23/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CERangeSlider : UIControl


@property (nonatomic) float maxValue;
@property (nonatomic) float minValue;
@property (nonatomic) float upperValue;
@property (nonatomic) float lowerValue;







@property (nonatomic) NSString * trackBackGroundImageName;
@property (nonatomic) NSString * trackImageName;
@property (nonatomic) NSString * upperKnobImageName;
@property (nonatomic) NSString * lowerKnobImageName;
@property (nonatomic) NSString * upperKnobHighLightedImageName;
@property (nonatomic) NSString * lowerKnobHighLightedImageName;


@property (nonatomic) UIImage * trackBackGroundImage;
@property (nonatomic) UIImage * trackImage;
@property (nonatomic) UIImage * upperKnobImage;
@property (nonatomic) UIImage * lowerKnobImage;
@property (nonatomic) UIImage * upperKnobHighLightedImage;
@property (nonatomic) UIImage * lowerKnobHighLightedImage;



@property (nonatomic) float lowerKnobWidth;
@property (nonatomic) float lowerKnobHeight;
@property (nonatomic) float upperKnobWidth;
@property (nonatomic) float upperKnobHeight;




- (void)applyInitParameters;


@end
