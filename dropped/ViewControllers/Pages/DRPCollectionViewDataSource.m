
//  DRPCollectionViewDataSource.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPCollectionViewDataSource.h"
#import "DRPCollectionDataItem.h"
#import "DRPCollectionViewCell.h"

#import "DRPMatch.h"
#import "DRPGameCenterInterface.h"
#import <GameKit/GameKit.h>

@interface DRPCollectionViewDataSource ()

@property NSMutableArray *dataItems;
@property NSMutableSet *dataItemIDs;

@end

@implementation DRPCollectionViewDataSource

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Data

- (void)resetDataItems:(NSArray *)dataItems
{
    self.dataItemIDs = [[NSMutableSet alloc] init];
    self.dataItems = [dataItems mutableCopy];
    
    for (DRPCollectionDataItem *dataItem in self.dataItems) {
        [self.dataItemIDs addObject:dataItem.itemID];
    }
    
}

- (void)loadData:(NSArray *(^)())loadData
{
    [self resetDataItems:loadData()];
}

- (void)reloadDataForCollectionView:(UICollectionView *)collectionView
{
    if (!self.reloadData) return;
    
    // tmp, clear the cache each time data is reloaded
    self.dataItemIDs = nil;
    
    self.reloadData(^(NSArray *newDataItems) {
        if (!newDataItems) return;
        
        // Sorting
        if (self.comparator) {
            newDataItems = [newDataItems sortedArrayUsingComparator:self.comparator];
        }
        
        [self resetDataItems:newDataItems];
        
        // Perform batch operation on collectionView
        [collectionView reloadData];
    });
}

- (DRPCollectionDataItem *)dataItemForIndexPath:(NSIndexPath *)indexPath
{
    return self.dataItems[indexPath.row];
}

- (DRPCollectionDataItem *)dataItemForID:(NSString *)dataItemID
{
    if (![self.dataItemIDs containsObject:dataItemID]) return nil;
    
    for (DRPCollectionDataItem *dataItem in self.dataItems) {
        if ([dataItem.itemID isEqualToString:dataItemID]) {
            return dataItem;
        }
    }
    
    return nil;
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRPCollectionDataItem *dataItem = [self dataItemForIndexPath:indexPath];
    
    DRPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:dataItem.cellIdentifier forIndexPath:indexPath];
    [cell configureWithUserData:dataItem.userData];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataItems.count;
}

@end
