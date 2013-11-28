//
//  DRPAppDelegate.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPAppDelegate.h"
#import "DRPDictionary.h"

#import "DRPMatch.h"
#import "DRPBoard.h"
#import "DRPPosition.h"

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
//    DRPMatch *m = [[DRPMatch alloc] initWithGKMatch:nil];
//    NSArray *move = @[[DRPPosition positionWithI:5 j:5],
//                      [DRPPosition positionWithI:4 j:5],
//                      [DRPPosition positionWithI:4 j:4],
//                      [DRPPosition positionWithI:4 j:3],
//                      [DRPPosition positionWithI:0 j:3],
//                      [DRPPosition positionWithI:2 j:3],
//                      [DRPPosition positionWithI:1 j:3]];
//    [m.board appendMoveForPositions:move];
//    NSLog(@"%@", m.board.matchData);
    
    [self authenticateLocalPlayer];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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
            self.window.rootViewController = viewController;
        } else if (localPlayer.authenticated) {
            if (_localPlayerID && ![localPlayer.playerID isEqualToString:_localPlayerID]) {
                // Different user logged in
            }
            
            _localPlayerID = localPlayer.playerID;
        }
    };
}

@end
