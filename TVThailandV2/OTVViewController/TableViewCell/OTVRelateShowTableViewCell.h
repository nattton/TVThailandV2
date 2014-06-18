//
//  OTVRelateShowTableViewCell.h
//  TVThailandV2
//
//  Created by April Smith on 6/17/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Show;

@protocol OTVRelateShowTableViewCellDelegate;


@interface OTVRelateShowTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate> {
    UITableView *hortable;
}

@property (nonatomic, weak) id <OTVRelateShowTableViewCellDelegate> delegate;

- (void) configureWithShows:(NSArray *)shows;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width;

@end


@protocol OTVRelateShowTableViewCellDelegate <NSObject>

- (void)openOTVShow:(NSIndexPath *)indexPath show:(Show *)show;

@end