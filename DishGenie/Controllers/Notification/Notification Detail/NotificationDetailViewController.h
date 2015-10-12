//
//  NotificationDetailViewController.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 20/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationDetailViewController : UIViewController

@property (nonatomic) NSString *notificationId;
@property (nonatomic) NSString *actionType;
@property (nonatomic) NSString *elapsedTime;

@end
