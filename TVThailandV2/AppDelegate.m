//
//  AppDelegate.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/21/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"
#import "NSString+Utils.h"
#import "CMUser.h"
#import "UIImage+RoundedImage.h"

@implementation AppDelegate

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:kThemeColor, UITextAttributeTextColor, [UIColor whiteColor], UITextAttributeTextShadowColor, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UIBarButtonItem appearance] setTintColor:kThemeColor];
        
        [[UISearchBar appearance] setBackgroundImage:[UIImage imageWithColor:kThemeColor]];
        [[UIToolbar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    } else {
        [[UINavigationBar appearance] setTintColor:kThemeColor];
    }
    
    // Override point for customization after application launch.
    [FBLoginView class];
    
    // Load the FBProfilePictureView
    // You can find more information about why you need to add this line of code in our troubleshooting guide
    // https://developers.facebook.com/docs/ios/troubleshooting#objc
    [FBProfilePictureView class];
    
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 60;
    
    // Optional: set Logger to VERBOSE for debug information.
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:kAppTracker];
    
    
    return YES;
}



// In order to process the response you get from interacting with the Facebook login process,
// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

- (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"tvthai2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if(_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self documentsDirectory]
                       URLByAppendingPathComponent:@"tvthai2.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:self.managedObjectModel];
    
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:nil error:&error])
    {
        DLog(@"Error connecting persistent store: %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if(_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    return _managedObjectContext;
}

- (void)saveContext
{
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges] &&
        ![self.managedObjectContext save:&error]) {
        DLog(@"Error saving context: %@, %@", error, [error userInfo]);
        abort();
    }
}



@end
