//
//  DailyMotionViewController.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/23/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "DailyMotionViewController.h"
#import "GADBannerView.h"
@interface DailyMotionViewController ()
{
    GADBannerView *bannerView;
//    BOOL autoWeb;
}
@end

@implementation DailyMotionViewController

@synthesize viewBanner;
@synthesize webView;
@synthesize videoId;
@synthesize videoTitle;

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

//    BOOL isEmbed = [[NSUserDefaults standardUserDefaults] boolForKey:kDailyMotionWeb];
    
    [self openVideoIsWeb:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - function

//- (void)toggleMode
//{
//    [self openVideoIsWeb:!autoWeb];
//}

- (void)openVideoIsWeb:(BOOL)isWeb
{
//    autoWeb = isWeb;
//    
//    [[NSUserDefaults standardUserDefaults] setBool:autoWeb forKey:kDailyMotionWeb];
//    
//    NSString *menuTitle = (!autoWeb)?@"Web":@"Embed";
//    
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
//                                               [[UIBarButtonItem alloc] initWithTitle:menuTitle style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMode)],
//                                               nil];
    
    CGSize size;
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        size = CGSizeMake(768, 460);
    }
    else
    {
        size = CGSizeMake(320, 240);
    }
    
    if (isWeb) {
        if ([webView respondsToSelector:@selector(scrollView)]) {
            webView.scrollView.scrollEnabled = YES;
        }
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@?autoplay=1",videoId]]]];
    }
    else {
        if ([webView respondsToSelector:@selector(scrollView)]) {
            webView.scrollView.scrollEnabled = NO;
        }
        NSString *htmlString = [NSString stringWithFormat:@"<html><head>\
                                <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
                                <body style=\"margin-top:0px;margin-left:0px;margin-right:0px;\">\
                                <div align=\"center\"><iframe src=\"http://www.dailymotion.com/embed/video/%@?autoplay=1\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\"></iframe>\
                                </div></body></html>", size.width, videoId, size.width, size.height];
        
        [webView loadHTMLString:htmlString
                        baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/video/%@",videoId]]];
    }
}
@end
