//
//  GenieAnnotation.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 10/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GenieAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic) Record *genie;

-(instancetype)initWithGenie:(Record *)genie;

-(MKAnnotationView *)annotationView;

@end
