//
//  RateUserViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 04/05/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "RateUserViewController.h"

#import "NZCircularImageView.h"
#import "EDStarRating.h"
#import "NotificationViewController.h"

@interface RateUserViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet NZCircularImageView *imgV_Genie;
@property (weak, nonatomic) IBOutlet UILabel *lbl_GenieName;
@property (weak, nonatomic) IBOutlet EDStarRating *rating;

@end

@implementation RateUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUIComponents];
    
    [self.lbl_GenieName setText:self.userName];
    [self.imgV_Genie setImageWithResizeURL:self.userImage
                          placeholderImage:[UIImage imageNamed:@"img_placeholder"]
               usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
}

-(IBAction)submitRating:(id)sender
{
    [NetworkClient request:kN_SendRating withParameters:@{@"user_id":self.userID, @"genie_id":self.genieID, @"rating":[@(_rating.rating) stringValue], @"rate_by":[(Record *)[Utility getUser] type], @"job_id":self.jobID} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
    {
        [Utility hideHUD];
        
        if ([model isSuccess])
        {
            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:self];
        }
        else
        {
            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
        }
    }
    andErrorBlock:nil];
}

#pragma mark - Alertview delegate method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    if ([self.title rangeOfString:@"Genie"].location != NSNotFound)
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    else
    {
        [self performSegueWithIdentifier:@"UnwindToNotifications" sender:self];
    }
}

-(void)configureUIComponents
{
    [self.imgV_Genie setBorderWidth:@3];
    
    _rating.starImage = [UIImage imageNamed:@"star_inactive"];
    _rating.starHighlightedImage = [UIImage imageNamed:@"star_active"];
    _rating.maxRating = 5.0;
    _rating.editable = YES;
    _rating.displayMode = EDStarRatingDisplayFull;
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
