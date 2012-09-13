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


#import "Three20/Three20.h"
#import "GANTracker.h"
#import "GADBannerView.h"

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
    
    timeKey = [NSString getUnixTime];
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
        cellHeight = 120.0;
    }
    else {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPhone;
        cellHeight = 90.0;
    }
    
    bannerView.rootViewController = self;
    
    [self.viewBanner addSubview:bannerView];
    
    [bannerView loadRequest:[GADRequest request]];
    
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"TV Thailand";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconLauncher"] style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    
    
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithTitle:@"Like" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)],
                                                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showCam:)],
                                                   nil];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Like" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)];
    }
    
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView.hidden = YES;
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropProgramViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    [self loadProgram:@"0" cat_name:@"รายการล่าสุด"];
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
        //        cell.thumbnail.style = [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10.0f] next:[TTContentStyle styleWithNext:nil]]];
        
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
    [self openProgramlist:[dict objectForKey:@"program_id"] andProgramTitle:[dict objectForKey:@"title"]];
    [self.viewDeckController closeLeftViewAnimated:YES];
}

- (void)openProgramlist:(NSString *)program_id andProgramTitle:(NSString *)program_title
{
    NSString *nibName = (isPad)?@"ProgramListViewController_iPad":@"ProgramListViewController_iPhone";
    
    ProgramListViewController *programController = [[ProgramListViewController alloc] initWithNibName:nibName bundle:nil];
    [self.navigationController pushViewController:programController animated:YES];
    [programController loadProgramlist:program_id program_name:program_title];
}

#pragma mark - Load Category Function

-(void)loadProgram:(NSString *)cat_id cat_name:(NSString *)cat_name
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    timeKey = [NSString getUnixTime];
    self.cat_id = cat_id;
    self.cat_name = cat_name;
    if([self.cat_id isEqualToString:@"search"]) {
        self.navigationItem.title = [NSString stringWithFormat:@"Search : %@",self.cat_name];
    }
    else {
        self.navigationItem.title = self.cat_name;
    }
    
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [tempItems removeAllObjects];
    
    [self loadProgram];
}

-(void)loadProgram
{
    isLoading = YES;
    NSURL *getProgramUrl = nil;
    if([self.cat_id isEqualToString:@"search"]) {
        getProgramUrl = [NSURL URLWithString:kGetProgramSearch(self.cat_name, [tempItems count], timeKey)];
    }
    else {
        getProgramUrl = [NSURL URLWithString:kGetProgram(self.cat_id, [tempItems count], timeKey)];
    }
    
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
        
        if([self.cat_id isEqualToString:@"search"])
        {
            if([programItems count] == 0)
            {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                // Configure for text only and offset down
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"ไม่พบรายการที่ค้นหา";
                hud.margin = 10.f;
                hud.yOffset = 150.f;
                hud.removeFromSuperViewOnHide = YES;
                
                [hud hide:YES afterDelay:3];
            }
        }
    }
    
    [self.tableView reloadData];
    
    // GANTracker
    NSError *error;
    
    if([self.cat_id isEqualToString:@"search"]) {
        
        if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/getProgramSearch/%@", self.cat_name]
                                             withError:&error]) {
            // Handle error here
        }
    }
    else {
        
        if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/getProgram/%@", self.cat_id]
                                             withError:&error]) {
            // Handle error here
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.tableView.tableFooterView.hidden = YES;
    isLoading = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [[request error] description];
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
    
    NSLog(@"Error : %@",[[request error] description]);
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
