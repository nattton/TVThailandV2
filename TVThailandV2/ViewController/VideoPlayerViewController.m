//
//  YoutubePlayerViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/13/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Episode.h"
#import "PreRollAd.h"

#import "SVProgressHUD.h"

#import "HTMLParser.h"

#import "MakathonAdView.h"

#import <Google/Analytics.h>

#import "Channel.h"

#import "ChannelViewController.h"

@interface VideoPlayerViewController ()

@property (nonatomic, retain) AVPlayerViewController *avPlayerViewcontroller;

@end

@implementation VideoPlayerViewController {
    NSString *_videoId;
    CGSize _size;
    NSString *_videoFile;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(CGRectGetWidth(self.videoView.frame), CGRectGetHeight(self.videoView.frame));
    }
    else
    {
        _size = CGSizeMake(CGRectGetWidth(self.videoView.frame), CGRectGetHeight(self.videoView.frame));
    }
    
    [self sendTracker];
    
    [self setUpContentPlayer];
    
    [self requestAds];

//    [self playMovie];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
}

- (void) playMovie {
    NSURL *url = [NSURL URLWithString:self.channel.videoUrl];
    MPMoviePlayerController *controller = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    self.moviePlayerController = controller; //Super important
    controller.view.frame = self.view.bounds; //Set the size
    
    [self.view addSubview:controller.view]; //Show the view
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Content Player Setup

- (void)setUpContentPlayer {
    // Load AVPlayer with path to our content.
    NSURL *contentURL = [NSURL URLWithString:self.channel.videoUrl];
    self.contentPlayer = [AVPlayer playerWithURL:contentURL];
    
    // Create a player layer for the player.
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.contentPlayer];
    
    // Size, position, and display the AVPlayer.
    playerLayer.frame = self.videoView.layer.bounds;
    [self.videoView.layer addSublayer:playerLayer];
    
    self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.contentPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.contentPlayer.currentItem];
}

- (void)contentDidFinishPlaying:(NSNotification *)notification {
    // Make sure we don't call contentComplete as a result of an ad completing.
    if (notification.object == self.contentPlayer.currentItem) {
        // NOTE: This line will cause an error until the next step, "Request Ads".
        [self.adsLoader contentComplete];
    }
}

#pragma mark SDK Setup

- (void)setupAdsLoader {
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
    self.adsLoader.delegate = self;
}

- (void)setUpAdDisplayContainer {
    // Create our AdDisplayContainer. Initialize it with our videoView as the container. This
    // will result in ads being displayed over our content video.
    self.adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.videoView companionSlots:nil];
}

- (void)requestAds {
    [PreRollAd retrieveData:^(NSArray *ads, NSError *error) {
        if (error == nil) {
            PreRollAd *ad = [PreRollAd selectedAd:ads];
            if (ad != nil) {
                [self setupAdsLoader];
                [self setUpAdDisplayContainer];
                // Create an ad request with our ad tag, display container, and optional user context.
                IMAAdsRequest *request =
                [[IMAAdsRequest alloc] initWithAdTagUrl:ad.url
                                     adDisplayContainer:self.adDisplayContainer
                                        contentPlayhead:self.contentPlayhead
                                            userContext:nil];
                [self.adsLoader requestAdsWithRequest:request];
                return;
            }
        }
        
        [self playContent];
    }];
}

#pragma mark AdsLoader Delegates

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    // Create ads rendering settings to tell the SDK to use the in-app browser.
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    adsRenderingSettings.webOpenerPresentingController = self;
    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Something went wrong loading ads. Log the error and play the content.
    NSLog(@"Error loading ads: %@", adErrorData.adError.message);
    [self playContent];
}

#pragma mark AdsManager Delegates

- (void)adsManager:(IMAAdsManager *)adsManager
 didReceiveAdEvent:(IMAAdEvent *)event {
    // When the SDK notified us that ads have been loaded, play them.
    if (event.type == kIMAAdEvent_LOADED) {
        [adsManager start];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager
 didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    NSLog(@"AdsManager error: %@", error.message);
    [self playContent];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // The SDK is going to play ads, so pause the content.
    [_contentPlayer pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // The SDK is done playing ads (at least for now), so resume the content.
    [self playContent];
}

- (void)playContent {
//    [self.contentPlayer play];
//    self.videoView.hidden = YES;
    [self playMovie];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController] ) {
        if (self.channelViewController) {
            [self.channelViewController displayInterstitialAds];
        }
        NSLog(@"Back pressed");
    }
}

@end
