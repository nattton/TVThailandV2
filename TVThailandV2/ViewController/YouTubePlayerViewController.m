//
//  YouTubeViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/5/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "YouTubePlayerViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

#import "Episode.h"
#import "Show.h"
#import "VideoPartTableViewCell.h"

@interface YouTubePlayerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@end

@implementation YouTubePlayerViewController {
    NSString *_videoId;

}

#pragma mark - Staic Variable
static NSString *videoPartCell = @"videoPartCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLableContainner];
    [self refreshView:_idx];

    

 
}


- (void) initLableContainner {
    
    if ([self.episode.videos count] == 1||[self.episode.videos count] == 0) {
        self.tableOfVideoPart.hidden = YES;
        self.partNameLabel.hidden = YES;
    }
    
    self.titleContainerView.layer.masksToBounds = NO;
    self.titleContainerView.layer.cornerRadius = 2;
    self.titleContainerView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.titleContainerView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.titleContainerView.layer.shadowRadius = 0.6;
    self.titleContainerView.layer.shadowOpacity = 0.6;
    
    self.titleContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.titleContainerView.bounds].CGPath;
    
    self.tableOfVideoPart.separatorColor = [UIColor clearColor];
    [self.tableOfVideoPart setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.tableOfVideoPart setSeparatorColor:[UIColor colorWithRed: 240/255.0 green:240/255.0 blue:240/255.0 alpha:0.7]];
    


}

- (void) refreshView:(NSInteger)indexOfVideo {
 
    _videoId = self.episode.videos[indexOfVideo];
    
    self.showNameLabel.text = self.show.title;
    self.episodeNameLabel.text = self.episode.titleDisplay;
    self.viewCountLabel.text = self.episode.viewCount;
    self.partNameLabel.text = [NSString stringWithFormat:@"Part %ld/%ld", (indexOfVideo + 1), self.episode.videos.count ];


    [self playVideo:_videoId];
    
    [self setSelectedPositionOfVideoPartAtRow:indexOfVideo];
    
}

- (void) playVideo:(NSString *)videoIdString {
    
    [self.videoContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoIdString];
	[self.videoPlayerViewController presentInView:self.videoContainerView];
    [self.videoPlayerViewController.moviePlayer play];
}

- (void) setSelectedPositionOfVideoPartAtRow:(NSInteger)row {
    NSIndexPath *indexPathOfVideoPart=[NSIndexPath indexPathForRow:row inSection:0];
    [self.tableOfVideoPart selectRowAtIndexPath: indexPathOfVideoPart
                                       animated:YES
                                 scrollPosition:UITableViewScrollPositionMiddle];
}

- (void) viewWillDisappear:(BOOL)animated
{
	// Beware, viewWillDisappear: is called when the player view enters full screen on iOS 6+
	if ([self isMovingFromParentViewController])
		[self.videoPlayerViewController.moviePlayer stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.videoPlayerViewController.moviePlayer stop];
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.episode.videos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    
    VideoPartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:videoPartCell];
    
    [cell configureWithVideoPart:self.episode partNumber:indexPath.row+1];
    
    cell.selectedBackgroundView = selectedBackgroundViewForCell;

    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"SELECT!!!!");

    [self refreshView:indexPath.row];
    
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        Show *show = _searchShows[indexPath.row];
//        if (show.isOTV)
//            [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
//        else
//            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
//    }
//    else {
//        Show *show = _shows[indexPath.row];
//        if (show.isOTV)
//            [self performSegueWithIdentifier:OTVEPAndPartIdentifier sender:show];
//        else
//            [self performSegueWithIdentifier:EPAndPartIdentifier sender:show];
//    }
}

#pragma mark - UITableViewDelegate

@end
