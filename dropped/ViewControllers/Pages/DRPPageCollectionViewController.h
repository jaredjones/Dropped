//
//  DRPPageCollectionViewController.h
//  Dropped
//
//  Created by Brad Zeis on 2/13/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPPageViewController.h"

@class DRPCollectionViewDataSource;

@interface DRPPageCollectionViewController : DRPPageViewController <UICollectionViewDelegate>

@property (readonly) UICollectionView *scrollView;
@property (readonly) DRPCollectionViewDataSource *dataSource;

- (void)initDataSource;
- (void)registerCellIdentifiers;

@end
