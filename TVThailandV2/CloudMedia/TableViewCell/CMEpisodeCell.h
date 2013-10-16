//
//  CMEpisodeCell.h
//  CloudMedia
//
//  Created by April Smith on 10/1/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMEpisodeCellDelegate;
@class CMEpisode;

@interface CMEpisodeCell : UITableViewCell

@property (weak, nonatomic) id <CMEpisodeCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) CMEpisode *episode;
@property (weak, nonatomic) IBOutlet UIButton *playEPButton;
@property (weak, nonatomic) IBOutlet UIButton *previewEPButton;

-(void)configureWithCMEpisode:(CMEpisode *)cmEpisode;

@end

@protocol CMEpisodeCellDelegate <NSObject>

- (void)tappedPlayEpisodeButton:(CMEpisode *)episode;
- (void)tappedPreviewEpisodeButton:(CMEpisode *)episode;

@end