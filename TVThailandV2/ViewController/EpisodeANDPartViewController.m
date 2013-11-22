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
#import "Program.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "XLMediaZoom.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface EpisodeANDPartViewController ()<UITableViewDataSource, UITableViewDelegate,EPAndPartCellDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *showThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *showTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;



@end

@implementation EpisodeANDPartViewController{
    NSArray *_episodes;
    BOOL isLoading;
    BOOL isEnding;
    UIRefreshControl *_refreshControl;
    XLMediaZoom *_imageZoom;
}

static NSString *cellname = @"cell";
static NSString *EPPartShowPlayerSegue = @"EPPartShowPlayerSegue";
static double delayInSeconds = 1.0;

UIButton *buttonFavBar;

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
    
//    NSLog(@"Plateform: %@",self.platform);
    
    
    
    buttonFavBar =  [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonFavBar setImage:[UIImage imageNamed:@"icb_favorite.png"] forState:UIControlStateNormal];
    [buttonFavBar setImage:[UIImage imageNamed:@"icb_favorite_selected"] forState:UIControlStateSelected];
    [buttonFavBar addTarget:self action:@selector(addToFavButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    [buttonFavBar setFrame:CGRectMake(0, 0, 53, 31)];

    [self reloadFavorite];
    
    UIBarButtonItem *favoriteBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonFavBar];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(infoButtonTapped:)];
//    UIBarButtonItem *favoriteBarButton = [[UIBarButtonItem alloc] initWithTitle:@"+Favorite" style:UIBarButtonItemStylePlain target:self action:@selector(favButtonTapped:)];
    
    NSArray *barButtonArray = [[NSArray alloc] initWithObjects:infoBarButton, favoriteBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = barButtonArray;
    
    
    portable = [[UITableView alloc]init];
    [self setUpTableFrame];
    [portable setDelegate:self];
    [portable setDataSource:self];
    [self.view addSubview:portable];
    [portable setBackgroundColor:[UIColor clearColor]];
    [portable setSeparatorColor:[UIColor clearColor]];

    self.showTitleLabel.text = self.show.title;
    [self.showThumbnailImageView setImageWithURL:[NSURL URLWithString:self.show.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.showThumbnailImageView.layer.cornerRadius = 10.0;
    self.showThumbnailImageView.clipsToBounds = YES;
    
    _imageZoom = [[XLMediaZoom alloc] initWithAnimationTime:@(0.5) image:self.showThumbnailImageView blurEffect:YES];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.showThumbnailImageView addGestureRecognizer:singleTap];
    [self.showThumbnailImageView setUserInteractionEnabled:YES];
    
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

- (void)imageTaped:(UIGestureRecognizer *)gestureRecognizer {
    [self.view addSubview:_imageZoom];
    [_imageZoom show];
    if (self.show.posterUrl != nil && self.show.posterUrl.length > 0) {
        [_imageZoom.imageView setImageWithURL:[NSURL URLWithString:self.show.posterUrl]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [_imageZoom.imageView setImage:image];
        }];
    }
    
}

- (void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self reload];
}

- (void) setUpTableFrame {

     CGRect newFrame  = self.view.frame;
     CGSize actualSize = self.view.frame.size;
    
        if (newFrame.size.height > 500) {
            NSLog(@"Height > 500");
//            NSLog(@"iPhone5, width : %f, hight : %f", self.view.frame.size.width, self.view.frame.size.height);
            portable.frame = CGRectMake(0, 160, actualSize.width, actualSize.height-210);
//            NSLog(@"Final, width : %f, hight : %f", self.view.frame.size.width, self.view.frame.size.height);
        } else {

            portable.frame = CGRectMake(0, 100, actualSize.width, actualSize.height-100);;

        }
    
}

- (IBAction)infoButtonTapped:(id)sender {
    NSLog(@"info");
}

- (IBAction)addToFavButtonTapped:(id)sender {
    NSArray *bookmarks = [self queyFavorites];
    if(bookmarks.count == 0) {
        [self insertFavorite];
    }
    else {
        [self removeFavorite];
    }
    [self reloadFavorite];
}

- (IBAction)removeFromFavButtonTapped:(id)sender {
 

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

//- (IBAction)detailButtonTapped:(id)sender {
//    [self performSegueWithIdentifier:showDetailSegue sender:self.show];
//}

- (void)reloadFavorite {
    NSArray *bookmarks = [self queyFavorites];
    if(bookmarks.count == 0) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        [self setFavSelected:NO];
      
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_active"] forState:UIControlStateNormal];
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    
//    return [_episodes[section] titleDisplay] ;
//
//}


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
//    [epviewCountLabel setTextColor:[UIColor whiteColor]];
    [view addSubview:epviewCountLabel];
    
    
//    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:0.7]]; //your background color...
      [view setBackgroundColor:[UIColor colorWithRed: 246/255.0 green:246/255.0 blue:246/255.0 alpha:0.7]]; //your background color...
//    [view setBackgroundColor:[UIColor orangeColor]];
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

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.00f;
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
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
               value:@"Episode"];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:self.episode.Id
                                                          forKey:[GAIFields customDimensionForIndex:3]] build]];
    }
}


- (void) orientationDidChange: (NSNotification *) note
{
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        NSLog(@"Landscape");

    }
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        // code for Portrait orientation
        
        NSLog(@"Potrait");
    }

    // After Oreientation Change, Deley 1 second before setUpTableFrame because after orientaion change, its frame won't change immediately
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
        [self setUpTableFrame];
        [portable reloadData];
            
    });
    
}

// Check Platform of iPhone/iPad
- (NSString *) platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}


@end
