//
//  FilterGenieView.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 23/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterGenieView : UIView

@property (weak, nonatomic) IBOutlet UITextField *tf_Exp;
@property (weak, nonatomic) IBOutlet UITextField *tf_Rating;
@property (weak, nonatomic) IBOutlet UITextField *tf_Gender;

//-(void)showExperiencePicker:(id)sender;
-(void)showRatingPicker:(id)sender;
-(void)showGenderPicker:(id)sender;

-(void)toggleView;

@end
