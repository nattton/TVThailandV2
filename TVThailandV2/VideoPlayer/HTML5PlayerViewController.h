//
//  HTML5PlayerViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 8/2/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTML5PlayerViewController : UIViewController
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewBanner;

@property (strong, nonatomic) NSString *videoTitle;
@property (strong, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) NSString *videoPoster;

@end
