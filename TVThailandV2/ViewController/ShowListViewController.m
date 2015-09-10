//
//  ShowListViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowListViewController.h"
#import "ShowTableViewCell.h"
#import "Show.h"

#import "ShowCategoryViewController.h"
#import "VideoPlayerViewController.h"

#import "SVProgressHUD.h"

#import <Google/Analytics.h>

#import "EpisodePartViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "OTVShow.h"

#import "OTVEpisodePartViewController.h"

#import "MakathonAdView.h"

#import "Channel.h"

@interface ShowListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *alertTitleView;
@property (weak, nonatomic) IBOutlet UILabel *alertTitle;

@property (weak, nonatomic) IBOutlet UIButton *goToTopButton;
@property (weak, nonatomic) IBOutlet MakathonAdView *mkAdView;


@end

@implementation ShowListViewController {
    NSString *_screenName;
    NSArray *_shows;
    NSArray *_searchShows;
    NSString *_Id;
    ShowModeType _mode;
    bool isLoading;
    bool isEnding;
    UIRefreshControl *_refreshControl;
}

#pragma mark - Static Variable

static NSString *cellIdentifier = @"ShowCellIdentifier";
static NSString *searchCellIdentifier = @"SearchCellIdentifier";

//static NSString *showEpisodeSegue = @"ShowEpisodeSegue";
static NSString *showPlayerSegue = @"ShowPlayerSegue";

static NSString *EPAndPartIdentifier = @"EPAndPartIdentifier";
static NSString *OTVEPAndPartIdentifier = @"OTVEPAndPartIdentifier";


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:EPAndPartIdentifier]) {
        Show *show = (Show *)sender;
        EpisodePartViewController *episodeAndPartListViewController = segue.destinationViewController;
        episodeAndPartListViewController.show = show;
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
              value:_screenName];
        [tracker send:[[[GAIDictionaryBuilder createScreenView] set:show.title
                                                         forKey:[GAIFields customDimensionForIndex:2]] build]];
        
    }
    else if ([segue.identifier isEqualToString:showPlayerSegue]) {
        VideoPlayerViewController *videoPlayerViewController = segue.destinationViewController;
        videoPlayerViewController.channel = self.channel;
        videoPlayerViewController.navigationItem.title = [NSString stringWithFormat:@"Live : %@", self.navigationItem.title];
    }
    else if ([segue.identifier isEqualToString:OTVEPAndPartIdentifier ]) {
        Show *show = (Show *)sender;
        OTVEpisodePartViewController *otvEpAndPartViewController = segue.destinationViewController;
        otvEpAndPartViewController.show = show;
    }
}

#pragma mark - UIViewController

- (void) setChannel:(Channel *)channel {
    _channel = channel;
    self.navigationItem.title = channel.title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonTapped:)];
    
    self.navigationItem.rightBarButtonItem = searchBarButton;
    
    [self setUpGoToTop];
    
    self.mkAdView.parentViewController = self;
    [self.mkAdView requestAd];
    
    /** Alert View & Refresh Button - connection fail, try again **/
    self.alertTitleView.alpha = 0;
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    [self reload];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    switch (_mode) {
        case kWhatsNew:
            _screenName = @"WhatsNew";
            break;
        case kCategory:
        case kChannel:
            _screenName = @"Program";
            break;
        default:
            break;
    }
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.tableView setSeparatorColor:[UIColor colorWithRed: 240/255.0 green:240/255.0 blue:240/255.0 alpha:0.7]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:_screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)setUpGoToTop
{
    self.goToTopButton.hidden = YES;
    self.goToTopButton.layer.shadowColor = [UIColor grayColor].CGColor;
    self.goToTopButton.layer.shadowOpacity = 0.5;
    self.goToTopButton.layer.shadowRadius = 2;
    self.goToTopButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    DLog(@"%f", scrollView.contentOffset.y);
    self.goToTopButton.hidden = !(scrollView.contentOffset.y > 1000);
}

#pragma mark - IBAction

- (IBAction)goToTopTapped:(id)sender {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
}
- (IBAction)searchButtonTapped:(id)sender {
    
    [self.homeSlideMenuViewController revealLeftMenu];
    [self.homeSlideMenuViewController searchTapped];
    [self.homeSlideMenuViewController.searchTextField becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Function

- (void)reload {

    self.alertTitleView.alpha = 0;
    [SVProgressHUD showWithStatus:@"Loading..."];
    isEnding = NO;
    [self reload:0];
}

- (void)reloadWithMode:(ShowModeType) mode Id:(NSString *)Id {
    _mode = mode;
    _Id = Id;
    
//    if (_mode == kChannel) {
//        if (self.channel != nil && self.channel.videoUrl != nil && ![self.channel.videoUrl isEqualToString:@""]) {
//            UIBarButtonItem *liveButton = [[UIBarButtonItem alloc] initWithTitle:@"Live" style:UIBarButtonItemStylePlain target:self action:@selector(playLive:)];
//            liveButton.tintColor = [UIColor colorWithRed:248/255.0 green:126/255.0 blue:122/255.0 alpha:1.0];
//            self.navigationItem.rightBarButtonItem = liveButton;
//        }else{
//            self.navigationItem.rightBarButtonItem = nil;
//        }
//    }else if(_mode == kCategory){
//         self.navigationItem.rightBarButtonItem = nil;
//    }

}

- (void)playLive:(id)sender {
    [self performSegueWithIdentifier:showPlayerSegue sender:sender];
}

- (void)reload:(NSUInteger)start {
    if (isLoading || isEnding) {
        return;
    }
    
    isLoading = YES;
    if (_mode == kWhatsNew) {
        [Show loadWhatsNewDataWithStart:start Block:^(NSArray *tempShows, NSError *error) {
            
            [SVProgressHUD dismiss];
            
            
            if (error != nil) {
                self.alertTitleView.alpha = 0.85;
            }
            
            if ([tempShows count] == 0 ) {
                isEnding = YES;
            }
            
            if (start == 0) {
                _shows = tempShows;
            } else {
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_shows];
                [mergeArray addObjectsFromArray:tempShows];
                _shows = [NSArray arrayWithArray:mergeArray];
            }
            
            [self.tableView reloadData];
            isLoading = NO;
            
            
            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            
            if (error != nil) {
                double delayInSeconds = 10.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [self reload];
                });
            }
        }];
    }
    else if (_mode == kCategory) {
        [Show loadCategoryDataWithId:_Id Start:start Block:^(NSArray *tempShows, NSError *error) {
            
            [SVProgressHUD dismiss];
            
            
            if (error != nil) {
                self.alertTitleView.alpha = 0.85;
            }
            
            if ([tempShows count] == 0) {
                isEnding = YES;
            }
            
            if (start == 0) {
                _shows = tempShows;
            } else {
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_shows];
                [mergeArray addObjectsFromArray:tempShows];
                _shows = [NSArray arrayWithArray:mergeArray];
            }
            
            [self.tableView reloadData];
            isLoading = NO;
            
            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            
            if (error != nil) {
                double delayInSeconds = 10.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [self reload];
                });
            }
        }];
    }
    else if (_mode == kChannel) {
        [Show loadChannelDataWithId:_Id Start:start Block:^(NSArray *tempShows, NSError *error) {
            
            [SVProgressHUD dismiss];
            
            
            if (error != nil) {
                self.alertTitleView.alpha = 0.85;
            }
            
            if ([tempShows count] == 0) {
                isEnding = YES;
            }
            
            if (start == 0) {
                _shows = tempShows;
            } else {
                NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_shows];
                [mergeArray addObjectsFromArray:tempShows];
                _shows = [NSArray arrayWithArray:mergeArray];
            }
            
            [self.tableView reloadData];
            isLoading = NO;
            
            [_refreshControl endRefreshing];
            _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            
            if (_shows.count == 0 ) {
                [self performSegueWithIdentifier:showPlayerSegue sender:self];
            }
            
            if (error != nil) {
                double delayInSeconds = 10.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [self reload];
                });
            }
        }];
    }
}


#pragma mark - Table Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _searchShows.count;
    }
    return _shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
        }
        Show *show = _searchShows[indexPath.row];
        cell.textLabel.text = show.title;
        
        cell.selectedBackgroundView = selectedBackgroundViewForCell;
        
        return cell;
    } else {
            ShowTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (_mode == kWhatsNew) {
            [cell configureWhatsNewWithShow:_shows[indexPath.row]];
        } else if (_mode == kCategory || _mode == kChannel) {
            [cell configureWithShow:_shows[indexPath.row]];
        }
        
        if ((indexPath.row + 5) == _shows.count) {
            [self reload:_shows.count];
        }
        
        cell.selectedBackgroundView = selectedBackgroundViewForCell;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Show *show = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        show = _searchShows[indexPath.row];
    }
    else {
        show = _shows[indexPath.row];
    }
    
    if (show != nil) {
        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) && show.isOTV)
            [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
        else
            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    CGFloat footerWidth;
    CGFloat footerHeight;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        footerHeight = 90.f;
        footerWidth = 1024.f;
    } else {
        footerHeight = 50.0f;
        footerWidth = 568.f;
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerWidth, footerHeight)];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return 90.f;
    }
    return 50.0f;
}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self reload];
}

- (IBAction)alertRefreshButtonTouched:(id)sender {
    DLog(@"Refresh Click");
    [self reload];

}




@end
