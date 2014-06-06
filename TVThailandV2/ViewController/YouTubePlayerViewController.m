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

@interface YouTubePlayerViewController ()

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
    // Do any additional setup after loading the view.
    
    
    self.labelView.layer.masksToBounds = NO;
    self.labelView.layer.cornerRadius = 2; // if you like rounded corners
    self.labelView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.labelView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.labelView.layer.shadowRadius = 0.6;
    self.labelView.layer.shadowOpacity = 0.6;
    
    self.labelView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.labelView.bounds].CGPath;
    
    self.title = self.episode.title;
    
//    _videoId = self.episode.videos[self.idx];
//    
//    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:_videoId];
//	[self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
