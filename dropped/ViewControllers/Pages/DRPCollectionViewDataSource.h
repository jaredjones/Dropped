//
//  DRPCollectionViewDataSource.h
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPCollectionDataItem;

@interface DRPCollectionViewDataSource : NSObject <UICollectionViewDataSource>

// The reloadData block is responsible for building an array of DRPCollectionDataItems
// When it's done, it simply calls the passed in completion handler with the built array
// This needs to happen asynchronously because the data is often fetched from the server
@property (copy) void (^reloadData)(void (^completion)(NSArray *dataItems));

// Supplied to use custom sorting for the dataSource
@property (copy) NSComparator comparator;

- (void)loadData:(NSArray *(^)())loadData;
- (void)reloadDataForCollectionView:(UICollectionView *)collectionView;

- (DRPCollectionDataItem *)dataItemForIndexPath:(NSIndexPath *)indexPath;
- (DRPCollectionDataItem *)dataItemForID:(NSString *)dataItemID;
- (NSArray *)filterNewDataItemIDs:(NSArray *)dataItemIDs;

@end
