//
//  OTVEpAndPartViewController.m
//  TVThailandV2
//
//  Created by April Smith on 3/20/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVEpisodePartViewController.h"

#import "SVProgressHUD.h"
#import <Google/Analytics.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "DetailViewController.h"
#import "OTVEpisodePartTableViewCell.h"
#import "PlayerViewController.h"
#import "EpisodePartViewController.h"

#import "AppDelegate.h"
#import "OTVEpisode.h"
#import "Show.h"
#import "OTVShow.h"
#import "Program.h"


@interface OTVEpisodePartViewController () <UITableViewDataSource, UITableViewDelegate, OTVEpisodePartTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *portTableView;
@property (weak, nonatomic) IBOutlet UILabel *noContentLabel;

@end

@implementation OTVEpisodePartViewController {
    NSArray *_otvEpisodes;
    NSArray *_relateShows;
    BOOL _isLoading;
    BOOL _isEnding;
    
    OTVShow *_otvShow;
    OTVEpisode *_otvEpisode;
    
    UIRefreshControl *_refreshControl;
    UIButton *_buttonFavBar;
    UIButton *_buttonInfoBar;
}

#pragma mark - Staic Variable
static NSString *cellname = @"cell";
static NSString *PlayerSegue = @"PlayerSegue";
static NSString *showDetailSegue = @"ShowDetailSegue";
static NSString *EPAndPartIdentifier = @"EPAndPartIdentifier";

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.portTableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _buttonFavBar =  [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonFavBar addTarget:self action:@selector(favoriteButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    [_buttonFavBar setFrame:CGRectMake(0, 0, 50, 30)];
    
    _buttonInfoBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonInfoBar setImage:[UIImage imageNamed:@"icb_info"] forState:UIControlStateNormal];
    [_buttonInfoBar addTarget:self action:@selector(infoButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(youtubeLongTapped:)];
    lpgr.minimumPressDuration = 1.0f;
    [_buttonInfoBar addGestureRecognizer:lpgr];
    
    [_buttonInfoBar setFrame:CGRectMake(0, 0, 30, 30)];
    
    
    
    
    UIBarButtonItem *favoriteBarButton = [[UIBarButtonItem alloc] initWithCustomView:_buttonFavBar];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:_buttonInfoBar];
    
    
    NSArray *barButtonArray = [[NSArray alloc] initWithObjects:infoBarButton, favoriteBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = barButtonArray;
    
    [self.portTableView setBackgroundColor:[UIColor clearColor]];
    [self.portTableView setSeparatorColor:[UIColor clearColor]];
    
    [self.view addSubview:self.portTableView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.portTableView addSubview:_refreshControl];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
    [self reload];
    
    
}

- (void)setShow:(Show *)show {
    _show = show;
    self.navigationItem.title = show.title;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.portTableView reloadData];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"OTVEpisode"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    id<GAITracker> tracker2 = [[GAI sharedInstance] trackerWithName:@"OTV"
                                                         trackingId:kOTVTracker];
    [tracker2 set:kGAIScreenName value:@"OTVEpisode"];
    [tracker2 send:[[[GAIDictionaryBuilder createScreenView] set:self.show.title
                                                       forKey:[GAIFields customDimensionForIndex:1]] build]];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.show.Id) {
        [self reloadFavorite];
    } else {
        [Show loadShowDataWithOtvId:self.show.otvId Block:^(Show *show, NSError *error) {
            if (show != nil) {
                self.show = show;
                [self reloadFavorite];
            }

            
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)reload {
    _isEnding = NO;
    [self reload:0];
}



- (void)reload:(NSUInteger)start {
    if (_isLoading || _isEnding) {
        return;
    }
    
    _isLoading = YES;
    
    // TODO : New API Content
    [OTVEpisode retrieveDataWithCateName:self.show.otvApiName
                                           ShowID:self.show.otvId
                                            start:start
                                            Block:^(OTVShow *otvShow, NSArray *tempOtvEpisodes, NSArray *tempRelateShows, NSError *error)
    {
        _otvShow = otvShow;
        _relateShows = tempRelateShows;
        
//        NSLog([_relateShows.firstObject description]);
        
        if ([tempOtvEpisodes count] == 0) {
            _isEnding = YES;
        }
        
        if (start == 0) {
            [SVProgressHUD dismiss];
            
            _otvEpisodes = tempOtvEpisodes;
            
        } else {
            NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:_otvEpisodes];
            [mergeArray addObjectsFromArray:tempOtvEpisodes];
            _otvEpisodes = [NSArray arrayWithArray:mergeArray];
        }
        
        [self.portTableView reloadData];
        _isLoading = NO;
        
        
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        
        self.noContentLabel.hidden = _otvEpisodes.count > 0;
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _otvEpisodes.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    /* Create custom view to display section header... */
    
    UIImageView *epScrType = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
    if (_show && ![_show.otvLogo isEqualToString:@""]) {
        [epScrType sd_setImageWithURL:[NSURL URLWithString:_show.otvLogo] placeholderImage:[UIImage imageNamed:@"ic_otv"]];
    }
    else {
        [epScrType setImage:[UIImage imageNamed:@"ic_otv"]];
    }
    [view addSubview:epScrType];
    
    
    UILabel *epTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 2, tableView.frame.size.width - 50, 18)];
    [epTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    NSString *epTitleString = [_otvEpisodes[section] nameTh];
    [epTitleLabel setText:epTitleString];
    [epTitleLabel setBackgroundColor:[UIColor clearColor]];
    [view addSubview:epTitleLabel];
    
    UILabel *epUpdateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 19, tableView.frame.size.width - 70, 12)];
    [epUpdateTimeLabel setFont:[UIFont systemFontOfSize:10]];
    NSString *epUpdateTimeString = [NSString stringWithFormat:@"%@", [_otvEpisodes[section] date]];
    [epUpdateTimeLabel setText:epUpdateTimeString];
    [epUpdateTimeLabel setBackgroundColor:[UIColor clearColor]];
    [view addSubview:epUpdateTimeLabel];
    
    [view setBackgroundColor:[UIColor colorWithRed: 246/255.0 green:246/255.0 blue:246/255.0 alpha:0.7]]; //your background color...
    
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OTVEpisodePartTableViewCell *cell = [[OTVEpisodePartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:cellname
                                                       width:CGRectGetWidth(self.view.frame)];
	
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    [cell configureWithEpisode:_otvEpisodes[indexPath.section]];
    
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


- (IBAction)infoButtonTapped:(id)sender {
    [self performSegueWithIdentifier:showDetailSegue sender:_otvShow];
}

- (IBAction)youtubeLongTapped:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        DLog(@"UIGestureRecognizerStateEnded");
        //Do Whatever You want on End of Gesture
    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        DLog(@"UIGestureRecognizerStateBegan.");
        [self performSegueWithIdentifier:EPAndPartIdentifier sender:self.show];
    }
    
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
    if (self.show.Id) {
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

    return [NSArray array];
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

- (void)playVideoPart:(NSIndexPath *)indexPath episode:(OTVEpisode *)episode{
    
    _otvEpisode = episode;

    [self performSegueWithIdentifier:PlayerSegue sender:indexPath];

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PlayerSegue]) {
        
        PlayerViewController *playerViewController = segue.destinationViewController;
        playerViewController.show = self.show;
        playerViewController.otvEpisode = _otvEpisode;
        playerViewController.otvRelateShows = _relateShows;
        playerViewController.idx = [(NSIndexPath *)sender row];
        playerViewController.otvEPController = self;
        
    }
    else if ([segue.identifier isEqualToString:showDetailSegue]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.otvShow = _otvShow;
    }
    if ([segue.identifier isEqualToString:EPAndPartIdentifier]) {
        Show *show = (Show *)sender;
        EpisodePartViewController *episodeAndPartListViewController = segue.destinationViewController;
        episodeAndPartListViewController.show = show;
    }
}



@end
