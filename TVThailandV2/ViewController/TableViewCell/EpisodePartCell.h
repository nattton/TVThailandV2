//
//  EPAndPartCell.h
//  TVThailandV2
//
//  Created by April Smith on 11/9/2556 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPPartCellDelegate;

@class Episode;

@interface EpisodePartCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate> {
        UITableView *hortable;
}

@property (nonatomic, weak) Episode *episode;
@property (nonatomic, weak) id <EPPartCellDelegate> delegate;

- (void)configureWithEpisode:(Episode *)episode currentEp:(long)currentEpIndex;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width;
@end


@protocol EPPartCellDelegate <NSObject>

- (void)playVideoPart:(NSIndexPath *)indexPath episode:(Episode *)episode currentEp:(long)currentEpIndex;


@end