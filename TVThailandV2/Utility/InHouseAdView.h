//
//  InHouseAdView.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 8/5/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

#define kMethodInHouseAd(device, time) [NSString stringWithFormat:@"http://tv.makathon.com/api/getInHouseAd?device=%@&time=%@", device, time]

@interface InHouseAdView : UIView <ASIHTTPRequestDelegate,UIWebViewDelegate>
{
    NSString *device;
    double delayStart;
    double delayAd;
    NSMutableArray *adLists;
}
@property (nonatomic, assign) UIViewController *rootViewController;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString *device;
@property (strong, nonatomic) NSMutableArray *adLists;

- (void)loadRequest;
- (void)loadRequestWithDelayTime:(double)delayInSeconds;
@end
