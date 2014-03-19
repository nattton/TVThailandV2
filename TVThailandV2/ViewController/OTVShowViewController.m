//
//  OTVShowViewController.m
//  TVThailandV2
//
//  Created by April Smith on 3/19/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVShowViewController.h"
#import "SVProgressHUD.h"
#import "OTVShow.h"
#import "OTVShowTableViewCell.h"
#import "OTVCategory.h"


@interface OTVShowViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OTVShowViewController {
    @private
    UIRefreshControl *_refreshControl;
    NSArray *_shows;
    
}

#pragma mark - Static Variable

static NSString *cellIdentifier = @"OTVShowCellIdentifier";
//static NSString *OTVShowDetailListSegue = @"OTVShowDetailListSegue";

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    [OTVShow loadOTVShow:self.otvCategory.cateName Start:0 Block:^(NSArray *otvShows, NSError *error) {
        
        [SVProgressHUD dismiss];
        _shows = otvShows;
        
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



- (void)refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  
}




#pragma mark - Table Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTVShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell configWithOTVShow:_shows[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self performSegueWithIdentifier:OTVShowDetailListSegue sender:_shows[indexPath.row]];
}

@end
