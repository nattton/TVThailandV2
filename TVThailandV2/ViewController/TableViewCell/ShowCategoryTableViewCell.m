//
//  GenreTableViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ShowCategoryTableViewCell.h"
#import "ShowCategory.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ShowCategoryTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumbView;

@end

@implementation ShowCategoryTableViewCell

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

- (void)configureWithGenre:(ShowCategory *)genre {
    self.titleLabel.text = genre.title;
    
    [self.imageThumbView setImageWithURL:[NSURL URLWithString:genre.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ic_cate_empty"]];
    self.imageThumbView.contentMode = UIViewContentModeScaleAspectFit;

}

@end
