//
//  CMEpisodeCell.m
//  CloudMedia
//
//  Created by April Smith on 10/1/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMEpisodeCell.h"
#import "CMEpisode.h"
#import "UIImageView+AFNetworking.h"
#import "CMVideoPlayerViewController.h"


@interface CMEpisode () <CMEpisodeCellDelegate>

@end


@implementation CMEpisodeCell



- (IBAction)playVideo:(id)sender {
    NSLog(@"****playVideo:%@", self.episode.videoLink);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tappedPlayEpisodeButton:)]) {
        [self.delegate tappedPlayEpisodeButton:self.episode];
    }

}

- (IBAction)playPreview:(id)sender {
    NSLog(@"****playPreview:%@", self.episode.trailerLink);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tappedPreviewEpisodeButton:)]) {
        [self.delegate tappedPreviewEpisodeButton:self.episode];
    }
}


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


-(void)configureWithCMEpisode:(CMEpisode *)cmEpisode{

    self.titleLabel.text = cmEpisode.thaiName;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.frame = CGRectMake(100,5,208,23);
    [self.titleLabel sizeToFit];
    [self.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    
    
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:cmEpisode.imageSmall]];
    if ([cmEpisode.videoLink isEqualToString:@""]) {
        self.playEPButton.hidden= YES;
    }
    else {
        self.playEPButton.hidden= NO;
    }
    if([cmEpisode.trailerLink isEqualToString:@""]){
        self.previewEPButton.hidden=YES;
    }
    else
    {
        self.previewEPButton.hidden=NO;
    }
    
    self.episode = cmEpisode;
}


@end
