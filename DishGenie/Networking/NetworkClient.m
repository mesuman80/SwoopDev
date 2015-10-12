//
//  NetworkClient.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 24/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "NetworkClient.h"

#import "AFHTTPRequestOperationManager.h"
#import "Model.h"

@implementation NetworkClient


+(void)normalUrlRequest:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator responseBlock:(void (^)(NSString *, id))responseBlock andErrorBlock:(void (^)(NSString *, NSError *))errorBlock
{
    if (shouldShowProgressIndicator)
    {
        [Utility showHUD];
    }
    
    NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mParameters setObject:[[NSTimeZone localTimeZone] name] forKey:@"time_zone"];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager manager] init];
    
    [manager GET:requestMethod parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if (responseBlock)
             {
                 responseBlock(requestMethod, responseObject);
             }
             else
             {
                 [Utility hideHUD];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if (errorBlock)
             {
                 errorBlock(requestMethod, error);
             }
             else
             {
                 [Utility hideHUD];
             }
         }
     ];
}



+(void)urlRequest:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator responseBlock:(void (^)(NSString *, id))responseBlock andErrorBlock:(void (^)(NSString *, NSError *))errorBlock
{
    if (![self isNetworkAvailable])
    {
        [Utility hideHUD];
        [Utility showAlertWithTitle:@"Network Error" message:@"No internet connectivity, Please check your internet connection" andDelegate:nil];
        if (errorBlock)
        {
            errorBlock(requestMethod, nil);
        }
        return;
    }
    
    if (shouldShowProgressIndicator)
    {
        [Utility showHUD];
    }
    
    NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mParameters setObject:[[NSTimeZone localTimeZone] name] forKey:@"time_zone"];
    
    AFHTTPRequestOperationManager *manager= [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:kN_BaseURL]];
    
    [manager GET:requestMethod parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"Response: %@", [responseObject objectAtIndex:0]);
             NSMutableDictionary *data = [[NSMutableDictionary alloc]initWithDictionary:[responseObject objectAtIndex:0]];
             Model *model = [[Model alloc] initWithObject:data];
             
             if (responseBlock)
             {
                 responseBlock(requestMethod, model);
             }
             else
             {
                 [Utility hideHUD];
             }
         }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if (errorBlock)
             {
                 errorBlock(requestMethod, error);
             }
             else
             {
                 [Utility hideHUD];
             }
         }
     ];
}


+(void)putRequest:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator responseBlock:(void (^)(NSString *, id))responseBlock andErrorBlock:(void (^)(NSString *, NSError *))errorBlock
{
    if (![self isNetworkAvailable])
    {
        [Utility hideHUD];
        [Utility showAlertWithTitle:@"Network Error" message:@"No internet connectivity, Please check your internet connection" andDelegate:nil];
        if (errorBlock)
        {
            errorBlock(requestMethod, nil);
        }
        return;
    }
    
    if (shouldShowProgressIndicator)
    {
        [Utility showHUD];
    }
    
    NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mParameters setObject:[[NSTimeZone localTimeZone] name] forKey:@"time_zone"];
    
    AFHTTPRequestOperationManager *manager= [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:kN_BaseURL]];
    
    [manager PUT:requestMethod parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {

             if (responseBlock)
             {
                 responseBlock(requestMethod, responseObject);
             }
             else
             {
                 [Utility hideHUD];
             }
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if (errorBlock)
             {
                 errorBlock(requestMethod, error);
             }
             else
             {
                 [Utility hideHUD];
             }
         }
     ];
}


+(void)request:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator responseBlock:(void (^)(NSString *, id))responseBlock andErrorBlock:(void (^)(NSString *, NSError *))errorBlock
{
    if (![self isNetworkAvailable])
    {
        [Utility hideHUD];
        [Utility showAlertWithTitle:@"Network Error" message:@"No internet connectivity, Please check your internet connection" andDelegate:nil];
        
        if (errorBlock)
        {
            errorBlock(requestMethod, nil);
        }
        return;
    }
    
    if (shouldShowProgressIndicator)
    {
        [Utility showHUD];
    }
    
    NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mParameters setObject:[[NSTimeZone localTimeZone] name] forKey:@"time_zone"];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:kN_BaseURL]];
    [manager POST:requestMethod parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"Response: %@", responseObject);
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        Model *model = [[Model alloc] initWithObject:data];
        
        if (responseBlock)
        {
            responseBlock(requestMethod, model);
        }
        else
        {
            [Utility hideHUD];
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Error: %@", error);
        if(operation.response.statusCode  == 409) {
             //[Utility showAlertWithTitle:@"Alert" message:@"User already exist." andDelegate:nil];
        }
        else {
            [Utility showAlertWithTitle:@"Network Error" message:[error localizedDescription] andDelegate:nil];
        }
        if (errorBlock)
        {
            errorBlock(requestMethod, error);
        }
        else
        {
            [Utility hideHUD];
        }
    }];
}

+(void)requestMultiPart:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator imageInfo:(NSDictionary *)imageInfo responseBlock:(void (^)(NSString *requestMethod, id model))responseBlock andErrorBlock:(void (^)(NSString *requestMethod, NSError *error))errorBlock
{
    if (![self isNetworkAvailable])
    {
        [Utility hideHUD];
        
        [Utility showAlertWithTitle:@"Network Error" message:@"No internet connectivity, Please check your internet connection" andDelegate:nil];
        
        if (errorBlock)
        {
            errorBlock(requestMethod, nil);
        }
        
        return;
    }
    
    if (shouldShowProgressIndicator)
    {
        [Utility showHUDWithProgress:0.0];
    }
    
    NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mParameters setObject:[[NSTimeZone localTimeZone] name] forKey:@"time_zone"];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:kN_BaseURL]];
    
    AFHTTPRequestOperation *requestOperation = [manager POST:requestMethod parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        if (imageInfo)
        {
            NSString *key = [[imageInfo allKeys] firstObject];
            NSArray *images = [imageInfo objectForKey:key];
            
            int i = 0;
            for (NSData *imageData in images)
            {

                [formData appendPartWithFileData:imageData name:key fileName:@"profilepic.jpg" mimeType:@"image/jpg"];
            }
        }
    }
    success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"Response: %@", responseObject);
        
        Model *model = [[Model alloc] initWithObject:responseObject];
        
        if (responseBlock)
        {
            responseBlock(requestMethod, model);
        }
        else
        {
            [Utility hideHUD];
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Error: %@", error);
        
        [Utility showAlertWithTitle:@"Network Error" message:[error localizedDescription] andDelegate:nil];
        
        if (errorBlock)
        {
            errorBlock(requestMethod, error);
        }
        else
        {
            [Utility hideHUD];
        }
    }];
    
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
    {
        double percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"progress updated(percentDone) : %f", percentDone);
        
        [Utility showHUDWithProgress:percentDone];
    }];
    
    [requestOperation start];
}

+(BOOL)isNetworkAvailable
{
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

@end
