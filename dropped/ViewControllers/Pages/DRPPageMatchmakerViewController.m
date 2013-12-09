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
        self.view.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

#pragma mark DRPPageViewController

- (void)didMoveToCurrent
{
    // Create new GKTurnBasedMatchMakerViewController
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    request.defaultNumberOfPlayers = 2;
    
    GKTurnBasedMatchmakerViewController *gkMatchMakerViewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    [gkMatchMakerViewController willMoveToParentViewController:self];
    // matchmaker must be presented modally
}

@end
