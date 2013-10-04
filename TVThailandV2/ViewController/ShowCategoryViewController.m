//
//  GenreListViewController.m
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

@interface ShowCategoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ShowCategoryViewController {
    
@private
    UIRefreshControl *_refreshControl;
    ShowCategoryList *_genreList;
}

static NSString *cellIdentifier = @"GenreCellIdentifier";
static NSString *showListSegue = @"ShowListSegue";

#pragma mark - UIViewController

- (void) loadView {
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    _genreList = [[ShowCategoryList alloc] init];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
//    [_refreshControl beginRefreshing];
    
    [self reload];
    

}

- (void)reload {
    [_genreList loadData:^(NSError *error) {
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

#pragma mark - Table Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _genreList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (indexPath.section == 0) {
        [cell configureAllGenre];
    }
    else {
        [cell configureWithGenre:_genreList[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:showListSegue sender:nil];
    } else {
        [self performSegueWithIdentifier:showListSegue sender:_genreList[indexPath.row]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showListSegue]) {
        ShowListViewController *showListViewController = segue.destinationViewController;
        if (sender) {
            ShowCategory *selectedGenre = (ShowCategory *)sender;
            showListViewController.navigationItem.title = selectedGenre.title;
            [showListViewController reloadWithMode:kCategory Id:selectedGenre.Id];
        } else {
            showListViewController.navigationItem.title = @"TV Thailand";
            [showListViewController reloadWithMode:kWhatsNew Id:nil];
        }
    }
}

@end
