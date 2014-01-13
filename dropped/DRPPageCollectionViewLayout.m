//
//  DRPPageCollectionViewLayout.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPPageCollectionViewLayout.h"

@implementation DRPPageCollectionViewLayout

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = [super collectionViewContentSize];
    contentSize.height = MAX(self.collectionView.bounds.size.height + 0.5, contentSize.height);
    return contentSize;
}

@end
