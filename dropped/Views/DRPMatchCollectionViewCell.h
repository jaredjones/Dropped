//
//  DRPMatchCollectionViewCell.h
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRPMatch;

typedef NS_ENUM(NSInteger, DRPMatchCellState) {
    DRPMatchCellStatePlayer1Active,
    DRPMatchCellStatePlayer2Active,
    DRPMatchCellStatePlayer1Won,
    DRPMatchCellStatePlayer2Won,
    DRPMatchCellStatePlayer2Declined
};

@interface DRPMatchCollectionViewCell : UICollectionViewCell

- (void)configureWithMatch:(DRPMatch *)match;

@end
