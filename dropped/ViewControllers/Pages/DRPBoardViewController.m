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

#import "NSArray+Mutable.h"
#import "FRBSwatchist.h"

@interface DRPBoardViewController ()

@property DRPBoard *board;

@property (readwrite) DRPPlayedWord *currentPlayedWord;

// Maps DRPPosition -> DRPTileView
@property NSMutableDictionary *tiles;

// Maps DRPCharacter -> Array of DRPTileViews
// Keeps track of how many selected tiles are surrounding the multipliers
@property NSMutableDictionary *adjacentMultipliers;

// UIDynamics stuff used for dropping tiles
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
        self.adjacentMultipliers = [[NSMutableDictionary alloc] init];
        self.pushes = [[NSMutableDictionary alloc] init];
        self.boardEnabled = YES;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:({
        CGFloat l = [FRBSwatchist floatForKey:@"board.boardWidth"];
        CGRectMake(0, 0, l, l);
    })];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.gravity = [[UIGravityBehavior alloc] init];
    self.gravity.magnitude = [FRBSwatchist floatForKey:@"animation.gravity"];
    [self.animator addBehavior:self.gravity];
    
    self.collision = [[UICollisionBehavior alloc] init];
    [self.collision addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(0, 960) toPoint:CGPointMake(self.view.frame.size.width, 960)];
    self.collision.collisionDelegate = self;
    self.collision.collisionMode = UICollisionBehaviorModeBoundaries;
    [self.animator addBehavior:self.collision];
}

#pragma mark Loading

- (void)loadBoard:(DRPBoard *)board atTurn:(NSInteger)turn
{
    [self clearCurrentBoard];
    
    self.board = board;
    self.tiles = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 0; j < 6; j++) {
            DRPPosition *position = [DRPPosition positionWithI:i j:j];
            
            DRPTileView *tile = [DRPTileView dequeueResusableTile];
            tile.character = [self.board characterAtPosition:position forTurn:turn];
            tile.position = position;
            tile.center = [self centerForPosition:position];
            tile.transform = CGAffineTransformIdentity;
            tile.userInteractionEnabled = YES;
            [self.view addSubview:tile];
            [self.view sendSubviewToBack:tile];
            
            self.tiles[position] = tile;
            tile.delegate = self;
        }
    }
    
    self.currentPlayedWord = [[DRPPlayedWord alloc] init];
}

- (void)clearCurrentBoard
{
    for (DRPPosition *position in self.tiles) {
        [self.tiles[position] removeFromSuperview];
    }
}

- (CGPoint)centerForPosition:(DRPPosition *)position
{
    CGFloat width = [FRBSwatchist floatForKey:@"board.boardWidth"];
    CGFloat tileLength = [FRBSwatchist floatForKey:@"board.tileLength"];
    CGFloat tileMargin = [FRBSwatchist floatForKey:@"board.tileMargin"];
    return CGPointMake((width / 2) + (tileLength + tileMargin) * (position.i - 2.5),
                       (width / 2) + (tileLength + tileMargin) * (position.j - 2.5));
}

#pragma mark DRPTileDelegate

// DRPTileViews have 2 (basic) states: selected and highlighted
// Highlighted tiles are the ones that the user is currently interacting with
// Selected tiles are the ones that have been tapped

// When the user highlights a tile in the board, we want to immediately add
// it to the current word so the appearence of tiles can be updated, the score
// in the header can be changed, and the character can be added to the
// currentWordViewController.

- (void)tileWasHighlighted:(DRPTileView *)tile
{
    // Tiles that are already selected can be highlighted, but we don't
    // want to do anything else in that case
    BOOL newCharacter = ![self.currentPlayedWord.positions containsObject:tile.position];
    
    // Highlight tiles around adjacentMultiplier if it is activated
    DRPCharacter *adjacentMultiplier = tile.character.adjacentMultiplier;
    if (newCharacter && adjacentMultiplier) {
        
        // Add the tile to adjacentMultipliers
        NSMutableArray *adjacent = self.adjacentMultipliers[adjacentMultiplier];
        if (!adjacent) {
            adjacent = [[NSMutableArray alloc] init];
            self.adjacentMultipliers[adjacentMultiplier] = adjacent;
        }
        
        if (![adjacent containsObject:tile]) {
            [adjacent addObject:tile];
        }
        
        // If the multiplier has been activated...
        if (adjacent.count >= adjacentMultiplier.multiplier) {
            adjacentMultiplier.multiplierActive = YES;
            
            // Light up the surrounding tiles
            for (DRPTileView *tile in adjacent) {
                [tile resetAppearence];
            }
            
            // Add the active multiplier to the currentWord if it hasn't been done so already
            if (newCharacter) {
                // The DRPPlayedWord expects a DRPPosition, not a DRPCharacter
                DRPPosition *multiplierPosition = [self.board positionOfMultiplierCharacter:adjacentMultiplier];
                
                if (![self.currentPlayedWord.multipliers containsObject:multiplierPosition]) {
                    self.currentPlayedWord.multipliers = [self.currentPlayedWord.multipliers arrayByAddingObject:multiplierPosition];
                }
            }
        }
    }
    
    // newCharacters should be added to the currentWord
    if (newCharacter) {
        self.currentPlayedWord.positions = [self.currentPlayedWord.positions arrayByAddingObject:tile.position];
        [self.delegate characterWasAddedToCurrentWord:tile.character];
    }
    
    [self.delegate characterWasHighlighted:tile.character];
}

- (void)tileWasDehighlighted:(DRPTileView *)tile
{
    [self.delegate characterWasDehighlighted:tile.character];
}

- (void)tileWasSelected:(DRPTileView *)tile
{
}

// Similarly, there's a whole bunch of stuff that needs to happen
// immediately after the user deselects a tile
- (void)tileWasDeselected:(DRPTileView *)tile
{
    // Dehighlight tiles around adjacentMultiplier if necessary
    DRPCharacter *adjacentMultiplier = tile.character.adjacentMultiplier;
    if (adjacentMultiplier) {
        NSMutableArray *adjacent = self.adjacentMultipliers[adjacentMultiplier];
        
        [adjacent removeObject:tile];
        if (adjacent.count < adjacentMultiplier.multiplier) {
            adjacentMultiplier.multiplierActive = NO;
            
            DRPPosition *multiplierPosition = [self.board positionOfMultiplierCharacter:adjacentMultiplier];
            self.currentPlayedWord.multipliers = [self.currentPlayedWord.multipliers arrayByRemovingObject:multiplierPosition];
            
            for (DRPTileView *tile in adjacent) {
                [tile resetAppearence];
            }
        }
    }
    
    // Remove character from current word, update delegate
    self.currentPlayedWord.positions = [self.currentPlayedWord.positions arrayByRemovingObject:tile.position];
    [self.delegate characterWasRemovedFromCurrentWord:tile.character];
}

#pragma mark Disable/Enable board

- (void)setBoardEnabled:(BOOL)boardEnabled
{
    _boardEnabled = boardEnabled;
    [self setCurrentTilesEnabled:self.boardEnabled];
}

- (void)setCurrentTilesEnabled:(BOOL)enabled
{
    for (DRPPosition *position in self.tiles) {
        DRPTileView *tile = self.tiles[position];
        tile.enabled = enabled;
    }
}

#pragma mark Current Word

// This stuff is called from the DRPPageMatchViewController to
// reset the state of the board

- (void)resetCurrentWord
{
    self.currentPlayedWord.positions = @[];
    self.currentPlayedWord.multipliers = @[];
    for (DRPCharacter *multiplier in self.adjacentMultipliers) {
        multiplier.multiplierActive = NO;
    }
    [self.adjacentMultipliers removeAllObjects];
}

- (void)deselectCurrentWord
{
    for (DRPPosition *position in self.currentPlayedWord.positions) {
        DRPTileView *tile = self.tiles[position];
        tile.selected = NO;
        tile.highlighted = NO;
        [tile resetAppearence];
    }
    
    [self resetCurrentWord];
}

#pragma mark Move Submission

// Drops a playedWord and handles all of the animations necessary to advance the board to the next turn
- (void)dropPlayedWord:(DRPPlayedWord *)playedWord fromTurn:(NSInteger)turn withCompletion:(void(^)())completion
{
    // Explicitly set activeMultipliers to active (since this is intentially not done when loaded)
    // so that dropped tiles are colored
    NSMutableArray *multiplierCharacters = [[NSMutableArray alloc] init];
    for (DRPPosition *position in playedWord.multipliers) {
        DRPTileView *tile = self.tiles[position];
        tile.character.multiplierActive = YES;
        [multiplierCharacters addObject:tile.character];
    }
    
    // Drop selected positions
    NSArray *droppedPositions = [NSArray arrayWithArrays:playedWord.positions, playedWord.multipliers, playedWord.additionalMultipliers, nil];
    NSArray *droppedTiles = [self dropPositions:droppedPositions];
    
    // However, we have to set multiplierActive back to NO so it doesn't interfere with subsequent playbacks
    for (DRPCharacter *multiplier in multiplierCharacters) {
        multiplier.multiplierActive = NO;
    }
    
    // Move everything else down
    // TODO: this can probably be cleaned up by combining all of the transitioning tiles
    NSMutableArray *transitioningTiles = [[NSMutableArray alloc] init];
    NSMutableDictionary *diff = [[NSMutableDictionary alloc] initWithDictionary:playedWord.diff];
    
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 5; j >= 0; j--) {
            DRPPosition *start = [DRPPosition positionWithI:i j:j];
            DRPPosition *end = diff[start] ?: start;
            
            DRPTileView *tile = self.tiles[start];
            if (!tile) continue;
            tile.character = [self.board characterAtPosition:end forTurn:turn+1];
            tile.position = end;
            tile.character.multiplierActive = NO;
            self.tiles[end] = tile;
            
            if (![start isEqual:end]) {
                [self transitionTile:tile toPosition:end withCompletion:nil];
                [transitioningTiles addObject:tile];
            }
        }
    }
    
    
    // Jared: this is some quite tricksy block code. I think it's neat.
    //
    // The goal is to run the passed in completion handler when _all_ of
    // the new tiles are in place. It's hard to calculate when that is.
    //
    // The solution is to create a second block that keeps track of how
    // many times its been called and call it every time a tile finishes
    // animating into place. When they have all called the secondary
    // completion block, it's safe to call the completion block passed
    // in to this method.
    
    __block NSInteger numberOfTilesWithCompletedAnimations = 0;
    void (^tileTransitionCompletion)() = ^{
        numberOfTilesWithCompletedAnimations++;
        if (numberOfTilesWithCompletedAnimations == playedWord.tileCount) {
            
            // Reset the appearence of all transitioning tiles
            for (DRPTileView *tile in transitioningTiles) {
                tile.selected = NO;
                tile.userInteractionEnabled = YES;
                [tile resetAppearence];
            }
            
            // Now safe to run the completion handler
            // TODO: make sure a minimum amount of time has passed first
            if (completion) {
                completion();
            }
        }
    };
    
    // Create new DRPTileViews at the top
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
            tile.enabled = NO;
            [self.view addSubview:tile];
            self.tiles[end] = tile;
            
            [self transitionTile:tile toPosition:end withCompletion:tileTransitionCompletion];
            [transitioningTiles addObject:tile];
        }
    }
    
    // Bring Dropped Tiles to Front
    for (UIView *tile in droppedTiles) {
        [self.view bringSubviewToFront:tile];
    }
    
    [self resetCurrentWord];
}

// Drops an array of DRPPositions from the board
// Returns an array of the DRPTileViews that were dropped
- (NSArray *)dropPositions:(NSArray *)positions
{
    NSMutableArray *droppedTiles = [[NSMutableArray alloc] init];
    
    for (DRPPosition *position in positions) {
        DRPTileView *tile = self.tiles[position];
        if (!tile) continue;
        [self.tiles removeObjectForKey:position];
        
        tile.scaleCharacter = NO;
        tile.selected = YES;
        tile.enabled = NO;
        [tile resetAppearence];
        
        // The push is randomized,
        UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[tile] mode:UIPushBehaviorModeInstantaneous];
        CGFloat angleRange = [FRBSwatchist floatForKey:@"animation.tileDropAngleRange"];
        CGFloat baseMag = [FRBSwatchist floatForKey:@"animation.tileDropBaseMagnitude"];
        CGFloat magRange = [FRBSwatchist floatForKey:@"animation.tileDropMagnitudeRange"];
        push.angle = -M_PI_2 + (float)random() / RAND_MAX * angleRange - angleRange / 2;
        push.magnitude = baseMag + (float)random() / RAND_MAX * magRange - magRange / 2;
        [push setTargetOffsetFromCenter:UIOffsetMake(0, [FRBSwatchist floatForKey:@"board.tileLength"] / 4) forItem:tile];
        [self.animator addBehavior:push];
        self.pushes[tile] = push;
        
        [self.gravity addItem:tile];
        [self.collision addItem:tile];
        
        tile.userInteractionEnabled = NO;
        [self.view bringSubviewToFront:tile];
        
        [droppedTiles addObject:tile];
    }
    
    return droppedTiles;
}

// Removes dropped tiles from the view hierarchy once they're offscreen
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    [DRPTileView queueReusableTile:(DRPTileView *)item];
    
    [behavior removeItem:item];
    [self.gravity removeItem:item];
    [self.pushes[item] removeItem:item];
    [self.animator removeBehavior:self.pushes[item]];
    [self.pushes removeObjectForKey:item];
}

// Animates the movement of a tile from one position in the board to another
- (void)transitionTile:(DRPTileView *)tile toPosition:(DRPPosition *)position withCompletion:(void(^)())completion
{
    tile.selected = YES;
    tile.userInteractionEnabled = NO;
    [tile resetAppearence];
    
    CGPoint dest = [self centerForPosition:position];
    CGFloat dist = dest.y - tile.center.y;
    CGFloat rate = [FRBSwatchist floatForKey:@"animation.newTileDropSpeed"];
    CGFloat duration = MIN(MAX(dist / rate, [FRBSwatchist floatForKey:@"animation.newTileDropMinDuration"]),
                           [FRBSwatchist floatForKey:@"animation.newTileDropMaxDuration"]);
    CGFloat delay = [FRBSwatchist floatForKey:@"animation.newTileDropDelay"];
    
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         tile.center = dest;
                     }
                     completion:^(BOOL finished) {
                         // completion is passed in from dropPlayedWord:withCompletion: and
                         // updates a counter of the number of tiles that have finished
                         if (completion) {
                             completion();
                         }
                     }];
}

@end
