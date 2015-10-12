//
//  GenieAnnotation.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 10/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "GenieAnnotation.h"

@implementation GenieAnnotation

-(instancetype)initWithGenie:(Record *)genie
{
    self = [super init];
    if (self)
    {
        _genie = genie;
        
        CLLocationCoordinate2D cords = CLLocationCoordinate2DMake([[genie latitude] doubleValue], [[genie longitude] doubleValue]);
        
        _title = [genie username];
        _coordinate = cords;
    }
    return self;
}

-(MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"GenieAnnotation"];
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:NO];
    [annotationView setImage:[UIImage imageNamed:@"map_pin"]];
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    
    return annotationView;
}

@end
