//
//  RadioCollectionViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/27/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "RadioCollectionViewCell.h"
#import "Radio.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation RadioCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)configureWithRadio:(Radio *)radio {
    self.titleLabel.text = radio.title;
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:radio.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
}
@end
