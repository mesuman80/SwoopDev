//
//  CountryCodeTable.m
//  TextTimeMachine
//
//  Created by Tripta on 14/04/15.
//  Copyright (c) 2015 Artyllect. All rights reserved.
//

#import "CountryCodeTable.h"
//#import "Data.h"

@implementation CountryCodeTable
{
    NSArray *countriesList;
}

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"]];
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        
        if (localError != nil) {
            //NSLog(@"%@", [localError userInfo]);
        }
        countriesList = (NSArray *)parsedObject;
        [self tableViewSetup];
        return self;
    }
    return nil;
}

-(void)tableViewSetup
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width,40)];
   // [[Data sharedInstance]addBorderToUiView:view withBorderWidth:1.0f cornerRadius:0.0f Color:[UIColor grayColor]];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton addTarget:self
               action:@selector(clickAtCancel:)
     forControlEvents:UIControlEventTouchUpInside];
     [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
     cancelButton.frame = CGRectMake(self.frame.size.width-60,0,55,view.frame.size.height-6);
     [view addSubview:cancelButton];
     [cancelButton setCenter:CGPointMake(cancelButton.center.x,view.frame.size.height/2.0f)];
     [self addSubview:view];
    
    
     self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,40, self.frame.size.width, self.frame.size.height-40)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self addSubview:self.tableView];
}
-(void)clickAtCancel:(id)sender
{
    [self removeFromSuperview];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return countriesList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }

    NSString *str =[[countriesList objectAtIndex:indexPath.row] valueForKey:@"name"];
    if(str.length>25)
    {
        str = [str substringToIndex:22];
        str = [str stringByAppendingString:@"..."];
    }
    cell.textLabel.text = str;
    cell.detailTextLabel.text = [[countriesList objectAtIndex:indexPath.row] valueForKey:@"dial_code"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.delegate)
    {
        [self.delegate setCountryCode:[[countriesList objectAtIndex:indexPath.row] valueForKey:@"dial_code"]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
