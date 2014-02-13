//
//  DRPCollectionViewLayout.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPCollectionViewLayout.h"
#import "FRBSwatchist.h"

@implementation DRPCollectionViewLayout

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = [super collectionViewContentSize];
    contentSize.height = MAX(self.collectionView.bounds.size.height + 0.5, contentSize.height);
    return contentSize;
}

- (void)recalculateSectionInsetsWithCollectionView:(UICollectionView *)collectionView cellCount:(NSInteger)cellCount
{
    CGSize itemSize = [FRBSwatchist sizeForKey:@"list.itemSize"];
    CGFloat itemSpacing = [FRBSwatchist floatForKey:@"list.lineSpacing"];
    CGFloat inset = [FRBSwatchist floatForKey:@"list.sectionInset"];
    
    CGFloat height = itemSize.height * cellCount + itemSpacing * (cellCount - 1);
    if (cellCount && height - 2 * inset < collectionView.bounds.size.height) {
        self.sectionInset = UIEdgeInsetsMake((collectionView.bounds.size.height - height) / 2, 0,
                                             (collectionView.bounds.size.height - height) / 2, 0);
    } else {
        self.sectionInset = UIEdgeInsetsMake(inset, 0, inset, 0);
    }
}

@end
