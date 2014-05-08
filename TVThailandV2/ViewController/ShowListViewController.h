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

typedef enum {
    kWhatsNew = 0,
    kCategory = 1,
    kChannel = 2
} ShowModeType;

@interface ShowListViewController : UIViewController

@property (nonatomic, weak) NSString *videoUrl;

- (void)reloadWithMode:(ShowModeType) mode Id:(NSString *)Id;

@end
