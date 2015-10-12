//
//  LoginViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 22/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "LoginViewController.h"
#import "LocationManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import "<FBSDKLoginKit/FBS"



@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIView *view_Login;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cn_LogoY;

@property (weak, nonatomic) IBOutlet UITextField *tf_Username;
@property (weak, nonatomic) IBOutlet UITextField *tf_Password;

@end

@implementation LoginViewController


{
    
    NSString *fbAccessToken;
    NSDictionary* facebookUser;
}
#pragma mark - View controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc]init];
    loginButton.center            = CGPointMake( self.view.center.x, self.view.frame.size.height * .9);
    [self.view addSubview:loginButton];
    
    loginButton.delegate= self;
    
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    
    //[loginButton addTarget:self  action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    [self configureUIComponents];
    [self performSelector:@selector(animateLogo) withObject:nil afterDelay:2.0f];
}


- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
     NSLog(@"Logged out");
}

- (void)loginButton:	(FBSDKLoginButton *)loginButton didCompleteWithResult:	(FBSDKLoginManagerLoginResult *)result error: (NSError *)error{
    
    if (error) {
        NSLog(@"Process error");
    } else if (result.isCancelled) {
        NSLog(@"Cancelled");
    } else {
        NSLog(@"Logged in");
        
        if(result.token)   // This means if There is current access token.
        {

            fbAccessToken =result.token.tokenString;
             NSLog(@"fbAccessToken:%@", fbAccessToken);
            [[NSUserDefaults standardUserDefaults] setValue:(fbAccessToken)  forKey:@"fbaccesstoken"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            if ([FBSDKAccessToken currentAccessToken]) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name, last_name, picture.type(large), email, name, id, gender"}]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         NSLog(@"fetched user:%@", result);
                         
                         [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"fbuser"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         facebookUser = [[NSDictionary alloc]initWithDictionary:result];
                         
                         [self registerUsingFB:result];
                     }
                 }];
            }
        }
    }
}

-(void)registerUsingFB:(NSDictionary*)fbuser{
    
    
    
    [[LocationManager sharedManager] fetchLocationWithCompletionBlock:^(NSString *lat, NSString *lon)
     {
         
         NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"username":[fbuser objectForKey:@"id"],
                                                                                           @"password":@"", @"LoginType": kFBUser ,
                                                                                           @"AuthToken" : @"AUT-FB",
                                                                                           @"FBuserid": [fbuser objectForKey:@"id"],
                                                                                           @"FBToken" : fbAccessToken, @"latitude":lat, @"longitude":lon, @"device_type":kDeviceType, @"device_token":[Utility getObjectFromDefaultsWithKey:@"DeviceToken"]}];
         
         [NetworkClient request:kN_Registration withParameters:parameters shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
              {
                  [Utility hideHUD];
                  
                  if ([model isSuccess])
                  {
                      [Utility saveObjectInDefaults:[[model records] firstObject] withKey:@"User"];
                      [self downloadFBProfielPic:fbuser];
                      //[self switchToTabbar];
                  }
                  else
                  {
                      [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
                  }
              }
              andErrorBlock:^(NSString *requestMethod, NSError *error) {
                  
                  NSLog(@"Error: %@", error.localizedDescription);
                  if ([error.localizedDescription containsString:@"409"])
                  {
                      [self loginUsingFBDetails:fbuser];
                  }
              }];
     }];
}

-(void)downloadFBProfielPic:(NSDictionary*)fbuser{
   
    
    NSString *postStr = [[[fbuser objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"] ;
    
    [NetworkClient normalUrlRequest:postStr withParameters:nil shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id result)
        {
            //
            
            NSLog(@"result  %@", result);
                              
        }
            andErrorBlock:^(NSString *requestMethod, NSError *error)
        {
            //
            
        }];

}

-(void)uploadFBProfilePicToServer:(NSDictionary*)fbuser andData:(NSData*)imgData{

    NSString *apiKey=[NSString stringWithFormat:@"Username=%@&flag=2", [fbuser objectForKey:@"id"]];
    NSString *postStr = [NSString stringWithFormat:@"%@/?=%@",kN_UserProfilePic, apiKey];
    
    [NetworkClient urlRequest:postStr withParameters:nil shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
     {
         [Utility hideHUD];
         
         if ([model isSuccess])
         {

         }
     }
    andErrorBlock:nil];
    
}


-(void)loginUsingFBDetails:(NSDictionary*)fbuser{
    
    NSDictionary* data  =@{   @"username":[fbuser objectForKey:@"id"],
                              @"password":@"",
                              @"LoginType": kFBUser,
                              @"AuthToken" : @"AUT-FB",
                              @"FBuserid": [fbuser objectForKey:@"id"],
                              @"FBToken" : fbAccessToken
                              };
    
    NSString *postStr = [NSString stringWithFormat:@"%@/?=",kN_Login];
    NSString *apiKey=[NSString stringWithFormat:
                      @"Username=%@&Password=%@&Logintype=%@&Authtoken=%@&FBuserid=%@&FBToken=%@",
                      [fbuser objectForKey:@"id"],@"", kFBUser, @"AUT-FB",
                      [fbuser objectForKey:@"id"],fbAccessToken];
    
    postStr = [postStr stringByAppendingString:apiKey];
    [self loginServiceCallWith:data andUrl:postStr];
    
}

// CUSTOM FB LOGIN
//-(void)loginButtonClicked
//{
//    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//    [login
//     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
//     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//         if (error) {
//             NSLog(@"Process error");
//         } else if (result.isCancelled) {
//             NSLog(@"Cancelled");
//         } else {
//             NSLog(@"Logged in");
//         }
//     }];
//}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [Utility hideStatusBar];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [Utility showStatusBar];
}

- (IBAction)signIn:(id)sender
{
    [self.view endEditing:YES];
    if ([[self.tf_Username text] length] && [[self.tf_Password text] length])
    {
//        NSDictionary* data=@{@"UserName":[self.tf_Username text],
//                             @"Password":[self.tf_Password text],
//                             @"LoginType": kGeneralUser ,
//                             @"AuthToken" : @"AUT-PWD"};
//        
//        
        NSString *postStr = [NSString stringWithFormat:@"%@/?=",kN_Login];
        NSString *apiKey=[NSString stringWithFormat:@"Username=%@&Password=%@&Logintype=%@&Authtoken=%@",
                          [self.tf_Username text],[self.tf_Password text], kGeneralUser, @"AUT-PWD"];
        
        postStr = [postStr stringByAppendingString:apiKey];
        [self loginServiceCallWith:@{} andUrl:postStr];
        
    }
    else
    {
        [Utility showAlertWithTitle:@"Validation Error" message:@"Please enter all required fields" andDelegate:nil];
    }
}


-(void)loginServiceCallWith:(NSDictionary*)data andUrl:(NSString*)url{
    
    [[LocationManager sharedManager] fetchLocationWithCompletionBlock:^(NSString *lat, NSString *lon)
     {
         [NetworkClient urlRequest:url withParameters:data shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
          {
              [Utility hideHUD];
              
              if ([model isSuccess])
              {
                  [Utility saveObjectInDefaults:[[model records] firstObject] withKey:@"User"];
                  [self switchToTabbar];
                  
                  //[self downloadFBProfielPic:facebookUser];
              }
              else
              {
                  [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
              }
          }
            andErrorBlock:nil];
     }];
    
}




-(void)animateLogo
{
    [self.cn_LogoY setConstant:141];
    
    [UIView animateWithDuration:1.f animations:^
    {
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished)
    {
        [self.view_Login setAlpha:0];
        [self.view_Login setHidden:NO];
        
        [UIView animateWithDuration:0.5f animations:^
        {
            [self.view_Login setAlpha:1];
        }];
    }];
}

-(void)configureUIComponents
{
    [self addLeftViewsInTextfields:@[self.tf_Username, self.tf_Password] withImageNames:@[@"log_user_icon", @"log_lock_icon"]];
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
