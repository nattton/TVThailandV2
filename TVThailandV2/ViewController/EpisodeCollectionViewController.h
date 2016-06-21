//
//  EpisodeViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 12/11/2558 BE.
//  Copyright © 2558 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Show;
@class Episode;

@interface EpisodeCollectionViewController : UICollectionViewController

@property (nonatomic, strong) Show *show;
@property (nonatomic, weak) Episode *episode;
@property (nonatomic, weak) Episode *otherEpisode;

@end
