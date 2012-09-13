//
//  YoutubeViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/23/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YoutubeViewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewBanner;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *videoId;
@property (strong, nonatomic) NSString *videoTitle;

@end
