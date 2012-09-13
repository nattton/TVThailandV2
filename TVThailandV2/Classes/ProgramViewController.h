//
//  ProgramViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/22/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@class InHouseAdView;
@interface ProgramViewController : UIViewController <ASIHTTPRequestDelegate,UITableViewDataSource,UITableViewDelegate>
{
    InHouseAdView *inHouseAdView;
}
@property (strong, nonatomic) IBOutlet UIView *viewBanner;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) InHouseAdView *inHouseAdView;
@property (strong, nonatomic) NSString *cat_id;
@property (strong, nonatomic) NSString *cat_name;

-(void)loadProgram:(NSString *)cat_id cat_name:(NSString *)cat_name;
- (void)reloadInHouseAd;
@end
