//
//  AppDelegate.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/21/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <BugSense-iOS/BugSenseCrashController.h>

#import "AppDelegate.h"

#import "IIViewDeckController.h"

#import "CategoryViewController.h"
#import "ProgramViewController.h"

#import "SBJson.h"
#import "GANTracker.h"
#import "NSString+Utils.h"

static const NSInteger kLoadMessageiOS = 1;
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation AppDelegate
{
    BOOL closing;
    NSMutableArray *arrayButtonURL;
}

@synthesize window = _window;
@synthesize centerViewController = _centerViewController;
@synthesize categoryViewController = _categoryViewController;
@synthesize programViewController = _programViewController;
@synthesize rightController = _rightController;


@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
////////////////////////////////// BugSense ////////////////////////////////
    [BugSenseCrashController sharedInstanceWithBugSenseAPIKey:@"eb08d56b"
                                               userDictionary:nil
                                              sendImmediately:NO];
    
//////////////////////////////// Google Analytics ////////////////////////////////
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-22403997-3"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
                                         withError:&error]) {
        // Handle error here
    }
    
    ////////////////////////////////////////////////////////////////
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        self.programViewController = [[ProgramViewController alloc] initWithNibName:@"ProgramViewController_iPhone" bundle:nil];
    } else {
//        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
        self.programViewController = [[ProgramViewController alloc] initWithNibName:@"ProgramViewController_iPad" bundle:nil];
    }
    
    self.centerViewController = [[UINavigationController alloc] initWithRootViewController:self.programViewController];
    
    self.categoryViewController = [[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
    
    IIViewDeckController* deckController = [[IIViewDeckController alloc] initWithCenterViewController:self.centerViewController leftViewController:self.categoryViewController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        deckController.leftLedge = 400.0;
    }
    else {
        deckController.leftLedge = 44;
    }
    
    
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
    
    
    // Setup Notification
    
    closing = NO;
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            //            NSLog(@"Launched from push notification: %@", dictionary);
            [self clearNotifications];
            [self notificationToSwitchApplication:dictionary];
        }
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    closing = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self loadMessageiOS];
    closing = NO;
//    [self clearNotifications];
    [self.programViewController reloadInHouseAd];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - function

- (void)loadMessageiOS
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:kGetMessageiOS([NSString getUnixTimeKey])]];
    request.tag = kLoadMessageiOS;
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag == kLoadMessageiOS) {
        NSDictionary *dict = [[request responseString] JSONValue];
        if (dict) {
            if(![[dict objectForKey:@"id"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMessageID]])
            {
                [[NSUserDefaults standardUserDefaults] setValue:[dict objectForKey:@"id"] forKey:kMessageID];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIAlertView *alert= [[UIAlertView alloc]
                                     initWithTitle:[dict objectForKey:@"title"]
                                     message:[dict objectForKey:@"message"]
                                     delegate:self
                                     cancelButtonTitle:@"Close"
                                     otherButtonTitles:nil];
                
                @try {
                    arrayButtonURL = [NSMutableArray array];
                    NSArray *buttons = [dict objectForKey:@"buttons"];
                    for (int i = 0; i < [buttons count]; i++) {
                        NSDictionary *button = [buttons objectAtIndex:i];
                        [alert addButtonWithTitle:[button objectForKey:@"label"]];
                        [arrayButtonURL addObject:[button objectForKey:@"url"]];
                    }
                }
                @catch (NSException *exception) {
                    BUGSENSE_LOG(exception, @"getMessageiOS");
                }
                [alert show];
            }
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[arrayButtonURL objectAtIndex:(buttonIndex - 1)]]];
    }
    
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
        NSLog(@"Error connecting persistent store: %@, %@", error, [error userInfo]);
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
        NSLog(@"Error saving context: %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //    NSLog(@"My token is: %@", deviceToken );
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(sendDeviceToken:) object:deviceToken];
    [queue addOperation:operation];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if (closing) {
        [self notificationToSwitchApplication:userInfo];
        closing = NO;
    }
    else
    {
        //        [self performSelectorOnMainThread:@selector(alertCenter) withObject:[[userInfo objectForKey:@"aps"] objectForKey:@"title"] waitUntilDone:YES];
        //        [[TKAlertCenter defaultCenter] postAlertWithMessage:];
    }
}


- (void)sendDeviceToken:(NSData *)deviceToken
{
    
    NSString *token = [[[[NSString stringWithFormat:@"%@",deviceToken]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *uniqueIdentifier = [[UIDevice currentDevice] uniqueIdentifier];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:
                               [NSURL URLWithString: kDeviceToken(uniqueIdentifier, token)]];
    [request startSynchronous];
}

- (void)notificationToSwitchApplication:(NSDictionary *)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    
    NSString *title = ([[userInfo objectForKey:@"aps"] objectForKey:@"title"])?[[userInfo objectForKey:@"aps"] objectForKey:@"title"]:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"program_id"]) {
        [self.centerViewController.navigationController popToRootViewControllerAnimated:NO];
        [self.programViewController loadProgram:[[userInfo objectForKey:@"aps"] objectForKey:@"program_id"] cat_name:title]; 
    }
    else if ([[userInfo objectForKey:@"aps"] objectForKey:@"cat_id"])
    {
        [self.centerViewController.navigationController popToRootViewControllerAnimated:NO];
        [self.programViewController loadProgram:[[userInfo objectForKey:@"aps"] objectForKey:@"cat_id"] cat_name:title];
    }
}

- (void) clearNotifications {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [UIApplication sharedApplication].scheduledLocalNotifications = [NSArray array];
    
    //    NSArray* notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //    NSLog(@"%@",notifications);
    
    //    [UIApplication sharedApplication].scheduledLocalNotifications = notifications;
}

@end
