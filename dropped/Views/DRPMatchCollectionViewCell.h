//
//  DRPMatchCollectionViewCell.h
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPCollectionViewCell.h"

@class DRPMatch;

// CellState is just an enum that makes it easy to figure out
// how to display a given match. DRPMatchCellState is trivial
// to compute given a DRPMatch
typedef NS_ENUM(NSInteger, DRPMatchCellState) {
    DRPMatchCellStatePlayer1Active,
    DRPMatchCellStatePlayer2Active,
    DRPMatchCellStatePlayer1Won,
    DRPMatchCellStatePlayer2Won,
    DRPMatchCellStateTie,
    DRPMatchCellStatePlayer2Declined
};

@interface DRPMatchCollectionViewCell : DRPCollectionViewCell

//- (void)configureWithMatch:(DRPMatch *)match;

@end
