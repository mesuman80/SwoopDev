//
//  JobDescriptionViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 11/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "JobDescriptionViewController.h"

#import "ActionSheetPicker.h"
#import "LocationManager.h"
#import "MediaManager.h"
#import "JobImageCollectionViewCell.h"

#define kPlaceholder_Desc @"Please enter description here"

@interface JobDescriptionViewController () <UITextViewDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lbl_Location;

@property (weak, nonatomic) IBOutlet UILabel *lbl_JobStart;
@property (weak, nonatomic) IBOutlet UILabel *lbl_JobEnd;
@property (weak, nonatomic) IBOutlet UILabel *lbl_EstimatedTime;
@property (weak, nonatomic) IBOutlet UILabel *lbl_EstimatedFare;

@property (weak, nonatomic) IBOutlet UITextView *tv_Desc;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageCollectionViewHeightConstraint;

@end

@implementation JobDescriptionViewController
{
    MediaManager *manager;
    NSMutableArray *images;
}

-(MediaManager *)getMediaManager
{
    if (!manager)
    {
        manager = [[MediaManager alloc] init];
    }
    return manager;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    images = [NSMutableArray array];
    [self.imageCollectionViewHeightConstraint setConstant:0.0f];
    [self.contentViewHeightConstraint setConstant:539.0f];
    
    [[LocationManager sharedManager] fetchLocation:self.genie_coordinates withCompletionBlock:^(NSString *location)
    {
        [self.lbl_Location setText:location];
    }];
    
    [self textViewDidEndEditing:self.tv_Desc];
}

- (IBAction)jobStart:(id)sender
{
    NSDate *dateSelected = [[NSDate date] dateByAddingTimeInterval:15 * 60]; //15 mins
    
    NSDate *minDate = dateSelected;
    
    if ([[self.lbl_JobStart text] length])
    {
        dateSelected = [Utility getDate:[self.lbl_JobStart text]];
    }
    
    [ActionSheetDatePicker showPickerWithTitle:@"Select Date" datePickerMode:UIDatePickerModeDateAndTime selectedDate:dateSelected minimumDate:minDate maximumDate:nil doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin)
    {
        [self.lbl_JobStart setText:[Utility getDateString:selectedDate]];
        
        //Reseting labels
        [self.lbl_JobEnd setText:nil];
        [self.lbl_EstimatedTime setText:nil];
        [self.lbl_EstimatedFare setText:nil];
    }
    cancelBlock:nil origin:sender];
}

- (IBAction)jobEnd:(id)sender
{
    if ([[self.lbl_JobStart text] length])
    {
        NSDate *dateSelected = [NSDate dateWithTimeInterval:1 * 60 sinceDate:[Utility getDate:[self.lbl_JobStart text]]];//1 min
        
        NSDate *minDate = dateSelected;
        
        if ([[self.lbl_JobEnd text] length])
        {
            dateSelected = [Utility getDate:[self.lbl_JobEnd text]];
        }
        
        [ActionSheetDatePicker showPickerWithTitle:@"Select Date" datePickerMode:UIDatePickerModeDateAndTime selectedDate:dateSelected minimumDate:minDate maximumDate:nil doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin)
        {
            [self.lbl_JobEnd setText:[Utility getDateString:selectedDate]];
            
            //Setting estimated time and fare
            NSDate *startDate = [Utility getDate:[self.lbl_JobStart text]];
            NSDate *endDate = [Utility getDate:[self.lbl_JobEnd text]];
            NSTimeInterval timeInterval = [endDate timeIntervalSinceDate:startDate];
            
            CGFloat hours = timeInterval / 3600;
            
            [self.lbl_EstimatedTime setText:[NSString stringWithFormat:@"%.2f Hrs", hours]];
            [self.lbl_EstimatedFare setText:[NSString stringWithFormat:@"$%.2f", self.genie_fare * hours]];
        }
        cancelBlock:nil origin:sender];
    }
}

- (IBAction)uploadImages:(id)sender
{
    if ([images count] < 5)
    {
        [[self getMediaManager] openMedia:self withCompletionBlock:^(UIImage *image)
        {
            [images addObject:image];
            [self.imageCollectionView reloadData];
            
            if ([self.imageCollectionViewHeightConstraint constant] == 0)
            {
                [self.imageCollectionViewHeightConstraint setConstant:60.0f];
                [self.contentViewHeightConstraint setConstant:599.0f];
            }
        }];
    }
    else
    {
        [Utility showAlertWithTitle:@"Note" message:@"You can attach 5 images only" andDelegate:nil];
    }
}

- (IBAction)sendRequest:(id)sender
{
    [self.view endEditing:YES];
    
    if ([[self.lbl_JobStart text] length] && [[self.lbl_JobEnd text] length])
    {
        [Utility showHUD];
        
        NSString *location = [[self.lbl_Location text] isEqualToString:@"---"] ? @"" : [self.lbl_Location text];
        NSString *startTime = [Utility getDateStringInServerFormat:[self.lbl_JobStart text]];
        NSString *endTime = [Utility getDateStringInServerFormat:[self.lbl_JobEnd text]];
        NSString *time = [[self.lbl_EstimatedTime text] stringByReplacingOccurrencesOfString:@" Hrs" withString:@""];
        NSString *fare = [[self.lbl_EstimatedFare text] stringByReplacingOccurrencesOfString:@"$" withString:@""];
        NSString *desc = [[self.tv_Desc text] isEqualToString:kPlaceholder_Desc] ? @"" : [self.tv_Desc text];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"user_id":[[Utility getUser] idd],
                                                                                          @"genie_id":self.genie_id,
                                                                                          @"location":location,
                                                                                          @"start_time":startTime,
                                                                                          @"end_time":endTime,
                                                                                          @"estimated_hours":time,
                                                                                          @"estimated_fare":fare,
                                                                                          @"description":desc}];
        
        NSMutableArray *imagesToAttached;
        if (images)
        {
            imagesToAttached = [NSMutableArray array];
            for (UIImage *image in images)
            {
                [imagesToAttached addObject:[image getCompressedImageData]];
            }
        }
        
        [NetworkClient requestMultiPart:kN_CreateJob withParameters:parameters shouldShowProgressIndicator:NO imageInfo:imagesToAttached ? @{@"jobs_image[]":imagesToAttached} : nil responseBlock:^(NSString *requestMethod, id model)
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
        [Utility showAlertWithTitle:@"Validation Error" message:@"Please enter start and end time of job" andDelegate:nil];
    }
}

#pragma mark - Collection view delegate methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [images count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ImageCell";
    
    JobImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    UIImage *image = [images objectAtIndex:[indexPath row]];
    
    [cell updateCell:image withDeletionBlock:^
    {
        [images removeObject:image];
        [self.imageCollectionView reloadData];
        
        if (![images count])
        {
            [self.imageCollectionViewHeightConstraint setConstant:0.0f];
            [self.contentViewHeightConstraint setConstant:539.0f];
        }
    }];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    //Implementation required to show menu on cell
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Implementation required to show menu on cell
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    //Implementation required to show menu on cell
    NSLog(@"performAction");
}

#pragma mark - UIAlertview delegate method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Textview delegate methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:kPlaceholder_Desc])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.text = kPlaceholder_Desc;
        textView.textColor = [UIColor lightGrayColor];
    }
}

@end
