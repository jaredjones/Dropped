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

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(oldBounds) != CGRectGetWidth(newBounds)) {
        NSLog(@"aw yiss");
        return YES;
    }
        
    return NO;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *newAttributes = [[NSMutableArray alloc] init];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        [newAttributes addObject:[self layoutAttributesForItemAtIndexPath:attribute.indexPath]];
    }
    
    return newAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *currentAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    currentAttributes.center = ({
        CGPoint center = currentAttributes.center;
        center.y += [self cellOffset];
        center;
    });
    return currentAttributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
}

- (CGFloat)cellOffset
{
    NSInteger cellCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    CGFloat height = self.itemSize.height * cellCount + self.minimumLineSpacing * (cellCount - 1);
    CGFloat offset = 0;
    
    if (cellCount && height < self.collectionView.bounds.size.height - (self.sectionInset.top + self.sectionInset.bottom)) {
        offset = (self.collectionView.bounds.size.height - height) / 2 - self.sectionInset.top;
    }
    return offset;
}

@end
