//
//  EpisodeTableViewCell.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/12/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;
@interface EpisodeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageThumbView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *airedLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewLabel;

- (void)configureWithEpisode:(Episode *)episode;

@end
