//
//  YoutubePlayerViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/13/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "Episode.h"

#import "SVProgressHUD.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "HTMLParser.h"

#import "MakathonAdView.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface VideoPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet MakathonAdView *mkAdView;

@end

@implementation VideoPlayerViewController {
    NSString *_videoId;
    CGSize _size;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self calulateUI];
}

- (void)calulateUI
{
    CGRect viewFrame = self.view.frame;
    CGRect adFrame = self.mkAdView.frame;
    
    adFrame.size.width = viewFrame.size.width;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        adFrame.size.height = 90;
    }
    else
    {
        adFrame.size.height = 50;
    }
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        adFrame.origin.y = viewFrame.size.height - adFrame.size.height;
    }
    else
    {
        adFrame.origin.y = viewFrame.size.height - adFrame.size.height - 50;
    }
    
    [self.mkAdView setFrame:adFrame];
    NSLog(@"adFrame, width : %f, hight : %f, x : %f, y : %f", adFrame.size.width, adFrame.size.height, adFrame.origin.x, adFrame.origin.y);
    
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.webView.scrollView setScrollEnabled:NO];
    [self.mkAdView requestAd];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _size = CGSizeMake(768, 460);
    }
    else
    {
        _size = CGSizeMake(320, 240);
    }
    
    
    if (self.episode) {
        self.navigationItem.title = [NSString stringWithFormat:@"Part %d", (_idx + 1)];
        _videoId = self.episode.videos[self.idx];
        
        if ([self.episode.srcType isEqualToString:@"0"]) {
            [self openWithYoutube];
        }
        else if ([self.episode.srcType isEqualToString:@"1"]) {
            [self openWithDailymotion];
        }
        else if ([self.episode.srcType isEqualToString:@"11"]) {
            [self openWebSite:_videoId];
        }
        else if ([self.episode.srcType isEqualToString:@"12"]) {
            [self openWithVideoUrl:_videoId];
        }
        else if ([self.episode.srcType isEqualToString:@"13"]) {
            [self loadMThaiWebVideo];
        }
        else if ([self.episode.srcType isEqualToString:@"14"]) {
            [self loadMThaiWebVideo];
        }
        else if ([self.episode.srcType isEqualToString:@"15"]) {
            [self loadMThaiWebVideoWithPassword:self.episode.password];
        }
    }
    else if (self.videoUrl) {
        [self openWithVideoUrl:self.videoUrl];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"Video not support"];
    }
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"VideoPlayer"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self calulateUI];
}

- (void)openWebSite:(NSString *)stringUrl {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringUrl]]];
}

- (void)openWithYoutube {
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
    <body style=\"margin-top:0px;margin-left:0px\">\
    <div align=\"center\"><object width=\"%0.0f\" height=\"%0.0f\">\
    <param name=\"movie\" value=\"http://www.youtube.com/v/%@\"></param>\
    <param name=\"wmode\" value=\"transparent\"></param>\
    <embed src=\"http://www.youtube.com/v/%@\"\
    type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed>\
    </object></div></body></html>";
    
    NSString *html = [NSString stringWithFormat:htmlString,
                      _size.width,
                      _size.width,
                      _size.height,
                      _videoId,
                      _videoId,
                      _size.width,
                      _size.height];
    
    NSURL *youtubeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",_videoId]];
    [self.webView loadHTMLString:html baseURL:youtubeUrl];
    
    
}

- (void)openWithDailymotion {
    NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
                            <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
                            <div align=\"center\"><iframe src=\"http://www.dailymotion.com/embed/video/%@?autoplay=1\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\"></iframe>\
                            </div></body></html>", _size.width, _videoId, _size.width, _size.height];
    
    [self.webView loadHTMLString:htmlString
                    baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",_videoId]]];
}

- (void) openWithVideoUrl:(NSString *)videoUrl {
    // HTML to embed YouTube video
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no\"/></head>\
    <body style=\"margin-top:0px;margin-left:0px\">\
    <div align=\"center\"><video poster=\"%@\" height=\"%0.0f\" width=\"%0.0f\" controls autoplay>\
    <source src=\"%@\" />\
    </video></div></body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:htmlString,
                      [self.episode videoThumbnail:_idx],
                      _size.height,
                      _size.width,
                      videoUrl
                      ];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:videoUrl]];
}

- (void) loadMThaiWebVideo {
    
//    NSURL *urlMThai = [NSURL URLWithString:[NSString stringWithFormat:@"http://video.mthai.com/player.php?id=24M%@M0",_videoId]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://video.mthai.com"]];
    [httpClient getPath:[NSString stringWithFormat:@"player.php?id=24M%@M0",_videoId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self startMThaiVideoFromData:responseObject];
//        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"str: %@", str);
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void) loadMThaiWebVideoWithPassword:(NSString *)password {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://video.mthai.com"]];
    [httpClient postPath:[NSString stringWithFormat:@"player.php?id=24M%@M0",_videoId] parameters:@{@"clip_password": password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self startMThaiVideoFromData:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void) startMThaiVideoFromData:(NSData *)data {
    NSError *error = nil;
//    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *sourceNodes = [bodyNode findChildTags:@"source"];
    
    for (HTMLNode *sourceNode in sourceNodes)
    {
        if ([sourceNode getAttributeNamed:@"src"]) {
            NSString *videoUrl = [NSString stringWithString:[sourceNode getAttributeNamed:@"src"]];
            if ([videoUrl rangeOfString:_videoId].location != NSNotFound) {
                if ([videoUrl hasSuffix:@"flv"]) {
                    NSLog(@"FLV");
                        [SVProgressHUD  showErrorWithStatus:@"Cannot play flv file."];
                    return;
                }else {
                    [self openWithVideoUrl:videoUrl];
                }
                return;
            }
        }
    }
    
    [SVProgressHUD  showErrorWithStatus:@"Video have problem!"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
