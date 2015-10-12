//
//  FilterGenieView.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 23/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "FilterGenieView.h"

#import "ActionSheetPicker.h"
#import "RatingsDropdownView.h"

#define kCollapsedHeight 46.0f
#define kExpandedHeight 223.0f
#define isExpanded [self.c_Height constant] == kExpandedHeight

@interface FilterGenieView ()

@property (weak, nonatomic) IBOutlet UIImageView *imgV_BG;
@property (weak, nonatomic) IBOutlet UIImageView *imgV_Arrow;
@property (weak, nonatomic) IBOutlet UIView *view_Dropdown;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *c_Height;

@end

@implementation FilterGenieView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setClipsToBounds:YES];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *placeholderColor = [UIColor colorWithRed:0.00 green:0.61 blue:0.73 alpha:1.00];
    
    [self.tf_Exp setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Experience" attributes:@{NSForegroundColorAttributeName: placeholderColor}]];
    [self.tf_Rating setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Ratings" attributes:@{NSForegroundColorAttributeName: placeholderColor}]];
    [self.tf_Gender setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Gender" attributes:@{NSForegroundColorAttributeName: placeholderColor}]];
}

-(IBAction)didTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint pointTouch = [tapGesture locationInView:self];
    
    if (pointTouch.y <= kCollapsedHeight)
    {
        [self toggleView];
    }
}

-(void)toggleView
{
    if (isExpanded)
    {
        [self.view_Dropdown setHidden:YES];
        self.imgV_Arrow.transform = CGAffineTransformMakeRotation(0);
        [self.imgV_BG setImage:[UIImage imageNamed:@"search_background"]];
        [self.c_Height setConstant:kCollapsedHeight];
    }
    else
    {
        [self.view_Dropdown setHidden:NO];
        self.imgV_Arrow.transform = CGAffineTransformMakeRotation(M_PI);
        [self.imgV_BG setImage:[UIImage imageNamed:@"search_background_expend"]];
        [self.c_Height setConstant:kExpandedHeight];
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self layoutIfNeeded];
    }];
}

-(void)showRatingPicker:(id)sender
{
    NSArray *ratings = @[@"Select",
                         [UIImage imageNamed:@"1star"],
                         [UIImage imageNamed:@"2star"],
                         [UIImage imageNamed:@"3star"],
                         [UIImage imageNamed:@"4star"],
                         [UIImage imageNamed:@"5star"]];
    
    NSString *text = [self.tf_Rating text];
    NSInteger index_sel = 0;
    
    if ([text length])
    {
        index_sel = [text integerValue];
    }
    
    [RatingsDropdownView showPickerWithTitle:@"Select Rating" initialSelectedIndex:index_sel datasource:ratings delegate:self origin:self doneBlock:^(NSInteger selectedIndex)
    {
        if (selectedIndex == 0)
        {
            [self.tf_Rating setText:nil];
        }
        else
        {
            [self.tf_Rating setText:[@(selectedIndex) stringValue]];
        }
    }];
}

-(void)showGenderPicker:(id)sender
{
    NSArray *gender = @[@"Select",
                        @"Male",
                        @"Female",
                        @"Other"];
    
    NSString *text = [self.tf_Gender text];
    NSInteger index_sel = 0;
    
    if ([text length])
    {
        index_sel = [gender indexOfObject:text];
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Gender" rows:gender initialSelection:index_sel doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        if (selectedIndex == 0)
        {
            [self.tf_Gender setText:nil];
        }
        else
        {
            [self.tf_Gender setText:[gender objectAtIndex:selectedIndex]];
        }
    }
    cancelBlock:nil origin:sender];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
