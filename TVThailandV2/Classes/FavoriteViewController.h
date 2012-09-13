//
//  FavoriteViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 8/3/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (unsafe_unretained, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewBanner;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@end
