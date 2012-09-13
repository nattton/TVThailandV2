//
//  YoutubeViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/23/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "YoutubeViewController.h"
#import "GADBannerView.h"

#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
@interface YoutubeViewController () <UIWebViewDelegate,ASIHTTPRequestDelegate>
{
    GADBannerView *bannerView;
    BOOL autoWeb;
}
@end

@implementation YoutubeViewController

@synthesize viewBanner;
@synthesize webView;
@synthesize videoTitle;
@synthesize videoId;

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
    
    BOOL isWeb = [[NSUserDefaults standardUserDefaults] boolForKey:kYoutubeWeb];
    
    [self openYoutubeIsWeb:isWeb];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Function

- (void)toggleMode
{
    [self openYoutubeIsWeb:!autoWeb];
}

- (void)openYoutubeIsWeb:(BOOL)isWeb
{
    autoWeb = isWeb;
    
    [[NSUserDefaults standardUserDefaults] setBool:autoWeb forKey:kYoutubeWeb];
    
    NSString *menuTitle = (!autoWeb)?@"Web":@"Embed";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:menuTitle style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMode)];
    CGSize size;
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        size = CGSizeMake(768, 460);
    }
    else
    {
        size = CGSizeMake(320, 240);
    }
    
    self.webView.delegate = self;
    
    if (isWeb) {
        if ([webView respondsToSelector:@selector(scrollView)]) {
            webView.scrollView.scrollEnabled = YES;
        }
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",videoId]]]];
    }
    else {
        if ([webView respondsToSelector:@selector(scrollView)]) {
            webView.scrollView.scrollEnabled = NO;
        }
        // HTML to embed YouTube video
        NSString *htmlString = @"<html><head>\
        <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
        <body style=\"margin-top:0px;margin-left:0px\">\
        <div align=\"center\"><object width=\"%0.0f\" height=\"%0.0f\">\
        <param name=\"movie\" value=\"http://www.youtube.com/v/%@\"></param>\
        <param name=\"wmode\" value=\"transparent\"></param>\
        <embed src=\"http://www.youtube.com/v/%@\"\
        type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed>\
        </object></div></body></html>";
        
        // Populate HTML with the URL and requested frame size
        NSString *html = [NSString stringWithFormat:htmlString,
                          size.width,
                          size.width,
                          size.height,
                          videoId,
                          videoId,
                          size.width,
                          size.height];
        [webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",videoId]]];
    }
}

#pragma mark - Web Delegate

-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    UIButton *b = [self findButtonInView:_webView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    if ([view isMemberOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    return button;
}

#pragma mark - Release

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
    self.viewBanner = nil;
}




@end
