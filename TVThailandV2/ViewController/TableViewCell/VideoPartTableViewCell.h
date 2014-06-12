//
//  VideoPartTableViewCell.h
//  TVThailandV2
//
//  Created by April Smith on 6/6/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;

@interface VideoPartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *partNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeNameLabel;

- (void)configureWithVideoPart:(Episode *)episode partNumber:(long)partNumber;

@end
