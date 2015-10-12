//
//  NotificationTableViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 20/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "NotificationTableViewController.h"

#define kRecordsCount @"10"

//typedef NS_ENUM(NSUInteger, NotificationStatus)
//{
//    NotificationStatusRequestSent,
//    NotificationStatusRequestReceived,
//    NotificationStatusRequestAccepted,
//    NotificationStatusJobCancelled,
//    NotificationStatusJobFinished
//};

@interface NotificationTableViewController ()

@end

@implementation NotificationTableViewController
{
    NSInteger offset;
    BOOL isLoadMore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.datasource = [NSMutableArray array];
    
    offset = 1;
    [self requestNotificationsWithIndicator:YES andCompletionBlock:nil];
}

- (IBAction)tableViewDidRefresh:(id)sender
{
    offset = 1;
//    isLoadMore = YES;
    
    [self requestNotificationsWithIndicator:NO andCompletionBlock:nil];
}

-(void)loadMoreContent:(void(^)(void))completionBlock
{
    offset++;
    [self requestNotificationsWithIndicator:NO andCompletionBlock:completionBlock];
}

#pragma mark - Network request
-(void)requestNotificationsWithIndicator:(BOOL)shouldShowIndicator andCompletionBlock:(void(^)(void))completionBlock;
{
    [NetworkClient request:kN_GetNotifications withParameters:@{@"user_id":[[Utility getUser] idd], @"offset":[[NSNumber numberWithUnsignedInteger:offset] stringValue], @"limit":kRecordsCount} shouldShowProgressIndicator:shouldShowIndicator responseBlock:^(NSString *requestMethod, id model)
    {
        [Utility hideHUD];
        
        if (offset == 1)
        {
            [self.datasource removeAllObjects];
        }
        
        if ([model isSuccess])
        {
            if ([[model pages] integerValue] == offset)
            {
                isLoadMore = NO;
            }
            else
            {
                isLoadMore = YES;
            }
            
            [self.datasource addObjectsFromArray:[model records]];
            
            if (completionBlock)
            {
                completionBlock();
            }
            
            [self.tableView reloadData];
            
            [self.refreshControl endRefreshing];
        }
        else
        {
            [self.refreshControl endRefreshing];
            
            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
        }
    }
    andErrorBlock:^(NSString *requestMethod, NSError *error)
    {
        [Utility hideHUD];
        
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Tableview delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoadMore)
    {
        return [self.datasource count] + 1;
    }
    return [self.datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isLoadMore && [self.datasource count] == [indexPath row])
    {
        NSString *cellId = @"LoadingCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1];
        [indicatorView startAnimating];
        
        [self loadMoreContent:^{
            [indicatorView stopAnimating];
        }];
        
        return cell;
    }
    
    static NSString *cellId = @"NotificationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    if ([indexPath row] % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]];
    }
    
    [cell setTag:[indexPath row]];
    
    Record *notification = [self.datasource objectAtIndex:[indexPath row]];
    
    // Configure the cell...
    UILabel *lbl_Desc = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *lbl_Time = (UILabel *)[cell.contentView viewWithTag:2];
    UIImageView *imgV_Status = (UIImageView *)[cell.contentView viewWithTag:3];
    
    //'send_request','recieve_request','accept_request','rejected','job_done','job_canceled'
    
    [lbl_Desc setText:[notification notification_message]];
    [lbl_Time setText:[notification date_added]];
    [imgV_Status setImage:[UIImage imageNamed:[notification action_type]]];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        Record *notification = [self.datasource objectAtIndex:[indexPath row]];
        
        //Deleting notification on server from here
        [NetworkClient request:kN_DeleteNotification withParameters:@{@"notification_id":[notification idd]} shouldShowProgressIndicator:NO responseBlock:nil andErrorBlock:nil];
        
        [self.datasource removeObject:notification];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }];
    
    [deleteAction setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:155.0/255.0 blue:187.0/255.0 alpha:1.0]];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Required to implement for RowActions to get worked
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self parentViewController] performSegueWithIdentifier:@"NotificationDetailSegue" sender:indexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
