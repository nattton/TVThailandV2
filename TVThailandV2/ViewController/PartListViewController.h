//
//  PartListViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/13/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoPlayerViewController;
@class Episode;
@interface PartListViewController : UIViewController

@property (nonatomic, weak) Episode *episode;
@property (nonatomic, weak) VideoPlayerViewController *videoPlayer;

@end
