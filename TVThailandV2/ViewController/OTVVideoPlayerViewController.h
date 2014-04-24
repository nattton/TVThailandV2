//
//  OTVVideoPlayerViewController.h
//  TVThailandV2
//
//  Created by April Smith on 3/25/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVAsset.h>

@class OTVEpisode;
@class Show;

@interface OTVVideoPlayerViewController : UIViewController

@property (nonatomic, weak) Show *show;
@property (nonatomic, weak) OTVEpisode *otvEpisode;

@property (nonatomic, unsafe_unretained) NSUInteger idx;

-(NSString *)htmlEntityDecode:(NSString *)string;

@end
