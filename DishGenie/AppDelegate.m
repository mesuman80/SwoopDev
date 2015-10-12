//
//  AppDelegate.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 22/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "AppDelegate.h"

#import "PayPalMobile.h"
#import "AFNetworking.h"
//#import <Fabric/Fabric.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self configureUIAppearances];
    [self initializeSDKs];
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    [application registerForRemoteNotifications];
    if (![Utility isUserExist]) {
        [self.window setRootViewController:[Utility getController:@"LoginNavigationController"]];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)initializeSDKs
{
    //Crashlytics
    //[Fabric with:@[CrashlyticsKit]];
    
    //AFNetworking
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //Paypal
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction:kPaypalProductionID,
                                                           PayPalEnvironmentSandbox:kPaypalDevelopmentID}];
}

-(void)configureUIAppearances {
    id tabbarAppearance = [UITabBar appearance];
    id navigationBarAppearance = [UINavigationBar appearance];
    id barBtnInNavigationBarAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
     UIColor *tabbarTintColor = [UIColor colorWithRed:0.0/255.0 green:155.0/255.0 blue:187.0/255.0 alpha:1.0];
    [tabbarAppearance setTintColor:tabbarTintColor];
    UIImage *backIndicatorImage = [UIImage imageNamed:@"back_btn"];
    backIndicatorImage = [backIndicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [navigationBarAppearance setBackIndicatorImage:backIndicatorImage];
    [navigationBarAppearance setBackIndicatorTransitionMaskImage:backIndicatorImage];
    
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                     NSFontAttributeName:[UIFont systemFontOfSize:14.0f]};
    
    [barBtnInNavigationBarAppearance setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [barBtnInNavigationBarAppearance setTitleTextAttributes:textAttributes forState:UIControlStateHighlighted];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - Push notification delegate methods
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *tokenAsString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [Utility saveObjectInDefaults:tokenAsString withKey:@"DeviceToken"];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@",error);
    [Utility saveObjectInDefaults:@"" withKey:@"DeviceToken"];
}

@end
