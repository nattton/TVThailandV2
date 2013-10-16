//
//  CMMovieCell.h
//  CloudMedia
//
//  Created by April Smith on 9/30/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMMovie;

@interface CMMovieCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *movieNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


- (void) configureWithCMMovie:(CMMovie *)cmMovie;


@end
