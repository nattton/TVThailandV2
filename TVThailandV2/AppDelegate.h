//
//  AppDelegate.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/21/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@class CategoryViewController;
@class ProgramViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *centerViewController;
@property (strong, nonatomic) CategoryViewController *categoryViewController;
@property (strong, nonatomic) ProgramViewController *programViewController;
@property (strong, nonatomic) UIViewController *rightController;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)sendDeviceToken:(NSData *)deviceToken;
- (void)notificationToSwitchApplication:(NSDictionary *)userInfo;
- (void) clearNotifications;


@end
