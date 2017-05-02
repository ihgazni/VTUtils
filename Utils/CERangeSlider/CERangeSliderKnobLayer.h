//
//  CERangeSliderKnobLayer.h
//  UView
//
//  Created by dli on 11/24/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class CERangeSlider;

@interface CERangeSliderKnobLayer : CALayer

@property BOOL highlighted;
@property (weak) CERangeSlider* slider;

@end