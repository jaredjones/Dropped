//
//  DRPAppDelegate.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPAppDelegate.h"
#import "DRPMainViewController.h"
#import "FRBSwatchist.h"

#import <GameKit/GameKit.h>

@interface DRPAppDelegate ()

// Store the localPlayerID after authenticating
// to determine when a different  Game Center
// account logs in while Dropped is in background
@property NSString *localPlayerID;

@end

@implementation DRPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self authenticateLocalPlayer];
    [self loadSwatches];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[DRPMainViewController alloc] initWithNibName:nil bundle:nil];
    
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
    [FRBSwatchist loadSwatch:[[NSBundle mainBundle] URLForResource:@"animation" withExtension:@"plist" subdirectory:@"Swatches"]
                     forName:@"animation"];
}

#pragma mark Game Center

- (void)authenticateLocalPlayer
{
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if (viewController != nil) {
            // User not authenticated, make sure they sign in
            if (_localPlayerID) {
                // User logged out while app running
            } else {
                // New launch, user not logged in
            }
        } else if (localPlayer.authenticated) {
            // DEBUG: Kill all Game Center matches when authenticating.
            // Trust me, super handy during testing.
            [self killAllGameCenterMatches];
            
            if (_localPlayerID && ![localPlayer.playerID isEqualToString:_localPlayerID]) {
                // Different user logged in
            }
            
            _localPlayerID = localPlayer.playerID;
        }
    };
}

- (void)killAllGameCenterMatches
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        for (GKTurnBasedMatch *match in matches) {
            [match endMatchInTurnWithMatchData:nil completionHandler:^(NSError *error) {
                [match removeWithCompletionHandler:nil];
            }];
        }
    }];
}

@end
