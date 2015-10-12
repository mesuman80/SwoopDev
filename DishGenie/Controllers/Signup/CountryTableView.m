//
//  CountryTableView.m
//  TextTimeMachine
//
//  Created by Yogesh Gupta on 24/04/15.
//  Copyright (c) 2015 Artyllect. All rights reserved.
//

#import "CountryTableView.h"
#import "CountryDetailView.h"

@interface CountryTableView ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) CountryDetailView *resultsTableController;
@end

@implementation CountryTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    
    _resultsTableController = [[CountryDetailView alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self;
   // self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsUpdater = self;// so we can monitor text changes + others
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    // Do any additional setup after loading the view.
    
    self.title = @"Your Country";
    

}
-(void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.countryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(!cell)
    {
        cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    
    [self configureCell:cell countryData:self.countryList[indexPath.row]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(self.delegate)
    {
        if(self.searchController.searchBar.text.length>0)
        {
            [self.delegate setCountryCode:[[self.resultsTableController.filteredArray objectAtIndex:indexPath.row] valueForKey:@"dial_code"]];
        }
        else
        {
            [self.delegate setCountryCode:[[self.countryList objectAtIndex:indexPath.row] valueForKey:@"dial_code"]];
        }
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
   
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.countryList mutableCopy];
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strippedString.length > 0) {
        NSString *str = strippedString;
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name CONTAINS[c] %@)", str];
        searchResults = [[searchResults filteredArrayUsingPredicate:pred]mutableCopy];
        CountryDetailView *countryDetailView = (CountryDetailView *)self.searchController.searchResultsController;
        countryDetailView.filteredArray = searchResults;
        [countryDetailView.tableView reloadData];
    }
   
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
