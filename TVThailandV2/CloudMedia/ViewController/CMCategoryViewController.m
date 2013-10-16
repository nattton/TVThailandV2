//
//  ViewController.m
//  CloudMedia
//
//  Created by April Smith on 9/29/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMCategoryViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMCateCell.h"
#import "CMCategory.h"
#import "CMMovieViewController.h"
#import "CMAccountViewController.h"
#import "CMUser.h"
#import "CMProfileViewController.h"
#import "SVProgressHUD.h"

@interface CMCategoryViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CMCategoryViewController{
    NSArray *_cmCate;
    BOOL isLoading;
    BOOL isEnding;
    UIRefreshControl *_refreshControl;
@private
    MovieModeType MODE;
    
}



static NSString *cmCateCellIdentifier = @"CMCateCellIdentifier";
static NSString *cmMovieSegue = @"CMMovieSegue";
static NSString *cmAccountSegue = @"CMAccountSegue";
static NSString *cmProfileSegue = @"CMProfileSegue";
static NSString *cmPurchaseSegue = @"CMPurchaseSegue";
static NSString *cmWishlistSegue = @"CMWishListSegue";

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

- (IBAction)tabOnAccountButton:(id)sender {
    CMUser *cmUser = [CMUser sharedInstance];

    if (cmUser.isLogin) {
        [self performSegueWithIdentifier:cmProfileSegue sender:nil];
    }
    else{
        [self performSegueWithIdentifier:cmAccountSegue sender:nil];
    }
    

}
- (IBAction)tabOnPurchaseButton:(id)sender {
    MODE = kPurchase;
    [self performSegueWithIdentifier:cmMovieSegue sender:nil];
    
}
- (IBAction)tabOnWishlistButton:(id)sender {
    MODE = kWishlist;
    [self performSegueWithIdentifier:cmMovieSegue sender:nil];
}
- (void) reload{
    isEnding = NO;
    [self reload:0];
}
- (void) reload:(NSUInteger)start{
    if (isLoading || isEnding) {
        return;
    }
    isLoading = YES;
    
    [CMCategory loadCMCategory:start Block:^(NSArray *cmCategories, NSError *error) {
        [SVProgressHUD dismiss];
        if ([cmCategories count] == 0) {
            isEnding = YES;
        }
        if (start == 0){
            _cmCate = cmCategories;
        }else{
            NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_cmCate];
            [mergeArray addObjectsFromArray:cmCategories];
            _cmCate = [NSArray arrayWithArray:mergeArray];
        }
        
        [self.tableView reloadData];
        isLoading = NO;
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    }];
    
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:cmMovieSegue]) {
        CMMovieViewController *cmMovieViewController = segue.destinationViewController;
        if (MODE == kMovie){
           cmMovieViewController.cmCategory = (CMCategory *)sender;
            
        }
        cmMovieViewController.mode = MODE;
    }

}

#pragma Mark - Table Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cmCate.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMCateCell *cell = [tableView dequeueReusableCellWithIdentifier:cmCateCellIdentifier];

   [cell configureWithCMCategory:_cmCate[indexPath.row]];
    
    if ((indexPath.row + 5) == _cmCate.count) {
        [self reload:_cmCate.count];
    }
    
    return cell;
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CMCategory *cmCategory = _cmCate[indexPath.row];
    MODE = kMovie;
    [self performSegueWithIdentifier:cmMovieSegue  sender:cmCategory];
}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self reload];
}

@end
