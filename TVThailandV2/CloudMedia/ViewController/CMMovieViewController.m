//
//  CMMovieViewController.m
//  CloudMedia
//
//  Created by April Smith on 9/30/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMMovieViewController.h"
#import "CMCategory.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMMovie.h"
#import "CMMovieCell.h"
#import "CMEpisodeViewController.h"
#import "SVProgressHUD.h"

@interface CMMovieViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CMMovieViewController{
    NSArray *_cmMovie;
    BOOL isLoading;
    BOOL isEnding;
    UIRefreshControl *_refreshControl;
}

static NSString *CMMovieCellIdentifier = @"CMMovieCellIdentifier";
static NSString *CMEpisodeSegue = @"CMEpisodeSegue";


- (void)viewDidLoad
{
    [super viewDidLoad];
    [SVProgressHUD showWithStatus:@"Loading..."];

    [self reload];

    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}
- (void)reload {
    isEnding = NO;
    [self reload:0];
}
- (void) reload:(NSUInteger)start{
    if (isLoading||isEnding) {
        return;
    }
    isLoading = YES;
    
    if (_mode == kMovie) {
        
        self.navigationItem.title = self.cmCategory.title;
        [CMMovie loadCMMovieWithCateID:self.cmCategory.idCM start:start Block:^(NSArray *cmMovies, NSError *error) {
            [SVProgressHUD dismiss];
            if ([cmMovies count] == 0) {
                isEnding = YES;
            }
            if (start==0) {
                _cmMovie = cmMovies;
            }else{
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_cmMovie];
                [mergeArray addObjectsFromArray:cmMovies];
                _cmMovie = [NSArray arrayWithArray:mergeArray];
            }
            
            isLoading = NO;

            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            [self.tableView reloadData];
            
        }];
    
    }else if(_mode == kPurchase){
        self.navigationItem.title = @"Purchase";
        [CMMovie loadCMPurchaseBlock:^(NSArray *cmMovies, NSError *error) {
            [SVProgressHUD dismiss];
            _cmMovie = cmMovies;

            isLoading = NO;
            isEnding = YES;
            
            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            [self.tableView reloadData];

        }];
        
    }else if(_mode == kWishlist){
        self.navigationItem.title = @"Wishlist";
        [CMMovie loadCMWishlistBlock:^(NSArray *cmMovies, NSError *error) {
            [SVProgressHUD dismiss];
            _cmMovie = cmMovies;

            isLoading = NO;
            isEnding = YES;
            
            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            [self.tableView reloadData];

        }];
    }



}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cmMovie.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMMovieCell *cell = [tableView dequeueReusableCellWithIdentifier:CMMovieCellIdentifier];
    
    [cell configureWithCMMovie:_cmMovie[indexPath.row]];

    if (_mode == kMovie) {
        if ((indexPath.row + 5) == _cmMovie.count) {
            
            [self reload:_cmMovie.count];
        }
    }

    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CMMovie *cmMovie = _cmMovie[indexPath.row];
    [self performSegueWithIdentifier:CMEpisodeSegue  sender:cmMovie];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:CMEpisodeSegue]) {
        CMEpisodeViewController *cmEpisodeViewController = segue.destinationViewController;
        cmEpisodeViewController.cmMovie = (CMMovie *)sender;
    }
}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self reload];
}

@end
