//
//  AppDelegate.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/21/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

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
    
    // Add registration for remote notifications
	[[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
	
	// Clear application badge when app launches
	application.applicationIconBadgeNumber = 0;
    
    
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    //    NSLog(@"My token is: %@", deviceToken );
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(sendDeviceToken:) object:devToken];
    [queue addOperation:operation];
    
//#if !TARGET_IPHONE_SIMULATOR
//    
//	// Get Bundle Info for Remote Registration (handy if you have more than one app)
//	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
//	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//	
//	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
//	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//	
//	// Set the defaults to disabled unless we find otherwise...
//	NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
//	NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
//	NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
//	
//	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
//	UIDevice *dev = [UIDevice currentDevice];
//	NSString *deviceUuid;
//	if ([dev respondsToSelector:@selector(uniqueIdentifier)])
//		deviceUuid = dev.uniqueIdentifier;
//	else {
//		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//		id uuid = [defaults objectForKey:@"deviceUuid"];
//		if (uuid)
//			deviceUuid = (NSString *)uuid;
//		else {
//			CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
//			deviceUuid = (__bridge NSString *)cfUuid;
//			CFRelease(cfUuid);
//			[defaults setObject:deviceUuid forKey:@"deviceUuid"];
//		}
//	}
//	NSString *deviceName = dev.name;
//	NSString *deviceModel = dev.model;
//	NSString *deviceSystemVersion = dev.systemVersion;
//	
//	// Prepare the Device Token for Registration (remove spaces and < >)
//	NSString *deviceToken = [[[[devToken description]
//                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
//                              stringByReplacingOccurrencesOfString:@">" withString:@""]
//                             stringByReplacingOccurrencesOfString: @" " withString: @""];
//	
//	// Build URL String for Registration
//	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
//	// !!! SAMPLE: "secure.awesomeapp.com"
//	NSString *host = kApiDomain;
//	
//	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED
//	// !!! ( MUST START WITH / AND END WITH ? ).
//	// !!! SAMPLE: "/path/to/apns.php?"
//	NSString *urlString = [NSString stringWithFormat:@"/apns?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
//	
//	// Register the Device Data
//	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
//	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//	NSLog(@"Register URL: %@", url);
//	NSLog(@"Return Data: %@", returnData);
//	
//#endif
    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
#if !TARGET_IPHONE_SIMULATOR
        
    NSLog(@"Error in registration. Error: %@", error);

#endif
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
    
    
//#if !TARGET_IPHONE_SIMULATOR
//    
//	NSLog(@"remote notification: %@",[userInfo description]);
//	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
//	
//	NSString *alert = [apsInfo objectForKey:@"alert"];
//	NSLog(@"Received Push Alert: %@", alert);
//	
//	NSString *sound = [apsInfo objectForKey:@"sound"];
//	NSLog(@"Received Push Sound: %@", sound);
//	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//	
//	NSString *badge = [apsInfo objectForKey:@"badge"];
//	NSLog(@"Received Push Badge: %@", badge);
//	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
//	
//#endif
}


- (void)sendDeviceToken:(NSData *)deviceToken
{
#if !TARGET_IPHONE_SIMULATOR
    NSString *token = [[[[NSString stringWithFormat:@"%@",deviceToken]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *uniqueIdentifier = [[UIDevice currentDevice] uniqueIdentifier];
    
//    NSLog(@"uniqueIdentifier : %@",uniqueIdentifier);
//    NSLog(@"token : %@",token);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:
                               [NSURL URLWithString: kDeviceToken(uniqueIdentifier, token)]];
    [request startSynchronous];
#endif
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
