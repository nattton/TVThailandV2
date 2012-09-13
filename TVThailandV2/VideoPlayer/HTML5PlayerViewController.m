//
//  HTML5PlayerViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 8/2/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "HTML5PlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GADBannerView.h"
@interface HTML5PlayerViewController ()
{
    GADBannerView *bannerView;
}
@end

@implementation HTML5PlayerViewController
@synthesize webView;
@synthesize viewBanner;
@synthesize videoTitle;
@synthesize videoUrl;
@synthesize videoPoster;

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
    
    self.navigationItem.title = videoTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(openVideoPlayer:)];
    
    if ([webView respondsToSelector:@selector(scrollView)]) {
        webView.scrollView.scrollEnabled = NO;
    }
    
    // Setup AdMob
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPad;
    }
    else {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 0)];
        bannerView.adUnitID = adUnitID_iPhone;
    }
    
    bannerView.rootViewController = self;
    
    [self.viewBanner addSubview:bannerView];
    
    [bannerView loadRequest:[GADRequest request]];
    
    CGSize size;
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        size = CGSizeMake(768, 460);
    }
    else
    {
        size = CGSizeMake(320, 240);
    }
    
    // HTML to embed YouTube video
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no\"/></head>\
    <body style=\"margin-top:0px;margin-left:0px\">\
    <div align=\"center\"><video poster=\"%@\" height=\"%0.0f\" width=\"%0.0f\" controls autoplay>\
    <source src=\"%@\" />\
    </video></div></body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:htmlString,
                      videoPoster,
                      size.height,
                      size.width,
                      videoUrl
                      ];
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:videoUrl]];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setViewBanner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)openVideoPlayer:(id)sender
{
    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:videoUrl]];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
}

@end
