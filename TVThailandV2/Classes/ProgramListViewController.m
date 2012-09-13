//
//  ProgramListViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/22/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "ProgramListViewController.h"
#import "AppDelegate.h"
#import "Program.h"
#import "ProgramListViewCell.h"
#import "EPViewController.h"
#import "ProgramInfoViewController.h"

#import "YoutubeViewController.h"
#import "DailyMotionViewController.h"


#import "ODRefreshControl.h"
#import "IIViewDeckController.h"

#import "GANTracker.h"
#import "GADBannerView.h"

#import "SBJson.h"
#import "NSString+Utils.h"
#import "Base64.h"
#import "UIViewController+VideoPlayer.h"
#import "MBProgressHUD.h"


static NSString *programListViewcell = @"ProgramListViewCell";

@interface ProgramListViewController () <UIActionSheetDelegate>
{
    GADBannerView *bannerView;
    
    NSArray *programItems;
    NSMutableArray *tempItems;
    
    BOOL isLast;
    BOOL isLoading;
    BOOL isPad;
    
    NSUInteger retryCount;
    NSString *videoKeyCurrent;    
    
    NSDateFormatter *df;
    NSDateFormatter *thaiFormat;
    NSNumberFormatter *numberFormatter;
    
    NSString *timeKey;
    NSString *userAgentString;
    
    ASIHTTPRequest *asiRequest;
}

@property (strong, nonatomic) NSArray *programItems;

@end

@implementation ProgramListViewController

@synthesize viewBanner = _viewBanner;
@synthesize tableView = _tableView;
@synthesize program_id = _program_id;
@synthesize program_title = _program_title;
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
    tempItems = [NSMutableArray array];
    df = [[NSDateFormatter alloc] init];
    thaiFormat = [[NSDateFormatter alloc] init];
    numberFormatter = [[NSNumberFormatter alloc] init];
    
    [df setDateFormat:@"yyyy-MM-dd"];
    [thaiFormat setDateFormat:@"dd MMMM yyyy"];
    [thaiFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th"]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeData];
    
    UIButton *infoButton;
    
    if (isPad){
        infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    }
    else {
        infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    }
    infoButton.frame = CGRectMake(infoButton.frame.origin.x, infoButton.frame.origin.y, infoButton.frame.size.width + 20, infoButton.frame.size.height);
    [infoButton addTarget:self action:@selector(displayInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *likeBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Like" style:UIBarButtonItemStyleBordered target:self action:@selector(insertFavorite)];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    if ([self.navigationItem respondsToSelector:@selector(setRightBarButtonItems:)]){
        [self.navigationItem setRightBarButtonItems:[[NSArray alloc] initWithObjects:infoBarButton,likeBarButton, nil]];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(selectAction)]];
    }
    

    // Setup AdMob
    
    if (isPad) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPad;
    }
    else {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPhone;
    }
    
    bannerView.rootViewController = self;
    [self.viewBanner addSubview:bannerView];
    [bannerView loadRequest:[GADRequest request]];
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView.hidden = YES;
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropProgramViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
 
    [self loadProgramlist:self.program_id program_title:self.program_title];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [asiRequest cancel];
    [super viewWillDisappear:animated];
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
    return YES;
}

- (IBAction)displayInfo:(id)sender
{
    ProgramInfoViewController *programInfoViewController = [[ProgramInfoViewController alloc] initWithNibName:@"ProgramInfoViewController" bundle:nil];
    programInfoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    programInfoViewController.program_id = self.program_id;
    programInfoViewController.program_title = self.program_title;
    
    [self presentModalViewController:programInfoViewController animated:YES];
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
    ProgramListViewCell *cell = (ProgramListViewCell *)[tableView dequeueReusableCellWithIdentifier:programListViewcell];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]
                                    loadNibNamed:programListViewcell owner:nil options:nil];
        
        for (id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[ProgramListViewCell class]])
            {
                cell = (ProgramListViewCell *)currentObject;
                break;
            }
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        if(isPad)
        {
            [cell.name setFrame:CGRectMake(10, 5, 740, 50)];
        }
        
    }
    
    // Configure the cell.
    NSDictionary *dict = [self.programItems objectAtIndex:indexPath.row];
    
    NSString * epname = [dict objectForKey:@"epname"];
    if ([epname isEqualToString:@""]) {
        [cell.name setText:[NSString stringWithFormat:@"ตอนที่ %@",
                            [dict objectForKey:@"ep"]]];
    }
    else
    {
        [cell.name setText:[NSString stringWithFormat:@"ตอนที่ %@ - %@",
                            [dict objectForKey:@"ep"],
                            epname]];
    }
    
    
    NSDate *listDate = [df dateFromString: [dict objectForKey:@"date"]];
    [cell.date setText:[NSString stringWithFormat:@"วันที่ออกอากาศ %@",
                        [thaiFormat stringFromDate:listDate]]];
    [cell.view setText:[NSString stringWithFormat:@"จำนวนที่ชม %@",
                        [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[dict objectForKey:@"count"] intValue]]]]];
    
    if((indexPath.row == [programItems count] - 5) && !isLast && !isLoading)
    {
        self.tableView.tableFooterView.hidden = FALSE;
        [self loadProgramlist];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.programItems objectAtIndex:indexPath.row];
    [self selectProgramlist:dict];
    [self.viewDeckController closeLeftViewAnimated:YES];
}

- (void)selectProgramlist:(NSDictionary *)dict
{
    NSString *title = @"";
    NSString *epname = [dict objectForKey:@"epname"];
    NSString *programlist_id = [dict objectForKey:@"programlist_id"];
    if([epname isEqualToString: @""] ){
        title = [NSString stringWithFormat:@"ตอนที่ %@",[dict objectForKey:@"ep"]];
    }
    else {
        title = [NSString stringWithFormat:@"ตอนที่ %@ - %@",[dict objectForKey:@"ep"],[dict objectForKey:@"epname"]];
        
    }
    //    NSString *program_id = [dict objectForKey:@"program_id"];
    NSString *programlist_youtube = [dict objectForKey:@"youtube_encrypt"];
    programlist_youtube = [[[[[[[[[[[[[[[[[[[[[[programlist_youtube 
                                                stringByReplacingOccurrencesOfString:@"-" withString:@"+"]
                                               stringByReplacingOccurrencesOfString:@"/" withString:@"/"] 
                                              stringByReplacingOccurrencesOfString:@"," withString:@"="]
                                             stringByReplacingOccurrencesOfString:@"!" withString:@"a"] 
                                            stringByReplacingOccurrencesOfString:@"@" withString:@"b"] 
                                           stringByReplacingOccurrencesOfString:@"#" withString:@"c"] 
                                          stringByReplacingOccurrencesOfString:@"$" withString:@"d"]
                                         stringByReplacingOccurrencesOfString:@"%" withString:@"e"] 
                                        stringByReplacingOccurrencesOfString:@"^" withString:@"f"] 
                                       stringByReplacingOccurrencesOfString:@"&" withString:@"g"] 
                                      stringByReplacingOccurrencesOfString:@"*" withString:@"h"] 
                                     stringByReplacingOccurrencesOfString:@"(" withString:@"i"]
                                    stringByReplacingOccurrencesOfString:@")" withString:@"j"]
                                   stringByReplacingOccurrencesOfString:@"{" withString:@"k"]
                                  stringByReplacingOccurrencesOfString:@"}" withString:@"l"]
                                 stringByReplacingOccurrencesOfString:@"[" withString:@"m"]
                                stringByReplacingOccurrencesOfString:@"]" withString:@"n"]
                               stringByReplacingOccurrencesOfString:@":" withString:@"o"]
                              stringByReplacingOccurrencesOfString:@";" withString:@"p"]
                             stringByReplacingOccurrencesOfString:@"<" withString:@"q"]
                            stringByReplacingOccurrencesOfString:@">" withString:@"r"]
                           stringByReplacingOccurrencesOfString:@"?" withString:@"s"];
    
    [Base64 initialize];
    NSData * data = [Base64 decode:programlist_youtube];
    programlist_youtube = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSArray *youtube_list = [programlist_youtube componentsSeparatedByString:@","];
    NSUInteger yt_count = [youtube_list count];
    
    NSString *src_type = [dict objectForKey:@"src_type"];
    NSString *password = [dict objectForKey:@"pwd"];
    if (yt_count == 1) {
        [self openVideoWithTitle:title SrcType:src_type VideoId:[youtube_list objectAtIndex:0] Password:password];
    }
    else if (yt_count > 1)
    {
        NSString *nibName = (isPad)?@"EPViewController_iPad":@"EPViewController_iPhone";
        EPViewController *epViewController = [[EPViewController alloc] initWithNibName:nibName bundle:nil];
        [self.navigationController pushViewController:epViewController animated:YES];
        [epViewController setEPTitle:title andVideoItems:youtube_list andSrcType:src_type andPassword:password];
    }
    
    [self viewStat:programlist_id];
}

- (void)viewStat:(NSString *)programlist_id
{   
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:kViewProgramlist(programlist_id)]];
    [request startAsynchronous];
    
    // GANTracker
    NSError *error;
    
    if (![[GANTracker sharedTracker] trackPageview:[[NSString stringWithFormat:@"/api/viewProgramlist/%@?program_id=%@&program_title=%@",programlist_id, self.program_id, self.program_title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                         withError:&error]) {
        // Handle error here
    }  
}

#pragma mark - Function

-(void)loadProgramlist:(NSString *)program_id program_title:(NSString *)program_title
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    timeKey = [NSString getUnixTimeKey];
    self.program_id = program_id;
    self.program_title = program_title;
    self.navigationItem.title = program_title;
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [tempItems removeAllObjects];
    
    [self loadProgramlist];
    
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:[[NSString stringWithFormat:@"/api/getProgramlist/%@/0/?program_title=%@", self.program_id, self.program_title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                         withError:&error]) {
        // Handle error here
    }
}

-(void)loadProgramlist
{
    isLoading = YES;
    asiRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:kGetProgramlist(self.program_id, [tempItems count], timeKey)]];
//    NSLog(@"%@",[request.url absoluteURL]);
    asiRequest.delegate = self;
    [asiRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.tableView.tableFooterView.hidden = YES;
    isLoading = NO;
    NSDictionary *dict = [[request responseString] JSONValue];
    
    if(dict)
    {
        [tempItems addObjectsFromArray:[dict objectForKey:@"programlists"]];
        programItems = [NSArray arrayWithArray:tempItems];
        
        isLast = ([[dict objectForKey:@"programlists"] count] == 0);
    }
    
    [self.tableView reloadData];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (![request isCancelled]) {        
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
        
        NSError *error;
        if (![[GANTracker sharedTracker] trackPageview:[[NSString stringWithFormat:@"/api/getProgramlist/%@/0/?program_title=%@&error=1", self.program_id, self.program_title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                             withError:&error]) {
            // Handle error here
        }
    }
}


#pragma mark - ODRefreshControl
- (void)dropProgramViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadProgramlist:self.program_id program_title:self.program_title];
        [refreshControl endRefreshing];
    });
}

#pragma mark - CoreData

- (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (void)insertFavorite
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Program" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"program_id like %@", _program_id];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *programArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if([programArray count] == 0)
    {
        Program *program = [NSEntityDescription insertNewObjectForEntityForName:@"Program" inManagedObjectContext:self.managedObjectContext];
        program.program_id = self.program_id;
        program.program_title = self.program_title;
        program.program_thumbnail = self.program_thumbnail;
        program.program_time = self.program_time;
        [self.managedObjectContext save:nil];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"Add to My Favorites"];
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    // GANTracker
    
    if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/insertFavorite/%@",_program_id]
                                         withError:&error]) {
        // Handle error here
    }
}


- (void)selectAction
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Menu" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Like",@"Info", nil];
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self insertFavorite];
            break;
        case 1:
            [self displayInfo:actionSheet];
            break;
        default:
            break;
    }
}

@end
