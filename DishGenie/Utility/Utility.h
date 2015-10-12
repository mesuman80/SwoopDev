//
//  Utility.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 23/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SVProgressHUD.h"

@interface Utility : NSObject

+(id)getUser;

+(BOOL)isUserExist;

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message andDelegate:(id)delegate;

+(id)getController:(NSString *)controllerId;

+(UIWindow *)getApplicationWindow;

+(void)showStatusBar;
+(void)hideStatusBar;

+(void)showHUD;
+(void)showHUDWithProgress:(float)progress;
+(void)hideHUD;

+(void)saveObjectInDefaults:(id)object withKey:(NSString *)key;
+(id)getObjectFromDefaultsWithKey:(NSString *)key;
+(void)deleteObjectFromsDefaultsWithKey:(NSString *)key;

+(NSString *)getDateString:(NSDate *)date;
+(NSDate *)getDate:(NSString *)dateString;
+(NSDate *)getDate:(NSString *)dateString fromFormat:(NSString *)format;

+(NSString *)getDateStringInServerFormat:(NSString *)dateString;

+(BOOL)isValidEmail:(NSString *)emailString Strict:(BOOL)strictFilter;

@end

#pragma mark - NSString Category
@interface NSObject (Utility)

-(NSString *)getFilteredString;

@end

#pragma mark - UIImage Category
@interface UIImage (Utility)

-(UIImage *)getOriginalImage;
-(NSData *)getCompressedImageData;

@end