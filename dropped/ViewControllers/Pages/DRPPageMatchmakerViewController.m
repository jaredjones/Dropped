//
//  DRPPageMatchmakerViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageMatchmakerViewController.h"
#import "DRPMainViewController.h"
#import <GameKit/GameKit.h>

@interface DRPPageMatchmakerViewController ()

@end

@implementation DRPPageMatchmakerViewController

- (id)init
{
    self = [super initWithPageID:DRPPageMatchMaker];
    if (self) {
    }
    return self;
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    // Create new GKTurnBasedMatchMakerViewController
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    request.defaultNumberOfPlayers = 2;
    
    GKTurnBasedMatchmakerViewController *gkMatchmakerViewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    gkMatchmakerViewController.turnBasedMatchmakerDelegate = self;
    [self presentViewController:gkMatchmakerViewController animated:YES completion:nil];
}

#pragma mark GKTurnBasedMatchMakerViewControllerDelegate

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
    
}

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.mainViewController setCurrentPageID:DRPPageList animated:YES userInfo:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    
}

@end
