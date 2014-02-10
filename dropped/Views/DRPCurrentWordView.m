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

// Keeps track of the tiles currently animating (because they were recently added)
@property NSMutableSet *animatingTiles;

// Keeps track of the tiles currently running animations that should unselect when finished
@property NSMutableSet *unselectedTiles;

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
        _animatingTiles = [[NSMutableSet alloc] init];
        _unselectedTiles = [[NSMutableSet alloc] init];
        [self loadGestureRecognizers];
    }
    return self;
}

- (void)loadGestureRecognizers
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:_panGestureRecognizer];
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
        tile.center = [self centerForNewTile:tile];
        [_tiles addObject:tile];
        [self addSubview:tile];
        
    } else {
        tile.selected = YES;
        tile.highlighted = YES;
        [tile resetAppearence];
    }
    
    [self bringSubviewToFront:tile];
    [_animatingTiles addObject:tile];
    
    
    // There's a (very) visibly noticeable jump in the animation
    // when  the repositioning happens at the same time as adding
    // a dequeued tile. Delaying by a tiny amount fixes the problem.
    //
    // The source of the problem is UIViewAnimationOptionsBeginFromCurrentState
    // for repositioning animations (which should be the case). For some
    // reason the animation still thinks the center of the tile is in its
    // previous location.
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.001 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self repositionTilesAnimated:YES];
    });
}

- (void)characterWasDehighlighted:(DRPCharacter *)character
{
    DRPTileView *tile = [self tileForCharacter:character];
    
    if ([_animatingTiles containsObject:tile]) {
        [_unselectedTiles addObject:tile];
    } else {
        [self deselectTile:tile];
        [self repositionTilesAnimated:YES];
    }
}

- (void)deselectTile:(DRPTileView *)tile
{
    tile.selected = NO;
    tile.highlighted = NO;
    [tile resetAppearence];
    tile.backgroundColor = [UIColor clearColor];
}

- (void)characterWasRemoved:(DRPCharacter *)character
{
    DRPTileView *removedTile = [self tileForCharacter:character];
    
    if (removedTile) {
        [removedTile removeFromSuperview];
        [_tiles removeObject:removedTile];
        [self repositionTilesAnimated:YES];
        [DRPTileView queueReusableTile:removedTile];
    }
}

- (void)removeAllCharacters
{
    for (DRPTileView *tile in _tiles) {
        [tile removeFromSuperview];
        [DRPTileView queueReusableTile:tile];
    }
    [_tiles removeAllObjects];
    [_animatingTiles removeAllObjects];
    [_unselectedTiles removeAllObjects];
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

- (NSInteger)characterCount
{
    return _tiles.count;
}

#pragma mark Resetting Characters

- (void)setCharacters:(NSArray *)characters
{
    [self removeAllCharacters];
    
    for (DRPCharacter *character in characters) {
        DRPTileView *tile = [DRPTileView dequeueResusableTile];
        tile.scaleCharacter = NO;
        tile.enabled = NO;
        tile.character = character;
        [self deselectTile:tile];
        [_tiles addObject:tile];
        [self addSubview:tile];
    }
    
    [self repositionTilesAnimated:NO];
}

- (BOOL)currentCharactersEqualCharacters:(NSArray *)characters
{
    if (_tiles.count != characters.count) {
        return NO;
    }
    
    for (NSInteger i = 0; i < _tiles.count; i++) {
        if (((DRPTileView *)_tiles[i]).character != characters[i]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark Repositioning Tiles

// Animates repositioning of tiles in _tileContainer (from adding/removing/selecting a character)
- (void)repositionTilesAnimated:(BOOL)animated
{
    // This method _might_ be called a few too many times
    // It's called somewhat recursively, so it ends up being
    // called 2-3 times per character added to the word.
    // Don't freak out, it should be fine since the tiles
    // actually _need_ to reposition themselves that often.
    
    CGPoint *centers = [self tileCenters];
    
    if (animated) {
        // The animation is handled in a separate method because it's
        // a bit hairy. Gotta keep these methods small, yo
        [self animateTilesToCenters:centers];
        
    } else {
        for (NSInteger i = 0; i < _tiles.count; i++) {
            [self positionTile:_tiles[i] toCenter:centers[i]];
        }
    }
    
    free(centers);
}

- (void)animateTilesToCenters:(CGPoint *)centers
{
    // When a new tile is added before the last tile finishes its
    // animation, the old animations stop. We only want to run
    // the final [self repositionTilesAnimated:YES] when _all_ the
    // new tiles finish their initial animation
    NSInteger numberAnimatingTiles = _animatingTiles.count;
    __block NSInteger numberTilesFinished = 0;
    
    for (NSInteger i = 0; i < _tiles.count; i++) {
        DRPTileView *tile = _tiles[i];
        
        [UIView animateWithDuration:[FRBSwatchist floatForKey:@"animation.currentWordManipulationDuration"]
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self positionTile:tile toCenter:centers[i]];
                         }
                         completion:^(BOOL finished) {
                             
                             if (finished) {
                                 [_animatingTiles removeObject:tile];
                                 
                                 if ([_unselectedTiles containsObject:tile]) {
                                     [self deselectTile:tile];
                                     [_unselectedTiles removeObject:tile];
                                 }
                                 
                                 // This trick is the same one used to run the completion handler
                                 // when tiles finish dropping from the board
                                 numberTilesFinished++;
                                 if (numberAnimatingTiles >= 1 && numberTilesFinished == numberAnimatingTiles) {
                                     [self repositionTilesAnimated:YES];
                                 }
                             }
                         }];
    }
}

- (void)positionTile:(DRPTileView *)tile toCenter:(CGPoint)center
{
    tile.center = center;
    
    if (tile.selected) {
        tile.transform = CGAffineTransformIdentity;
    } else {
        tile.transform = CGAffineTransformMakeScale(_tileScale, _tileScale);
    }
}

// Returns an array of CGPoints that represent the center
// of the tiles in _tileContainer
// Be sure to free() the returned array
- (CGPoint *)tileCenters
{
    CGPoint *centers = malloc(sizeof(CGPoint) * _tiles.count);
    
    _wordWidth = 0;
    CGFloat letterSpacing = [FRBSwatchist floatForKey:@"board.matchCurrentWordLetterSpacing"];
    
    // Initial Spacing
    for (NSInteger i = 0; i < _tiles.count; i++) {
        DRPTileView *tile = _tiles[i];
        
        CGFloat advancement = tile.selected ? tile.frame.size.width : [DRPTileView advancementForCharacter:tile.character.character];
        centers[i] = CGPointMake(_wordWidth + advancement / 2, self.bounds.size.height / 2);
        _wordWidth += advancement + letterSpacing;
    }
    
    // Recenter entire word
    // Word is sometimes too long to fit. Favor right side of the word
    _tileScale = 1;
    if (_wordWidth > self.frame.size.width) {
        _tileScale = self.frame.size.width / _wordWidth;
    }
    
    CGFloat offset = self.frame.size.width / 2 - _wordWidth / 2;
    
    CGFloat hw = self.bounds.size.width / 2;
    for (NSInteger i = 0; i < _tiles.count; i++) {
        centers[i].x = hw + (centers[i].x + offset - hw) * _tileScale;
    }
    
    return centers;
}

// The center point for a tile in the process of being added
// to the current word (highlighted the tile, have not touched up yet)
- (CGPoint)centerForNewTile:(DRPTileView *)tile
{
    // Ignore advancement when the first letter is being added
    CGFloat tileWidth = _wordWidth > 0 ? tile.frame.size.width : 0;
    CGFloat letterSpacing = [FRBSwatchist floatForKey:@"board.matchCurrentWordLetterSpacing"];
    letterSpacing = _wordWidth > 0 ? letterSpacing : -letterSpacing;
    return CGPointMake((self.frame.size.width + _wordWidth + tileWidth + letterSpacing) / 2,
                       self.bounds.size.height / 2);
}

#pragma mark Touch Events

- (void)setGesturesEnabled:(BOOL)enabled
{
    _tapGestureRecognizer.enabled = enabled;
    _panGestureRecognizer.enabled = enabled;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    [_delegate currentWordWasTapped];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        self.frame = ({
            CGRect frame = self.frame;
            frame.origin.x = translation.x;
            frame;
        });
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [gesture velocityInView:self];
        
        // TODO: crickey, this is twitchy
        if (fabs(velocity.x) > 200) {
            [_delegate currentWordWasSwipedWithVelocity:velocity.x];
        } else {
            [_delegate currentWordSwipeFailedWithVelocity:velocity.x];
        }
    }
}

@end
