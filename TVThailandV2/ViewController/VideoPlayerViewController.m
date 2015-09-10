//
//  YoutubePlayerViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/13/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Episode.h"
#import "PreRollAd.h"

#import "SVProgressHUD.h"

#import "HTMLParser.h"

#import "MakathonAdView.h"

#import <Google/Analytics.h>

#import "Channel.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController {
    NSString *_videoId;
    CGSize _size;
    NSString *_videoFile;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scrollView.scrollEnabled = NO;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(680.0f, 380.0f);
    }
    else
    {
        _size = CGSizeMake(320, 240);
    }
    
    [self sendTracker];
    
    [self setUpContentPlayer];
    
    [self requestAds];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
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


- (void) openWithVideoUrl:(NSString *)videoUrl {
    // HTML to embed YouTube video
    
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 100%%\"/></head>\
    <body style=\"background-color: #000;\">\
    <video style=\"margin: auto; position: absolute; top: 0; left: 0; right: 0; bottom: 0;\" poster=\"%@\" height=\"%0.0f\" width=\"%0.0f\" src=\"%@\" controls autoplay>\
    </video></body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:htmlString,
                      self.channel.thumbnailUrl,
                      _size.height,
                      _size.width,
                      videoUrl
                      ];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:videoUrl]];
    [SVProgressHUD dismiss];

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
}

#pragma mark SDK Setup

- (void)setupAdsLoader {
    self.webView.hidden = YES;
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
                                            userContext:nil];
                [self.adsLoader requestAdsWithRequest:request];
                return;
            }
        }
        
        [self playContent];
    }];
}

- (void)createAdsRenderingSettings {
    self.adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    self.adsRenderingSettings.webOpenerPresentingController = self;
}

- (void)createContentPlayhead {
    self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.contentPlayer];
}

#pragma mark AdsLoader Delegates

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    // Create ads rendering settings to tell the SDK to use the in-app browser.
    [self createAdsRenderingSettings];
    // Create a content playhead so the SDK can track our content for VMAP and ad rules.
    [self createContentPlayhead];
    // Initialize the ads manager.
    [self.adsManager initializeWithContentPlayhead:self.contentPlayhead
                              adsRenderingSettings:self.adsRenderingSettings];
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
    self.webView.hidden = NO;
    self.videoView.hidden = YES;
    [self openWithVideoUrl:self.channel.videoUrl];
}

@end
