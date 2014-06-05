//
//  YouTubeViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/5/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;
@interface YouTubePlayerViewController : UIViewController

@property (nonatomic, weak) Episode *episode;
@property (nonatomic, unsafe_unretained) NSUInteger idx;
@property (nonatomic, weak) NSString *videoUrl;

@property (nonatomic) BOOL isHidenToolbarPlayer;

@end
