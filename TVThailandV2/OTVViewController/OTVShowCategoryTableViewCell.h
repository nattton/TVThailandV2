//
//  OTVShowCategoryTableViewCell.h
//  TVThailandV2
//
//  Created by April Smith on 3/18/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTVCategory;

@interface OTVShowCategoryTableViewCell : UITableViewCell

- (void)configureWithOTVCate:(OTVCategory *)category;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end
