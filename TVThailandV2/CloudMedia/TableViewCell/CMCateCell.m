//
//  CMCateCell.m
//  CloudMedia
//
//  Created by April Smith on 9/29/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMCateCell.h"
#import "CMCategory.h"
#import "UIImageView+AFNetworking.h"

@interface CMCateCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

@implementation CMCateCell

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

- (void)configureWithCMCategory:(CMCategory *)cmCategory{
    self.titleLabel.text = cmCategory.title;
    self.descriptionLabel.text  =   cmCategory.descriptionOfCM;
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:cmCategory.thumbnail]];
}

@end
