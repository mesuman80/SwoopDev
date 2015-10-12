//
//  ProfileViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 22/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "ProfileViewController.h"

#import "EditableImageView.h"
#import "EDStarRating.h"
#import "ActionSheetStringPicker.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet EditableImageView *imgV_Profile;

@property (weak, nonatomic) IBOutlet UILabel *lbl_ProfileName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Gender;
@property (weak, nonatomic) IBOutlet UITextView *tv_About;

@property (weak, nonatomic) IBOutlet EDStarRating *rating;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUIComponents];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateProfile:[Utility getUser]];
    
    //[self requestUserProfileWithActivityIndicator:NO];
}

-(void)requestUserProfileWithActivityIndicator:(BOOL)shoudShowActivityIndicator
{
    //Record *rcd = [Utility getUser];
    
    NSString * str = [[Utility getUser] idd];
    
    
    [NetworkClient request:kN_UserProfile withParameters:@{@"id":[[Utility getUser] idd]} shouldShowProgressIndicator:shoudShowActivityIndicator responseBlock:^(NSString *requestMethod, id model)
    {
        [Utility hideHUD];
        
        if ([model isSuccess])
        {
            Record *user = [[model records] firstObject];
            
            [Utility saveObjectInDefaults:user withKey:@"User"];
            [self updateProfile:user];
        }
        else
        {
            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
        }
    }
    andErrorBlock:nil];
}

-(void)updateProfile:(Record *)user
{
    [self.imgV_Profile setImageWithResizeURL:[user thumb_image]
                            placeholderImage:[UIImage imageNamed:@"img_placeholder"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        if (error)
        {
            [self.imgV_Profile resetImageSelection];
        }
    }
    usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.lbl_ProfileName setText:[user username]];
    [self.lbl_Gender setText:[[user gender] length] ? [[user gender] capitalizedString] : @"Other"];
    [self.tv_About setText:[[user about] length] ? [user about] : @"Please add something about yourself in settings"];
    _rating.rating = [[user rating] floatValue];
}

-(void)configureUIComponents
{
    [self.imgV_Profile setController:self];
    [self.imgV_Profile setBorderWidth:@3];
    
    _rating.starImage = [UIImage imageNamed:@"star_inactive"];
    _rating.starHighlightedImage = [UIImage imageNamed:@"star_active"];
    _rating.maxRating = 5.0;
    
    _rating.editable = NO;
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
