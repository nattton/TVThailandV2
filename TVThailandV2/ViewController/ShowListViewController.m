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
#import "EpisodeListViewController.h"
#import "VideoPlayerViewController.h"

#import "SVProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "EpisodeANDPartViewController.h"
#import "Reachability.h"

@interface ShowListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *alertTitleView;
@property (strong, nonatomic) IBOutlet UILabel *alertTitle;

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
static NSString *EPAndPartIdentifier = @"EPAndPartIdentifier";


static NSString *showEpisodeSegue = @"ShowEpisodeSegue";
static NSString *showPlayerSegue = @"ShowPlayerSegue";



#pragma mark - Seque Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:EPAndPartIdentifier]) {
        Show *show = (Show *)sender;
        EpisodeANDPartViewController *episodeAndPartListViewController = segue.destinationViewController;
        episodeAndPartListViewController.show = show;
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
              value:_screenName];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:show.title
                                                         forKey:[GAIFields customDimensionForIndex:2]] build]];
        
    }
    else if ([segue.identifier isEqualToString:showPlayerSegue]) {
        VideoPlayerViewController *videoPlayerViewController = segue.destinationViewController;
        videoPlayerViewController.videoUrl = self.videoUrl;
        videoPlayerViewController.navigationItem.title = [NSString stringWithFormat:@"Live : %@", self.navigationItem.title];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /** Alert View & Refresh Button - connection fail, try again **/
    self.alertTitleView.alpha = 0;
    
    
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        DLog(@"Load resources for iOS 6.1 or earlier");
        self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    } else {
        DLog(@"Load resources for iOS 7 or later");
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.7];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

        
        
    }


    
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
        if (self.videoUrl != nil && ![self.videoUrl isEqualToString:@""]) {
            UIBarButtonItem *liveButton = [[UIBarButtonItem alloc] initWithTitle:@"Live" style:UIBarButtonItemStylePlain target:self action:@selector(playLive:)];
            self.navigationItem.rightBarButtonItem = liveButton;
        }
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
        }
        Show *show = _searchShows[indexPath.row];
        cell.textLabel.text = show.title;
        
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
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:EPAndPartIdentifier sender:_searchShows[indexPath.row]];
    }
    else {
        // Comment the current version of showEpisodeSegue
//        [self performSegueWithIdentifier:showEpisodeSegue sender:_shows[indexPath.row]];
        [self performSegueWithIdentifier:EPAndPartIdentifier sender:_shows[indexPath.row]];
    }
}

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
    internetReachableTVThailand = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableTVThailand.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
//            DLog(@"Yayyy, we have the interwebs!");
            
            self.alertTitle.text = @"connection fail, try again";
            
        });
    };
    
    // Internet is not reachable
    internetReachableTVThailand.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"Nooo, someone broke internet!");
            self.alertTitle.text = @"no internet connection";
            self.alertTitleView.alpha = 0.85;
            
            
        });
    };
    
    [internetReachableTVThailand startNotifier];
}

- (IBAction)alertRefreshButtonTouched:(id)sender {
    DLog(@"Refresh Click");
    [self reload];

}





@end
