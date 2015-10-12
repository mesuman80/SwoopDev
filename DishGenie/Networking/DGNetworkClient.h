//
//  DGNetworkClient.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 23/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGNetworkClient : NSObject

//Requests webservice
+(void)request:(NSString *)requestMethod withParameters:(NSDictionary *)parameters responseBlock:(void(^)(NSString* requestMethod, id model))responseBlock andErrorBlock:(void(^)(NSString *requestMethod, NSError *error))errorBlock;

//Returns network connectivity state
+(BOOL)isNetworkAvailable;

@end
