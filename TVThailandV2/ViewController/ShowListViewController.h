//
//  ShowListViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SASlideMenuViewController.h"
#import "HomeSlideMenuViewController.h"

@import GoogleMobileAds;

typedef NS_ENUM(NSInteger, ShowModeType) {
    kWhatsNew = 0,
    kCategory = 1,
    kChannel = 2,
};

@class Channel;
@interface ShowListViewController : UIViewController

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property (nonatomic, weak) Channel *channel;
@property (nonatomic, weak) HomeSlideMenuViewController *homeSlideMenuViewController;

- (void)reloadWithMode:(ShowModeType) mode Id:(NSString *)Id;

@end
