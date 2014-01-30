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
#import "UIView+Introspective.h"

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
        [self loadGestureRecognizers];
        
        
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

- (void)loadGestureRecognizers
{
//    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//    [self addGestureRecognizer:_tapGestureRecognizer];
//    
//    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
//    [self addGestureRecognizer:_panGestureRecognizer];
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
        tile.position = nil;
        tile.transform = CGAffineTransformIdentity;
        tile.center = [self centerForNewTile:tile];
        [_tiles addObject:tile];
        [self addSubview:tile];
        
    } else {
        tile.selected = YES;
        tile.highlighted = YES;
        [tile resetAppearence];
    }
    
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
        [self repositionTiles];
    });
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

- (void)characterWasRemoved:(DRPCharacter *)character
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
    for (DRPTileView *tile in _tiles) {
        [tile removeFromSuperview];
    }
    [_tiles removeAllObjects];
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

#pragma mark Repositioning Tiles

//// Called during orientation changes to make sure the current
//// container is properly centered
//- (void)recenter
//{
//    if (_currentContainer == _tileContainer) {
//        [self repositionTiles];
//    } else {
//        _turnsLeftLabel.center = rectCenter(self.bounds);
//    }
//}

// Animates repositioning of tiles in _tileContainer (from adding/removing/selecting a character)
- (void)repositionTiles
{
    CGPoint *centers = [self tileCenters];
    
    [UIView animateWithDuration:[FRBSwatchist floatForKey:@"animation.currentWordManipulationDuration"]
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
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

// Returns an array of CGPoints that represent the center
// of the tiles in _tileContainer
// Be sure to free() the returned array
- (CGPoint *)tileCenters
{
    CGPoint *centers = malloc(sizeof(CGPoint) * _tiles.count);
    
    _wordWidth = 0;
    CGFloat letterSpacing = [FRBSwatchist floatForKey:@"page.matchCurrentWordLetterSpacing"];
    
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
    CGFloat letterSpacing = [FRBSwatchist floatForKey:@"page.matchCurrentWordLetterSpacing"];
    letterSpacing = _wordWidth > 0 ? letterSpacing : -letterSpacing;
    return CGPointMake((self.frame.size.width + _wordWidth + tileWidth + letterSpacing) / 2,
                       self.bounds.size.height / 2);
}

#pragma mark Touch Events

//- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
//{
//    [_delegate currentWordViewTapped];
//}
//
//- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
//{
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        
//    } else if (gesture.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [gesture translationInView:self];
//        _currentContainer.center = CGPointMake(self.bounds.size.width / 2 + translation.x, _currentContainer.center.y);
//        
//    } else if (gesture.state == UIGestureRecognizerStateEnded) {
//        
//        CGPoint velocity = [gesture velocityInView:self];
//        
//        if (_currentContainer == _turnsLeftLabel) {
//            // No swiping the _turnsLeftLabel
//            [self snapBackContainer:_turnsLeftLabel withVelocity:velocity.x];
//            
//        } else {
//            if (fabs(velocity.x) > 200) {
//                [self setCurrentContainer:_turnsLeftLabel withVelocity:velocity.x];
//                [_delegate currentWordViewSwiped];
//            } else {
//                [self snapBackContainer:_tileContainer withVelocity:velocity.x];
//            }
//        }
//    }
//}

@end
