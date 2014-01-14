//
//  DRPPageListDataSource.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPPageListDataSource.h"
#import "DRPMatch.h"
#import "DRPMatchCollectionViewCell.h"
#import "DRPGameCenterInterface.h"
#import <GameKit/GameKit.h>

@interface DRPPageListDataSource ()

@property NSMutableArray *matches;
@property NSMutableSet *loadedMatchIDs;

@end

@implementation DRPPageListDataSource

- (id)init
{
    self = [super init];
    if (self) {
        _matches = [[NSMutableArray alloc] init];
        _loadedMatchIDs = [[NSMutableSet alloc] init];
    }
    
    return self;
}

#pragma mark Data

- (void)reloadMatchesWithCompletion:(void (^)())completion
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        
        for (GKTurnBasedMatch *gkMatch in matches) {
            
            // Ran into invalid matches occassonally during testing
            // that couldn't be removed from GC. Don't show them here,
            // they're annoying
            if (![DRPGameCenterInterface gkMatchIsValid:gkMatch]) {
                continue;
            }
            
            // Don't reload matches already loaded
            if ([_loadedMatchIDs containsObject:gkMatch.matchID]) {
                continue;
            }
            
            [_matches addObject:[[DRPMatch alloc] initWithGKMatch:gkMatch]];
            [_loadedMatchIDs addObject:gkMatch.matchID];
        }
        
        // TODO: sort matches
        
        if (completion) {
            completion();
        }
    }];
}

- (DRPMatch *)matchForIndexPath:(NSIndexPath *)indexPath
{
    return _matches[indexPath.row];
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRPMatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    [cell configureWithMatch:[self matchForIndexPath:indexPath]];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _matches.count;
}

@end
