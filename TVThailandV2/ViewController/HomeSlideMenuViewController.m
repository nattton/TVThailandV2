//
//  HomeSlideMenuViewController.m
//  TVThailandV2
//
//  Created by April Smith on 4/30/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "HomeSlideMenuViewController.h"
#import "HomeContentViewController.h"
#import "ShowCategoryList.h"
#import "ShowCategoryTableViewCell.h"
#import "FBTableViewCell.h"
#import "SVProgressHUD.h"

#import "ShowListViewController.h"
#import "ShowCategory.h"
#import "Show.h"
#import "CMUser.h"

#import "FavoriteViewController.h"

@interface HomeSlideMenuViewController () <SASlideMenuDataSource, SASlideMenuDelegate,UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>


@end



@implementation HomeSlideMenuViewController {

 UIRefreshControl *_refreshControl;
 ShowCategoryList *_categoryList;
 NSArray *_searchShows;
    
}

//** cell Identifier **//
static NSString *cellIdentifier = @"cellIdentifier";
static NSString *fbCellIdentifier = @"fbCellIdentifier";
static NSString *favoriteCellIdentifier = @"favoriteCellIdentifier";
static NSString *channelCellIdentifier = @"channelCellIdentifier";
static NSString *cateCellIdentifier = @"cateCellIdentifier";
static NSString *radioCellIdentifier = @"radioCellIdentifier";
static NSString *searchCellIdentifier = @"searchCellIdentifier";

//** content segue Identifier **//
static NSString *homeContentSegue = @"homeContentSegue";
static NSString *FBContentSegue = @"FBContentSegue";
static NSString *favoriteContentSegue = @"favoriteContentSegue";
static NSString *channelContentSegue = @"channelContentSegue";
static NSString *radioContentSegue = @"radioContentSegue";
static NSString *showListContentSegue = @"showListContentSegue";

//** sending segue **//
static NSString *showListSegue = @"ShowListSegue";


/** sequence of section Header **/
static NSInteger secFacebook = 0;
static NSInteger secFavorite = 1;
static NSInteger secChannel = 2;
static NSInteger secRadio = 3;
static NSInteger secCategory = 4;


-(void)tap:(id)sender{
    
}

- (void) loadView {
    [super loadView];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
//    UISearchBar *search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
//    self.tableView.tableHeaderView = search;

    [SVProgressHUD showWithStatus:@"Loading..."];
    
    _categoryList = [[ShowCategoryList alloc] init];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    self.tableView.separatorColor = [UIColor clearColor];
    
    
    [self reload];

}



- (void)reload
{
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

- (void)refresh {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

#pragma mark -
#pragma mark SASlideMenuDataSource

-(void) prepareForSwitchToContentViewController:(UINavigationController *)content{
//    UIViewController* controller = [content.viewControllers firstObject];
    
//    if ([controller isKindOfClass:[ShowListViewController class]]) {
//        ShowListViewController* showListViewController = (ShowListViewController*) controller;
////        showListViewController.menuController = self;
//        
//    }
//    else {
//        HomeContentViewController* homeContentViewController = (HomeContentViewController*) controller;
////        homeContentViewController.menuController = self;
//    }
}

// It configure the menu button. The beahviour of the button should not be modified
-(void) configureMenuButton:(UIButton *)menuButton{
    menuButton.frame = CGRectMake(0, 0, 25, 40);
    [menuButton setImage:[UIImage imageNamed:@"MenuIcon"] forState:UIControlStateNormal];
}



// This is the segue you want visibile when the controller is loaded the first time
-(NSIndexPath*) selectedIndexPath{

        return [NSIndexPath indexPathForRow:0 inSection:4];
    
}


// It maps each indexPath to the segueId to be used. The segue is performed only the first time the controller needs to loaded, subsequent switch to the content controller will use the already loaded controller
-(NSString*) segueIdForIndexPath:(NSIndexPath *)indexPath{


    NSInteger section = indexPath.section;
    if (section == secFacebook) {
        return FBContentSegue;
    } else if (section == secCategory) {
        return showListContentSegue;
    } else if (section == secFavorite) {
        return favoriteContentSegue;
    } else if (section == secChannel) {
        return channelContentSegue;
    } else {
        return homeContentSegue;
    }

}

-(Boolean) disableContentViewControllerCachingForIndexPath:(NSIndexPath *)indexPath{
    return YES;
}



#pragma mark -
#pragma mark UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return 5;
    }
    
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

        return nil;
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _searchShows.count;
    } else if (_categoryList && [_categoryList count] > 0) {
        
        if (section == secFacebook) {
            return 1;
        } else if (section == secFavorite){
            return 1;
        } else if (section == secChannel){
            return 1;
        }else if (section == secRadio){
            return 1;
        } else if (section == secCategory){
            return [_categoryList count];
        } else {
            return 1;
        }
  
    }
    
    return 1;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    UITableViewCell* cellOfSearch = [self.tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    
    

    NSInteger section = indexPath.section;
    

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
    
        if (section == secFacebook) {
            FBTableViewCell* cellOfFB = [self.tableView dequeueReusableCellWithIdentifier:fbCellIdentifier];
            cellOfFB.selectedBackgroundView = selectedBackgroundViewForCell;
            
            CMUser *cm_user = [CMUser sharedInstance];
            
            if (cm_user.fbId == nil || [cm_user.fbId isEqualToString: @""]) {
                [cellOfFB configureWithTitle:@"Login with Facebook"];
            }else{
                [cellOfFB configureWithTitle:[NSString stringWithFormat:@"Hello, %@", cm_user.firstName]];
            }
            
            return cellOfFB;
        } else if (section == secFavorite){
            UITableViewCell* cellOfFavorite = [self.tableView dequeueReusableCellWithIdentifier:favoriteCellIdentifier];
            cellOfFavorite.selectedBackgroundView = selectedBackgroundViewForCell;
            return cellOfFavorite;
        } else if (section == secChannel){
            UITableViewCell* cellOfChannel = [self.tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
            cellOfChannel.selectedBackgroundView = selectedBackgroundViewForCell;
            return cellOfChannel;
        } else if (section == secRadio){
            UITableViewCell* cellOfRadio = [self.tableView dequeueReusableCellWithIdentifier:radioCellIdentifier];
            cellOfRadio.selectedBackgroundView = selectedBackgroundViewForCell;
            return cellOfRadio;
        } else if (section == secCategory){
            ShowCategoryTableViewCell *cellOfCate = [self.tableView dequeueReusableCellWithIdentifier:cateCellIdentifier];
            cellOfCate.selectedBackgroundView = selectedBackgroundViewForCell;
        
        
            if ( _categoryList && [_categoryList count] > 0) {
                [cellOfCate configureWithGenre:_categoryList[indexPath.row]];
            }
        
        
            return cellOfCate;
            
        }else {
            UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            return cell;
        }
    }

}

-(CGFloat) leftMenuVisibleWidth{
    return 260;
}



#pragma mark -
#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   

    NSInteger section = indexPath.section;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        Show *show = _searchShows[indexPath.row];
//        if (show.isOTV)
//            [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
//        else
//            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
    } else {
        if (section == secCategory) {
        
            [self performSegueWithIdentifier:showListContentSegue sender:_categoryList[indexPath.row]];
     
        }else if (section == secFavorite) {
        
            [self performSegueWithIdentifier:favoriteContentSegue sender:nil];
            
        }else if (section == secChannel) {
        
            [self performSegueWithIdentifier:channelContentSegue sender:nil];
        
        }else if (section == secRadio) {
        
            [self performSegueWithIdentifier:radioContentSegue sender:nil];
        
        }else if (section == secFacebook) {
        
            [self performSegueWithIdentifier:FBContentSegue sender:nil];
        
        }else {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:showListContentSegue]) {

        UINavigationController *content = segue.destinationViewController;
        ShowListViewController* controller = [content.viewControllers firstObject];
        
        ShowCategory *selectedCat = (ShowCategory *)sender;
        controller.navigationItem.title = selectedCat.title;
        
        if ( _categoryList && [_categoryList count] > 0 ) {
           
            [controller reloadWithMode:kCategory Id:selectedCat.Id];
        } else {
            controller.navigationItem.title = @"รายการล่าสุด";
            [controller reloadWithMode:kCategory Id:@"recents"];
        }
        
        
    }
    

//    else if ([segue.identifier isEqualToString:EPAndPartIdentifier]) {
//        Show *show = (Show *)sender;
//        EpisodePartViewController *episodeAndPartListViewController = segue.destinationViewController;
//        episodeAndPartListViewController.show = show;
//        
//        id tracker = [[GAI sharedInstance] defaultTracker];
//        [tracker set:kGAIScreenName
//               value:@"Search"];
//        [tracker send:[[[GAIDictionaryBuilder createAppView] set:show.title
//                                                          forKey:[GAIFields customDimensionForIndex:2]] build]];
//        
//    }
//    else if ([segue.identifier isEqualToString:OTVEPAndPartIdentifier ]) {
//        
//        Show *show = (Show *)sender;
//        
//        OTVEpisodePartViewController *otvEpAndPartViewController = segue.destinationViewController;
//        otvEpAndPartViewController.navigationItem.title = show.title;
//        
//        otvEpAndPartViewController.show = show;
//        
//    }
    
    
}

#pragma mark - Search

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self search:searchString];
    return YES;
}

- (void)search:(NSString *)keyword {
    if (![keyword isEqualToString:@""]) {
        [Show loadSearchDataWithKeyword:keyword Block:^(NSArray *tempShows, NSError *error) {
            _searchShows = tempShows;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }];
    }
}
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
//    [self.searchBarView setFrame:CGRectMake(0, 36, self.searchBarView.frame.size.width, self.searchBarView.frame.size.height)];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
//    [self.searchBarView setFrame:CGRectMake(0, 36, self.searchBarView.frame.size.width, self.searchBarView.frame.size.height)];
}



#pragma mark -
#pragma mark SASlideMenuDelegate

-(void) slideMenuWillSlideIn:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuWillSlideIn");
}
-(void) slideMenuDidSlideIn:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuDidSlideIn");
}
-(void) slideMenuWillSlideToSide:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuWillSlideToSide");
    [self.tableView reloadData];
}
-(void) slideMenuDidSlideToSide:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuDidSlideToSide");
}
-(void) slideMenuWillSlideOut:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuWillSlideOut");
}
-(void) slideMenuDidSlideOut:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuDidSlideOut");
}
-(void) slideMenuWillSlideToLeft:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuWillSlideToLeft");
}
-(void) slideMenuDidSlideToLeft:(UINavigationController *)selectedContent{
    NSLog(@"slideMenuDidSlideToLeft");
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 5)];
    
    [view setBackgroundColor:[UIColor colorWithRed: 246/255.0 green:246/255.0 blue:246/255.0 alpha:0.7]];
    [underline setBackgroundColor:[UIColor colorWithRed: 246/255.0 green:246/255.0 blue:246/255.0 alpha:0.7]];
    
    if (section == secFacebook) {
        return underline;
    } else if (section == secFavorite){
        return underline;
    } else if (section == secChannel){
        return underline;
    } else if (section == secRadio){
        return underline;
    } else if (section == secCategory){
        return view;
    } else {
        return nil;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == secFacebook) {
        return 5;
    } else if (section == secFavorite){
        return 0;
    } else if (section == secChannel){
        return 0;
    } else if (section == secRadio){
        return 0;
    } else if (section == secCategory){
        return 10;
    } else {
        return 0;
    }
}


@end
