//
//  MakathonAdView.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/5/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakathonAdView : UIView <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webViewShow;
@property (nonatomic, strong) UIViewController *parentViewController;
- (void)requestAd;

@end
