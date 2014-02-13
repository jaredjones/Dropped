//
//  DRPCollectionViewDataSource.h
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPMatch;

// TODO: DRPDataItem
//      - cellIdentifier
//          - The cell will know how to configure itself with the userData
//      - (id)userData
//      - void (^selected)(DRPPageCollectionViewController *)

// TODO: loadInitialData/reloadData blocks (make them the same for the match list) (pass in the UICollectionView for reordering)

@interface DRPCollectionViewDataSource : NSObject <UICollectionViewDataSource>

- (void)reloadMatchesWithCompletion:(void (^)())completion;
- (DRPMatch *)matchForIndexPath:(NSIndexPath *)indexPath;
- (DRPMatch *)matchForMatchID:(NSString *)matchID;

@end
