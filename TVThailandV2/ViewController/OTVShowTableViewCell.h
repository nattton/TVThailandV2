//
//  OTVShowTableViewCell.h
//  TVThailandV2
//
//  Created by April Smith on 3/19/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OTVShow;

@interface OTVShowTableViewCell : UITableViewCell

- (void)configWithOTVShow:(OTVShow *)otvShow;

@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleShow;
@property (strong, nonatomic) IBOutlet UILabel *detailShow;

@end
