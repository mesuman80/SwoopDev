//
//  JobDescriptionViewController.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 11/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "BaseViewController.h"

@interface JobDescriptionViewController : BaseViewController

@property (nonatomic) NSString *genie_id;
@property (nonatomic) NSArray *genie_coordinates;
@property (nonatomic) CGFloat genie_fare;

@end
