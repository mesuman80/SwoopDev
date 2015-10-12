//
//  UIDrawableSubclasses.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 04/05/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDrawableSubclasses : NSObject

@end

IB_DESIGNABLE

@interface DrawableTextView : UITextView
{
    IBInspectable UIColor *borderColor;
    IBInspectable CGFloat borderWidth;
    IBInspectable CGFloat cornerRadius;
}

@end
