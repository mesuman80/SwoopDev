//
//  BaseViewController.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 22/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

-(void)switchToTabbar;
-(void)switchToLogin;

-(void)addLeftViewsInTextfields:(NSArray *)textfields withImageNames:(NSArray *)imageNames;

@end
