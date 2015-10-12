//
//  CountryBaseTableView.h
//  TextTimeMachine
//
//  Created by Yogesh Gupta on 24/04/15.
//  Copyright (c) 2015 Artyllect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryBaseTableView : UITableViewController
- (void)configureCell:(UITableViewCell *)cell countryData:(NSDictionary *)dictionary;
@end
