//
//  LivePlayerViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/4/2558 BE.
//  Copyright © 2558 luciferultram@gmail.com. All rights reserved.
//

#import "LivePlayerViewController.h"

#import <Google/Analytics.h>

#import "ChannelViewController.h"
#import "Channel.h"

@interface LivePlayerViewController ()

@end

@implementation LivePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self playContent];
    [self sendTracker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController] ) {
        if (self.channelViewController) {
            [self.channelViewController displayInterstitialAds];
        }
        NSLog(@"Back pressed");
    }
}

- (void) playContent {
    NSURL *url = [NSURL URLWithString:self.channel.videoUrl];
    MPMoviePlayerController *controller = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    self.moviePlayerController = controller; //Super important
    controller.view.frame = self.view.bounds; //Set the size
    
    [self.view addSubview:controller.view]; //Show the view
    controller.fullscreen = YES;
    [controller play]; //Start playing
}

- (void) setChannel:(Channel *)channel {
    _channel = channel;
    self.navigationItem.title = [NSString stringWithFormat:@"Live : %@", channel.title];
}

- (void)sendTracker
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"VideoPlayer"];
    [tracker send:[[[GAIDictionaryBuilder createScreenView] set:self.channel.title
                                                         forKey:[GAIFields customDimensionForIndex:3]] build]];
}


@end
