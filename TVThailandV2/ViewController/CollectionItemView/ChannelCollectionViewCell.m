//
//  ChannelCollectionViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/27/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "ChannelCollectionViewCell.h"
#import "Channel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ChannelCollectionViewCell

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

- (void)configureWithChannel:(Channel *)channel {
    self.titleLabel.text = channel.title;
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString: channel.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.liveLabel.hidden = !(channel.videoUrl != nil && channel.videoUrl.length > 0);
}

@end
