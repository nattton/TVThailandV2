//
//  EpisodeListViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "EpisodeListViewController.h"
#import "Show.h"
#import "Episode.h"
#import "EpisodeTableViewCell.h"
#import "PartListViewController.h"
#import "DetailViewController.h"

#import "AppDelegate.h"
#import "Program.h"
#import "SVProgressHUD.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "XLMediaZoom.h"
#import "SVProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface EpisodeListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end

@implementation EpisodeListViewController {
    NSArray *_episodes;
    BOOL isLoading;
    BOOL isEnding;
    UIRefreshControl *_refreshControl;
    XLMediaZoom *_imageZoom;
}

static NSString *cellIndentifier = @"EpisodeCellIdentifier";
static NSString *showPartSegue = @"ShowPartSegue";
static NSString *showDetailSegue = @"ShowDetailSegue";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showPartSegue]) {
        PartListViewController *partListViewController = segue.destinationViewController;
        Episode *ep  = (Episode *)sender;
        partListViewController.episode = ep;
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
               value:@"Episode"];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:ep.Id
                                                          forKey:[GAIFields customDimensionForIndex:3]] build]];
    }
    else if ([segue.identifier isEqualToString:showDetailSegue]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.show = self.show;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = self.show.title;
    [self.showImageView setImageWithURL:[NSURL URLWithString:self.show.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.showImageView.layer.cornerRadius = 10.0;
    self.showImageView.clipsToBounds = YES;
    
    _imageZoom = [[XLMediaZoom alloc] initWithAnimationTime:@(0.5) image:self.showImageView blurEffect:YES];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.showImageView addGestureRecognizer:singleTap];
    [self.showImageView setUserInteractionEnabled:YES];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [self reloadFavorite];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self reload];
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
        
        [self.tableView reloadData];
        isLoading = NO;
        
        [_refreshControl endRefreshing];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _episodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    [cell configureWithEpisode:_episodes[indexPath.row]];
    
    if ((indexPath.row + 5) == _episodes.count) {
        [self reload:_episodes.count];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:showPartSegue sender:_episodes[indexPath.row]];
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

- (IBAction)detailButtonTapped:(id)sender {
    [self performSegueWithIdentifier:showDetailSegue sender:self.show];
}

- (void)reloadFavorite {
    NSArray *bookmarks = [self queyFavorites];
    if(bookmarks.count == 0) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
//        [self.favoriteButton setTitle:@"+ Favorite" forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_active"] forState:UIControlStateNormal];
//        [self.favoriteButton setTitle:@"- Favorite" forState:UIControlStateNormal];
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
//    [SVProgressHUD showErrorWithStatus:@"Remove from Favorite"];
}


@end
