//
//  ProgramListViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/22/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface ProgramListViewController : UIViewController <ASIHTTPRequestDelegate,UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>

@property (unsafe_unretained, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UIView *viewBanner;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *program_id;
@property (strong, nonatomic) NSString *program_title;
@property (strong, nonatomic) NSString *program_time;
@property (strong, nonatomic) NSString *program_thumbnail;

@end
