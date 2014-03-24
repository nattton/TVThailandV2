//
//  OTVEpAndPartViewController.h
//  TVThailandV2
//
//  Created by April Smith on 3/20/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OTVCategory;
@class OTVShow;
@class OTVEpisode;


@interface OTVEpAndPartViewController : UIViewController {
    UITableView *portable;
}

@property (nonatomic, strong) OTVCategory *otvCategory;
@property (nonatomic, strong) OTVShow *otvShow;
@property (nonatomic, strong) OTVEpisode *otvEpisode;


@end
