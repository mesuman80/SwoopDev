//
//  LocationManager.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 09/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "LocationManager.h"

#import <CoreLocation/CoreLocation.h>

@interface LocationManager () <CLLocationManagerDelegate>

@end

@implementation LocationManager
{
    CLLocationManager *locationManager;
    void(^didCompleteBlock)(NSString *lat, NSString *lon);
    
    CLGeocoder *geocoder;
    
    BOOL isRequestDelivered;
}

+(instancetype)sharedManager
{
    static LocationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            [locationManager requestWhenInUseAuthorization];
        
        geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

-(void)fetchLocationWithCompletionBlock:(void (^)(NSString *, NSString *))completionBlock
{
    [Utility showHUD];
    
    didCompleteBlock = completionBlock;
    
    [locationManager startUpdatingLocation];
    
//    [self performSelector:@selector(sendError) withObject:nil afterDelay:3.0f];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    if (didCompleteBlock)
    {
        didCompleteBlock(@"0", @"0");
        didCompleteBlock = nil;
//        isRequestDelivered = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    [locationManager stopUpdatingLocation];
    
    if (newLocation && didCompleteBlock)
    {
        didCompleteBlock([NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude]);
        didCompleteBlock = nil;
//        isRequestDelivered = YES;
    }
}

//-(void)sendError
//{
//    if (!isRequestDelivered && ![CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
//    {
//        if (didCompleteBlock)
//        {
//            didCompleteBlock(@"0", @"0");
//            didCompleteBlock = nil;
//        }
//    }
//    isRequestDelivered = NO;
//}

-(void)fetchLocation:(NSArray *)coordinates withCompletionBlock:(void (^)(NSString *))completionBlock
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[coordinates firstObject] doubleValue] longitude:[[coordinates lastObject] doubleValue]];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (error)
        {
            NSLog(@"Geocode failed with error: %@", error);
            
            if (completionBlock)
            {
                completionBlock(@"None");
            }
            
            return;
        }
        
        if (completionBlock)
        {
            CLPlacemark *placemark = [placemarks firstObject];
            completionBlock([NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.ISOcountryCode]);
        }
    }];
}

+(BOOL)isLocationEnabled
{
    return [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
}

@end
