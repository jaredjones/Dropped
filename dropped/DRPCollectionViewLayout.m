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

- (id)init
{
    self = [super init];
    if (self) {
        self.itemSize = [FRBSwatchist sizeForKey:@"list.itemSize"];
        self.minimumLineSpacing = [FRBSwatchist floatForKey:@"list.lineSpacing"];
        // Make sure there can only be a single cell in a row
        self.minimumInteritemSpacing = MAX(CGRectGetWidth([UIScreen mainScreen].applicationFrame),
                                           CGRectGetHeight([UIScreen mainScreen].applicationFrame));
        self.sectionInset = UIEdgeInsetsMake([FRBSwatchist floatForKey:@"list.sectionInset"], 0,
                                             [FRBSwatchist floatForKey:@"list.sectionInset"], 0);
    }
    return self;
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = [super collectionViewContentSize];
    contentSize.height = MAX(self.collectionView.bounds.size.height + 0.5, contentSize.height);
    return contentSize;
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
    return nil;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
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
