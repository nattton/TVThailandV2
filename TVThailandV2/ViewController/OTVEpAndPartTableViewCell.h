//
//  OTVEpAndPartTableViewCell.h
//  TVThailandV2
//
//  Created by April Smith on 3/21/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OTVEpisode;
@class OTVPart;

@protocol OTVEpAndPartTableViewCellDelegate;

@interface OTVEpAndPartTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate> {
    UITableView *hortable;
}
@property (nonatomic, weak) OTVEpisode *otvEpisode;
@property (nonatomic, weak) id <OTVEpAndPartTableViewCellDelegate> delegate;

- (void) configureWithEpisode:(OTVEpisode *)otvEpisode;

@end



@protocol OTVEpAndPartTableViewCellDelegate <NSObject>

- (void)playVideoPart:(NSIndexPath *)indexPath episode:(OTVEpisode *)otvEpisode;

@end