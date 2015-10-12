//
//  UIDrawableSubclasses.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 04/05/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "UIDrawableSubclasses.h"

@implementation UIDrawableSubclasses

@end

@implementation DrawableTextView

IBInspectable
-(void)setBorderColor:(UIColor *)color
{
    super.layer.borderColor = color.CGColor;
}

IBInspectable
-(void)setBorderWidth:(CGFloat)width
{
    super.layer.borderWidth = width;
}

IBInspectable
-(void)setCornerRadius:(CGFloat)radius
{
    super.layer.cornerRadius = radius;
}

@end
