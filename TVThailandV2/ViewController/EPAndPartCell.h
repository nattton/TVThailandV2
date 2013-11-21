//
//  EPAndPartCell.h
//  TVThailandV2
//
//  Created by April Smith on 11/9/2556 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPAndPartCellDelegate;

@class Episode;

@interface EPAndPartCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate>{
        UITableView *hortable;
}

@property (nonatomic, weak) Episode *episode;
@property (nonatomic, weak) id <EPAndPartCellDelegate> delegate;

- (void)configureWithEpisode:(Episode *)episode;

@end


@protocol EPAndPartCellDelegate <NSObject>

- (void)playVideoPart:(NSIndexPath *)indexPath episode:(Episode *)episode;


@end