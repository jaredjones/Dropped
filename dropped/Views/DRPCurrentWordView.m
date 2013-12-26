//
//  DRPCurrentWordView.m
//  dropped
//
//  Created by Brad Zeis on 12/25/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCurrentWordView.h"
#import "DRPCharacter.h"
#import "DRPTileView.h"
#import "DRPBoardViewController.h"
#import "FRBSwatchist.h"

@interface DRPCurrentWordView ()

@property NSMutableArray *tiles;

@property CGFloat wordWidth;

@end

@implementation DRPCurrentWordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        _tiles = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterAddedToCurrentWord:(DRPCharacter *)character
{
    DRPTileView *tile = [DRPTileView dequeueResusableTile];
    tile.selected = NO;
    tile.highlighted = NO;
    tile.character = character;
    tile.backgroundColor = [UIColor clearColor];
    tile.transform = CGAffineTransformIdentity;
    tile.center = [self centerForNewTile:tile];
    [_tiles addObject:tile];
    [self addSubview:tile];
    
    [self repositionTiles];
}

- (void)characterRemovedFromCurrentWord:(DRPCharacter *)character
{
    DRPTileView *removedTile = [self tileForCharacter:character];
    
    if (removedTile) {
        [removedTile removeFromSuperview];
        [_tiles removeObject:removedTile];
        [self repositionTiles];
    }
}

- (void)removeAllCharactersFromCurrentWord
{
    [_tiles removeAllObjects];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    _wordWidth = 0;
}

- (DRPTileView *)tileForCharacter:(DRPCharacter *)character
{
    NSInteger i = [_tiles indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if (((DRPTileView *)obj).character == character) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (i != NSNotFound) return _tiles[i];
    return nil;
}

#pragma mark Repositioning

- (void)repositionTiles
{
    CGPoint *centers = [self tileCenters];
    
    [UIView animateWithDuration:[FRBSwatchist floatForKey:@"animation.currentWordManipulationDuration"] animations:^{
        for (NSInteger i = 0; i < _tiles.count; i++) {
            ((UIView *)_tiles[i]).center = centers[i];
        }
    }];
    
    free(centers);
}

- (CGPoint *)tileCenters
{
    CGPoint *centers = malloc(sizeof(CGPoint) * _tiles.count);
    
    _wordWidth = 0;
    CGFloat letterSpacing = [FRBSwatchist floatForKey:@"page.matchCurrentWordLetterSpacing"];
    
    // Initial Spacing
    for (NSInteger i = 0; i < _tiles.count; i++) {
        DRPTileView *tile = _tiles[i];
        CGFloat advancement = [DRPTileView advancementForCharacter:tile.character.character];
        centers[i] = CGPointMake(_wordWidth + advancement / 2, 25);
        _wordWidth += advancement + letterSpacing;
    }
    
    // Recenter entire word
    CGFloat offset = self.frame.size.width / 2 - _wordWidth / 2;
    for (NSInteger i = 0; i < _tiles.count; i++) {
        centers[i].x = centers[i].x + offset;
    }
    
    return centers;
}

- (CGPoint)centerForNewTile:(DRPTileView *)tile
{
    // Ignore advancement when the first letter is being added
    CGFloat tileWidth = _wordWidth > 0 ? tile.frame.size.width : 0;
    CGFloat letterSpacing = [FRBSwatchist floatForKey:@"page.matchCurrentWordLetterSpacing"];
    letterSpacing = _wordWidth > 0 ? letterSpacing : -letterSpacing;
    return CGPointMake((self.frame.size.width + _wordWidth + tileWidth + letterSpacing) / 2, 25);
}

@end
