//
//  DGNetworkClient.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 23/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "DGNetworkClient.h"

#import "AFHTTPRequestOperationManager.h"
#import "Model.h"

@implementation DGNetworkClient

+(void)request:(NSString *)requestMethod withParameters:(NSDictionary *)parameters responseBlock:(void (^)(NSString *, id))responseBlock andErrorBlock:(void (^)(NSString *, NSError *))errorBlock
{
    if (![self isNetworkAvailable])
    {
        [Utility showAlertWithTitle:@"Network Error" message:@"No internet connectivity, Please check your internet connection" andDelegate:nil];
        
        if (errorBlock)
        {
            errorBlock(requestMethod, nil);
        }
        
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:kN_BaseURL]];
    [manager POST:requestMethod parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         Model *model = [[Model alloc] initWithObject:responseObject];
         
         if (responseBlock)
         {
             responseBlock(requestMethod, model);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         
         [Utility showAlertWithTitle:@"Network Error" message:@"Invalid response from server, please try again later" andDelegate:nil];
         
         if (errorBlock)
         {
             errorBlock(requestMethod, error);
         }
     }];
}

+(BOOL)isNetworkAvailable
{
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

@end
