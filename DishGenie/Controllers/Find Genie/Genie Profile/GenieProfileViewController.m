//
//  GenieProfileViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 11/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "GenieProfileViewController.h"

#import "NZCircularImageView.h"
#import "EDStarRating.h"
#import "JobDescriptionViewController.h"

@interface GenieProfileViewController ()

@property (weak, nonatomic) IBOutlet NZCircularImageView *imgV_Profile;
@property (weak, nonatomic) IBOutlet EDStarRating *rating;

@property (weak, nonatomic) IBOutlet UILabel *lbl_Name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Gender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Exp;

@end

@implementation GenieProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUIComponents];
    
    [self.imgV_Profile setImageWithResizeURL:[self.genie thumb_image]
                         placeholderImage:[UIImage imageNamed:@"img_placeholder"]
              usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    _rating.rating = [[self.genie rating] floatValue];
    
    [self.lbl_Name setText:[[self.genie username] length] ? [[self.genie username] capitalizedString] : @"---"];
    [self.lbl_Gender setText:[[self.genie gender] length] ? [[self.genie gender] capitalizedString] : @"---"];
    [self.lbl_Exp setText:[[self.genie experience] length] ? [[self.genie experience] capitalizedString] : @"---"];
}

-(IBAction)cross:(id)sender
{
    [[self.presentationController presentedViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)configureUIComponents
{
    [self.imgV_Profile setBorderWidth:@3];
    
    _rating.starImage = [UIImage imageNamed:@"star_inactive"];
    _rating.starHighlightedImage = [UIImage imageNamed:@"star_active"];
    _rating.maxRating = 5.0;
    _rating.editable = NO;
    _rating.displayMode = EDStarRatingDisplayFull;
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"JobDescriptionSegue"])
    {
        JobDescriptionViewController *controller = [segue destinationViewController];
        [controller setGenie_id:[self.genie idd]];
        [controller setGenie_fare:[[self.genie hourly_rate] floatValue]];
        [controller setGenie_coordinates:@[[self.genie latitude], [self.genie longitude]]];
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
