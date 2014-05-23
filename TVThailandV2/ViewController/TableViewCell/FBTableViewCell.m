//
//  FBTableViewCell.m
//  TVThailandV2
//
//  Created by April Smith on 5/23/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "FBTableViewCell.h"

@interface FBTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *fbTitleLabel;


@end

@implementation FBTableViewCell

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


- (void) configureWithTitle:(NSString *)title {
    self.fbTitleLabel.text = title;
}


@end
