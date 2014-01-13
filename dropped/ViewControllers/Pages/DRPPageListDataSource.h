//
//  DRPPageListDataSource.h
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPMatch;

@interface DRPPageListDataSource : NSObject <UICollectionViewDataSource>

- (void)reloadMatchesWithCompletion:(void (^)())completion;
- (DRPMatch *)matchForIndexPath:(NSIndexPath *)indexPath;

@end
