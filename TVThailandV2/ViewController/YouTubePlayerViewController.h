//
//  YouTubeViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/5/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;
@class Show;
@interface YouTubePlayerViewController : UIViewController

@property (nonatomic, weak) Show *show;
@property (nonatomic, weak) Episode *episode;
@property (nonatomic, unsafe_unretained) NSInteger idx;
@property (nonatomic, weak) NSString *videoUrl;

@property (nonatomic) BOOL isHidenToolbarPlayer;
@property (weak, nonatomic) IBOutlet UIView *titleContainerView;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (weak, nonatomic) IBOutlet UILabel *showNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *partNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeNameLabel;

@end
