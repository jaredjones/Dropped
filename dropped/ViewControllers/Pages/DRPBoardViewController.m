//
//  DRPBoardViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPBoardViewController.h"
#import "NSArray+Mutable.h"

#import "DRPTileView.h"

#import "DRPBoard.h"
#import "DRPPosition.h"
#import "DRPCharacter.h"
#import "DRPPlayedWord.h"

#import "FRBSwatchist.h"

@interface DRPBoardViewController ()

@property DRPBoard *board;
@property DRPPlayedWord *currentPlayedWord;

@property NSMutableDictionary *tiles, *adjacentMultipliers;
@property NSMutableArray *queuedTiles;

@property UIDynamicAnimator *animator;
@property UIGravityBehavior *gravity;
@property UICollisionBehavior *collision;
@property NSMutableDictionary *pushes;

@end

@implementation DRPBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _adjacentMultipliers = [[NSMutableDictionary alloc] init];
        _pushes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    _gravity = [[UIGravityBehavior alloc] init];
    _gravity.magnitude = [FRBSwatchist floatForKey:@"animation.gravity"];
    [_animator addBehavior:_gravity];
    
    _collision = [[UICollisionBehavior alloc] init];
    [_collision addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(0, 960) toPoint:CGPointMake(self.view.frame.size.width, 960)];
    _collision.collisionDelegate = self;
    _collision.collisionMode = UICollisionBehaviorModeBoundaries;
    [_animator addBehavior:_collision];
}

#pragma mark Loading

- (void)loadBoard:(DRPBoard *)board
{
    [self clearCurrentBoard];
    
    _board = board;
    _tiles = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 0; j < 6; j++) {
            DRPPosition *position = [DRPPosition positionWithI:i j:j];
            
            DRPTileView *tile = [self dequeueResusableTile];
            tile.character = [_board characterAtPosition:position];
            tile.position = position;
            tile.center = [self centerForPosition:position];
            tile.userInteractionEnabled = YES;
            [self.view addSubview:tile];
            [self.view sendSubviewToBack:tile];
            
            _tiles[position] = tile;
            tile.delegate = self;
        }
    }
    
    _currentPlayedWord = [[DRPPlayedWord alloc] init];
}

- (void)clearCurrentBoard
{
    for (DRPPosition *position in _tiles) {
        [_tiles[position] removeFromSuperview];
    }
}

- (DRPTileView *)dequeueResusableTile
{
    if (!_queuedTiles) _queuedTiles = [[NSMutableArray alloc] init];
    if (!_queuedTiles.count) return [[DRPTileView alloc] initWithCharacter:nil];
    
    DRPTileView *tile = [_queuedTiles lastObject];
    [_queuedTiles removeLastObject];
    return tile;
}

- (void)queueReusableTile:(DRPTileView *)tile
{
    [_queuedTiles addObject:tile];
}

- (CGPoint)centerForPosition:(DRPPosition *)position
{
    return CGPointMake(160 + 53 * (position.i - 2.5), 160 + 53 * (position.j - 2.5));
}

#pragma mark DRPTileDelegate

- (void)tileWasHighlighted:(DRPTileView *)tile
{
    // Highlight tiles around adjacentMultiplier if it is activated
    DRPCharacter *adjacentMultiplier = tile.character.adjacentMultiplier;
    if (adjacentMultiplier) {
        NSMutableArray *adjacent = _adjacentMultipliers[adjacentMultiplier];
        
        if (!adjacent) {
            adjacent = [[NSMutableArray alloc] init];
            _adjacentMultipliers[adjacentMultiplier] = adjacent;
        }
        
        if (![adjacent containsObject:tile]) {
            [adjacent addObject:tile];
        }
        
        if (adjacent.count >= adjacentMultiplier.multiplier) {
            adjacentMultiplier.multiplierActive = YES;
            
            for (DRPTileView *tile in adjacent) {
                [tile resetAppearence];
            }
        }
    }
}

- (void)tileWasDehighlighted:(DRPTileView *)tile
{
    // Dehighlight tiles around adjacentMultiplier if necessary
    DRPCharacter *adjacentMultiplier = tile.character.adjacentMultiplier;
    if (adjacentMultiplier) {
        NSMutableArray *adjacent = _adjacentMultipliers[adjacentMultiplier];
        
        [adjacent removeObject:tile];
        if (adjacent.count < adjacentMultiplier.multiplier) {
            adjacentMultiplier.multiplierActive = NO;
            
            for (DRPTileView *tile in adjacent) {
                [tile resetAppearence];
            }
        }
    }
}

- (void)tileWasSelected:(DRPTileView *)tile
{
    // add character to current word, update delegate
    _currentPlayedWord.positions = [_currentPlayedWord.positions arrayByAddingObject:tile.position];
    [_delegate characterAddedToCurrentWord:tile.character];
}

- (void)tileWasDeselected:(DRPTileView *)tile
{
    // remove character from current word, update delegate
    _currentPlayedWord.positions = [_currentPlayedWord.positions arrayByRemovingObject:tile.position];
    [_delegate characterRemovedFromCurrentWord:tile.character];
}

#pragma mark Current Word

- (NSString *)currentWord
{
    return [_board wordForPositions:_currentPlayedWord.positions];
}

- (NSArray *)currentPositions
{
    return _currentPlayedWord.positions;
}

- (void)resetCurrentWord
{
    _currentPlayedWord.positions = @[];
    [_adjacentMultipliers removeAllObjects];
}

#pragma mark Move Submission

- (void)dropPlayedWord:(DRPPlayedWord *)playedWord
{
    
    // First, drop positions
    [self dropPositions:playedWord.positions];
    [self dropPositions:playedWord.multipliers];
    [self dropPositions:playedWord.additionalMultipliers];
    
    NSMutableDictionary *diff = [[NSMutableDictionary alloc] initWithDictionary:playedWord.diff];
    
    // Move everything else down
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 5; j >= 0; j--) {
            DRPPosition *start = [DRPPosition positionWithI:i j:j];
            DRPPosition *end = diff[start] ?: start;
            
            DRPTileView *tile = _tiles[start];
            if (!tile) continue;
            tile.character = [_board characterAtPosition:end];
            tile.position = end;
            _tiles[end] = tile;
            
            if (![start isEqual:end]) {
                [self transitionTile:tile toPosition:end];
            }
        }
    }
    
    // Create DRPTileViews at the top
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = -1; j >= -6; j--) {
            DRPPosition *start = [DRPPosition positionWithI:i j:j];
            if (!diff[start]) break;
            
            DRPCharacter *character = diff[start][0];
            DRPPosition *end = diff[start][1];
            
            DRPTileView *tile = [[DRPTileView alloc] initWithCharacter:character];
            tile.position = end;
            tile.center = [self centerForPosition:start];
            tile.delegate = self;
            [self.view addSubview:tile];
            _tiles[end] = tile;
            
            [self transitionTile:tile toPosition:end];
        }
    }
    
    [self resetCurrentWord];
}

- (void)dropPositions:(NSArray *)positions
{
    for (DRPPosition *position in positions) {
        DRPTileView *tile = _tiles[position];
        [_tiles removeObjectForKey:position];
        
        UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[tile] mode:UIPushBehaviorModeInstantaneous];
        CGFloat angleRange = .05;
        CGFloat magRange = .046;
        push.angle = -M_PI_2 + (float)rand() / RAND_MAX * angleRange - angleRange / 2;
        push.magnitude = 0.23 + (float)rand() / RAND_MAX * magRange - magRange / 2;
        [push setTargetOffsetFromCenter:UIOffsetMake(0, 24) forItem:tile];
        [_animator addBehavior:push];
        _pushes[tile] = push;
        
        [_gravity addItem:tile];
        [_collision addItem:tile];
        
        tile.userInteractionEnabled = NO;
        [self.view bringSubviewToFront:tile];
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    [self queueReusableTile:(DRPTileView *)item];
    
    [behavior removeItem:item];
    [_gravity removeItem:item];
    [_animator removeBehavior:_pushes[item]];
}

- (void)transitionTile:(DRPTileView *)tile toPosition:(DRPPosition *)position
{
    tile.selected = YES;
    tile.userInteractionEnabled = NO;
    [tile resetAppearence];
    
    CGPoint dest = [self centerForPosition:position];
    CGFloat dist = dest.y - tile.center.y;
    CGFloat rate = 120;
    CGFloat duration = MIN(MAX(dist / rate, 0.2), 0.78);
    
    [UIView animateWithDuration:duration animations:^{
        tile.center = dest;
    } completion:^(BOOL finished) {
        tile.selected = NO;
        tile.userInteractionEnabled = YES;
        [tile resetAppearence];
    }];
}

@end
