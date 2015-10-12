//
//  CountryCodeTable.h
//  TextTimeMachine
//
//  Created by Tripta on 14/04/15.
//  Copyright (c) 2015 Artyllect. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol countryCodeDelegate <NSObject>
-(void)setCountryCode:(NSString *)countryCode;
@end

@interface CountryCodeTable : UIView <UITableViewDelegate,UITableViewDataSource>

@property UITableView *tableView;

@property(nonatomic,assign)id <countryCodeDelegate>delegate;

@end
