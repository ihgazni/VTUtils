//
//  CERangeSlider.m
//  UView
//
//  Created by dli on 11/23/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import "CERangeSlider.h"
#import <QuartzCore/QuartzCore.h>
#import "CERangeSliderKnobLayer.h"
#import "UIImageTools.h"

@implementation CERangeSlider

{
    CERangeSlider* _rangeSlider;
    
    CALayer* _trackLayer;
    CERangeSliderKnobLayer* _upperKnobLayer;
    CERangeSliderKnobLayer* _lowerKnobLayer;
    
    float _knobWidth;
    float _useableTrackLength;
    
    CGPoint _previousTouchPoint;
    CGPoint _previousUpperTouchPoint;
    CGPoint _previousLowerTouchPoint;
    
    NSString * _previousUpperTouchKey;
    NSString * _previousLowerTouchKey;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/






    

    

        ////[self setLayerFrames];
        

        
        
- (void)applyInitParameters
{
    if (_trackImage == NULL) {
        _trackImage = [UIImage imageNamed:_trackImageName];
    } else {
        NSLog(@"_trackImage  inited:%@",_trackImage);
    }
    
    if (_upperKnobImage == NULL) {
        _upperKnobImage = [UIImage imageNamed:_upperKnobImageName];
    }
    
    if (_lowerKnobImage == NULL) {
        _lowerKnobImage = [UIImage imageNamed:_lowerKnobImageName];
    }
    
    if (_upperKnobHighLightedImage == NULL) {
        _upperKnobHighLightedImage = [UIImage imageNamed:_upperKnobHighLightedImageName];
    }
    
    if (_lowerKnobHighLightedImage == NULL) {
        _lowerKnobHighLightedImage = [UIImage imageNamed:_lowerKnobHighLightedImageName];
    }
    
    
    
    
    // Initialization code
    _maxValue = 10.0;
    _minValue = 0.0;
    _upperValue = 8.0;
    _lowerValue = 2.0;
    
    
    _trackLayer = [CALayer layer];
    _trackLayer.backgroundColor = [UIColor greenColor].CGColor;
    _trackLayer.opacity = 1.0;
    
    
    _trackLayer.contents = (id) _trackImage.CGImage;
    
    
    [self.layer addSublayer:_trackLayer];
    
    _upperKnobLayer = [CERangeSliderKnobLayer layer];
    _upperKnobLayer.slider = self;
    _upperKnobLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    
    _upperKnobLayer.contents = (id) _upperKnobImage.CGImage;
    
    [self.layer addSublayer:_upperKnobLayer];
    
    _lowerKnobLayer = [CERangeSliderKnobLayer layer];
    _lowerKnobLayer.slider = self;
    _lowerKnobLayer.backgroundColor = [UIColor grayColor].CGColor;
    _lowerKnobLayer.contents = (id) _lowerKnobImage.CGImage;
    
    [self.layer addSublayer:_lowerKnobLayer];
    
    
    
    
    _knobWidth = self.bounds.size.height;
    _useableTrackLength = self.bounds.size.width - _knobWidth;
    
    
    if ( _lowerKnobWidth == 0) {
        _lowerKnobWidth = _knobWidth / 2;
    }
    if ( _lowerKnobHeight == 0) {
        _lowerKnobHeight = _knobWidth;
    }
    
    if ( _upperKnobWidth == 0) {
        _upperKnobWidth = _knobWidth / 2;
    }
    if ( _upperKnobHeight == 0) {
        _upperKnobHeight = _knobWidth;
    }
    

    
    [self setLayerFrames];

}









- (void) setLayerFrames
{
    
    
    _trackLayer.frame = CGRectInset(self.bounds, 0, self.bounds.size.height / 3.5);
    ////[_trackLayer setNeedsDisplay];
    

    
    float upperKnobCentre = [self positionForValue:_upperValue which:true];
    _upperKnobLayer.frame = CGRectMake(upperKnobCentre - _upperKnobWidth / 2, 0, _upperKnobWidth , _upperKnobHeight);
    
    float lowerKnobCentre = [self positionForValue:_lowerValue which:false];
    _lowerKnobLayer.frame = CGRectMake(lowerKnobCentre - _lowerKnobWidth / 2, 0, _lowerKnobWidth , _lowerKnobHeight);
    
    
    ////NSLog(@"%lf",_lowerKnobLayer.frame.size.width);
    ////NSLog(@"%lf",_lowerKnobLayer.frame.size.height);
    
    
    ////UIImage * lKImage = [UIImage imageNamed:_lowerKnobImageName];
    
    
    ////NSLog(@"%lf",lKImage.size.width);
    ////NSLog(@"%lf",lKImage.size.height);
    
    ////[_upperKnobLayer setNeedsDisplay];
    ////[_lowerKnobLayer setNeedsDisplay];
    

    
}

- (float) positionForValue:(float)value which:(BOOL)isUpper
{
    if (isUpper) {
        return _useableTrackLength * (value - _minValue) /
        (_maxValue - _minValue) + (_upperKnobWidth / 2);
    } else {
        return _useableTrackLength * (value - _minValue) /
        (_maxValue - _minValue) + (_lowerKnobWidth / 2);
    }

}


/*
////-------------these can only track one UITouch at the same time
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _previousTouchPoint = [touch locationInView:self];
    
    
    if (CGRectContainsPoint(_lowerKnobLayer.frame, _previousTouchPoint)&&CGRectContainsPoint(_upperKnobLayer.frame, _previousTouchPoint))
    {
        _lowerKnobLayer.highlighted = YES;
        [_lowerKnobLayer setNeedsDisplay];
        _upperKnobLayer.highlighted = YES;
        [_upperKnobLayer setNeedsDisplay];
        
    } else if(CGRectContainsPoint(_lowerKnobLayer.frame, _previousTouchPoint))
    {
        _lowerKnobLayer.highlighted = YES;
        [_lowerKnobLayer setNeedsDisplay];
        
    } else if(CGRectContainsPoint(_upperKnobLayer.frame, _previousTouchPoint))
    {
        _upperKnobLayer.highlighted = YES;
        [_upperKnobLayer setNeedsDisplay];
    }
    return _upperKnobLayer.highlighted || _lowerKnobLayer.highlighted;
}


#define BOUND(VALUE, UPPER, LOWER)	MIN(MAX(VALUE, LOWER), UPPER)

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    // 1. determine by how much the user has dragged
    float delta = touchPoint.x - _previousTouchPoint.x;
    float valueDelta = (_maxValue - _minValue) * delta / _useableTrackLength;
    
    _previousTouchPoint = touchPoint;
    
    // 2. update the values
    if (_lowerKnobLayer.highlighted && _upperKnobLayer.highlighted) {
        
        _upperValue += valueDelta;
        ////_upperValue = BOUND(_upperValue, _maxValue, _lowerValue);
        _upperValue = BOUND(_upperValue, _maxValue, _minValue);
        
        _lowerValue += valueDelta - _knobWidth / 5;
        _lowerValue = BOUND(_lowerValue, _maxValue, _minValue);
        
    }
    else if (_lowerKnobLayer.highlighted)
    {
        _lowerValue += valueDelta;
        ////_lowerValue = BOUND(_lowerValue, _upperValue, _minValue);
        _lowerValue = BOUND(_lowerValue, _maxValue, _minValue);
    }
    else if (_upperKnobLayer.highlighted)
    {
        _upperValue += valueDelta;
        ////_upperValue = BOUND(_upperValue, _maxValue, _lowerValue);
        _upperValue = BOUND(_upperValue, _maxValue, _minValue);

    }
    
    // 3. Update the UI state
    [CATransaction begin];
    [CATransaction setDisableActions:YES] ;
    
    [self setLayerFrames];
    
    [CATransaction commit];
    
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _lowerKnobLayer.highlighted = _upperKnobLayer.highlighted = NO;
    [_lowerKnobLayer setNeedsDisplay];
    [_upperKnobLayer setNeedsDisplay];
}
 
////--------------these can only track one UITouch at the same time
*/





- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    for (UITouch * touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        
        NSLog(@"%@:touches   cancelled",key);
        
        
    }
    
}


- (void)touchesEstimatedPropertiesUpdated:(NSSet *)touches
{
    
    for (UITouch * touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        
        NSLog(@"%@:touches EstimatedPropertiesUpdated",key);
        
        
    }
    
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
    
    for (UITouch * touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];

        _previousTouchPoint = [touch locationInView:self];
        
  
        
        if (CGRectContainsPoint(_lowerKnobLayer.frame, _previousTouchPoint)&& CGRectContainsPoint(_upperKnobLayer.frame, _previousTouchPoint))
        {
            _lowerKnobLayer.highlighted = YES;
            

            _lowerKnobLayer.contents = (id) _lowerKnobHighLightedImage.CGImage;
            
            
            _previousLowerTouchPoint = _previousTouchPoint;
            _previousLowerTouchKey = key;
            ////[_lowerKnobLayer setNeedsDisplay];
            
            _upperKnobLayer.highlighted = YES;
            

            _upperKnobLayer.contents = (id) _upperKnobHighLightedImage.CGImage;
            
            
            _previousUpperTouchPoint = _previousTouchPoint;
            _previousUpperTouchKey = key;
            ////[_upperKnobLayer setNeedsDisplay];
            
            NSLog(@"%@:touches begin  overlaped",key);
            
            
        } else if(CGRectContainsPoint(_lowerKnobLayer.frame, _previousTouchPoint))
        {
            _lowerKnobLayer.highlighted = YES;
            

            _lowerKnobLayer.contents = (id) _lowerKnobHighLightedImage.CGImage;
            
            
            
            _previousLowerTouchPoint = _previousTouchPoint;
            _previousLowerTouchKey = key;
            ////[_lowerKnobLayer setNeedsDisplay];
            
            NSLog(@"%@:touches begin  lower",key);
            
            
        } else if(CGRectContainsPoint(_upperKnobLayer.frame, _previousTouchPoint))
        {
            _upperKnobLayer.highlighted = YES;
            

            _upperKnobLayer.contents = (id) _upperKnobHighLightedImage.CGImage;
            
            _previousUpperTouchPoint = _previousTouchPoint;
            _previousUpperTouchKey = key;
            ////[_upperKnobLayer setNeedsDisplay];
            
             NSLog(@"%@:touches begin  upper",key);
            
        }
        
        
        
    

    }
    
   
    
}


#define BOUND(VALUE, UPPER, LOWER)	MIN(MAX(VALUE, LOWER), UPPER)


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];

        
        
        CGPoint touchPoint = [touch locationInView:self];
        

        
        
        BOOL cond1 = [_previousLowerTouchKey isEqualToString: key];
        BOOL cond2 = [_previousUpperTouchKey isEqualToString: key];
        

        
        
        // 2. update the values
        if (_lowerKnobLayer.highlighted && _upperKnobLayer.highlighted && cond1 && cond2) {
            
        
            float delta = touchPoint.x - _previousUpperTouchPoint.x;
            float valueDelta = (_maxValue - _minValue) * delta / _useableTrackLength;
            _previousUpperTouchPoint = touchPoint;
            
            _upperValue += valueDelta;
            ////_upperValue = BOUND(_upperValue, _maxValue, _lowerValue);
            _upperValue = BOUND(_upperValue, _maxValue, _minValue);
            
            
            delta = touchPoint.x - _previousLowerTouchPoint.x;
            valueDelta = (_maxValue - _minValue) * delta / _useableTrackLength;
            _previousLowerTouchPoint = touchPoint;
            
            _lowerValue += valueDelta - _knobWidth / 3;
            _lowerValue = BOUND(_lowerValue, _maxValue, _minValue);
            
        }
        else if (_lowerKnobLayer.highlighted && cond1)
        {
            
            
            float delta = touchPoint.x - _previousLowerTouchPoint.x;
            float valueDelta = (_maxValue - _minValue) * delta / _useableTrackLength;
            _previousLowerTouchPoint = touchPoint;
            _lowerValue += valueDelta;
            ////_lowerValue = BOUND(_lowerValue, _upperValue, _minValue);
            _lowerValue = BOUND(_lowerValue, _maxValue, _minValue);
        }
        else if (_upperKnobLayer.highlighted && cond2)
        {
            float delta = touchPoint.x - _previousUpperTouchPoint.x;
            float valueDelta = (_maxValue - _minValue) * delta / _useableTrackLength;
            _previousUpperTouchPoint = touchPoint;
            _upperValue += valueDelta;
            ////_upperValue = BOUND(_upperValue, _maxValue, _lowerValue);
            _upperValue = BOUND(_upperValue, _maxValue, _minValue);
            
        }
        
        
        // 3. Update the UI state
        [CATransaction begin];
        [CATransaction setDisableActions:YES] ;
        
        [self setLayerFrames];
        
        [CATransaction commit];
        
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        
     
    }
    

}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];

        BOOL cond1 = [_previousLowerTouchKey isEqualToString: key];
        BOOL cond2 = [_previousUpperTouchKey isEqualToString: key];
        
        if (_lowerKnobLayer.highlighted && _upperKnobLayer.highlighted && cond1 && cond2) {
            _lowerKnobLayer.highlighted = NO;
            

            _lowerKnobLayer.contents = (id) _lowerKnobImage.CGImage;
            
            ////[_lowerKnobLayer setNeedsDisplay];
            
            
            _upperKnobLayer.highlighted = NO;
            
            _upperKnobLayer.contents = (id) _upperKnobImage.CGImage;
            ////[_upperKnobLayer setNeedsDisplay];
            
        } else if (_lowerKnobLayer.highlighted && cond1)
        {
            _lowerKnobLayer.highlighted = NO;
            
            _lowerKnobLayer.contents = (id) _lowerKnobImage.CGImage;
            ////[_lowerKnobLayer setNeedsDisplay];

        }
        else if (_upperKnobLayer.highlighted && cond2)
        {
            _upperKnobLayer.highlighted = NO;
            
            _upperKnobLayer.contents = (id) _upperKnobImage.CGImage;
            
            ////[_upperKnobLayer setNeedsDisplay];
        }
        ////[self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}




@end
