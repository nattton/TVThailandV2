//
//  MakathonAdView.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/5/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "MakathonAdView.h"
#import "MakathonAd.h"

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
    
    [self setHidden:YES];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.webView.delegate = self;
    [self addSubview:self.webView];
}

- (void)requestAd
{
    [MakathonAd loadAds:^(NSArray *ads, NSError *error) {
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
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ad.url]]];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setHidden:NO];
    [self.webView setHidden:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayAd * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self startRotateAd];
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setHidden:YES];
    [self.webView setHidden:YES];
    [self startRotateAd];
}

@end
