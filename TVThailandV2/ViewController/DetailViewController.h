//
//  DetailViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 10/3/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Show;
@class OTVShow;
@interface DetailViewController : UIViewController

@property (nonatomic, weak) Show *show;
@property (nonatomic, weak) OTVShow *otvShow;

@end
