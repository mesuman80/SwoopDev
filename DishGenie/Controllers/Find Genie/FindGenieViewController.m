//
//  FindGenieViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 22/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "FindGenieViewController.h"

#import "FilterGenieView.h"
#import "LocationManager.h"
#import <MapKit/MapKit.h>
#import "GenieAnnotation.h"
#import "GenieProfileViewController.h"

#define kLatitudinalMeters 1000.0 //1km
#define kLongitudinalMeters 1000.0 //1km
#define kRefreshTime 10.0

@interface FindGenieViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet FilterGenieView *view_Filter;

@end

@implementation FindGenieViewController
{
    NSTimer *refreshTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self requestGenies];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![LocationManager isLocationEnabled])
    {
        [Utility showAlertWithTitle:@"Error" message:@"Please enable location services from settings" andDelegate:nil];
    }
    else
    {
        //[self startAutoRefreshMechanism];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self disableAutoRefreshMechanism];
}

-(IBAction)search:(id)sender
{
    [self.view_Filter toggleView];
    [self.view endEditing:YES];
    
    //[self requestGenies];
}

-(IBAction)dropdowns:(id)sender
{
    [self.view endEditing:YES];
    
    switch ([sender tag])
    {
        case 1:
//            [self.view_Filter showExperiencePicker:sender];
            break;
        case 2:
            [self.view_Filter showRatingPicker:sender];
            break;
        case 3:
            [self.view_Filter showGenderPicker:sender];
            break;
            
        default:
            break;
    }
}

-(void)requestGenies
{
    NSString *exp = [[self.view_Filter tf_Exp] text];
    NSString *rating = [[self.view_Filter tf_Rating] text];
    NSString *gender = [[self.view_Filter tf_Gender] text];
    
    [[LocationManager sharedManager] fetchLocationWithCompletionBlock:^(NSString *lat, NSString *lon)
    {
        [NetworkClient request:kN_FindGenie withParameters:@{@"rating":rating, @"gender":gender, @"experience":exp, @"latitude":lat, @"longitude":lon} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
        {
            [Utility hideHUD];
            
            if ([model isSuccess])
            {
                [self resetMap];
                
                for (Record *record in [model records])
                {
                    GenieAnnotation *annotation = [[GenieAnnotation alloc] initWithGenie:record];
                    [self.mapView addAnnotation:annotation];
                }
                [self.mapView showAnnotations:[self.mapView annotations] animated:YES];
            }
            else
            {
                [self resetMap];
                
                [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
            }
        }
        andErrorBlock:nil];
    }];
}

#pragma mark - Auto refresh methods
-(void)startAutoRefreshMechanism
{
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTime target:self selector:@selector(requestGenies) userInfo:nil repeats:YES];
}

-(void)disableAutoRefreshMechanism
{
    [refreshTimer invalidate];
}

#pragma mark - MKMap delegate methods
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GenieAnnotation class]])
    {
        GenieAnnotation *genieAnnotation = annotation;
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"GenieAnnotation"];
        
        if (!annotationView)
        {
            annotationView = [genieAnnotation annotationView];
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    else //MKUserAnnotation
    {
        MKPinAnnotationView *userAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        userAnnotation.image = [UIImage imageNamed:@"user_pin"];
        userAnnotation.animatesDrop = NO;
        userAnnotation.canShowCallout = YES;
        return userAnnotation;
    }
    
    return [mapView viewForAnnotation:annotation];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([[view annotation] isKindOfClass:[GenieAnnotation class]])
    {
        [self performSegueWithIdentifier:@"GenieProfileSegue" sender:[view annotation]];
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D cords = [[[mapView userLocation] location] coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(cords, kLatitudinalMeters, kLongitudinalMeters);
    
    if (![[self.mapView annotations] count])
    {
        [mapView setRegion:region animated:YES];
    }
}

-(void)resetMap
{
    [self.mapView removeAnnotations:[self.mapView annotations]];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GenieProfileSegue"])
    {
        if ([sender isKindOfClass:[GenieAnnotation class]])
        {
            GenieProfileViewController *controller = (GenieProfileViewController *)[[segue destinationViewController] topViewController];
            [controller setGenie:[(GenieAnnotation *)sender genie]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
