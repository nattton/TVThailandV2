//
//  AppDelegate.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/21/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowListViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@end
