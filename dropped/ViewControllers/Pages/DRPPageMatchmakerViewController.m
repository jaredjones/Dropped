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
    [DRPMatch newMatchWithCompletion:^(DRPMatch *match) {
        if (match) {
            [self.mainViewController setCurrentPageID:DRPPageMatch animated:YES userInfo:@{@"match" : match}];
            
        } else {
            NSLog(@"error starting match");
        }
    }];
}

@end
