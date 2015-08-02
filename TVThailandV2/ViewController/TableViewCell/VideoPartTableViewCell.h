//
//  VideoPartTableViewCell.h
//  TVThailandV2
//
//  Created by April Smith on 6/6/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;
@class OTVEpisode;
@class Show;


@interface VideoPartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *partNameLabel;

- (void)configureWithVideoPart:(Episode *)episode partNumber:(NSInteger)partNumber;
- (void)configureWithOTVVideoPart:(OTVEpisode *)otvEpisode partNumber:(NSInteger)partNumber;
- (void)configureWithOTVRelateShows:(Show *)relateOTVShow;

@end
