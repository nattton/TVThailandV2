//
//  OTVShowCategoryViewController.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVShowCategoryViewController.h"
#import "OTVShowCategoryTableViewCell.h"
#import "SVProgressHUD.h"
#import "OTVCategory.h"

@interface OTVShowCategoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OTVShowCategoryViewController {
    @private
    UIRefreshControl *_refreshControl;
    NSArray *_categories;
}

static NSString *cellIdentifier = @"OTVShowCategoryCellIdentifier";

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        DLog(@"Load resources for iOS 6.1 or earlier");
        self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    } else {
        DLog(@"Load resources for iOS 7 or later");
        //        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.7];
        self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    }
    
    
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [self reload];
}

- (void)reload {
    [OTVCategory loadOTVCategory:^(NSArray *otvCategories, NSError *error) {
        [SVProgressHUD dismiss];
        _categories = otvCategories;
        
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Table Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTVShowCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
//    [cell configureWithCate:_category[indexPath.row]];
    [cell configureWithOTVCate:_categories[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self performSegueWithIdentifier:showListSegue sender:_categoryList[indexPath.row]];
}




@end
