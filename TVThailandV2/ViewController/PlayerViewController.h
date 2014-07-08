//
//  YouTubeViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 6/5/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

// IMA SDK
#import "IMAAVPlayerContentPlayhead.h"
#import "IMAAd.h"
#import "IMAAdsLoader.h"
#import "IMAAdsManager.h"

@class Episode;
@class Show;
@class OTVEpisode;
@class OTVEpisodePartViewController;

@interface PlayerViewController : UIViewController 

@property (nonatomic, weak) Show *show;
@property (nonatomic, weak) Episode *episode;
@property (nonatomic, weak) Episode *otherEpisode;

@property (nonatomic, weak) OTVEpisode *otvEpisode;
@property (nonatomic, weak) NSArray *otvRelateShows;
@property (nonatomic, weak) OTVEpisodePartViewController *otvEPController;

@property (nonatomic, unsafe_unretained) NSInteger idx;


@property (weak, nonatomic) IBOutlet UIView *titleContainerView;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (weak, nonatomic) IBOutlet UILabel *showNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *partNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoOfEpisodeButton;
@property (weak, nonatomic) IBOutlet UIButton *openWithButton;

@property (weak, nonatomic) IBOutlet UITableView *tableOfVideoPart;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailOTV;


@property(nonatomic, strong) IMAAdsLoader *adsLoader;
@property(nonatomic, strong) IMAAdsManager *adsManager;
@property(nonatomic, strong) IMAAdsRenderingSettings *adsRenderingSettings;

@end
