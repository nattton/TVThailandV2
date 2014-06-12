//
//  EpisodeANDPartViewController.h
//  TVThailandV2
//
//  Created by April Smith on 11/9/2556 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Show;
@class Episode;

@interface EpisodePartViewController : UIViewController{
    UITableView *portable;
}

@property (nonatomic, strong) Show *show;
@property (nonatomic, weak) Episode *episode;
@property (nonatomic, weak) Episode *otherEpisode;


@end
