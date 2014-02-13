//
//  DRPCollectionViewDataSource.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPCollectionViewDataSource.h"
#import "DRPMatch.h"
#import "DRPMatchCollectionViewCell.h"
#import "DRPGameCenterInterface.h"
#import <GameKit/GameKit.h>

@interface DRPCollectionViewDataSource ()

@property NSMutableArray *matches;
@property NSMutableSet *loadedMatchIDs;

@end

@implementation DRPCollectionViewDataSource

- (id)init
{
    self = [super init];
    if (self) {
        self.matches = [[NSMutableArray alloc] init];
        self.loadedMatchIDs = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            if ([self.loadedMatchIDs containsObject:gkMatch.matchID]) {
                continue;
            }
            
            [self.matches addObject:[[DRPMatch alloc] initWithGKMatch:gkMatch]];
            [self.loadedMatchIDs addObject:gkMatch.matchID];
        }
        
        // TODO: sort matches
        
        if (completion) {
            completion();
        }
    }];
}

- (DRPMatch *)matchForIndexPath:(NSIndexPath *)indexPath
{
    return self.matches[indexPath.row];
}

- (DRPMatch *)matchForMatchID:(NSString *)matchID
{
    if (![self.loadedMatchIDs containsObject:matchID]) return nil;
    
    for (DRPMatch *match in self.matches) {
        if ([match.matchID isEqualToString:matchID]) {
            return match;
        }
    }
    
    return nil;
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRPMatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell configureWithMatch:[self matchForIndexPath:indexPath]];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.matches.count;
}

@end
