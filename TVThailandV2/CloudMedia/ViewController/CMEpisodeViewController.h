//
//  CMEpisodeViewController.h
//  CloudMedia
//
//  Created by April Smith on 9/30/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMCategoryViewController.h"
@class CMMovie;

@interface CMEpisodeViewController : UIViewController

@property (strong, nonatomic) CMMovie *cmMovie;
@property (weak, nonatomic) IBOutlet UIImageView *movieThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *movieNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *moviePriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *previewMovieButton;
@property (weak, nonatomic) IBOutlet UIButton *rentButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;

@end
