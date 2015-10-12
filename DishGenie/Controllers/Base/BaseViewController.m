//
//  BaseViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 22/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

-(void)switchToTabbar
{
    UIWindow *window = [Utility getApplicationWindow];
    
    [UIView transitionWithView:window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [window setRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"TabbarNavigationController"]];
                    }
                    completion:nil];
}

-(void)switchToLogin
{
    UIWindow *window = [Utility getApplicationWindow];
    
    [UIView transitionWithView:window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [window setRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"]];
                    }
                    completion:nil];
}

-(void)addLeftViewsInTextfields:(NSArray *)textfields withImageNames:(NSArray *)imageNames
{
    [textfields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [imgV setImage:[UIImage imageNamed:[imageNames objectAtIndex:idx]]];
        [imgV setContentMode:UIViewContentModeCenter];
        [obj setLeftView:imgV];
        [obj setLeftViewMode:UITextFieldViewModeAlways];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
