//
//  ShowTableViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowTableViewCell.h"
#import "Show.h"
#import "Program.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

@interface ShowTableViewCell ()


@end

@implementation ShowTableViewCell

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

- (void)configureWhatsNewWithShow:(Show *)show {
    self.titleLable.text = show.title;
    self.detailLabel.text = show.lastEp;
    [self.imageThumbView sd_setImageWithURL:[NSURL URLWithString:show.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"show_thumb_wide_s"]];
}

- (void)configureWithShow:(Show *)show {
    self.titleLable.text = show.title;
    self.detailLabel.text = show.desc;
    [self.imageThumbView sd_setImageWithURL:[NSURL URLWithString:show.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"show_thumb_wide_s"]];
}

- (void)configureWithProgram:(Program *)program {
    self.titleLable.text = program.program_title;
    self.detailLabel.text = program.program_time;
    [self.imageThumbView sd_setImageWithURL:[NSURL URLWithString:program.program_thumbnail] placeholderImage:[UIImage imageNamed:@"show_thumb_wide_s"]];
}

@end









