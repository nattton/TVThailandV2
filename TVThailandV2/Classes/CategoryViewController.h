//
//  CategoryViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/21/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@interface CategoryViewController : UIViewController <ASIHTTPRequestDelegate,UISearchDisplayDelegate,UISearchBarDelegate> {
    
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSArray *catItems;
@property (nonatomic, retain) NSArray *chItems;


- (void)beginSearch;
@end
