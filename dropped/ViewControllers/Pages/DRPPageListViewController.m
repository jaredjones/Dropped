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

#import "DRPMatchCollectionViewCell.h"
#import "DRPMatch.h"

#import "DRPNetworking.h"
#import "FRBSwatchist.h"

@interface DRPPageListViewController ()

@end

@implementation DRPPageListViewController

- (instancetype)init
{
    self = [super initWithPageID:DRPPageList];
    if (self) {
        self.topCue = @"Pull for New Game";
        self.bottomCue = @"Et Cetera";
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
        
        [[DRPNetworking sharedNetworking] currentMatchIDsWithCompletion:^(NSArray *matchIDs) {
            
            // Accumulate new DRPMatches in dataItems
            // Once all are loaded, call the compltion handler
            NSMutableArray *dataItems = [[NSMutableArray alloc] init];
            __block NSInteger dataResponsesReceived = 0;
            
            // This block is called every time a response is received from DRPNetworking
            // When a response has been received from every matchID
            void (^matchDataResponseReceived)() = ^{
                dataResponsesReceived += 1;
                if (dataItems.count >= matchIDs.count) {
                    completion(dataItems);
                }
            };
            
            for (NSString *matchID in matchIDs) {
                DRPCollectionDataItem *dataItem = [wkSelf.dataSource dataItemForID:matchID];
                
                if (dataItem) {
                    // Match is already in the list, refresh the data
                    [dataItems addObject:dataItem];
                    [(DRPMatch *)dataItem.userData reloadMatchDataWithCompletion:^(BOOL newTurns) {
                        matchDataResponseReceived();
                    }];
                    
                } else {
                    // MatchID is not in the list, create a new dataItem
                    [dataItems addObject:({
                        
                        DRPCollectionDataItem *dataItem = [[DRPCollectionDataItem alloc] init];
                        dataItem.itemID = matchID;
                        dataItem.cellIdentifier = @"matchCell";
                        
                        // matchData loading is asynchronous
                        [DRPMatch matchWithMatchID:matchID completion:^(DRPMatch *match) {
                            
                            dataItem.userData = match;
                            matchDataResponseReceived();
                        }];
                        
                        // Go to DRPPageMatch when the dataItem is selected
                        dataItem.selected = ^(DRPMatch *match) {
                            if (match) {
                                [wkSelf.mainViewController setCurrentPageID:DRPPageMatch animated:YES userInfo:@{@"match" : match}];
                            }
                        };
                        
                        dataItem;
                    })];
                }
            }
        }];
    };
}

- (void)registerCellIdentifiers
{
    [self.scrollView registerClass:[DRPMatchCollectionViewCell class] forCellWithReuseIdentifier:@"matchCell"];
}

@end
