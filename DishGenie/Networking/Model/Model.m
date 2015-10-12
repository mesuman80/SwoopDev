//
//  Model.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 24/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "Model.h"

@implementation Model

-(instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self)
    {
        
        
        
        if(object){
            self.response_code = @"200";
            self.messageStatus = @"success";
            self.messageContent =object;// [object valueForKey:@"messageContent"];
        }else{
            self.messageStatus = @"failure";
        }

        //self.pages = [object valueForKey:@"pages"];
        
        //NSArray *records = object; //[object valueForKey:@"records"];
        
        
        
        
        
        
        
        self.records = [NSMutableArray array];
        
        [self.records addObject: [[Record alloc] initWithObject:object]];
        
            for (NSString *name in object)
            {
                //NSLog(@" %@  :  %@", name, [object valueForKey:name]);
                
                NSDictionary * dict = @{name : [object valueForKey:name]};
                
                //[self.records addObject: [[Record alloc] initWithObject:dict]];
            }
        
        NSLog(@" %@  :", self.records);
        
    }
    return self;
}

-(BOOL)isSuccess
{
    return [self.response_code integerValue] == 200;
}

@end

@implementation Record

-(instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self)
    {
        
       // NSLog(@"uid  %@", [object valueForKey:@"id"]);
        
        self.idd = [NSString stringWithFormat:@"%@", [object valueForKey:@"id"]];//[[object valueForKey:@"id"] getFilteredString];
        self.username = [[object valueForKey:@"username"] getFilteredString];
        self.type = [[object valueForKey:@"type"] getFilteredString];
        self.payment_method = [[object valueForKey:@"payment_method"] getFilteredString];
        self.latitude = [[object valueForKey:@"latitude"] getFilteredString];
        self.longitude = [[object valueForKey:@"longitude"] getFilteredString];
        self.experience = [[object valueForKey:@"experience"] getFilteredString];
        self.gender = [[object valueForKey:@"gender"] getFilteredString];
        self.orignal_image = [[object valueForKey:@"orignal_image"] getFilteredString];
        self.thumb_image = [[object valueForKey:@"thumb_image"] getFilteredString];
        self.about = [[object valueForKey:@"about"] getFilteredString];
        self.rating = [[object valueForKey:@"rating"] getFilteredString];
        self.hourly_rate = [[object valueForKey:@"hourly_rate"] getFilteredString];
        self.action_type = [[object valueForKey:@"action_type"] getFilteredString];
        self.actual_receiver_id = [[object valueForKey:@"actual_receiver_id"] getFilteredString];
        self.date_added = [[object valueForKey:@"date_added"] getFilteredString];
        self.notification_message = [[object valueForKey:@"notification_message"] getFilteredString];
        self.receiver = [[object valueForKey:@"receiver"] getFilteredString];
        self.receiver_id = [[object valueForKey:@"receiver_id"] getFilteredString];
        self.receiver_orignal_image = [[object valueForKey:@"receiver_orignal_image"] getFilteredString];
        self.receiver_thumb_image = [[object valueForKey:@"receiver_thumb_image"] getFilteredString];
        self.receiver_type = [[object valueForKey:@"receiver_type"] getFilteredString];
        self.ref_id = [[object valueForKey:@"ref_id"] getFilteredString];
        self.sender = [[object valueForKey:@"sender"] getFilteredString];
        self.sender_id = [[object valueForKey:@"sender_id"] getFilteredString];
        self.sender_orignal_image = [[object valueForKey:@"sender_orignal_image"] getFilteredString];
        self.sender_thumb_image = [[object valueForKey:@"sender_thumb_image"] getFilteredString];
        self.sender_type = [[object valueForKey:@"sender_type"] getFilteredString];
        self.actual_end_time = [[object valueForKey:@"actual_end_time"] getFilteredString];
        self.actual_start_time = [[object valueForKey:@"actual_start_time"] getFilteredString];
        self.descriptionn = [[object valueForKey:@"description"] getFilteredString];
        self.end_time = [[object valueForKey:@"end_time"] getFilteredString];
        self.estimated_hours = [[object valueForKey:@"estimated_hours"] getFilteredString];
        self.price = [[object valueForKey:@"price"] getFilteredString];
        self.genie_id = [[object valueForKey:@"genie_id"] getFilteredString];
        self.location = [[object valueForKey:@"location"] getFilteredString];
        self.start_time = [[object valueForKey:@"start_time"] getFilteredString];
        self.status = [[object valueForKey:@"status"] getFilteredString];
        self.user_id = [[object valueForKey:@"user_id"] getFilteredString];
        self.time_diff = [[object valueForKey:@"time_diff"] getFilteredString];
        self.email = [[object valueForKey:@"email"] getFilteredString];
        self.fname = [[object valueForKey:@"fname"] getFilteredString];
        self.start_job_btn_time = [[object valueForKey:@"start_job_btn_time"] getFilteredString];
        self.is_rate = [[object valueForKey:@"is_rate"] getFilteredString];
        
        NSLog(@"uid  %@", self.idd);
        
        
//        NSArray *jobMedia = [object valueForKey:@"job_media"];
//        
//        if ([jobMedia count])
//        {
//            self.job_media = [NSMutableArray array];
//            
//            for (NSDictionary *record in jobMedia)
//            {
//                [self.job_media addObject:[[Record alloc] initWithObject:record]];
//            }
//        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.idd forKey:@"id"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.orignal_image forKey:@"orignal_image"];
    [encoder encodeObject:self.thumb_image forKey:@"thumb_image"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.fname forKey:@"fname"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.about forKey:@"about"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        self.idd = [decoder decodeObjectForKey:@"id"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.orignal_image = [decoder decodeObjectForKey:@"orignal_image"];
        self.thumb_image = [decoder decodeObjectForKey:@"thumb_image"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.fname = [decoder decodeObjectForKey:@"fname"];
        self.gender = [decoder decodeObjectForKey:@"gender"];
        self.about = [decoder decodeObjectForKey:@"about"];
    }
    return self;
}

@end