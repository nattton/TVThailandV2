//
//  MakathonAdView.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/5/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "MakathonAdView.h"
#import "MakathonAd.h"
#import <SVWebViewController/SVWebViewController.h>

@implementation MakathonAdView {
    NSArray *_ads;
    double delayAd;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];

    CGRect adFrame = self.frame;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        adFrame.size = CGSizeMake(adFrame.size.width, 90);
    }
    else
    {
        adFrame.size = CGSizeMake(adFrame.size.width, 50);
    }
    
    if(!self.webViewShow)
    {
        self.webViewShow = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, adFrame.size.width, adFrame.size.height)];
        self.webViewShow.delegate = self;
        [self.webViewShow.scrollView setScrollEnabled:NO];
        [self addSubview:self.webViewShow];
    }
    else
    {
        self.frame = adFrame;
        [self.webViewShow setFrame:CGRectMake(0, 0, adFrame.size.width, adFrame.size.height)];
    }
}

- (void)requestAd {
    [MakathonAd retrieveData:^(NSArray *ads, NSError *error) {
        _ads = ads;
        [self startRotateAd];
    }];
    
}

- (void)startRotateAd
{
    if ([_ads count] > 0) {
        int x = arc4random() % [_ads count];
        MakathonAd *ad = [_ads objectAtIndex:x];
        delayAd = [ad.time doubleValue] / 1000.0f;
        [self.webViewShow loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ad.url]]];
        
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:[request URL]];
        if (self.parentViewController && self.parentViewController.navigationController) {
            [self.parentViewController.navigationController pushViewController:webViewController animated:YES];
        } else {
            [[UIApplication sharedApplication] openURL:[request URL]];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setHidden:NO];
    [self.webViewShow setHidden:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayAd * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self startRotateAd];
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setHidden:YES];
    [self.webViewShow setHidden:YES];
    [self startRotateAd];
}

@end
