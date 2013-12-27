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
#import "DRPUtility.h"

@interface DRPCurrentWordView ()

@property NSMutableArray *tiles;

@property CGFloat wordWidth;

@property UITapGestureRecognizer *tapGestureRecognizer;
@property UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation DRPCurrentWordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tiles = [[NSMutableArray alloc] init];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    return self;
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterWasHighlighted:(DRPCharacter *)character
{
    DRPTileView *tile = [self tileForCharacter:character];
    if (!tile) {
        tile = [DRPTileView dequeueResusableTile];
        tile.scaleCharacter = NO;
        tile.enabled = NO;
        tile.selected = YES;
        tile.highlighted = YES;
        tile.character = character;
        tile.transform = CGAffineTransformIdentity;
        tile.center = [self centerForNewTile:tile];
        [_tiles addObject:tile];
        [self addSubview:tile];
        
        if (CGRectGetMaxX(tile.frame) > self.frame.size.width) {
            [self repositionTiles];
        }
        
    } else {
        [self bringSubviewToFront:tile];
        tile.selected = YES;
        tile.highlighted = YES;
        [tile resetAppearence];
        [self repositionTiles];
    }
}

- (void)characterWasDehighlighted:(DRPCharacter *)character
{
    DRPTileView *tile = [self tileForCharacter:character];
    tile.selected = NO;
    tile.highlighted = NO;
    [tile resetAppearence];
    tile.backgroundColor = [UIColor clearColor];
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

#pragma mark Repositioning Tiles

- (void)repositionTiles
{
    CGPoint *centers = [self tileCenters];
    
    [UIView animateWithDuration:[FRBSwatchist floatForKey:@"animation.currentWordManipulationDuration"]
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         for (NSInteger i = 0; i < _tiles.count; i++) {
                             ((UIView *)_tiles[i]).center = centers[i];
                         }
                     }
                     completion:nil];
    
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
        
        CGFloat advancement = tile.selected ? 50 : [DRPTileView advancementForCharacter:tile.character.character];
        centers[i] = CGPointMake(_wordWidth + advancement / 2, 25);
        _wordWidth += advancement + letterSpacing;
    }
    
    // Recenter entire word
    // Word is sometimes too long to fit. Favor right side of the word
    CGFloat offset = self.frame.size.width / 2 - _wordWidth / 2;
    if (_wordWidth > self.frame.size.width) {
        offset = self.frame.size.width - _wordWidth;
    }
    
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

#pragma mark Touch Events

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    [_delegate currentWordViewTapped];
}

@end
