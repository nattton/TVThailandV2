//
//  AppDelegate.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/21/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "AppDelegate.h"

#import "IIViewDeckController.h"
#import "ViewController.h"
#import "ProgramViewController.h"
#import "CategoryViewController.h"

#import "GANTracker.h"

static const NSInteger kGANDispatchPeriodSec = 10;

@implementation AppDelegate

@synthesize window = _window;
@synthesize centerViewController = _centerViewController;
@synthesize categoryViewController = _categoryViewController;
@synthesize programViewController = _programViewController;
@synthesize rightController = _rightController;

@synthesize viewController = _viewController;
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
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
//    self.window.rootViewController = self.viewController;
    

    self.programViewController = [[ProgramViewController alloc] initWithNibName:@"ProgramViewController" bundle:nil];
    self.centerViewController = [[UINavigationController alloc] initWithRootViewController:self.programViewController];
    
    self.categoryViewController = [[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
    
    IIViewDeckController* deckController = [[IIViewDeckController alloc] initWithCenterViewController:self.centerViewController leftViewController:self.categoryViewController rightViewController:self.viewController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        deckController.leftLedge = 300;
        deckController.rightLedge = 300;
    }
    else {
        deckController.leftLedge = 150;
        deckController.rightLedge = 150;
    }
    
    
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
