//
//  EpisodeANDPartViewController.m
//  TVThailandV2
//
//  Created by April Smith on 11/9/2556 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "EpisodeANDPartViewController.h"
#import "AppDelegate.h"
#import "EPAndPartCell.h"
#import "Show.h"
#import "Episode.h"
#import "VideoPlayerViewController.h"
#import "DetailViewController.h"
#import "Program.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "XLMediaZoom.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "MakathonAdView.h"

@interface EpisodeANDPartViewController ()<UITableViewDataSource, UITableViewDelegate,EPAndPartCellDelegate>


@property (weak, nonatomic) IBOutlet MakathonAdView *makathonAdView;


@end

@implementation EpisodeANDPartViewController{
    NSArray *_episodes;
    BOOL isLoading;
    BOOL isEnding;
    UIRefreshControl *_refreshControl;
    XLMediaZoom *_imageZoom;
}

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static NSString *cellname = @"cell";
static NSString *EPPartShowPlayerSegue = @"EPPartShowPlayerSegue";
static NSString *showDetailSegue = @"ShowDetailSegue";


UIButton *buttonFavBar;
UIButton *buttonInfoBar;

UILabel *titleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setUpTableFrame];

    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.makathonAdView requestAd];
    
    
    
    
    buttonFavBar =  [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonFavBar addTarget:self action:@selector(favoriteButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    [buttonFavBar setFrame:CGRectMake(0, 0, 45, 30)];
    
    buttonInfoBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonInfoBar setImage:[UIImage imageNamed:@"icb_info"] forState:UIControlStateNormal];
    [buttonInfoBar addTarget:self action:@selector(infoButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    [buttonInfoBar setFrame:CGRectMake(0, 0, 30, 30)];


    [self reloadFavorite];
    
    UIBarButtonItem *favoriteBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonFavBar];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonInfoBar];

    
    NSArray *barButtonArray = [[NSArray alloc] initWithObjects:infoBarButton, favoriteBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = barButtonArray;
    
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.show.title;
    [titleLabel setBackgroundColor:[UIColor colorWithRed: 25/255.0 green:25/255.0 blue:25/255.0 alpha:0.7]];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    portable = [[UITableView alloc] init];
    [portable setBackgroundColor:[UIColor clearColor]];
    [portable setSeparatorColor:[UIColor clearColor]];
    
    [self setUpTableFrame];
    [portable setDelegate:self];
    [portable setDataSource:self];
    

    
    
    [self.view addSubview:titleLabel];
    [self.view addSubview:portable];


    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [portable addSubview:_refreshControl];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(orientationDidChange:)
                                                 name: UIApplicationDidChangeStatusBarOrientationNotification
                                               object: nil];
}

- (void)setFavSelected:(BOOL)isSelected
{
    if (isSelected) {
        [buttonFavBar setImage:[UIImage imageNamed:@"icb_favorite_selected"] forState:UIControlStateNormal];
    }
    else {
        [buttonFavBar setImage:[UIImage imageNamed:@"icb_favorite"] forState:UIControlStateNormal];
    }
    
}



- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self reload];
}

- (void) setUpTableFrame {
    
     CGRect newFrame  = self.view.frame;
     CGSize actualSize = self.view.frame.size;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {

        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            /* iPAD */
            
                portable.frame = CGRectMake(0, 183, actualSize.width, actualSize.height-240);
                titleLabel.frame = CGRectMake(0, 153, self.view.frame.size.width, 30);
            
        } else {
            /* iPhone */
                portable.frame = CGRectMake(0, 143, actualSize.width, actualSize.height-190);
                titleLabel.frame = CGRectMake(0, 113, self.view.frame.size.width, 30);
                
            
        }


    } else {
        /** OS < 7 **/
        
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            /* iPAD */
           
                portable.frame = CGRectMake(0, 118, actualSize.width, actualSize.height-120);
                titleLabel.frame = CGRectMake(0, 88, self.view.frame.size.width, 30);
                
  
        } else {
            /* iPhone */

                portable.frame = CGRectMake(0, 78, actualSize.width, actualSize.height-70);
                titleLabel.frame = CGRectMake(0, 48, self.view.frame.size.width, 30);
                

        }
    }
    



}

- (IBAction)infoButtonTapped:(id)sender {
    [self performSegueWithIdentifier:showDetailSegue sender:self.show];
}

- (IBAction)favoriteButtonTapped:(id)sender {
    NSArray *bookmarks = [self queyFavorites];
    if(bookmarks.count == 0) {
        [self insertFavorite];
    }
    else {
        [self removeFavorite];
    }
    [self reloadFavorite];
}


- (void)reloadFavorite {
    NSArray *bookmarks = [self queyFavorites];
    if(bookmarks.count == 0) {
        
        [self setFavSelected:NO];
      
    } else {
        
        [self setFavSelected:YES];
    }
}

#pragma mark - CoreData

- (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}


- (NSArray *)queyFavorites {
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Program" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"program_id like %@", self.show.Id];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *programArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return programArray;
}

- (void)insertFavorite
{
    Program *program = [NSEntityDescription insertNewObjectForEntityForName:@"Program" inManagedObjectContext:self.managedObjectContext];
    program.program_id = self.show.Id;
    program.program_title = self.show.title;
    program.program_thumbnail = self.show.thumbnailUrl;
    program.program_time = self.show.desc;
    [self.managedObjectContext save:nil];
    
    [SVProgressHUD showSuccessWithStatus:@"Add to Favorite"];
}

- (void)removeFavorite {
    NSArray *programArray = [self queyFavorites];
    for (Program *toDelete in programArray) {
        [self.managedObjectContext deleteObject:toDelete];
        [self.managedObjectContext save:nil];
    }
    
}

- (void)reload {
    isEnding = NO;
    [self reload:0];
}



- (void)reload:(NSUInteger)start {
    if (isLoading || isEnding) {
        return;
    }
    
    isLoading = YES;
    [Episode loadEpisodeDataWithId:self.show.Id Start:start Block:^(Show *show, NSArray *tempEpisodes, NSError *error) {
        if (show) {
            self.show = show;
        }
        
        if ([tempEpisodes count] == 0) {
            isEnding = YES;
        }
        
        if (start == 0) {
            [SVProgressHUD dismiss];
            
            self.show = show;
            _episodes = tempEpisodes;
        } else {
            NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_episodes];
            [mergeArray addObjectsFromArray:tempEpisodes];
            _episodes = [NSArray arrayWithArray:mergeArray];
        }
        
        [portable reloadData];
        isLoading = NO;
        
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
  
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _episodes.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    /* Create custom view to display section header... */
    
    UIImageView *epScrType = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];

    if ([[_episodes[section] srcType] isEqualToString:@"0"]) {
        [epScrType setImage:[UIImage imageNamed:@"ic_youtube"]];
    }else if ([[_episodes[section] srcType] isEqualToString:@"1"]) {
        [epScrType setImage:[UIImage imageNamed:@"ic_dailymotion"]];
    }else if ([[_episodes[section] srcType] isEqualToString:@"11"]) {
        [epScrType setImage:[UIImage imageNamed:@"ic_chrome"]];
    }else {
        [epScrType setImage:[UIImage imageNamed:@"ic_player"]];
    }

    [view addSubview:epScrType];

    
    UILabel *epTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 2, tableView.frame.size.width - 50, 18)];
    [epTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    NSString *epTitleString = [_episodes[section] titleDisplay];
    [epTitleLabel setText:epTitleString];
    [epTitleLabel setBackgroundColor:[UIColor clearColor]];
    [view addSubview:epTitleLabel];
    
    UILabel *epUpdateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 19, tableView.frame.size.width - 150, 12)];
    [epUpdateTimeLabel setFont:[UIFont systemFontOfSize:10]];
    NSString *epUpdateTimeString = [_episodes[section] updatedDate];
    [epUpdateTimeLabel setText:epUpdateTimeString];
    [epUpdateTimeLabel setBackgroundColor:[UIColor clearColor]];
    [view addSubview:epUpdateTimeLabel];
    
    UILabel *epviewCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 110, 19, 100, 12)];
    [epviewCountLabel setFont:[UIFont systemFontOfSize:10]];
    NSString *epViewCountString = [_episodes[section] viewCount];
    [epviewCountLabel setText:epViewCountString];
    [epviewCountLabel setBackgroundColor:[UIColor clearColor]];
    epviewCountLabel.textAlignment = NSTextAlignmentRight;

    [view addSubview:epviewCountLabel];
    

    [view setBackgroundColor:[UIColor colorWithRed: 246/255.0 green:246/255.0 blue:246/255.0 alpha:0.7]]; //your background color...

    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    EPAndPartCell *cell = (EPAndPartCell *)[tableView dequeueReusableCellWithIdentifier:cellname];
    
    
    cell = [[EPAndPartCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellname];
	
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setBackgroundColor:[UIColor clearColor]];

    [cell configureWithEpisode:_episodes[indexPath.section]];
  
    if ((indexPath.section + 5) == _episodes.count) {

        [self reload:_episodes.count];
        
    }
    
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        NSLog(@"indexPath section%d",[indexPath section]);
        NSLog(@"rows === %d",[indexPath row]);

}

- (void)playVideoPart:(NSIndexPath *)indexPath episode:(Episode *)episode{
        self.episode = episode;
        [self performSegueWithIdentifier:EPPartShowPlayerSegue sender:indexPath];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EPPartShowPlayerSegue]) {
        VideoPlayerViewController *youtubePlayer = segue.destinationViewController;
        youtubePlayer.episode = self.episode;
        NSIndexPath *idx = (NSIndexPath *)sender;
        youtubePlayer.idx = idx.row;
        
        [self.episode sendViewEpisode];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
               value:@"Episode"];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:self.episode.Id
                                                          forKey:[GAIFields customDimensionForIndex:3]] build]];
    }else if ([segue.identifier isEqualToString:showDetailSegue]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.show = self.show;

    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
 
    [self setUpTableFrame];
    [portable reloadData];
    
}


- (void) orientationDidChange: (NSNotification *) note
{
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        
//        NSLog(@"Landscape");

    }
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        
//        NSLog(@"Potrait");
    }

    
}

@end
