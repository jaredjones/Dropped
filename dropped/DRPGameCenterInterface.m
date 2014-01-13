//
//  DRPGameCenterInterface.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPGameCenterInterface.h"
#import "DRPLocalPlayerListener.h"
#import <GameKit/GameKit.h>

// Store the localPlayerID after authenticating
// to determine when a different  Game Center
// account logs in while Dropped is in background
static NSString *localPlayerID;
static UIViewController *authenticationViewController;

@implementation DRPGameCenterInterface

+ (void)authenticateLocalPlayer
{
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if (viewController != nil) {
            // User not authenticated, make sure they sign in
            if (localPlayerID) {
                // User logged out while app running
            } else {
                // New launch, user not logged in
            }
            
            authenticationViewController = viewController;
            
        } else if (localPlayer.authenticated) {
            // DEBUG: Kill all Game Center matches when authenticating.
            // Trust me, super handy during testing.
            [self killAllGameCenterMatches];
            
            if (localPlayerID && ![localPlayer.playerID isEqualToString:localPlayerID]) {
                // Different user logged in
            }
            
            localPlayerID = localPlayer.playerID;
            [[NSNotificationCenter defaultCenter] postNotificationName:DRPGameCenterLocalPlayerAuthenticatedNotificationName
                                                                object:nil];
            
        } else {
            NSLog(@"%@", error);
            authenticationViewController = nil;
        }
    };
    
    [localPlayer registerListener:[[DRPLocalPlayerListener alloc] init]];
}

+ (UIViewController *)authenticationViewController
{
    return authenticationViewController;
}

+ (void)killAllGameCenterMatches
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        for (GKTurnBasedMatch *match in matches) {
            
            for (GKTurnBasedParticipant *participant in match.participants) {
                participant.matchOutcome = GKTurnBasedMatchOutcomeQuit;
            }
            
            [match endMatchInTurnWithMatchData:[[NSData alloc] init] completionHandler:^(NSError *error) {
                [match removeWithCompletionHandler:^(NSError *error) {
                }];
            }];
        }
        
        NSLog(@"DEBUG: quit %ld %@", (long)matches.count, matches.count == 1 ? @"match" : @"matches");
    }];
}

@end
