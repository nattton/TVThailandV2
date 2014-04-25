//
//  OTVShowCategoryTableViewCell.m
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVShowCategoryTableViewCell.h"
#import "OTVCategory.h"

#import <SDWebImage/UIImageView+WebCache.h>


@implementation OTVShowCategoryTableViewCell

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

- (void)configureWithOTVCate:(OTVCategory *)category {
    
    self.titleLabel.text = category.title;
    

    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:category.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"otv_icon"]];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;

}

@end
