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

@interface YouTubePlayerViewController ()

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@end

@implementation YouTubePlayerViewController {
    NSString *_videoId;
}

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
    [self refreshView];

    
    [self.videoContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:_videoId];
	[self.videoPlayerViewController presentInView:self.videoContainerView];
    [self.videoPlayerViewController.moviePlayer play];
 
}


- (void) initLableContainner {
    self.titleContainerView.layer.masksToBounds = NO;
    self.titleContainerView.layer.cornerRadius = 2;
    self.titleContainerView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.titleContainerView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.titleContainerView.layer.shadowRadius = 0.6;
    self.titleContainerView.layer.shadowOpacity = 0.6;
    
    self.titleContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.titleContainerView.bounds].CGPath;
}

- (void) refreshView {
    _videoId = self.episode.videos[self.idx];
    
    self.showNameLabel.text = self.show.title;
    self.episodeNameLabel.text = self.episode.titleDisplay;
    self.viewCountLabel.text = self.episode.viewCount;
    self.partNameLabel.text = [NSString stringWithFormat:@"Part %ld/%ld", (_idx + 1), self.episode.videos.count ];
    

    
    
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

@end
