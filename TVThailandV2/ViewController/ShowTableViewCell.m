//
//  ShowTableViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowTableViewCell.h"
#import "Show.h"

//#import "UIImageView+AFNetworking.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ShowTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageThumbView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

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
    [self.imageThumbView setImageWithURL:[NSURL URLWithString:show.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder40"]];

    [self setNeedsLayout];
    
}

- (void)configureGenreWithShow:(Show *)show {
    self.titleLable.text = show.title;
    self.detailLabel.text = show.desc;
    [self.imageThumbView setImageWithURL:[NSURL URLWithString:show.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder40"]];
}

@end
