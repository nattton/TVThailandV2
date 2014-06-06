//
//  VideoPartTableViewCell.m
//  TVThailandV2
//
//  Created by April Smith on 6/6/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "VideoPartTableViewCell.h"
#import "Episode.h"
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
    self.partNameLabel.text = [NSString stringWithFormat:@"Part %ld/%ld", partNumber, episode.videos.count ];
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:[episode videoThumbnail:partNumber-1]] placeholderImage:[UIImage imageNamed:@"show_thumb_wide_s"] options:SDWebImageProgressiveDownload];

    
}

@end
