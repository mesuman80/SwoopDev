//
//  RatingsDropdownView.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 12/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "RatingsDropdownView.h"

@interface RatingsDropdownView () <ActionSheetCustomPickerDelegate>

@property (nonatomic) NSArray *datasource;

@end

@implementation RatingsDropdownView
{
    NSInteger picker_selectedIndex;
    void(^completionBlock)(NSInteger selectedIndex);
}

+(instancetype)showPickerWithTitle:(NSString *)title initialSelectedIndex:(NSInteger)selectedIndex datasource:(NSArray *)datasource delegate:(id)delegate origin:(id)origin doneBlock:(void (^)(NSInteger))doneBlock
{
    RatingsDropdownView *ratingsDropdown = [[RatingsDropdownView alloc] initWithTitle:title initialSelectedIndex:selectedIndex datasource:datasource delegate:delegate origin:origin doneBlock:doneBlock];
    return ratingsDropdown;
}

-(instancetype)initWithTitle:(NSString *)title initialSelectedIndex:(NSInteger)selectedIndex datasource:(NSArray *)datasource delegate:(id)delegate origin:(id)origin doneBlock:(void (^)(NSInteger))doneBlock
{
    self = [super init];
    if (self)
    {
        completionBlock = doneBlock;
        self.datasource = datasource;
        picker_selectedIndex = selectedIndex;
        
        [ActionSheetCustomPicker showPickerWithTitle:title delegate:self showCancelButton:YES origin:origin];
    }
    return self;
}

#pragma mark - PickerView delegate methods
-(void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView
{
    if (picker_selectedIndex)
    {
        [pickerView selectRow:picker_selectedIndex inComponent:0 animated:NO];
    }
}

-(void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    if (completionBlock)
    {
        completionBlock([(UIPickerView *)[actionSheetPicker pickerView] selectedRowInComponent:0]);
        completionBlock = nil;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.datasource count];
}

//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return self.datasource[row];
//}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if ([[self.datasource objectAtIndex:row] isKindOfClass:[NSString class]])
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView frame].size.width, 30.0f)];
        [lbl setText:[self.datasource objectAtIndex:row]];
        [lbl setFont:[UIFont systemFontOfSize:22.0f]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        return lbl;
    }
    return [[UIImageView alloc] initWithImage:[self.datasource objectAtIndex:row]];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0f;
}

@end
