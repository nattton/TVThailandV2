//
//  EpisodeTableViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "EpisodeTableViewCell.h"
#import "Episode.h"

@interface EpisodeTableViewCell()

@end

@implementation EpisodeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithEpisode:(Episode *)episode {
    
    self.titleLabel.text = episode.titleDisplay;
    self.airedLabel.text = episode.updatedDate;
    self.viewLabel.text = episode.viewCount;
    
    if ([episode.srcType isEqualToString:@"0"]) {
        [self.imageThumbView setImage:[UIImage imageNamed:@"ic_youtube"]];
    } else if ([episode.srcType isEqualToString:@"1"]) {
        [self.imageThumbView setImage:[UIImage imageNamed:@"ic_dailymotion"]];
    }
    else if ([episode.srcType isEqualToString:@"12"]) {
        [self.imageThumbView setImage:[UIImage imageNamed:@"ic_web"]];
    }
     else if ([episode.srcType isEqualToString:@"13"]
        || [episode.srcType isEqualToString:@"14"]
        || [episode.srcType isEqualToString:@"15"]) {
        
        [self.imageThumbView setImage:[UIImage imageNamed:@"ic_player"]];
    }
}

@end
