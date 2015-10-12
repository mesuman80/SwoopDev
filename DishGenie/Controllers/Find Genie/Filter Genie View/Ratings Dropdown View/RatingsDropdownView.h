//
//  RatingsDropdownView.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 12/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ActionSheetPicker.h"

@interface RatingsDropdownView : NSObject

+(instancetype)showPickerWithTitle:(NSString *)title initialSelectedIndex:(NSInteger)selectedIndex datasource:(NSArray *)datasource delegate:(id)delegate origin:(id)origin doneBlock:(void (^)(NSInteger selectedIndex))doneBlock;

@end
