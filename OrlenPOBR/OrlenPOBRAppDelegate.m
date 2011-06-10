//
//  OrlenPOBRAppDelegate.m
//  OrlenPOBR
//
//  Created by Mapedd on 11-05-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrlenPOBRAppDelegate.h"

#import "MainViewController.h"





@implementation OrlenPOBRAppDelegate


@synthesize window=_window;

@synthesize mainViewController=_mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the main view controller's view to the window and display.
    
    // 4.x property
    if ([self.window respondsToSelector:@selector(setRootViewController:)]) {
        [self.window setRootViewController:self.mainViewController];
    } else {
        [self.window addSubview:self.mainViewController.view];
    }
    
    NSString *appIdentifier = [[NSString alloc] initWithFormat:@"d5ca658347224e3753619ca825b71ead"];
    
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:appIdentifier];
    [BWHockeyManager sharedHockeyManager].delegate = self;
    
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:appIdentifier];
    [BWQuincyManager sharedQuincyManager].feedbackActivated = YES;
    [BWQuincyManager sharedQuincyManager].delegate = self;

    [appIdentifier release];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_mainViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark BWHockeyControllerDelegate

- (void)connectionOpened {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"connection opened");
}

- (void)connectionClosed {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"connection closed");
}


#pragma mark -
#pragma mark BWQuincyControllerDelegate


// Return the userid the crashreport should contain, empty by default
-(NSString *) crashReportUserID{
    
    return [NSString stringWithFormat:@"crashReportUserID"];
}

// Return the contact value (e.g. email) the crashreport should contain, empty by default
-(NSString *) crashReportContact{
    
    return [NSString stringWithFormat:@"crashReportContact"];
}

// Return the description the crashreport should contain, empty by default
-(NSString *) crashReportDescription{
    
    return [NSString stringWithFormat:@"crashReportDescription"];
}


@end
