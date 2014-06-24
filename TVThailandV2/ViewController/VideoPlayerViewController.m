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

#import "SVProgressHUD.h"

#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

#import "HTMLParser.h"

#import "MakathonAdView.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "Channel.h"

@interface VideoPlayerViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
//@property (weak, nonatomic) IBOutlet MakathonAdView *mkAdView;

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
    
    [self openWithVideoUrl:self.channel.videoUrl];
    
    [self sendTracker];
    
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
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:self.channel.title
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


@end
