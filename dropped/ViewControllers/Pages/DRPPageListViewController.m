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
            
            NSMutableArray *dataItems = [[NSMutableArray alloc] init];
            
            for (NSString *matchID in matchIDs) {
                if (![wkSelf.dataSource dataItemForID:matchID]) {
                    [dataItems addObject:({
                        DRPCollectionDataItem *dataItem = [[DRPCollectionDataItem alloc] init];
                        dataItem.itemID = matchID;
                        
                        dataItem.userData = nil; // TODO: load the match
                        
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

@end
