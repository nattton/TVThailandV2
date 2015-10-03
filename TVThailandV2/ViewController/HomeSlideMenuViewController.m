//
//  HomeSlideMenuViewController.m
//  TVThailandV2
//
//  Created by April Smith on 4/30/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "HomeSlideMenuViewController.h"
#import "ShowCategoryList.h"
#import "ShowCategoryTableViewCell.h"
#import "FBTableViewCell.h"
#import "SVProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"

#import "ShowListViewController.h"
#import "ChannelViewController.h"
#import "ShowCategory.h"
#import "Show.h"
#import "CMUser.h"
#import "AppDelegate.h"

#import "FavoriteViewController.h"

#import "EpisodePartViewController.h"
#import "OTVEpisodePartViewController.h"

@interface HomeSlideMenuViewController () <SASlideMenuDataSource, SASlideMenuDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIButton *backToSlideMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *clearSearchFieldButton;
@property (weak, nonatomic) IBOutlet UILabel *tvThailandLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;

@property (weak, nonatomic) IBOutlet UIView *alertTitleView;
@property (weak, nonatomic) IBOutlet UILabel *alertTitle;

@end



@implementation HomeSlideMenuViewController {

 UIRefreshControl *_refreshControl;
 ShowCategoryList *_categoryList;
 NSArray *_searchShows;
 UIView *_searchUIView;
 int _numSection;
 UITableView *_searchTable;
    
}

//** cell Identifier **//
static NSString *cellIdentifier = @"cellIdentifier";
static NSString *fbCellIdentifier = @"fbCellIdentifier";
static NSString *favoriteCellIdentifier = @"favoriteCellIdentifier";
static NSString *channelCellIdentifier = @"channelCellIdentifier";
static NSString *cateCellIdentifier = @"cateCellIdentifier";
static NSString *radioCellIdentifier = @"radioCellIdentifier";
static NSString *settingCellIdentifier = @"settingCellIdentifier";
static NSString *searchCellIdentifier = @"searchCellIdentifier";

//** content segue Identifier **//
static NSString *homeContentSegue = @"homeContentSegue";
static NSString *FBContentSegue = @"FBContentSegue";
static NSString *favoriteContentSegue = @"favoriteContentSegue";
static NSString *channelContentSegue = @"channelContentSegue";
static NSString *radioContentSegue = @"radioContentSegue";
static NSString *settingContentSegue = @"settingContentSegue";
static NSString *showListContentSegue = @"showListContentSegue";
static NSString *searchMenuSegue = @"searchMenuSegue";

static NSString *EPAndPartIdentifier = @"EPAndPartIdentifier";
static NSString *OTVEPAndPartIdentifier = @"OTVEPAndPartIdentifier";


//** sending segue **//
static NSString *showListSegue = @"ShowListSegue";


/** sequence of section Header **/
static NSInteger secFacebook = 0;
static NSInteger secFavorite = 1;
static NSInteger secChannel = 2;
static NSInteger secRadio = 3;
static NSInteger secSetting = 4;
static NSInteger secCategory = 5;
static NSInteger totalSection = 6;

/** TAG of tableview **/
static NSInteger tagSearchTable = 999;

-(void)tap:(id)sender{
    
}

- (void) loadView {
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.alertTitleView setHidden:YES];
    
    _numSection = (int)totalSection;
    self.searchTextField.delegate = self;
    [self.searchTextField addTarget:self
                             action:@selector(textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    
    _categoryList = [[ShowCategoryList alloc] initWithWhatsNew];
    
    [self.tableView reloadData];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    self.tableView.separatorColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    
    [self reload];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *statusNumber = [dict objectForKey:AFNetworkingReachabilityNotificationStatusItem];
    AFNetworkReachabilityStatus status = (AFNetworkReachabilityStatus)statusNumber.intValue;
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [self.alertTitleView setHidden:YES];
            [self reload];
            break;
        case AFNetworkReachabilityStatusNotReachable:
        default:
            [self.alertTitleView setHidden:NO];
            [self.alertTitle setText:@"No Internet Connection"];
            break;
    }
}

- (void)reload
{
    [self.alertTitleView setHidden:YES];
    [_categoryList retrieveData:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        if (error) {
            if (error != nil) {
                [self.alertTitleView setHidden:NO];
                [self.alertTitle setText:error.localizedDescription];
            }
        }
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

#pragma mark - Search UI

- (IBAction)searchTapped:(id)sender {
    [self searchTapped];
    [self.searchTextField becomeFirstResponder];
}

- (void)searchTapped {
    
    if (_searchUIView == nil  && _searchTable == nil) {
        _searchUIView = [[UIView alloc] initWithFrame:CGRectMake(0, 88, 260, self.tableView.frame.size.height)];
        _searchUIView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_searchUIView];
        
        _searchTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 260, self.tableView.frame.size.height - 90) style:UITableViewStylePlain];
        _searchTable.tag = tagSearchTable;
        _searchTable.delegate = self;
        _searchTable.dataSource = self;
        [_searchTable setBackgroundColor:[UIColor clearColor]];
		[_searchUIView addSubview:_searchTable];
        
    }
    
    self.tvThailandLabel.hidden = YES;
    self.backToSlideMenuButton.hidden = NO;
    self.searchLabel.hidden = NO;
    
    _searchUIView.hidden = NO;
    _numSection = 0;
    [self.tableView reloadData];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [self searchTapped];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
   
    return YES;
}

- (void)textFieldDidChange{
    
    if ([self.searchTextField.text length] == 0) {
        self.clearSearchFieldButton.hidden = YES;
    } else {
        self.clearSearchFieldButton.hidden = NO;
    }
    
    [self search:self.searchTextField.text];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchTextField endEditing:YES];
    return YES;
}

- (IBAction)backToSlideMenuTapped:(id)sender {
    self.searchTextField.text = @"";
    self.clearSearchFieldButton.hidden = YES;
    
    self.tvThailandLabel.hidden = NO;
    self.backToSlideMenuButton.hidden = YES;
    self.searchLabel.hidden = YES;
    
    _searchUIView.hidden = YES;
    _numSection = (int)totalSection;
    [self.tableView reloadData];
    
    _searchShows = nil;
    [_searchTable reloadData];
    [self.searchTextField resignFirstResponder];
}

- (IBAction)clearTextFieldTapped:(id)sender {
    self.searchTextField.text = @"";
    self.clearSearchFieldButton.hidden = YES;
    _searchShows = nil;
    [_searchTable reloadData];
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

        return [NSIndexPath indexPathForRow:0 inSection:5];
    
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
    } else if (section == secSetting){
        return settingContentSegue;
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
    if (tableView.tag == tagSearchTable) {
        return 1;
    }
    
    return _numSection;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == tagSearchTable) {
        return _searchShows.count;
    }

    if (section == secFacebook || section == secFavorite || section == secChannel || section == secRadio || section == secSetting) {
        return 1;
    } else if (section == secCategory){
        return [_categoryList count];
    }
    
    return 1;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    UITableViewCell* cellOfSearch = [self.tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    
    

    NSInteger section = indexPath.section;
    

    if (tableView.tag == tagSearchTable) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
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
                [cellOfFB configureWithTitle:@"Login"];
            }else{
//                [cellOfFB configureWithTitle:[NSString stringWithFormat:@"Hello, %@", cm_user.firstName]];
                [cellOfFB configureWithTitle:[NSString stringWithFormat:@"My Profile"]];
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
        } else if (section == secSetting){
            UITableViewCell* cellOfSetting = [self.tableView dequeueReusableCellWithIdentifier:settingCellIdentifier];
            cellOfSetting.selectedBackgroundView = selectedBackgroundViewForCell;
            return cellOfSetting;
        } else if (section == secCategory){
            ShowCategoryTableViewCell *cellOfCate = [self.tableView dequeueReusableCellWithIdentifier:cateCellIdentifier];
            cellOfCate.selectedBackgroundView = selectedBackgroundViewForCell;
         
            [cellOfCate configureWithGenre:_categoryList[indexPath.row]];
        
            return cellOfCate;
            
        }
        
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        return cell;
    }

}

-(CGFloat) leftMenuVisibleWidth{
    return 260;
}



#pragma mark -
#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   

    NSInteger section = indexPath.section;
    if (tableView.tag == tagSearchTable) {
        
      [self.searchTextField endEditing:YES];
        
        Show *show = _searchShows[indexPath.row];
        
        if (show != nil) {
            if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) && show.isOTV) {
                [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
            } else {
                [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
            }
        }
        
        
        
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
        
        }else if (section == secSetting) {
            
            [self performSegueWithIdentifier:settingContentSegue sender:nil];
            
        }
//        else {
//            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UINavigationController *content = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:showListContentSegue]) {

        ShowListViewController* showListController = [content.viewControllers firstObject];
        
        ShowCategory *selectedCat;
        if ([sender isKindOfClass:[ShowCategory class]]) {
            selectedCat = (ShowCategory *)sender;
           
        }
        else {
            if (_categoryList == nil || [_categoryList count] == 0) {
                _categoryList = [[ShowCategoryList alloc] initWithWhatsNew];
            }
            
            selectedCat = _categoryList[0];
        }
        
        showListController.homeSlideMenuViewController = self;
        showListController.navigationItem.title = selectedCat.title;
        [showListController reloadWithMode:kCategory Id:selectedCat.Id];
        
    } else if ([segue.identifier isEqualToString:channelContentSegue]) {
        ChannelViewController* channelController = [content.viewControllers firstObject];
        channelController.homeSlideMenuViewController = self;
    } else if ([segue.identifier isEqualToString:EPAndPartIdentifier]) {
        Show *show = (Show *)sender;
        EpisodePartViewController *episodeAndPartListViewController = [content.viewControllers firstObject];
        episodeAndPartListViewController.show = show;
    } else if ([segue.identifier isEqualToString:OTVEPAndPartIdentifier ]) {
        Show *show = (Show *)sender;
        OTVEpisodePartViewController *otvEpAndPartViewController = [content.viewControllers firstObject];
        otvEpAndPartViewController.show = show;
    }
    
}

#pragma mark - Search


- (void)search:(NSString *)keyword {
    if (![keyword isEqualToString:@""]) {
        [Show loadSearchDataWithKeyword:keyword Block:^(NSArray *tempShows, NSError *error) {
            _searchShows = tempShows;
           
//            [self.searchDisplayController.searchResultsTableView reloadData];
            [_searchTable reloadData];
        }];
    }
}




#pragma mark -
#pragma mark SASlideMenuDelegate

-(void) slideMenuWillSlideIn:(UINavigationController *)selectedContent{
//    NSLog(@"slideMenuWillSlideIn");
    [self.searchTextField endEditing:YES];
}
-(void) slideMenuDidSlideIn:(UINavigationController *)selectedContent{
//    NSLog(@"slideMenuDidSlideIn");
}
-(void) slideMenuWillSlideToSide:(UINavigationController *)selectedContent{
//    NSLog(@"slideMenuWillSlideToSide");
    [self.tableView reloadData];
}
-(void) slideMenuDidSlideToSide:(UINavigationController *)selectedContent{
//    NSLog(@"slideMenuDidSlideToSide");
}
-(void) slideMenuWillSlideOut:(UINavigationController *)selectedContent{
//    NSLog(@"slideMenuWillSlideOut");
}
-(void) slideMenuDidSlideOut:(UINavigationController *)selectedContent{
//    NSLog(@"slideMenuDidSlideOut");
}
-(void) slideMenuWillSlideToLeft:(UINavigationController *)selectedContent{
//    NSLog(@"slideMenuWillSlideToLeft");
}
-(void) slideMenuDidSlideToLeft:(UINavigationController *)selectedContent{
//    NSLog(@"slideMenuDidSlideToLeft");
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
    } else if (section == secSetting){
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
    } else if (section == secSetting){
        return 0;
    } else if (section == secCategory){
        return 10;
    } else {
        return 0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (self.tvThailandLabel.hidden && [self.searchTextField isEditing]) {
        [self.searchTextField endEditing:YES];
    }

}


@end
