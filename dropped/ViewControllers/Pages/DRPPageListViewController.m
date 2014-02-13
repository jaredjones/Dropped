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
#import "DRPCollectionDataItem.h"
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
    __block DRPPageListViewController *wkSelf = self;
    self.dataSource.reloadData = ^(void (^completion)(NSArray *)) {
        [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        
            NSMutableArray *dataItems = [[NSMutableArray alloc] init];
            
            for (GKTurnBasedMatch *gkMatch in matches) {
                // Ran into invalid matches occassonally during testing
                // that couldn't be removed from GC. Don't show them here,
                // they're annoying
                if (![DRPGameCenterInterface gkMatchIsValid:gkMatch]) {
                    continue;
                }
                
                if (![wkSelf.dataSource dataItemForID:gkMatch.matchID]) {
                    [dataItems addObject:({
                        DRPCollectionDataItem *dataItem = [[DRPCollectionDataItem alloc] init];
                        dataItem.itemID = gkMatch.matchID;
                        dataItem.userData = [[DRPMatch alloc] initWithGKMatch:gkMatch];
                        dataItem.cellIdentifier = @"matchCell";
                        dataItem.selected = ^(DRPMatch *match) {
                            [wkSelf.mainViewController setCurrentPageID:DRPPageMatch animated:YES userInfo:@{@"match" : match}];
                        };
                        dataItem;
                    })];
                }
            }
            
            completion(dataItems);
        }];
    };
}

- (void)registerCellIdentifiers
{
    [self.scrollView registerClass:[DRPMatchCollectionViewCell class] forCellWithReuseIdentifier:@"matchCell"];
}

#pragma mark Game Center Notifications

- (void)receivedRemoteGameCenterTurn:(NSNotification *)notification
{
    // This check is to prevent reloadMatchDataWithCompletion: from being called twice
    if (![self.mainViewController isCurrentPage:self]) return;
    
    GKTurnBasedMatch *gkMatch = notification.userInfo[@"gkMatch"];
    DRPMatch *match = [self.dataSource dataItemForID:gkMatch.matchID].userData;
    if (!match) return;

    // TODO: is this getting called twice? Definitely check
    [self.dataSource reloadDataForCollectionView:self.scrollView];
}

@end
