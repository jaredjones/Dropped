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

@property CGFloat wordWidth, tileScale;

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
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:_panGestureRecognizer];
    }
    return self;
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterWasHighlighted:(DRPCharacter *)character
{
    DRPTileView *tile = [self tileForCharacter:character];
    
    if (!tile) {
        // Tile doesn't exist in the current word, add a new one to the end
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
        
    } else {
        [self bringSubviewToFront:tile];
        tile.selected = YES;
        tile.highlighted = YES;
        [tile resetAppearence];
    }
    
    [self repositionTiles];
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

- (CGPoint)centerForNewTile:(DRPTileView *)tile
{
    // Ignore advancement when the first letter is being added
    CGFloat tileWidth = _wordWidth > 0 ? tile.frame.size.width : 0;
    CGFloat letterSpacing = [FRBSwatchist floatForKey:@"page.matchCurrentWordLetterSpacing"];
    letterSpacing = _wordWidth > 0 ? letterSpacing : -letterSpacing;
    return CGPointMake((self.frame.size.width + _wordWidth + tileWidth + letterSpacing) / 2, 25);
}

- (void)repositionTiles
{
    CGPoint *centers = [self tileCenters];
    
    [UIView animateWithDuration:[FRBSwatchist floatForKey:@"animation.currentWordManipulationDuration"]
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
                     animations:^{
                         for (NSInteger i = 0; i < _tiles.count; i++) {
                             DRPTileView *tile = _tiles[i];
                             tile.center = centers[i];
                             if (tile.selected) {
                                 tile.transform = CGAffineTransformIdentity;
                             } else {
                                 tile.transform = CGAffineTransformMakeScale(_tileScale, _tileScale);
                             }
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
    _tileScale = 1;
    if (_wordWidth > self.frame.size.width) {
        _tileScale = self.frame.size.width / _wordWidth;
    }
    
    CGFloat offset = self.frame.size.width / 2 - _wordWidth / 2;
    
    for (NSInteger i = 0; i < _tiles.count; i++) {
        centers[i].x = 160 + (centers[i].x + offset - 160) * _tileScale;
    }
    
    return centers;
}

// Following two methods deal with the swipeclears
- (void)swipeAwayTilesWithVelocity:(CGFloat)velocity
{
    [_delegate currentWordViewSwiped];
    
    [self removeAllCharactersFromCurrentWord];
    self.center = CGPointMake(160, self.center.y);
}

- (void)snapBackTilesWithVelocity:(CGFloat)velocity
{
    self.center = CGPointMake(160, self.center.y);
}

#pragma mark Touch Events

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    [_delegate currentWordViewTapped];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        self.center = CGPointMake(160 + translation.x, self.center.y);
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [gesture velocityInView:self];
        
        if (fabs(velocity.x) > 100) {
            [self swipeAwayTilesWithVelocity:velocity.x];
        } else {
            [self snapBackTilesWithVelocity:velocity.x];
        }
    }
}

@end
