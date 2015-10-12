//
//  CountryBaseTableView.m
//  TextTimeMachine
//
//  Created by Yogesh Gupta on 24/04/15.
//  Copyright (c) 2015 Artyllect. All rights reserved.
//

#import "CountryBaseTableView.h"

@interface CountryBaseTableView ()
@end

@implementation CountryBaseTableView

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(UITableViewCell *)cell countryData:(NSDictionary *)dictionary
{
    NSString *str =[dictionary valueForKey:@"name"];
    if(str.length>25)
    {
        str = [str substringToIndex:22];
        str = [str stringByAppendingString:@"..."];
    }
    cell.textLabel.text = str;
    cell.detailTextLabel.text = [dictionary valueForKey:@"dial_code"];
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
