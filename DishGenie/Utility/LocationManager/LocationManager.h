//
//  LocationManager.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 09/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject

+(instancetype)sharedManager;

-(void)fetchLocationWithCompletionBlock:(void(^)(NSString *lat, NSString *lon))completionBlock;

-(void)fetchLocation:(NSArray *)coordinates withCompletionBlock:(void(^)(NSString *location))completionBlock;

+(BOOL)isLocationEnabled;

@end
