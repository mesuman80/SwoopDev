//
//  Model.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 24/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic) NSString *response_code;
@property (nonatomic) NSString *messageStatus;
@property (nonatomic) NSString *messageContent;

@property (nonatomic) NSString *pages;

@property (nonatomic) NSMutableArray *records;

-(BOOL)isSuccess;

-(instancetype)initWithObject:(id)object;

@end

@interface Record : NSObject

@property (nonatomic) NSString *idd;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *payment_method;
@property (nonatomic) NSString *latitude;
@property (nonatomic) NSString *longitude;
@property (nonatomic) NSString *experience;
@property (nonatomic) NSString *gender;
@property (nonatomic) NSString *orignal_image;
@property (nonatomic) NSString *thumb_image;
@property (nonatomic) NSString *about;
@property (nonatomic) NSString *rating;
@property (nonatomic) NSString *hourly_rate;
@property (nonatomic) NSString *action_type;
@property (nonatomic) NSString *actual_receiver_id;
@property (nonatomic) NSString *date_added;
@property (nonatomic) NSString *notification_message;
@property (nonatomic) NSString *receiver;
@property (nonatomic) NSString *receiver_id;
@property (nonatomic) NSString *receiver_orignal_image;
@property (nonatomic) NSString *receiver_thumb_image;
@property (nonatomic) NSString *receiver_type;
@property (nonatomic) NSString *ref_id;
@property (nonatomic) NSString *sender;
@property (nonatomic) NSString *sender_id;
@property (nonatomic) NSString *sender_orignal_image;
@property (nonatomic) NSString *sender_thumb_image;
@property (nonatomic) NSString *sender_type;
@property (nonatomic) NSString *actual_end_time;
@property (nonatomic) NSString *actual_start_time;
@property (nonatomic) NSString *descriptionn;
@property (nonatomic) NSString *end_time;
@property (nonatomic) NSString *estimated_hours;
@property (nonatomic) NSString *price;
@property (nonatomic) NSString *genie_id;
@property (nonatomic) NSString *location;
@property (nonatomic) NSString *start_time;
@property (nonatomic) NSString *status;
@property (nonatomic) NSString *user_id;
@property (nonatomic) NSString *time_diff;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *fname;
@property (nonatomic) NSString *start_job_btn_time;
@property (nonatomic) NSString *is_rate;
@property (nonatomic) NSString *image;
@property (nonatomic) NSString *job_id;

@property (nonatomic) NSMutableArray *job_media;

-(instancetype)initWithObject:(id)object;

@end
