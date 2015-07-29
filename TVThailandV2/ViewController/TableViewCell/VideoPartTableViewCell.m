//
//  VideoPartTableViewCell.m
//  TVThailandV2
//
//  Created by April Smith on 6/6/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "VideoPartTableViewCell.h"
#import "Episode.h"
#import "Show.h"
#import "OTVEpisode.h"
#import "OTVPart.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation VideoPartTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithVideoPart:(Episode *)episode partNumber:(NSInteger)partNumber {
    if ([episode.videos count] == 1) {
        self.partNameLabel.text = @"";
    } else {
        self.partNameLabel.text = [NSString stringWithFormat:@"Part %d/%d", [[NSNumber numberWithInteger:partNumber+1] intValue], [[NSNumber numberWithInteger:episode.videos.count] intValue]];
    }
    
    self.episodeNameLabel.text = episode.titleDisplay;
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:[episode videoThumbnail:partNumber]] placeholderImage:[UIImage imageNamed:@"show_thumb_wide_s"] options:SDWebImageProgressiveDownload];
}

- (void)configureWithOTVVideoPart:(OTVEpisode *)otvEpisode partNumber:(NSInteger)partNumber {
    if ([otvEpisode.parts count] == 1) {
        self.partNameLabel.text = @"";
    } else {
        self.partNameLabel.text = [otvEpisode.parts[partNumber] nameTh];
    }
    
    self.episodeNameLabel.text = [NSString stringWithFormat:@"%d/%d - %@", [[NSNumber numberWithInteger:partNumber+1] intValue], [[NSNumber numberWithInteger:otvEpisode.parts.count] intValue], otvEpisode.nameTh];
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:[otvEpisode.parts[partNumber] thumbnail]] placeholderImage:[UIImage imageNamed:@"show_thumb_wide_s"] options:SDWebImageProgressiveDownload];
}

- (void)configureWithOTVRelateShows:(Show *)relateOTVShow {
    self.partNameLabel.text =  relateOTVShow.title;
//    self.partNameLabel.text = @"";
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:relateOTVShow.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"show_thumb_wide_s"] options:SDWebImageProgressiveDownload];
}

@end
