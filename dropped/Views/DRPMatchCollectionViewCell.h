//
//  DRPMatchCollectionViewCell.h
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRPMatch;

@interface DRPMatchCollectionViewCell : UICollectionViewCell

// tmp
@property (readonly) UILabel *label;

- (void)configureWithMatch:(DRPMatch *)match;

@end
