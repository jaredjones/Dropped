//
//  DRPAppDelegate.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPAppDelegate.h"
#import "DRPMainViewController.h"
#import "DRPGameCenterInterface.h"
#import "FRBSwatchist.h"

#import "DRPDictionary.h"
#import "TestFlight.h"

@interface DRPAppDelegate ()

@property DRPMainViewController *mainViewController;

@end

@implementation DRPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srandomdev();
    
    [DRPGameCenterInterface authenticateLocalPlayer];
    [self loadSwatches];
 
    [DRPDictionary syncDictionary];
 
    [TestFlight takeOff:@"e04eea5f-3c76-4cc7-a01d-79f12d9fa6ad"];
    
    _mainViewController = [[DRPMainViewController alloc] initWithNibName:nil bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _mainViewController;
    
    [UIApplication sharedApplication].statusBarHidden = YES;
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

#pragma mark Swatches

- (void)loadSwatches
{
    NSArray *swatches = @[@"animation", @"board", @"colors", @"debug", @"list", @"page", @"tileOffset", @"tileScalingOffset"];
    for (NSString *swatch in swatches) {
        [self loadSwatchNamed:swatch];
    }
}

- (void)loadSwatchNamed:(NSString *)name
{
    [FRBSwatchist loadSwatch:[[NSBundle mainBundle] URLForResource:name withExtension:@"plist" subdirectory:@"Swatches"]
                     forName:name];
}

@end
