//
//  OTVVideoPlayerViewController.h
//  TVThailandV2
//
//  Created by April Smith on 3/25/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTVEpisode;
@class OTVCategory;

@interface OTVVideoPlayerViewController : UIViewController

@property (nonatomic, weak) OTVCategory *otvCategory;
@property (nonatomic, weak) OTVEpisode *otvEpisode;

@property (nonatomic, unsafe_unretained) NSUInteger idx;

-(NSString *)htmlEntityDecode:(NSString *)string;

@end
