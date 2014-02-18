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

#import "ShowListViewController.h"
#import "SVProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface ShowCategoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ShowCategoryViewController {
    
@private
    UIRefreshControl *_refreshControl;
    ShowCategoryList *_categoryList;
}

static NSString *cellIdentifier = @"CategoryCellIdentifier";
static NSString *showListSegue = @"ShowListSegue";

#pragma mark - UIViewController

- (void) loadView {
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        DLog(@"Load resources for iOS 6.1 or earlier");
        self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    } else {
        DLog(@"Load resources for iOS 7 or later");
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.7];
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    _categoryList = [[ShowCategoryList alloc] init];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
//    [_refreshControl beginRefreshing];
    
    [self reload];
    

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
    return _categoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell configureWithGenre:_categoryList[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:showListSegue sender:_categoryList[indexPath.row]];
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
}

@end
