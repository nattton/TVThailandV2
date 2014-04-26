//
//  ShowCategoryViewController
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowCategoryViewController.h"
#import "ShowCategoryTableViewCell.h"
#import "ShowCategory.h"
#import "ShowCategoryList.h"
#import "SVProgressHUD.h"
#import "Show.h"

#import "ShowListViewController.h"
#import "EpisodePartViewController.h"
#import "OTVEpisodePartViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface ShowCategoryViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ShowCategoryViewController {
    
@private
    UIRefreshControl *_refreshControl;
    ShowCategoryList *_categoryList;
    NSArray *_searchShows;
}

static NSString *cellIdentifier = @"CategoryCellIdentifier";
static NSString *searchCellIdentifier = @"SearchCellIdentifier";

static NSString *showListSegue = @"ShowListSegue";

static NSString *EPAndPartIdentifier = @"EPAndPartIdentifier";
static NSString *OTVEPAndPartIdentifier = @"OTVEPAndPartIdentifier";

#pragma mark - UIViewController

- (void) loadView {
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
//    self.searchBar.barTintColor = kBarTintColor;
//    self.navigationController.navigationBar.barTintColor = kBarTintColor;
//    self.navigationController.navigationBar.tintColor = kTintColor;
    
    
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//        DLog(@"Load resources for iOS 6.1 or earlier");
//        self.navigationController.navigationBar.tintColor = [UIColor grayColor];
//    } else {
//        DLog(@"Load resources for iOS 7 or later");
////        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.7];
//        self.navigationController.navigationBar.tintColor = [UIColor grayColor];
//    }
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    _categoryList = [[ShowCategoryList alloc] init];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
//    [_refreshControl beginRefreshing];
    
    [self reload];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)reload {
    [_categoryList loadData:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    }];
}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshButtonTapped:(id)sender {
    [self refresh];
}

- (void)refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];
}

#pragma mark - Table Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _searchShows.count;
    }
    return _categoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
        }
        Show *show = _searchShows[indexPath.row];
        cell.textLabel.text = show.title;
        
        return cell;
    }
    else
    {
        [cell configureWithGenre:_categoryList[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        Show *show = _searchShows[indexPath.row];
        if (show.isOTV)
            [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
        else
            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
    }
    else {
        [self performSegueWithIdentifier:showListSegue sender:_categoryList[indexPath.row]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showListSegue]) {
        ShowListViewController *showListViewController = segue.destinationViewController;
        
        ShowCategory *selectedCat = (ShowCategory *)sender;
        showListViewController.navigationItem.title = selectedCat.title;
        [showListViewController reloadWithMode:kCategory Id:selectedCat.Id];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
               value:@"Category"];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:selectedCat.title
                                                          forKey:[GAIFields customDimensionForIndex:1]] build]];
    }
    else if ([segue.identifier isEqualToString:EPAndPartIdentifier]) {
        Show *show = (Show *)sender;
        EpisodePartViewController *episodeAndPartListViewController = segue.destinationViewController;
        episodeAndPartListViewController.show = show;
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
               value:@"Search"];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:show.title
                                                          forKey:[GAIFields customDimensionForIndex:2]] build]];
        
    }
    else if ([segue.identifier isEqualToString:OTVEPAndPartIdentifier ]) {
        
        Show *show = (Show *)sender;
        
        OTVEpisodePartViewController *otvEpAndPartViewController = segue.destinationViewController;
        otvEpAndPartViewController.navigationItem.title = show.title;
        
        otvEpAndPartViewController.show = show;
        
    }
}

#pragma mark - Search

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self search:searchString];
    return YES;
}

- (void)search:(NSString *)keyword {
    if (![keyword isEqualToString:@""]) {
        [Show loadSearchDataWithKeyword:keyword Block:^(NSArray *tempShows, NSError *error) {
            _searchShows = tempShows;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }];
    }
}
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    
}
@end
