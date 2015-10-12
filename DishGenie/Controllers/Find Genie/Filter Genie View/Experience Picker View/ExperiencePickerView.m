//
//  ExperiencePickerView.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 11/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "ExperiencePickerView.h"

@interface ExperiencePickerView () <ActionSheetCustomPickerDelegate>

@property (nonatomic) NSArray *datasource;

@end

@implementation ExperiencePickerView
{
    NSArray *selectedValues;
    void(^completionBlock)(NSString *selectedText);
}

+(instancetype)showPickerWithTitle:(NSString *)title initialSelectedText:(NSString *)selectedText datasource:(NSArray *)datasource delegate:(id)delegate origin:(id)origin doneBlock:(void (^)(NSString *))doneBlock
{
    ExperiencePickerView *expPicker = [[ExperiencePickerView alloc] initWithTitle:title initialSelectedText:selectedText datasource:datasource delegate:delegate origin:origin doneBlock:doneBlock];
    return expPicker;
}

-(instancetype)initWithTitle:(NSString *)title initialSelectedText:(NSString *)selectedText datasource:(NSArray *)datasource delegate:(id)delegate origin:(id)origin doneBlock:(void (^)(NSString *))doneBlock
{
    self = [super init];
    if (self)
    {
        completionBlock = doneBlock;
        self.datasource = datasource;
        
        if (selectedText)
        {
            NSInteger a = [datasource indexOfObject:[selectedText substringWithRange:NSMakeRange(0, 1)]];
            NSInteger b = [datasource indexOfObject:[selectedText substringWithRange:NSMakeRange(1, 1)]];
            NSInteger c = [datasource indexOfObject:[selectedText substringWithRange:NSMakeRange(2, 1)]];
            NSInteger d = [datasource indexOfObject:[selectedText substringWithRange:NSMakeRange(3, 1)]];
            
            selectedValues = @[@(a), @(b), @(c), @(d)];
        }
        
        [ActionSheetCustomPicker showPickerWithTitle:title delegate:self showCancelButton:YES origin:origin];
    }
    return self;
}

#pragma mark - PickerView delegate methods
-(void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView
{
    if (selectedValues)
    {
        [selectedValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            [pickerView selectRow:[obj integerValue] inComponent:idx animated:NO];
        }];
    }
}

-(void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    if (completionBlock)
    {
        NSInteger a = [(UIPickerView *)[actionSheetPicker pickerView] selectedRowInComponent:0];
        NSInteger b = [(UIPickerView *)[actionSheetPicker pickerView] selectedRowInComponent:1];
        NSInteger c = [(UIPickerView *)[actionSheetPicker pickerView] selectedRowInComponent:2];
        NSInteger d = [(UIPickerView *)[actionSheetPicker pickerView] selectedRowInComponent:3];
        
        completionBlock([NSString stringWithFormat:@"%@%@%@%@",self.datasource[a], self.datasource[b], self.datasource[c], self.datasource[d]]);
        completionBlock = nil;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.datasource count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.datasource[row];
}

@end
