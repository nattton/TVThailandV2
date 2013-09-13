//
//  YoutubePlayerViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/13/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;
@interface VideoPlayerViewController : UIViewController

@property (nonatomic, weak) Episode *episode;
@property (nonatomic, unsafe_unretained) NSUInteger idx;

@end
