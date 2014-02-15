//
//  DRPPageMatchmakerViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageMatchmakerViewController.h"
#import "DRPMainViewController.h"

#import "DRPCollectionViewDataSource.h"
#import "DRPCollectionDataItem.h"
#import "DRPCharacter.h"
#import "DRPMenuCollectionViewCell.h"

#import "DRPMatch.h"
#import <GameKit/GameKit.h>

@interface DRPPageMatchmakerViewController ()

@end

@implementation DRPPageMatchmakerViewController

- (id)init
{
    self = [super initWithPageID:DRPPageMatchMaker];
    if (self) {
        self.bottomCue = @"Back";
    }
    return self;
}

#pragma mark DRPPageViewController

- (void)initDataSource
{
    [self.dataSource loadData:^NSArray *{
        return @[({
            DRPCollectionDataItem *dataItem = [[DRPCollectionDataItem alloc] init];
            dataItem.itemID = @"Multiplayer";
            dataItem.cellIdentifier = @"menuCell";
            dataItem.userData = @{@"color" : @(DRPColorBlue), @"text" : @"Multiplayer"};
            dataItem.selected = ^(id userData){
                [self requestMatch];
            };
            dataItem;
        }), ({
            DRPCollectionDataItem *dataItem = [[DRPCollectionDataItem alloc] init];
            dataItem.itemID = @"Single Player";
            dataItem.cellIdentifier = @"menuCell";
            dataItem.userData = @{@"color" : @(DRPColorGreen), @"text" : @"Single Player"};
            dataItem;
        }), ({
            DRPCollectionDataItem *dataItem = [[DRPCollectionDataItem alloc] init];
            dataItem.itemID = @"Daily Challenge";
            dataItem.cellIdentifier = @"menuCell";
            dataItem.userData = @{@"color" : @(DRPColorYellow), @"text" : @"Daily Challenge"};
            dataItem;
        })];
    }];
}

- (void)registerCellIdentifiers
{
    [self.scrollView registerClass:[DRPMenuCollectionViewCell class] forCellWithReuseIdentifier:@"menuCell"];
}

- (void)requestMatch
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

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)gkMatch
{
    DRPMatch *match = [[DRPMatch alloc] initWithGKMatch:gkMatch];
    [self.mainViewController setCurrentPageID:DRPPageMatch animated:YES userInfo:@{@"match" : match}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self.mainViewController setCurrentPageID:DRPPageList animated:YES userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    // The GKTurnBasedMatchmakerViewController doesn't show existing matches,
    // so this delegate method will never be called
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self.mainViewController setCurrentPageID:DRPPageList animated:YES userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
