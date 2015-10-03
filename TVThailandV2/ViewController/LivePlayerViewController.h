//
//  LivePlayerViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/4/2558 BE.
//  Copyright © 2558 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Channel;
@class ChannelViewController;
@interface LivePlayerViewController : UIViewController

@property (nonatomic, weak) Channel *channel;
@property (nonatomic, assign) ChannelViewController *channelViewController;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;

@end
