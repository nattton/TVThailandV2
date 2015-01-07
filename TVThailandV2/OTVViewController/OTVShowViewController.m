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
#import "OTVEpisodePartViewController.h"


@interface OTVShowViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OTVShowViewController {
    @private
    UIRefreshControl *_refreshControl;
    NSArray *_shows;
    
    BOOL isLoading;
    BOOL isEnding;
    
}

#pragma mark - Static Variable
static NSString *cellIdentifier = @"OTVShowCellIdentifier";
static NSString *otvEPAndPartIdentifier = @"OTVEPAndPartIdentifier";

//static NSString *OTVShowDetailListSegue = @"OTVShowDetailListSegue";

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
     [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];
}

- (void)reload {
    isEnding = NO;
    [self reload:0];
}

- (void)reload:(NSUInteger)start {
    if (isLoading || isEnding) {
        return;
    }
    
    isLoading = YES;
    if ([_otvCategory.IdCate isEqualToString:kOTV_CH7]) {
     
        [OTVShow retrieveData:self.otvCategory.cateName Start:0 Block:^(NSArray *otvShows, NSError *error) {
            
            
            if ([otvShows count] == 0) {
                isEnding = YES;
            }
            
            if (start == 0) {
                [SVProgressHUD dismiss];
                _shows = otvShows;
                
            } else {
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_shows];
                [mergeArray addObjectsFromArray:otvShows];
                _shows = [NSArray arrayWithArray:mergeArray];
            }
            
            
            [self.tableView reloadData];
            isLoading = NO;
            
            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        }];
    }
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
    if ([segue.identifier isEqualToString:otvEPAndPartIdentifier ]) {
        
        OTVShow *otvShow = (OTVShow *)sender;
        
        OTVEpisodePartViewController *otvEpAndPartViewController = segue.destinationViewController;
        otvEpAndPartViewController.navigationItem.title = otvShow.title;
        
//        otvEpAndPartViewController.otvCategory = self.otvCategory;
//        otvEpAndPartViewController.otvShow = otvShow;

    }
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:otvEPAndPartIdentifier sender:_shows[indexPath.row]];
}

@end
