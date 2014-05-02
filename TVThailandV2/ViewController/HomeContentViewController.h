//
//  HomeContentViewController.h
//  TVThailandV2
//
//  Created by April Smith on 4/30/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASlideMenuViewController.h"

@interface HomeContentViewController : UIViewController


@property(nonatomic,strong) SASlideMenuViewController* menuController;

-(IBAction)tap:(id)sender;

@end
