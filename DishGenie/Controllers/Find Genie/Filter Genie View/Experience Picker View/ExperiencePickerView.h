//
//  ExperiencePickerView.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 11/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionSheetPicker.h"

@interface ExperiencePickerView : NSObject

+(instancetype)showPickerWithTitle:(NSString *)title initialSelectedText:(NSString *)selectedText datasource:(NSArray *)datasource delegate:(id)delegate origin:(id)origin doneBlock:(void(^)(NSString *selectedText))doneBlock;

@end
