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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSInteger, SPXCornerStyle)
{
  SPXCornerStyleRounded,
  SPXCornerStyleHard,
  SPXCornerStyleConcave,
};


/**
 * Defines a structure for representing the radius for each corner of a rectangle
 */
typedef struct SPXCornerRadii {
  CGFloat bottomLeft, topLeft, topRight, bottomRight;
} SPXCornerRadii;


/**
 *  Defines a structure for representing the style for each corner of a rectangle
 */
typedef struct SPXCornerStyles {
  SPXCornerStyle bottomLeft, topLeft, topRight, bottomRight;
} SPXCornerStyles;


/**
 *  Returns a new corner styles structure with the specified styles
 *
 *  @param bottomLeft  The bottom left style
 *  @param topLeft     The top left style
 *  @param topRight    The top right style
 *  @param bottomRight The bottom right style
 *
 *  @return A corner styles structure
 */
extern SPXCornerStyles SPXCornerStylesMake(SPXCornerStyle bottomLeft, SPXCornerStyle topLeft, SPXCornerStyle topRight, SPXCornerStyle bottomRight);


/**
 *  Returns a corner radii where all corners have a radius of 0
 *
 *  @return A corner radii structure
 */
extern const SPXCornerRadii SPXCornerRadiiZero;


/**
 *  Returns a new corner radii structure with the specified radii
 *
 *  @param bottomLeft  The bottom left radius
 *  @param topLeft     The top left radius
 *  @param topRight    The top right radius
 *  @param bottomRight The bottom right radius
 *
 *  @return A corner radii structure
 */
extern SPXCornerRadii SPXCornerRadiiMake(CGFloat bottomLeft, CGFloat topLeft, CGFloat topRight, CGFloat bottomRight);


/**
 *  Compares two SPXCornerRadii structures to determine equality
 *
 *  @param radii1 The first radii structure
 *  @param radii2 The second radii structure
 *
 *  @return YES if (radii1 == radii2). NO otherwise
 */
extern bool SPXCornerRadiiEquals(SPXCornerRadii radii1, SPXCornerRadii radii2);


/**
 *  Adds support for different corner radii on a layer
 */
@interface CALayer (SPXMasking)


/**
 *  Sets/gets the corner style to apply to this layer
 */
@property (nonatomic, assign) SPXCornerStyles cornerStyles;


/**
 *  Sets/gets the corner radii for the layer
 */
@property (nonatomic, assign) SPXCornerRadii cornerRadii;


/**
 *  Returns the current path applied to mask for this layer if its a CAShapeLayer
 *
 *  @return A UIBezier path if a mask is applied and is a CAShapeLayer, nil otherwise
 */
- (UIBezierPath *)maskPath;


@end


