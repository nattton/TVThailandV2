//
//  InHouseAdView.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 8/5/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

#define kMethodInHouseAd(time) [NSString stringWithFormat:@"http://tv.makathon.com/api/getInHouseAd?device=ios&time=%@", time]

@interface InHouseAdView : UIView <ASIHTTPRequestDelegate,UIWebViewDelegate>
{
    double delayStart;
    double delayAd;
    NSMutableArray *adLists;
}
@property (nonatomic, assign) UIViewController *rootViewController;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSMutableArray *adLists;

- (void)loadRequest;
- (void)loadRequestWithDelayTime:(double)delayInSeconds;
@end
