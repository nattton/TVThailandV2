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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoContainerTopSpace;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeftSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopSpace;

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
    [self refreshView:_idx sectionOfVideo:0];

    

    [self setUpOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)setUpOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            self.videoContainerTopSpace.constant = 0.0f;
            self.videoContainerWidth.constant = 700.0f;
            self.videoContainerHeight.constant = 390.0f;
            self.tableViewLeftSpace.constant = 0.0f;
            self.tableViewTopSpace.constant = self.videoContainerWidth.constant + 15.f;
        } else {
            self.videoContainerTopSpace.constant = -22.0f;
            self.videoContainerWidth.constant = 768.0f;
            self.videoContainerHeight.constant = 470.0f;
            self.tableViewLeftSpace.constant = 608.0f;
            self.tableViewTopSpace.constant = 15.f;
        }
    } else {
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            [self.videoPlayerViewController.moviePlayer setFullscreen:YES animated:YES];
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setUpOrientation:toInterfaceOrientation];
}


- (void) initLableContainner {
    

    
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

- (void) refreshView:(long)row sectionOfVideo:(long)section {
    
    self.showNameLabel.text = self.show.title;
 
    if (section == 0) {
        
        if ([self.episode.videos count] == 1||[self.episode.videos count] == 0) {
            self.partNameLabel.hidden = YES;
        } else {
            self.partNameLabel.hidden = NO;
        }
        
        _videoId = self.episode.videos[row];
        self.episodeNameLabel.text = self.episode.titleDisplay;
        self.viewCountLabel.text = self.episode.viewCount;
        self.partNameLabel.text = [NSString stringWithFormat:@"Part %ld/%ld", (row + 1), self.episode.videos.count ];
    } else {
        if ([self.otherEpisode.videos count] == 1||[self.otherEpisode.videos count] == 0) {
            self.partNameLabel.hidden = YES;
        } else {
            self.partNameLabel.hidden = NO;
        }
        
        _videoId = self.otherEpisode.videos[row];
        self.episodeNameLabel.text = self.otherEpisode.titleDisplay;
        self.viewCountLabel.text = self.otherEpisode.viewCount;
        self.partNameLabel.text = [NSString stringWithFormat:@"Part %ld/%ld", (row + 1), self.otherEpisode.videos.count ];
    }



    [self playVideo:_videoId];
    
    [self setSelectedPositionOfVideoPartAtRow:row section:section];
    
}

- (void) playVideo:(NSString *)videoIdString {
    
    [self.videoContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoIdString];
	[self.videoPlayerViewController presentInView:self.videoContainerView];
    [self.videoPlayerViewController.moviePlayer play];
}

- (void) setSelectedPositionOfVideoPartAtRow:(long)row section:(long)section {
    NSIndexPath *indexPathOfVideoPart=[NSIndexPath indexPathForRow:row inSection:section];
    [self.tableOfVideoPart selectRowAtIndexPath: indexPathOfVideoPart
                                       animated:YES
                                 scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(long)section {

    if (section == 0) {
        return [self.episode.videos count];
    } else if (section == 1){
        return [self.otherEpisode.videos count];
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *selectedBackgroundViewForCell = [UIView new];
    [selectedBackgroundViewForCell setBackgroundColor:[UIColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8]];
    VideoPartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:videoPartCell];
    cell.selectedBackgroundView = selectedBackgroundViewForCell;
    
    if (indexPath.section == 0) {
        [cell configureWithVideoPart:self.episode partNumber:indexPath.row+1];
    } else if (indexPath.section == 1){
        [cell configureWithVideoPart:self.otherEpisode partNumber:indexPath.row+1];

    }

    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 

    [self refreshView:indexPath.row sectionOfVideo:indexPath.section];
    

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Other videos";
    }
    
    return @"";
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 35;
    }
}

@end
