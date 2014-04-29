//
//  OTVShowTableViewCell.m
//  TVThailandV2
//
//  Created by April Smith on 3/19/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVShowTableViewCell.h"
#import "OTVShow.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation OTVShowTableViewCell

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

- (void)configWithOTVShow:(OTVShow *)otvShow {
    self.titleShow.text = otvShow.title;
    self.detailShow.text = otvShow.detail;
    
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:otvShow.thumbnail] placeholderImage:[UIImage imageNamed:@"otv_icon"]];

    
}


@end
