/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);
 
@interface UIView (ViewFrameGeometry)
@property CGPoint origin;
@property CGSize size;

@property CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat heights;
@property CGFloat widths;

@property CGFloat tops;
@property CGFloat lefts;

@property CGFloat bottoms;
@property CGFloat rights;

@property CGFloat centerXs;
@property CGFloat centerYs;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;
@end