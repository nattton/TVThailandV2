//
//  WebViewController.h
//  TVThailandV2
//
//  Created by April Smith on 6/24/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Episode;

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, weak) NSString *stringUrl;

@end
