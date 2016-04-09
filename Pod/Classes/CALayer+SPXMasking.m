/*
 Copyright (c) 2015 Shaps Mohsenin. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY Shaps Mohsenin `AS IS' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL Shaps Mohsenin OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "CALayer+SPXMasking.h"
#import <objc/runtime.h>

static IMP __original_Method_Imp;
int _replacement_Method(CALayer *self, SEL _cmd, CGFloat _value)
{
  assert([NSStringFromSelector(_cmd) isEqualToString:@"setCornerRadius:"]);
  self.cornerRadii = SPXCornerRadiiZero;
  return ((int(*)(CALayer*, SEL, CGFloat))__original_Method_Imp)(self, _cmd, _value);
}


SPXCornerStyles SPXCornerStylesMake(SPXCornerStyle bottomLeft, SPXCornerStyle topLeft, SPXCornerStyle topRight, SPXCornerStyle bottomRight)
{
  SPXCornerStyles style = { bottomLeft, topLeft, topRight, bottomRight };
  return style;
}

const SPXCornerRadii SPXCornerRadiiZero;

SPXCornerRadii SPXCornerRadiiMake(CGFloat bottomLeft, CGFloat topLeft, CGFloat topRight, CGFloat bottomRight)
{
  SPXCornerRadii cornerRadii = { bottomLeft, topLeft, topRight, bottomRight };
  return cornerRadii;
}

bool SPXCornerRadiiEquals(SPXCornerRadii radii1, SPXCornerRadii radii2)
{
  return (radii1.topLeft == radii2.topLeft &&
          radii1.topRight == radii2.topRight &&
          radii1.bottomLeft == radii2.bottomLeft &&
          radii1.bottomRight == radii2.bottomRight
          );
}

@implementation CALayer (SPXMasking)

+ (void)load
{
  Method method = class_getInstanceMethod([self class], @selector(setCornerRadius:));
  __original_Method_Imp = method_setImplementation(method, (IMP)_replacement_Method);
}

- (UIBezierPath *)maskPath
{
  if (![self.mask isKindOfClass:[CAShapeLayer class]]) {
    return nil;
  }
  
  CAShapeLayer *maskLayer = (CAShapeLayer *)self.mask;
  return [UIBezierPath bezierPathWithCGPath:maskLayer.path];
}

- (SPXCornerRadii)cornerRadii
{
  NSValue *value = objc_getAssociatedObject(self, @selector(cornerRadii));
  UIEdgeInsets insets = [value UIEdgeInsetsValue];
  SPXCornerRadii radii = SPXCornerRadiiMake(insets.top, insets.left, insets.bottom, insets.right);
  return radii;
}

- (void)setCornerRadii:(SPXCornerRadii)radii
{
  if (SPXCornerRadiiEquals(radii, SPXCornerRadiiZero)) {
    self.mask = nil;
    return;
  }
  
  if (SPXCornerRadiiEquals(radii, self.cornerRadii)) {
    return;
  }
  
  UIEdgeInsets insets = UIEdgeInsetsMake(radii.bottomLeft, radii.topLeft, radii.topRight, radii.bottomRight);
  NSValue *value = [NSValue valueWithUIEdgeInsets:insets];
  objc_setAssociatedObject(self, @selector(cornerRadii), value, OBJC_ASSOCIATION_COPY_NONATOMIC);
  
  [self spx_updateMaskPath];
}

- (SPXCornerStyles)cornerStyles
{
  NSValue *value = objc_getAssociatedObject(self, @selector(cornerStyles));
  UIEdgeInsets insets = [value UIEdgeInsetsValue];
  SPXCornerStyles styles = SPXCornerStylesMake((NSInteger)insets.top, (NSInteger)insets.left, (NSInteger)insets.bottom, (NSInteger)insets.right);
  return styles;
}

- (void)layoutSublayers
{
  [self spx_updateMaskPath];
}

- (void)setCornerStyles:(SPXCornerStyles)cornerStyles
{
  UIEdgeInsets insets = UIEdgeInsetsMake((NSInteger)cornerStyles.bottomLeft, (NSInteger)cornerStyles.topLeft, (NSInteger)cornerStyles.topRight, (NSInteger)cornerStyles.bottomRight);
  NSValue *value = [NSValue valueWithUIEdgeInsets:insets];
  objc_setAssociatedObject(self, @selector(cornerStyles), value, OBJC_ASSOCIATION_COPY_NONATOMIC);
  
  [self spx_updateMaskPath];
}

- (void)spx_updateMaskPath
{
  if (SPXCornerRadiiEquals(self.cornerRadii, SPXCornerRadiiZero)) {
    return;
  }
  
  self.cornerRadius = 0;
  
  CGFloat bottomLeft = fabs(self.cornerRadii.bottomLeft);
  CGFloat topLeft = fabs(self.cornerRadii.topLeft);
  CGFloat topRight = fabs(self.cornerRadii.topRight);
  CGFloat bottomRight = fabs(self.cornerRadii.bottomRight);
  
  UIBezierPath *path = [UIBezierPath bezierPath];
  CGRect rect = self.bounds;
  
  [path moveToPoint:CGPointMake(CGRectGetMinX(rect) + bottomLeft, CGRectGetMaxY(rect) - bottomLeft)];
  {
    if (bottomLeft) {
      CGPoint point = CGPointMake(CGRectGetMinX(rect) + bottomLeft, CGRectGetMaxY(rect) - bottomLeft);
      
      if (self.cornerStyles.bottomLeft == SPXCornerStyleHard) {
        [path addLineToPoint:point];
      }
      
      if (self.cornerStyles.bottomLeft == SPXCornerStyleRounded) {
        [path addArcWithCenter:point radius:bottomLeft startAngle:90 * M_PI / 180 endAngle:180 * M_PI / 180 clockwise:YES];
      }
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    if (topLeft) {
      CGPoint point = CGPointMake(CGRectGetMinX(rect) + topLeft, CGRectGetMinY(rect) + topLeft);
      
      if (self.cornerStyles.topLeft == SPXCornerStyleHard) {
        [path addLineToPoint:point];
      }
      
      if (self.cornerStyles.topLeft == SPXCornerStyleRounded) {
        [path addArcWithCenter:point radius:topLeft startAngle:180 * M_PI / 180 endAngle:270 * M_PI / 180 clockwise:YES];
      }
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    if (topRight) {
      CGPoint point = CGPointMake(CGRectGetMaxX(rect) - topRight, CGRectGetMinY(rect) + topRight);
      
      if (self.cornerStyles.topRight == SPXCornerStyleHard) {
        [path addLineToPoint:point];
      }
      
      if (self.cornerStyles.topRight == SPXCornerStyleRounded) {
        [path addArcWithCenter:point radius:topRight startAngle:270 * M_PI / 180 endAngle:0 * M_PI / 180 clockwise:YES];
      }
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    if (bottomRight) {
      CGPoint point = CGPointMake(CGRectGetMaxX(rect) - bottomRight, CGRectGetMaxY(rect) - bottomRight);
      
      if (self.cornerStyles.bottomRight == SPXCornerStyleHard) {
        [path addLineToPoint:point];
      }
      
      if (self.cornerStyles.bottomRight == SPXCornerStyleRounded) {
        [path addArcWithCenter:point radius:bottomRight startAngle:0 * M_PI / 180 endAngle:90 * M_PI / 180 clockwise:YES];
      }
    }
  }
  [path addLineToPoint:CGPointMake(CGRectGetMinX(rect) + bottomLeft, CGRectGetMaxY(rect))];
  [path closePath];
  
  CAShapeLayer *maskLayer = [CAShapeLayer layer];
  maskLayer.path = path.CGPath;
  self.mask = maskLayer;
}

@end

