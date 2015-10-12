//
//  NotificationViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 22/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "NotificationViewController.h"

#import "HMSegmentedControl.h"
#import "NotificationTableViewController.h"
#import "NotificationDetailViewController.h"
#import "MZTimerLabel.h"
#import "RateUserViewController.h"
#import "PaymentManager.h"

@interface NotificationViewController () <MZTimerLabelDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet HMSegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIView *view_Notification;
@property (weak, nonatomic) IBOutlet UIView *view_OnGoingJob;

@property (weak, nonatomic) IBOutlet UILabel *lbl_NoJobsAvailable;
@property (weak, nonatomic) IBOutlet UIView *view_Job;

@property (weak, nonatomic) IBOutlet UILabel *lbl_Desc;
@property (weak, nonatomic) IBOutlet MZTimerLabel *lbl_Timer;

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

@end

@implementation NotificationViewController
{
    Record *onGoingJob;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUIComponents];
    
    [self.lbl_NoJobsAvailable setHidden:NO];
    [self.view_Job setHidden:YES];
}

- (IBAction)cancelJob:(id)sender
{
    [NetworkClient request:kN_JobAction withParameters:@{@"job_id":[onGoingJob idd], @"status":@"canceled", @"sender_id":[[Utility getUser] idd], @"receiver_id":[onGoingJob user_id], @"start_time":[onGoingJob start_time], @"end_time":[onGoingJob end_time]} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
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

- (IBAction)confirmJob:(id)sender
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"job_id":[onGoingJob idd], @"status":@"completed", @"sender_id":[[Utility getUser] idd], @"receiver_id":[onGoingJob user_id], @"start_time":[onGoingJob start_time], @"end_time":[onGoingJob end_time]}];
    
    if ([[(Record *)[Utility getUser] type] isEqualToString:kPaypal])
    {
        [parameters setValue:[[PaymentManager sharedManager] getClientMetadataId] forKey:@"ClientMetadataId"];
    }
    
    [NetworkClient request:kN_JobAction withParameters:parameters shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
    {
        [Utility hideHUD];
        
        if ([model isSuccess])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[model messageStatus] message:[model messageContent] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView setTag:1];
            [alertView show];
        }
        else
        {
            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
        }
    }
    andErrorBlock:nil];
}

-(void)requestOnGoingJob
{
    Record *user = [Utility getUser];
    
    [NetworkClient request:kN_CurrentJob withParameters:@{@"user_id":[user idd], @"type":[user type]} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
    {
        [Utility hideHUD];
        
        if ([model isSuccess])
        {
            if ([[model records] count])
            {
                [self.lbl_NoJobsAvailable setHidden:YES];
                [self.view_Job setHidden:NO];
                
                Record *job = [[model records] firstObject];
                
//                NSDate *endTime = [Utility getDate:[job end_time] fromFormat:@"yyyy-MM-dd HH:mm:ss"];
//                NSTimeInterval interval = [endTime timeIntervalSinceDate:[NSDate date]];
                
                NSTimeInterval interval = [[job time_diff] integerValue];
                
                [self.lbl_Timer setCountDownTime:interval];
                [self.lbl_Timer reset];
                
                if (![self.lbl_Timer counting])
                {
                    [self.lbl_Timer start];
                }
                
                onGoingJob = job;
            }
            else
            {
                [self.lbl_NoJobsAvailable setHidden:NO];
                [self.view_Job setHidden:YES];
            }
            
            if ([[(Record *)[Utility getUser] type] isEqualToString:kGeneralUser])
            {
                [self.btnCancel setEnabled:NO];
                [self.btnConfirm setEnabled:NO];
            }
        }
        else
        {
            [self.lbl_NoJobsAvailable setHidden:NO];
            [self.view_Job setHidden:YES];
        }
    }
    andErrorBlock:nil];
}

#pragma mark - Alertview delegate method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 1)
    {
        //Pushing genie rating controller for success in job completion
        [self performSegueWithIdentifier:@"RateUserSegue" sender:self];
    }
    else
    {
        [self requestOnGoingJob];
    }
}

-(void)configureUIComponents
{
    [self.segmentedControl commonInit];
    [self.segmentedControl setSectionTitles:@[@"Notification", @"On Going Job"]];
    [self.segmentedControl setBackgroundColor:[UIColor colorWithRed:49.0/255.0 green:49.0/255.0 blue:49.0/255.0 alpha:1.0]];
    
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.segmentedControl setSelectedTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.0/255.0 green:155.0/255.0 blue:187.0/255.0 alpha:1.0]}];
//    [self.segmentedControl setSelectedTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [self.segmentedControl setType:HMSegmentedControlTypeText];
    [self.segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [self.segmentedControl setSelectionIndicatorBoxOpacity:1.0];
    [self.segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
//    [self.segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.0/255.0 green:155.0/255.0 blue:187.0/255.0 alpha:1.0]];
    [self.segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationNone];
    
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index)
    {
        [self.view_OnGoingJob setHidden:!index];
        
        if (index == 1)
        {
            [self requestOnGoingJob];
        }
    }];
    
    [self.lbl_Timer setTimerType:MZTimerLabelTypeTimer];
    [self.lbl_Timer setShouldCountBeyondHHLimit:YES];
//    [self.lbl_Timer setTimeFormat:@"HH:mm"];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"NotificationDetailSegue"])
    {
        NotificationTableViewController *notDetail = [self.childViewControllers firstObject];
        Record *notification = [[notDetail datasource] objectAtIndex:[sender row]];
        
        NotificationDetailViewController *controller = [segue destinationViewController];
        [controller setNotificationId:[notification ref_id]];
        [controller setActionType:[notification action_type]];
        [controller setElapsedTime:[notification date_added]];
    }
    else if ([[segue identifier] isEqualToString:@"RateUserSegue"])
    {
        UINavigationController *navCon = [segue destinationViewController];
        RateUserViewController *rateUser = (RateUserViewController *)[navCon topViewController];
        
        [rateUser setTitle:@"Rate General User"];
        
        //Setting genie id to rate
        [rateUser setUserID:[onGoingJob user_id]];
        [rateUser setGenieID:[onGoingJob genie_id]];
        [rateUser setUserName:[onGoingJob username]];
        [rateUser setUserImage:[onGoingJob thumb_image]];
        
        [rateUser setJobID:[onGoingJob idd]];
    }
}

-(IBAction)unwindToNotifications:(UIStoryboardSegue *)unwindSegue
{
    if ([[unwindSegue identifier] isEqualToString:@"UnwindToNotifications"])
    {
        [self requestOnGoingJob];
    }
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
