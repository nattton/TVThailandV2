//
//  EPViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/23/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface EPViewController : UIViewController <ASIHTTPRequestDelegate,UITableViewDataSource,UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UIView *viewBanner;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)setEPTitle:(NSString *)title  andVideoItems:(NSArray *)videoIdItems andSrcType:(NSString *)srcType andPassword:(NSString *)pwd;

@end
