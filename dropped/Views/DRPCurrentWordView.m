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

@property UIView *tileContainer;
@property UILabel *turnsLeftLabel;
@property (nonatomic) UIView *currentContainer;

// When swiping away the current word, the tiles need
// to be cleared at the end of the animation.
// However, a new word can be started before the animation
// completes. In that case, the tiles need to be cleared
// then.
// This flag stores whether the tiles are "dirty" so
// they can be cleared in the appropriate places.
@property BOOL tileContainerNeedsClearing;

@end

@implementation DRPCurrentWordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadTurnsLeftLabel];
        [self loadTileContainer];
        [self loadGestureRecognizers];
        
        _currentContainer = _turnsLeftLabel;
        
        _tiles = [[NSMutableArray alloc] init];
        
        // TODO: hide inactive container
    }
    return self;
}

- (void)loadTileContainer
{
    _tileContainer = [[UIView alloc] initWithFrame:self.leftFrame];
    [self addSubview:_tileContainer];
}

- (void)loadTurnsLeftLabel
{
    _turnsLeftLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _turnsLeftLabel.userInteractionEnabled = YES;
    
    _turnsLeftLabel.font = [FRBSwatchist fontForKey:@"board.tileFont"];
    _turnsLeftLabel.textColor = [FRBSwatchist colorForKey:@"colors.black"];
    
    _turnsLeftLabel.textAlignment = NSTextAlignmentCenter;
    _turnsLeftLabel.text = @"26 turns left";
    
    [self addSubview:_turnsLeftLabel];
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
    if (_tileContainerNeedsClearing) {
        [self removeAllCharactersFromCurrentWord];
    }
    
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
        [_tileContainer addSubview:tile];
        
    } else {
        [_tileContainer bringSubviewToFront:tile];
        tile.selected = YES;
        tile.highlighted = YES;
        [tile resetAppearence];
    }
    
    // There's a (very) visibly noticeable jump in the animation
    // when  the repositioning happens at the same time as adding
    // a dequeued tile. Delaying by a tiny amount fixes the problem.
    //
    // The source of the problem is that UIViewAnimationOptionsBeginFromCurrentState
    // for repositioning animations (which should be the case). For some
    // reason the animation still thinks the center of the tile is in its
    // previous location.
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.001 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self repositionTiles];
    });
    
    [self setCurrentContainer:_tileContainer];
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
        
        // Last tile removed, move back to _turnsLeftLabel
        if (_tiles.count == 0) {
            [self setCurrentContainer:_turnsLeftLabel];
        }
    }
}

- (void)removeAllCharactersFromCurrentWord
{
    for (DRPTileView *tile in _tiles) {
        [tile removeFromSuperview];
    }
    [_tiles removeAllObjects];
    _wordWidth = 0;
    _tileContainerNeedsClearing = NO;
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

#pragma mark Containers

- (CGRect)leftFrame
{
    return CGRectOffset(self.bounds, -self.bounds.size.width, 0);
}

- (CGRect)rightFrame
{
    return CGRectOffset(self.bounds, self.bounds.size.width, 0);
}

- (void)setCurrentContainer:(UIView *)currentContainer
{
    [self setCurrentContainer:currentContainer withVelocity:1200];
}

- (void)setCurrentContainer:(UIView *)currentContainer withVelocity:(CGFloat)velocity
{
    if (_currentContainer == currentContainer) return;
    
    UIView *old = _currentContainer;
    _currentContainer = currentContainer;
    _currentContainer.frame = self.leftFrame;
    
    [self swipeAwayContainer:old withVelocity:velocity];
    [self snapBackContainer:_currentContainer withVelocity:1];
}

#pragma mark Repositioning Tiles

- (void)repositionCurrentContainer
{
    if (_currentContainer == _tileContainer) {
        [self repositionTiles];
    } else {
        _turnsLeftLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

- (CGPoint)centerForNewTile:(DRPTileView *)tile
{
    // Ignore advancement when the first letter is being added
    CGFloat tileWidth = _wordWidth > 0 ? tile.frame.size.width : 0;
    CGFloat letterSpacing = [FRBSwatchist floatForKey:@"page.matchCurrentWordLetterSpacing"];
    letterSpacing = _wordWidth > 0 ? letterSpacing : -letterSpacing;
    return CGPointMake((self.frame.size.width + _wordWidth + tileWidth + letterSpacing) / 2,
                       self.bounds.size.height / 2);
}

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

// Following two methods deal with the swipeclears
- (void)swipeAwayContainer:(UIView *)container withVelocity:(CGFloat)velocity
{
    CGRect destFrame = velocity < 0 ? self.leftFrame : self.rightFrame;
    CGFloat dist = destFrame.origin.x - container.frame.origin.x;
    CGFloat t = dist / fabs(velocity);
    
    [UIView animateWithDuration:t
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         container.frame = destFrame;
                     }
                     completion:^(BOOL finished) {
                         if (_tileContainerNeedsClearing) {
                            [self removeAllCharactersFromCurrentWord];
                         }
                     }];
    
    if (container == _tileContainer) {
        _tileContainerNeedsClearing = YES;
    }
}

- (void)snapBackContainer:(UIView *)container withVelocity:(CGFloat)velocity
{
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:velocity * 0.001
                        options:0
                     animations:^{
                         container.frame = self.bounds;
                     }
                     completion:nil];
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
        _currentContainer.center = CGPointMake(self.bounds.size.width / 2 + translation.x, _currentContainer.center.y);
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [gesture velocityInView:self];
        
        if (_currentContainer == _turnsLeftLabel) {
            // No swiping the _turnsLeftLabel
            [self snapBackContainer:_turnsLeftLabel withVelocity:velocity.x];
            
        } else {
            if (fabs(velocity.x) > 200) {
                [self setCurrentContainer:_turnsLeftLabel withVelocity:velocity.x];
                [_delegate currentWordViewSwiped];
            } else {
                [self snapBackContainer:_tileContainer withVelocity:velocity.x];
            }
        }
    }
}

@end
