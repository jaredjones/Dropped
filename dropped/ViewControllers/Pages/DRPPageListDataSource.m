//
//  DRPPageListDataSource.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPPageListDataSource.h"
#import <GameKit/GameKit.h>

@interface DRPPageListDataSource ()

@property NSMutableArray *matches;

@end

@implementation DRPPageListDataSource

#pragma mark Data

- (void)reloadMatchesWithCompletion:(void (^)())completion
{
}

- (DRPMatch *)matchForIndexPath:(NSIndexPath *)indexPath
{
    return _matches[indexPath.row];
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _matches.count;
}

@end
