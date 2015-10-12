//
//  NetworkClient.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 24/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkClient : NSObject


// PUT request

+(void)putRequest:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator responseBlock:(void (^)(NSString *, id))responseBlock andErrorBlock:(void (^)(NSString *, NSError *))errorBlock;

// only URL request

+(void)normalUrlRequest:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator responseBlock:(void (^)(NSString *, id))responseBlock andErrorBlock:(void (^)(NSString *, NSError *))errorBlock;

// only URL Server Base request

+(void)urlRequest:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator responseBlock:(void(^)(NSString* requestMethod, id model))responseBlock andErrorBlock:(void(^)(NSString *requestMethod, NSError *error))errorBlock;


//Simple request
+(void)request:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator responseBlock:(void(^)(NSString* requestMethod, id model))responseBlock andErrorBlock:(void(^)(NSString *requestMethod, NSError *error))errorBlock;

//Multipart request
+(void)requestMultiPart:(NSString *)requestMethod withParameters:(NSDictionary *)parameters shouldShowProgressIndicator:(BOOL)shouldShowProgressIndicator imageInfo:(NSDictionary *)imageInfo responseBlock:(void (^)(NSString *requestMethod, id model))responseBlock andErrorBlock:(void (^)(NSString *requestMethod, NSError *error))errorBlock;

//Returns network connectivity state
+(BOOL)isNetworkAvailable;

@end
