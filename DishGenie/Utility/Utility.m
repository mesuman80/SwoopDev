//
//  Utility.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 23/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "Utility.h"

static NSDateFormatter *dateformatter;

@implementation Utility

+(NSDateFormatter *)getDateFormatter
{
    if (!dateformatter)
    {
        dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"dd/MM/yy, HH:mm"];
    }
    return dateformatter;
}

+(id)getUser
{
    return [Utility getObjectFromDefaultsWithKey:@"User"];
}

+(BOOL)isUserExist
{
    if ([Utility getObjectFromDefaultsWithKey:@"User"])
    {
        return YES;
    }
    return NO;
}

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message andDelegate:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

+(id)getController:(NSString *)controllerId
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    return [storyboard instantiateViewControllerWithIdentifier:controllerId];
}

+(UIWindow *)getApplicationWindow
{
    return [[[UIApplication sharedApplication] windows] firstObject];
}

+(void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

+(void)hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

+(void)showHUD
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}

+(void)showHUDWithProgress:(float)progress
{
    [SVProgressHUD showProgress:progress maskType:SVProgressHUDMaskTypeBlack];
}

+(void)hideHUD
{
    [SVProgressHUD dismiss];
}

+(void)saveObjectInDefaults:(id)object withKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:key];
    [defaults synchronize];
}

+(id)getObjectFromDefaultsWithKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:key]];;
}

+(void)deleteObjectFromsDefaultsWithKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}

+(NSString *)getDateString:(NSDate *)date
{
    NSDateFormatter *dateformatter = [Utility getDateFormatter];
    return [dateformatter stringFromDate:date];
}

+(NSDate *)getDate:(NSString *)dateString
{
    NSDateFormatter *dateformatter = [Utility getDateFormatter];
    return [dateformatter dateFromString:dateString];
}

+(NSDate *)getDate:(NSString *)dateString fromFormat:(NSString *)format
{
    NSDateFormatter *dateformatter = [Utility getDateFormatter];
    NSString *dateFormat = [dateformatter dateFormat];
    
    [dateformatter setDateFormat:format];
    NSDate *date = [dateformatter dateFromString:dateString];
    
    [dateformatter setDateFormat:dateFormat];
    return date;
}

+(NSString *)getDateStringInServerFormat:(NSString *)dateString
{
    NSDateFormatter *dateformatter = [Utility getDateFormatter];
    NSString *dateFormat = [dateformatter dateFormat];
    
    NSDate *date = [dateformatter dateFromString:dateString];
    [dateformatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    NSString *newDateString = [dateformatter stringFromDate:date];
    [dateformatter setDateFormat:dateFormat];
    
    return newDateString;
}

+(BOOL)isValidEmail:(NSString *)emailString Strict:(BOOL)strictFilter
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = strictFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

@end

@implementation NSObject (Utility)

-(NSString *)getFilteredString
{
    if ([self isKindOfClass:[NSString class]])
    {
        return (NSString *)self;
    }
    return nil;
}

@end

@implementation UIImage (Utility)

-(UIImage *)getOriginalImage
{
    return [self imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(NSData *)getCompressedImageData
{
    NSData *imageData= UIImageJPEGRepresentation(self, 1);
    
//    CGFloat compression = 0.6f;
//    CGFloat maxCompression = 0.1f;
//    int maxFileSize = 250 * 1024; //250 kb
//    
//    while ([imageData length] > maxFileSize && compression > maxCompression)
//    {
//        compression -= 0.1;
//        imageData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], compression);
//    }
    
    
    imageData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.3);
    
    
    return imageData;
}

@end
