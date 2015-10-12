//
//  CountryTableView.h
//  TextTimeMachine
//
//  Created by Yogesh Gupta on 24/04/15.
//  Copyright (c) 2015 Artyllect. All rights reserved.
//

#import "CountryBaseTableView.h"

@protocol CountryTableViewDelegate <NSObject>
-(void)setCountryCode:(NSString *)countryCode;
@end

@interface CountryTableView : CountryBaseTableView
@property(nonatomic,assign)id <CountryTableViewDelegate>delegate;
@property (nonatomic, copy) NSArray *countryList;

@end
