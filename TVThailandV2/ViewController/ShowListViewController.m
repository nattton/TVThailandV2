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

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "EpisodePartViewController.h"
#import "Reachability.h"

#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "OTVShow.h"

#import "OTVEpisodePartViewController.h"

#import "MakathonAdView.h"

#import "Channel.h"

@interface ShowListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIScrollViewDelegate>

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
    Reachability *internetReachableTVThailand;
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
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:show.title
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
//        otvEpAndPartViewController.navigationItem.title = show.title;
        
        otvEpAndPartViewController.show = show;
        
    }
}

- (void) setChannel:(Channel *)channel {
    _channel = channel;
    self.navigationItem.title = channel.title;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
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

    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:_screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.tableView setSeparatorColor:[UIColor colorWithRed: 240/255.0 green:240/255.0 blue:240/255.0 alpha:0.7]];
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
    
    if (_mode == kChannel) {
        if (self.channel != nil && self.channel.videoUrl != nil && ![self.channel.videoUrl isEqualToString:@""]) {
            UIBarButtonItem *liveButton = [[UIBarButtonItem alloc] initWithTitle:@"Live" style:UIBarButtonItemStylePlain target:self action:@selector(playLive:)];
            liveButton.tintColor = [UIColor colorWithRed:248/255.0 green:126/255.0 blue:122/255.0 alpha:1.0];
            self.navigationItem.rightBarButtonItem = liveButton;
        }else{
            self.navigationItem.rightBarButtonItem = nil;
        }
    }else if(_mode == kCategory){
         self.navigationItem.rightBarButtonItem = nil;
    }

    

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
        [self testInternetConnection];
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
        [self testInternetConnection];
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
        [self testInternetConnection];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        Show *show = _searchShows[indexPath.row];
        if (show.isOTV)
            [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
        else
            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
    }
    else {
        Show *show = _shows[indexPath.row];
        if (show.isOTV)
            [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
        else
            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
    }
}

//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    Show *show = _shows[indexPath.row];
//    if (show.isOTV) {
//        return YES;
//    }
//    return NO;
//}

//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        if (self.tableView == self.searchDisplayController.searchResultsTableView)
//        {
//            Show *show = _searchShows[indexPath.row];
//            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
//        }
//        else
//        {
//            Show *show = _shows[indexPath.row];
//            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
//        }
//    }
//}

//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"Youtube";
//}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self reload];
}


#pragma mark - Search

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self search:searchString];
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
//    self.searchDisplayController.searchBar.hidden = NO;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        CGRect statusBarFrame =  [[UIApplication sharedApplication] statusBarFrame];
//        [UIView animateWithDuration:0.25 animations:^{
//            for (UIView *subview in self.view.subviews)
//                subview.transform = CGAffineTransformMakeTranslation(0, statusBarFrame.size.height);
//        }];
//    }
}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//    self.searchDisplayController.searchBar.hidden = YES;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        [UIView animateWithDuration:0.25 animations:^{
//            for (UIView *subview in self.view.subviews)
//                subview.transform = CGAffineTransformIdentity;
//        }];
//    }
}

- (void)search:(NSString *)keyword {
    if (![keyword isEqualToString:@""]) {
        [Show loadSearchDataWithKeyword:keyword Block:^(NSArray *tempShows, NSError *error) {
            _searchShows = tempShows;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }];
    }
}

- (void)testInternetConnection
{
    __weak typeof(self) weakSelf = self;
    internetReachableTVThailand = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableTVThailand.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
//            DLog(@"Yayyy, we have the interwebs!");
            
            weakSelf.alertTitle.text = @"connection fail, try again";
            
        });
    };
    
    // Internet is not reachable
    internetReachableTVThailand.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"Nooo, someone broke internet!");
            weakSelf.alertTitle.text = @"no internet connection";
            weakSelf.alertTitleView.alpha = 0.85;
            
            
        });
    };
    
    [internetReachableTVThailand startNotifier];
}

- (IBAction)alertRefreshButtonTouched:(id)sender {
    DLog(@"Refresh Click");
    [self reload];

}




@end
