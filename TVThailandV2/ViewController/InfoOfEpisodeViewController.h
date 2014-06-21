//
//  InfoOfEpisodeViewController.h
//  TVThailandV2
//
//  Created by April Smith on 6/20/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OTVEpisode;

@interface InfoOfEpisodeViewController : UIViewController

@property (nonatomic, weak) OTVEpisode* otvEpisode;
@property (weak, nonatomic) IBOutlet UILabel *episodeName;
@property (weak, nonatomic) IBOutlet UILabel *updateDate;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

@end
