//
//  ChannelCollectionViewCell.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/27/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "ChannelCollectionViewCell.h"
#import "Channel.h"
#import "UIImageView+WebCacheRounded.h"
//#import <SDWebImage/UIImageView+WebCache.h>

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
    self.liveLabel.hidden = !(channel.videoUrl != nil && channel.videoUrl.length > 0);
    [self.thumbnailImageView setImageURL:[NSURL URLWithString:channel.thumbnailUrl]
                             placeholder:[UIImage imageNamed:@"placeholder"]
                                  radius:5.0
                                  toDisk:YES];
    
//    [self.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:channel.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageProgressiveDownload];
}

@end
