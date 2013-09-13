//
//  ProgramViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/22/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "ProgramViewController.h"
#import "ProgramViewCell.h"
#import "ProgramListViewController.h"
#import "AppDelegate.h"

#import "Three20/Three20.h"
#import "GAI.h"
#import "GADBannerView.h"
#import "InHouseAdView.h"

#import "SBJson.h"
#import "NSString+Utils.h"

#import "ODRefreshControl.h"
#import "IIViewDeckController.h"
#import "MBProgressHUD.h"

static NSString *programViewcell = @"ProgramViewCell";

@interface ProgramViewController ()
{
    GADBannerView *bannerView;
    
    NSArray *programItems;
    NSMutableArray *tempItems;
    
    NSString *thumbnailPath;
    NSString *timeKey;
    
    CGFloat cellHeight;
    
    BOOL isLast;
    BOOL isLoading;
    BOOL isPad;
}

@property (strong, nonatomic) NSArray *programItems;

@end

@implementation ProgramViewController

@synthesize viewBanner = _viewBanner;
@synthesize tableView = _tableView;
@synthesize cat_id = _cat_id;
@synthesize cat_name = _cat_name;
@synthesize programItems = _programItems;
@synthesize inHouseAdView = _inHouseAdView;

-(NSArray *)programItems
{
    if (!programItems) {
        programItems = [[NSArray alloc] init];
    }
    return programItems;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeData
{
    isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    
    timeKey = [NSString getUnixTimeKey];
    tempItems = [NSMutableArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeData];
    
    // Setup AdMob
    
    if (isPad) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPad;
        
        self.inHouseAdView = [[InHouseAdView alloc] initWithFrame:CGRectMake(0, 0, kGADAdSizeLeaderboard.size.width, kGADAdSizeLeaderboard.size.height)];
        
        cellHeight = 120.0;
    }
    else {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPhone;
        
        self.inHouseAdView = [[InHouseAdView alloc] initWithFrame:CGRectMake(0, 0, kGADAdSizeBanner.size.width, kGADAdSizeBanner.size.height)];
        
        cellHeight = 90.0;
    }
    
    bannerView.rootViewController = self;
    [self.viewBanner addSubview:bannerView];
    [bannerView loadRequest:[GADRequest request]];
    
    [self.viewBanner addSubview:self.inHouseAdView];
    self.inHouseAdView.rootViewController = self;
    [self.inHouseAdView loadRequest];
    
//    [self.inHouseAdView bringSubviewToFront:self.viewBanner];
    [self.viewBanner insertSubview:self.inHouseAdView aboveSubview:bannerView];
    self.navigationItem.title = @"TV Thailand";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconLauncher"] style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    
    AppDelegate *appDeleagate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CategoryViewController *categoryView = appDeleagate.categoryViewController;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:categoryView action:@selector(beginSearch)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView.hidden = YES;
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropProgramViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    [self loadProgram:@"0" cat_name:@"รายการล่าสุด"];
}

- (void)reloadInHouseAd
{
    if (self.inHouseAdView) {
        [self.inHouseAdView loadRequest];
    }
}

- (void)viewDidUnload
{
    [self setViewBanner:nil];
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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.programItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            [cell.title setFont:[UIFont systemFontOfSize:24]];
            [cell.detail setFrame:CGRectMake(160, 40, cell.detail.frame.size.width, cell.detail.frame.size.height)];
            [cell.detail setFont:[UIFont systemFontOfSize:20]];
        }
    }
    
    // Configure the cell.
    
    NSDictionary *dict = [programItems objectAtIndex:indexPath.row];
    
    [cell.title setText:[dict objectForKey:@"title"]];
    [cell.detail setText:[dict objectForKey:@"time"]];
    
    cell.thumbnail.urlPath = [NSString stringWithFormat:@"%@%@",thumbnailPath, [dict objectForKey:@"thumbnail"]];
    
    if((indexPath.row == [programItems count] - 10) && !isLast && !isLoading) 
    {
        self.tableView.tableFooterView.hidden = FALSE;
        [self loadProgram];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [programItems objectAtIndex:indexPath.row];
    [self openProgramlist:[dict objectForKey:@"program_id"] programTitle:[dict objectForKey:@"title"] programTime:[dict objectForKey:@"time"] programThumbnail:[NSString stringWithFormat:@"%@%@",thumbnailPath, [dict objectForKey:@"thumbnail"]]];
    [self.viewDeckController closeLeftViewAnimated:YES];
}

- (void)openProgramlist:(NSString *)program_id programTitle:(NSString *)program_title programTime:(NSString *)program_time programThumbnail:(NSString *)program_thumbnail
{
    NSString *nibName = (isPad)?@"ProgramListViewController_iPad":@"ProgramListViewController_iPhone";
    
    ProgramListViewController *programController = [[ProgramListViewController alloc] initWithNibName:nibName bundle:nil];
    programController.program_id = program_id;
    programController.program_title = program_title;
    programController.program_time = program_time;
    programController.program_thumbnail = program_thumbnail;
    [self.navigationController pushViewController:programController animated:YES];
}

#pragma mark - Load Category Function

-(void)loadProgram:(NSString *)cat_id cat_name:(NSString *)cat_name
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    timeKey = [NSString getUnixTimeKey];
    self.cat_id = cat_id;
    self.cat_name = cat_name;
    self.navigationItem.title = self.cat_name;
    
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [tempItems removeAllObjects];
    
    [self loadProgram];
    

}

-(void)loadProgram
{
    isLoading = YES;
    NSURL *getProgramUrl = nil;
    getProgramUrl = [NSURL URLWithString:kGetProgram(self.cat_id, [tempItems count], timeKey)];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:getProgramUrl];
//    NSLog(@"%@",[request.url absoluteURL]);
    request.delegate = self;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.tableView.tableFooterView.hidden = YES;
    isLoading = NO;
    NSDictionary *dict = [[request responseString] JSONValue];
    
    if(dict)
    {
        thumbnailPath = [dict objectForKey:@"thumbnail_path"];
        [tempItems addObjectsFromArray:[dict objectForKey:@"programs"]];
        programItems = [NSArray arrayWithArray:tempItems];
        
        isLast = ([[dict objectForKey:@"programs"] count] == 0);
    }
    
    [self.tableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.tableView.tableFooterView.hidden = YES;
    isLoading = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Loading Failed";
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    

}

#pragma mark - ODRefreshControl
- (void)dropProgramViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadProgram:self.cat_id cat_name:self.cat_name];
        [refreshControl endRefreshing];
    });
}


@end
