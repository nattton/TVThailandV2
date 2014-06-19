//
//  EpisodeANDPartViewController.m
//  TVThailandV2
//
//  Created by April Smith on 11/9/2556 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "EpisodePartViewController.h"
#import "AppDelegate.h"
#import "EpisodePartCell.h"
#import "Show.h"
#import "Episode.h"
#import "VideoPlayerViewController.h"
#import "PlayerViewController.h"
#import "DetailViewController.h"
#import "Program.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "XLMediaZoom.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface EpisodePartViewController ()<UITableViewDataSource, UITableViewDelegate, EPPartCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *portTableView;

@end

@implementation EpisodePartViewController{
    NSArray *_episodes;
    long _currentEpIndex;
    BOOL _isLoading;
    BOOL _isEnding;
    UIRefreshControl *_refreshControl;
    
    UIButton *_buttonFavBar;
    UIButton *_buttonInfoBar;
    
    UILabel *_titleLabel;
}

#pragma mark - Staic Variable
static NSString *cellname = @"cell";
static NSString *EPPartShowPlayerSegue = @"EPPartShowPlayerSegue";
static NSString *PlayerSegue = @"PlayerSegue";
static NSString *showDetailSegue = @"ShowDetailSegue";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.show.title;
    
    _buttonFavBar =  [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonFavBar addTarget:self action:@selector(favoriteButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    [_buttonFavBar setFrame:CGRectMake(0, 0, 50, 30)];
    
    _buttonInfoBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonInfoBar setImage:[UIImage imageNamed:@"icb_info"] forState:UIControlStateNormal];
    [_buttonInfoBar addTarget:self action:@selector(infoButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    [_buttonInfoBar setFrame:CGRectMake(0, 0, 30, 30)];

    [self reloadFavorite];
    
    UIBarButtonItem *favoriteBarButton = [[UIBarButtonItem alloc] initWithCustomView:_buttonFavBar];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:_buttonInfoBar];

    
    NSArray *barButtonArray = [[NSArray alloc] initWithObjects:infoBarButton, favoriteBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = barButtonArray;
    
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = self.show.title;
    [_titleLabel setBackgroundColor:[UIColor colorWithRed: 25/255.0 green:25/255.0 blue:25/255.0 alpha:0.7]];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.portTableView setBackgroundColor:[UIColor clearColor]];
    [self.portTableView setSeparatorColor:[UIColor clearColor]];
    
    [self.view addSubview:_titleLabel];
    [self.view addSubview:self.portTableView];

    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.portTableView addSubview:_refreshControl];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];
    
    [self sendTracker];
}

- (void)sendTracker
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Episode"];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:self.show.title
                                                      forKey:[GAIFields customDimensionForIndex:2]] build]];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.portTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.portTableView reloadData];
}


- (void)setFavSelected:(BOOL)isSelected
{
    if (isSelected) {
        [_buttonFavBar setImage:[UIImage imageNamed:@"icb_fav_selected"] forState:UIControlStateNormal];
    }
    else {
        [_buttonFavBar setImage:[UIImage imageNamed:@"icb_fav"] forState:UIControlStateNormal];
    }
}


- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self reload];
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
    _isEnding = NO;
    [self reload:0];
}



- (void)reload:(NSUInteger)start {
    if (_isLoading || _isEnding) {
        return;
    }
    
    _isLoading = YES;
    [Episode loadEpisodeDataWithId:self.show.Id Start:start Block:^(Show *show, NSArray *tempEpisodes, NSError *error) {
        if (show) {
            self.show = show;
        }
        
        if ([tempEpisodes count] == 0) {
            _isEnding = YES;
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
        
        [self.portTableView reloadData];
        _isLoading = NO;
        
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
    
    UILabel *epUpdateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 19, tableView.frame.size.width - 70, 12)];
    [epUpdateTimeLabel setFont:[UIFont systemFontOfSize:10]];
    NSString *epUpdateTimeString = [NSString stringWithFormat:@"%@ | %@",[_episodes[section] updatedDate],[_episodes[section] viewCount]];
    [epUpdateTimeLabel setText:epUpdateTimeString];
    [epUpdateTimeLabel setBackgroundColor:[UIColor clearColor]];
    [view addSubview:epUpdateTimeLabel];
 
    [view setBackgroundColor:[UIColor colorWithRed: 246/255.0 green:246/255.0 blue:246/255.0 alpha:0.7]]; //your background color...
    

    return view;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    EpisodePartCell *cell = (EpisodePartCell *)[tableView dequeueReusableCellWithIdentifier:cellname];
    
    
    cell = [[EpisodePartCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:cellname
                                           width:CGRectGetWidth(self.view.frame)];
	
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    _currentEpIndex = indexPath.section;
    
    [cell configureWithEpisode:_episodes[_currentEpIndex] currentEp:_currentEpIndex];
    

  
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
    
        DLog(@"indexPath section %ld", (long)indexPath.section );
        DLog(@"rows === %ld", (long)indexPath.row);
    

}

- (void)playVideoPart:(NSIndexPath *)indexPath episode:(Episode *)episode currentEp:(long)currentEpIndex{
    self.episode = episode;

    // Init Other Episode
    if (_episodes.count == 1 || _episodes.count ==  0 || _episodes == nil) {
        self.otherEpisode = nil;
    } else {
        if (_episodes.count != currentEpIndex + 1 ) {
            self.otherEpisode = _episodes[currentEpIndex + 1];
        } else {
            self.otherEpisode = _episodes[currentEpIndex - 1];
        }
    }
    
    [self performSegueWithIdentifier:PlayerSegue sender:indexPath];
    
//    if ([episode.srcType isEqualToString:@"0"]) {
//        
//        [self performSegueWithIdentifier:youtubePlayerSegue sender:indexPath];
//        
//    }
//    else {
//        [self performSegueWithIdentifier:EPPartShowPlayerSegue sender:indexPath];
//    }
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PlayerSegue]) {
        PlayerViewController *playerViewController = segue.destinationViewController;
        playerViewController.show = self.show;
        playerViewController.episode = self.episode;
        playerViewController.otherEpisode = self.otherEpisode;
        playerViewController.idx = [(NSIndexPath *)sender row];
        
    }else if ([segue.identifier isEqualToString:EPPartShowPlayerSegue]) {
        VideoPlayerViewController *videoPlayer = segue.destinationViewController;
        videoPlayer.episode = self.episode;
        NSIndexPath *idx = (NSIndexPath *)sender;
        videoPlayer.idx = idx.row;
        [self.episode sendViewEpisode];
        
    }else if ([segue.identifier isEqualToString:showDetailSegue]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.show = self.show;

    }
}

@end
