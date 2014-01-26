//
//  DRPGameCenterInterface.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPGameCenterInterface.h"
#import "FRBSwatchist.h"

@interface DRPGameCenterInterface ()

// Store the localPlayerID after authenticating
// to determine when a different  Game Center
// account logs in while Dropped is in background
@property NSString *localPlayerID;
@property UIViewController *authenticationViewController;

@end

@implementation DRPGameCenterInterface

static DRPGameCenterInterface *sharedGameCenterInterface;
+ (instancetype)sharedInterface
{
    if (!sharedGameCenterInterface) {
        sharedGameCenterInterface = [[DRPGameCenterInterface alloc] init];
    }
    
    return sharedGameCenterInterface;
}

+ (void)authenticateLocalPlayer
{
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        
        // If viewController is non-nil, the user hasn't authenticated
        if (viewController != nil) {
            // User not authenticated, make sure they sign in
            if ([DRPGameCenterInterface sharedInterface].localPlayerID) {
                // User logged out while app running
            } else {
                // New launch, user not logged in
            }
            
            [DRPGameCenterInterface sharedInterface].authenticationViewController = viewController;
            
        } else if (localPlayer.authenticated) {
            // DEBUG: Kill all Game Center matches when authenticating.
            // Trust me, super handy during testing.
            if ([FRBSwatchist boolForKey:@"debug.removeGCMatchesOnStartup"]) {
                [self killAllGameCenterMatches];
            }
            
            if ([DRPGameCenterInterface sharedInterface].localPlayerID && ![localPlayer.playerID isEqualToString:[DRPGameCenterInterface sharedInterface].localPlayerID]) {
                // Different user logged in
            }
            
            [DRPGameCenterInterface sharedInterface].localPlayerID = localPlayer.playerID;
            
            [localPlayer unregisterAllListeners];
            [localPlayer registerListener:[DRPGameCenterInterface sharedInterface]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DRPGameCenterLocalPlayerAuthenticatedNotificationName
                                                                object:nil];
            
        } else {
            // Error, oops
            NSLog(@"%@", error);
            [DRPGameCenterInterface sharedInterface].authenticationViewController = nil;
        }
    };
}

+ (UIViewController *)authenticationViewController
{
    return [DRPGameCenterInterface sharedInterface].authenticationViewController;
}

#pragma mark GKLocalPlayerListener

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)gkMatch didBecomeActive:(BOOL)didBecomeActive
{
    NSLog(@"aw yiss");
    
    // This is where turn notifications are sent. Pretty big deal.
    if (![player.playerID isEqualToString:gkMatch.currentParticipant.playerID]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DRPGameCenterReceivedTurnEventNotificationName
                                                        object:nil
                                                      userInfo:@{@"gkMatch" : gkMatch}];
}

#pragma mark Debug

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

+ (BOOL)gkMatchIsValid:(GKTurnBasedMatch *)gkMatch
{
    return gkMatch.participants.count > 0;
}

@end
