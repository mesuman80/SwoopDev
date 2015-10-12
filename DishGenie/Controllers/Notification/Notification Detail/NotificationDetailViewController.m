//
//  NotificationDetailViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 20/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "NotificationDetailViewController.h"

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "RateUserViewController.h"
#import "MHGallery.h"

@interface NotificationDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgV_NotificationStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Desc;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barbtn_Time;

@property (weak, nonatomic) IBOutlet UIView *view_Bottom;

@property (weak, nonatomic) IBOutlet UILabel *lbl_JobStart;
@property (weak, nonatomic) IBOutlet UILabel *lbl_JobEnd;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Hours;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Fare;

@property (weak, nonatomic) IBOutlet UICollectionView *cv_Images;

@property (weak, nonatomic) IBOutlet UIButton *btn_Accept;
@property (weak, nonatomic) IBOutlet UIButton *btn_Reject;

@property (weak, nonatomic) IBOutlet UIButton *btn_Start;

@property (weak, nonatomic) IBOutlet UIButton *btn_RateGenie;

@end

@implementation NotificationDetailViewController
{
    NSMutableArray *cvDatasource;
    
    Record *notification;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.imgV_NotificationStatus setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_big", self.actionType]]];
    [self.barbtn_Time setTitle:self.elapsedTime];
    
    [NetworkClient request:kN_GetJobDetails withParameters:@{@"job_id":self.notificationId} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
    {
        [Utility hideHUD];
        
        if ([model isSuccess])
        {
            Record *record = [[model records] firstObject];
            
            [self.imgV_NotificationStatus setImage:[UIImage imageNamed:[self getImageNameFromJobStatus:[record status]]]];
//            [self.barbtn_Time setTitle:[record date_added]];
            [self.lbl_Desc setText:[[record descriptionn] length] ? [record descriptionn] : @"No description available for this job."];
            [self.lbl_JobStart setText:[record start_time]];
            [self.lbl_JobEnd setText:[record end_time]];
            [self.lbl_Hours setText:[NSString stringWithFormat:@"%@ Hour(s)", [record estimated_hours]]];
            [self.lbl_Fare setText:[NSString stringWithFormat:@"$ %@", [record price]]];
            
            cvDatasource = [NSMutableArray arrayWithArray:[record job_media]];
            [self.cv_Images reloadData];
            
            if (([[record status] isEqualToString:@"pending"] || [[record status] isEqualToString:@"accepted"]) && [[(Record *)[Utility getUser] type] isEqualToString:kGenieUser])
            {
                [self.view_Bottom setHidden:NO];
                
                notification = record;
                
                if ([[record status] isEqualToString:@"accepted"])
                {
                    [self.btn_Accept setHidden:YES];
                    [self.btn_Reject setHidden:YES];
                    [self.btn_Start setHidden:NO];
                }
            }
            
            if ([[record status] isEqualToString:@"completed"] && [[(Record *)[Utility getUser] type] isEqualToString:kGeneralUser] && ![record is_rate])
            {
                [self.view_Bottom setHidden:NO];
                
                notification = record;
                
                [self.btn_Accept setHidden:YES];
                [self.btn_Reject setHidden:YES];
                [self.btn_RateGenie setHidden:NO];
            }
        }
        else
        {
            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
        }
    }
    andErrorBlock:nil];
}

-(IBAction)accept:(id)sender
{
    [NetworkClient request:kN_JobAction withParameters:@{@"job_id":self.notificationId, @"status":@"accepted", @"sender_id":[[Utility getUser] idd], @"receiver_id":[notification user_id], @"start_time":[notification start_time], @"end_time":[notification end_time]} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
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

-(IBAction)reject:(id)sender
{
    [NetworkClient request:kN_JobAction withParameters:@{@"job_id":self.notificationId, @"status":@"rejected", @"sender_id":[[Utility getUser] idd], @"receiver_id":[notification user_id], @"start_time":[notification start_time], @"end_time":[notification end_time]} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
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

-(IBAction)start:(id)sender
{
    NSDate *startDate = [Utility getDate:[notification start_time] fromFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if ([startDate timeIntervalSinceNow] < [[notification start_job_btn_time] doubleValue]) //15 mins
    {
//        NSTimeInterval timeInterval = [[notification estimated_hours] floatValue] * 3600;
        
        NSDate *endDate = [Utility getDate:[notification end_time] fromFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeInterval timeInterval = [endDate timeIntervalSinceDate:startDate];
        
        NSString *actualStartTime = [Utility getDateStringInServerFormat:[Utility getDateString:[NSDate date]]];
        NSString *actualEndTime = [Utility getDateStringInServerFormat:[Utility getDateString:[[NSDate date] dateByAddingTimeInterval:timeInterval]]];
        
        [NetworkClient request:kN_JobAction withParameters:@{@"job_id":self.notificationId, @"status":@"inprogress", @"sender_id":[[Utility getUser] idd], @"receiver_id":[notification user_id], @"start_time":actualStartTime, @"end_time":actualEndTime} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
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
    else
    {
        [Utility showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"You can start job prior to %.0f mins only",[[notification start_job_btn_time] floatValue] / 60] andDelegate:nil];
    }
}

-(IBAction)rateGenie:(id)sender
{
    [self performSegueWithIdentifier:@"RateGenieSegue" sender:self];
}

#pragma mark - Collection view delegate methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [cvDatasource count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ImageCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    Record *media = [cvDatasource objectAtIndex:[indexPath item]];
    
    UIImageView *imgView = (UIImageView *)[[cell contentView] viewWithTag:1];
    [imgView setImageWithURL:[NSURL URLWithString:[media thumb_image]] placeholderImage:[UIImage imageNamed:@"img_placeholder"] options:0 usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *galleryData = [NSMutableArray array];
    
    for (Record *record in cvDatasource)
    {
        MHGalleryItem *item = [MHGalleryItem itemWithURL:[record orignal_image] galleryType:MHGalleryTypeImage];
        [galleryData addObject:item];
    }
    
    MHGalleryController *gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeOverView];
    gallery.galleryItems = galleryData;
    gallery.presentationIndex = indexPath.item;
    gallery.UICustomization.hideShare = YES;
    gallery.UICustomization.barTintColor = [UIColor colorWithRed:0.0/255.0 green:155.0/255.0 blue:187.0/255.0 alpha:1.0];
    gallery.UICustomization.barButtonsTintColor = [UIColor whiteColor];
    gallery.UICustomization.barTextColor = [UIColor whiteColor];
    __weak MHGalleryController *blockGallery = gallery;
    
    gallery.finishedCallback = ^(NSInteger currentIndex, UIImage *image, MHTransitionDismissMHGallery *interactiveTransition, MHGalleryViewMode viewMode)
    {
        [blockGallery dismissViewControllerAnimated:YES completion:^
        {
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    };
    
    [self presentMHGalleryController:gallery animated:YES completion:nil];
}

#pragma mark - Alertview delegate method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)getImageNameFromJobStatus:(NSString *)status
{
    //'send_request','recieve_request','accept_request','job_done','job_canceled'
    
    if ([status isEqualToString:@"pending"])
    {
        return [[(Record *)[Utility getUser] type] isEqualToString:kGeneralUser] ? @"send_request_big" : @"recieve_request_big";
    }
    else if ([status isEqualToString:@"accepted"])
    {
        return @"accept_request_big";
    }
    else if ([status isEqualToString:@"rejected"])
    {
        return @"rejected_big";
    }
    else if ([status isEqualToString:@"completed"])
    {
        return @"job_done_big";
    }
    else if ([status isEqualToString:@"canceled"])
    {
        return @"job_canceled_big";
    }
    else if ([status isEqualToString:@"inprogress"])
    {
        return @"accept_request_big";
    }
    return nil;
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"RateGenieSegue"])
    {
        UINavigationController *navCon = [segue destinationViewController];
        RateUserViewController *rateUser = (RateUserViewController *)[navCon topViewController];
        
        //Setting genie id to rate
        [rateUser setUserID:[notification user_id]];
        [rateUser setGenieID:[notification genie_id]];
        [rateUser setUserName:[notification username]];
        [rateUser setUserImage:[notification thumb_image]];
        
        [rateUser setJobID:[notification idd]];
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
