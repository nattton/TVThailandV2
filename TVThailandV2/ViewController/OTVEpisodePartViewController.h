//
//  OTVEpAndPartViewController.h
//  TVThailandV2
//
//  Created by April Smith on 3/20/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Show;
@class OTVEpisode;


@interface OTVEpisodePartViewController : UIViewController

@property (nonatomic, strong) Show *show;

- (void)reload;
- (void)setShow:(Show *)show;

@end
