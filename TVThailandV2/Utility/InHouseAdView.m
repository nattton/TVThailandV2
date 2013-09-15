//
//  InHouseAdView.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 8/5/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "InHouseAdView.h"

//#import "SBJson.h"
#import "NSString+Utils.h"

@implementation InHouseAdView

@synthesize webView = _webView;
@synthesize rootViewController = _rootViewController;
@synthesize adLists;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        delayStart = 5.0;
        delayAd = 5.0;
        [self setHidden:YES];
        self.webView = [[UIWebView alloc] initWithFrame:frame];
        self.webView.delegate = self;
        [self addSubview:self.webView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)loadRequestWithDelayTime:(double)delayInSeconds
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadRequest];
    });
}

- (void)loadRequest
{
    [self setHidden:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayStart * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:
                                   [NSURL URLWithString:kMethodInHouseAd([NSString getUnixTimeKey])]];
        request.delegate = self;
        [request startAsynchronous];
    });
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
//    NSDictionary *dict = [[request responseString] JSONValue];
//    if (dict) {
//        delayStart = [[dict objectForKey:@"delayStart"] doubleValue] / 1000.0f;
//        adLists =  [NSMutableArray arrayWithArray:[dict objectForKey:@"ads"]];
//        [self startRotateAd];
//    }
}

- (void)startRotateAd
{
    if ([adLists count] > 0) {
        int x = arc4random() % [adLists count];
        NSDictionary *ad = [adLists objectAtIndex:x];
        NSString *url = [ad objectForKey:@"url"];
        delayAd = [[ad objectForKey:@"time"] doubleValue] / 1000.0f;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        [adLists removeObjectAtIndex:x];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if (self.rootViewController) {
            NSString *url = [[request URL] absoluteString];
//            TTWebController *webContrller = [[TTWebController alloc] init];
//            [webContrller openURL:[NSURL URLWithString:url]];
//            
//            webContrller.navigationController.navigationBar.tintColor = [UIColor blackColor];
//            
//            UINavigationController *navWeb = [[UINavigationController alloc] initWithRootViewController:webContrller];
//            webContrller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissModalViewController)];
            
//            [self.rootViewController presentModalViewController:navWeb animated:YES];
            
        }
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setHidden:NO];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayAd * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setHidden:YES];
        [self startRotateAd];
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self startRotateAd];
}

- (void)dismissModalViewController
{
    if (self.rootViewController) {
        [self.rootViewController dismissModalViewControllerAnimated:YES];
    }
}

@end
