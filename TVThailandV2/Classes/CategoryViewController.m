//
//  CategoryViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/21/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "CategoryViewController.h"
#import "ProgramViewController.h"
#import "SettingViewController.h"
#import "FavoriteViewController.h"
#import "ProgramListViewController.h"
#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "ODRefreshControl.h"
#import "NSString+Utils.h"
#import "MBProgressHUD.h"

#import "SBJson.h"
#import "GANTracker.h"
#import "ProgramViewCell.h"
#import "Three20/Three20.h"

static const NSInteger kLoadCategory = 1;
static const NSInteger kLoadSearchProgram = 2;
static NSString *programViewcell = @"ProgramViewCell";
static NSString *CellIdentifier = @"CellIdentifier";


@interface CategoryViewController () <UITableViewDataSource, UITableViewDelegate, IIViewDeckControllerDelegate>
{
    ProgramViewController *programViewController;
    NSArray *catItems;
    NSString *keyword;
    
    ASIHTTPRequest *requestSearch;
    NSString *thumbnailPath;
    NSArray *searchResults;
    BOOL isPad;
    
    CGFloat leftLedge;
    CGFloat cellHeight;
}
@end

@implementation CategoryViewController
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)InitialData
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    leftLedge = (isPad)?400:44;
    cellHeight = (isPad)?120.0:90.0;
    searchResults = [NSArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self InitialData];
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    AppDelegate *appDeleagate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    programViewController = (ProgramViewController *)appDeleagate.programViewController;
    
    [self loadCategory];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    return 2;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"";
    }
    else
    {
        switch (section) {
            case 0:
                return @"";
            case 1:
                return @"Category";
            default:
                return @"";
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
    else
    {
        switch (section) {
            case 0:
                return 1;
            case 1:
                return [catItems count];
            default:
                return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        ProgramViewCell *cell = (ProgramViewCell *)[tableView dequeueReusableCellWithIdentifier:programViewcell];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle]
                                        loadNibNamed:programViewcell owner:nil options:nil];
            for (id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[ProgramViewCell class]])
                {
                    cell = (ProgramViewCell *)currentObject;
                    break;
                }
            }
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.thumbnail.defaultImage = [UIImage imageNamed:@"Icon"];
            
            if(isPad)
            {
                [cell.thumbnail setFrame:CGRectMake(3, 5, 150, 110)];
                [cell.title setFrame:CGRectMake(160, 8, cell.title.frame.size.width, cell.title.frame.size.height)];
                [cell.title setFont:[UIFont systemFontOfSize:28]];
                [cell.detail setFrame:CGRectMake(160, 40, cell.detail.frame.size.width, cell.detail.frame.size.height)];
                [cell.detail setFont:[UIFont systemFontOfSize:24]];
            }
        }
        
        // Configure the cell.
        
        NSDictionary *dict = [searchResults objectAtIndex:indexPath.row];
        
        [cell.title setText:[dict objectForKey:@"title"]];
        [cell.detail setText:[dict objectForKey:@"time"]];

        cell.thumbnail.urlPath = [NSString stringWithFormat:@"%@%@",thumbnailPath, [dict objectForKey:@"thumbnail"]];
        
        return cell;
        
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
        }
        
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"My Favorites"];
                    break;
                case 2:
                    [cell.textLabel setText:@"Setting"];
                    break;
                default:
                    break;
            }
        }
        else if (indexPath.section == 1) {
            NSDictionary *dict = [catItems objectAtIndex:indexPath.row];
            [cell.textLabel setText:[dict objectForKey:@"category_name"]];
        }
        
         return cell;
    }    
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return cellHeight;
    }
    return 50;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [programViewController.navigationController popToRootViewControllerAnimated:NO];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        NSDictionary *dict = [searchResults objectAtIndex:indexPath.row];
        NSString *nibName = (isPad)?@"ProgramListViewController_iPad":@"ProgramListViewController_iPhone";

        ProgramListViewController *programController = [[ProgramListViewController alloc] initWithNibName:nibName bundle:nil];
        programController.program_id = [dict objectForKey:@"program_id"];
        programController.program_title = [dict objectForKey:@"title"];
        programController.program_time = [dict objectForKey:@"time"];
        programController.program_thumbnail = [NSString stringWithFormat:@"%@%@",thumbnailPath, [dict objectForKey:@"thumbnail"]];
        
        [self.view endEditing:YES];
        
        self.viewDeckController.leftLedge = leftLedge;
        [self.searchBar resignFirstResponder];
        [self.viewDeckController closeLeftView];
        
        TTButton* backButton = [TTButton buttonWithStyle:@"toolbarBackButton:" title:@"Back"];
        [backButton sizeToFit];
        [backButton addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        
        programController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        [programViewController.navigationController pushViewController:programController animated:YES];
        
    }
    else
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0) {
                [self.viewDeckController closeLeftViewAnimated:YES];
                NSString *nibName = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)?@"FavoriteViewController_iPad":@"FavoriteViewController_iPhone";
                FavoriteViewController *favoriteViewController = [[FavoriteViewController alloc] initWithNibName:nibName bundle:nil];
                [programViewController.navigationController pushViewController:favoriteViewController animated:NO];
            }
            else if (indexPath.row == 2) {
                [self openSetting];
            }
            
        }
        else if (indexPath.section == 1) {
            [self.viewDeckController closeLeftViewAnimated:YES];
            NSDictionary *dict = [catItems objectAtIndex:indexPath.row];
            [programViewController loadProgram:[dict objectForKey:@"category_id"] cat_name:[dict objectForKey:@"category_name"]];
        }
    }
}

#pragma mark - ODRefreshControl
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadCategory];
        [refreshControl endRefreshing];
    });
}

#pragma mark - SearchBar Delegate

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.viewDeckController.leftLedge = 0.0;
    [self.viewDeckController openLeftViewAnimated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.viewDeckController.leftLedge = leftLedge;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)beginSearch
{
    [self.viewDeckController openLeftViewAnimated:YES];
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:searchOption]];
    
    return YES;
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.viewDeckController.leftLedge = leftLedge;
    [self.searchBar resignFirstResponder];
}
- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope
{
    keyword = searchText;
    [requestSearch cancel];
    NSURL *getProgramUrl = [NSURL URLWithString:kGetProgramSearch(searchText, 0, [NSString getUnixTimeKey])];
    requestSearch = [ASIHTTPRequest requestWithURL:getProgramUrl];
    requestSearch.tag = kLoadSearchProgram;
    requestSearch.delegate = self;
    [requestSearch startAsynchronous];
}

#pragma mark - Load Category Function

-(void)loadCategory
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:kGetCategory([NSString getUnixTimeKey])]];
//    NSLog(@"%@",[request.url absoluteURL]);
    request.tag = kLoadCategory;
    request.delegate = self;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *dict = [[request responseString] JSONValue];
    
    if (request.tag == kLoadCategory) {
        if(dict)
        {
            catItems = [dict objectForKey:@"categories"];
        }
        
        [self.tableView reloadData];
        
        // GANTracker
        NSError *error;
        if (![[GANTracker sharedTracker] trackPageview:@"/api/getCategory"
                                             withError:&error]) {
            // Handle error here
        }
    }
    else if (request.tag == kLoadSearchProgram)
    {
        if (dict) {
            thumbnailPath = [dict objectForKey:@"thumbnail_path"];
            searchResults = [dict objectForKey:@"programs"];
            [self.searchDisplayController.searchResultsTableView reloadData];
            
            // GANTracker
            NSError *error;
            if (![[GANTracker sharedTracker] trackPageview:[[NSString stringWithFormat:@"/api/getProgramSearch/0/?keyword=%@&error=1", keyword] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                 withError:&error]) {
                // Handle error here
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.tag == kLoadCategory) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Loading Failed";
        hud.margin = 10.f;
        hud.yOffset = 150.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1];
        
        // GANTracker
        NSError *error;
        if (![[GANTracker sharedTracker] trackPageview:@"/api/getCategory/?error=1"
                                             withError:&error]) {
            // Handle error here
        }
    }
    else if (request.tag == kLoadSearchProgram)
    {
        
    }
}

#pragma mark - IIViewDeckControllerDelegate

- (void)viewDeckController:(IIViewDeckController*)viewDeckController slideOffsetChanged:(CGFloat)offset
{
    if (offset > 200) {
        [self.view setFrame:CGRectMake(0, 0, offset, self.view.bounds.size.height)];
    }

}

#pragma mark - Table Select

- (void) openSetting
{
    SettingViewController *settingView = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    UINavigationController *navSetting = [[UINavigationController alloc] initWithRootViewController:settingView];
//  AppDelegate *appDeleagate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    navSetting.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navSetting animated:YES];
}

@end
