//
//  GenreTableViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "GenreTableViewCell.h"
#import "Genre.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface GenreTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumbView;

@end

@implementation GenreTableViewCell

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

- (void)configureAllGenre {
    self.titleLabel.text = @"All Genres";
    [self.imageThumbView setImage:[UIImage imageNamed:@"ic_cate_empty"]];
}

- (void)configureWithGenre:(Genre *)genre {
    self.titleLabel.text = genre.title;
    [self.imageThumbView setImageWithURL:[NSURL URLWithString:genre.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ic_cate_empty"]];
}

@end
