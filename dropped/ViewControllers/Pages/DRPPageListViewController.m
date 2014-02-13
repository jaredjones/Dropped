//
//  DRPPageListViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageListViewController.h"
#import "DRPMainViewController.h"

#import "DRPCollectionViewDataSource.h"
#import "DRPCollectionViewLayout.h"

#import "DRPMatchCollectionViewCell.h"
#import "DRPMatch.h"

#import "DRPGameCenterInterface.h"
#import "FRBSwatchist.h"

@interface DRPPageListViewController ()

@property UICollectionView *scrollView;
@property DRPCollectionViewDataSource *dataSource;
@property DRPCollectionViewLayout *layout;

@end

@implementation DRPPageListViewController

- (instancetype)init
{
    self = [super initWithPageID:DRPPageList];
    if (self) {
        self.topCue = @"Pull for New Game";
        self.bottomCue = @"Et Cetera";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedRemoteGameCenterTurn:)
                                                     name:DRPGameCenterReceivedRemoteTurnNotificationName
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Loading

- (void)initDataSource
{
    
}

- (void)registerCellIdentifiers
{
    [self.scrollView registerClass:[DRPMatchCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRPMatch *match = [self.dataSource matchForIndexPath:indexPath];
    if (!match) return;
    
    [self.mainViewController setCurrentPageID:DRPPageMatch animated:YES userInfo:@{@"match" : match}];
}

#pragma mark Game Center Notifications

- (void)receivedRemoteGameCenterTurn:(NSNotification *)notification
{
    // This check is to prevent reloadMatchDataWithCompletion: from being called twice
    if (![self.mainViewController isCurrentPage:self]) return;
    
    GKTurnBasedMatch *gkMatch = notification.userInfo[@"gkMatch"];
    DRPMatch *match = [self.dataSource matchForMatchID:gkMatch.matchID];
    if (!match) return;
    
    // TODO: is this getting called twice? Definitely check
    [match reloadMatchDataWithCompletion:^(BOOL newTurns) {
        // TODO: ugh, this is a bad way to update the cells
        [self.scrollView reloadData];
    }];
}

@end
