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

@interface DRPBoardViewController ()

@property DRPBoard *board;
@property DRPPlayedWord *currentPlayedWord;

@property NSMutableDictionary *tiles, *adjacentMultipliers;

@end

@implementation DRPBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _adjacentMultipliers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
}

#pragma mark Loading

- (void)loadBoard:(DRPBoard *)board
{
    _board = board;
    _tiles = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 0; j < 6; j++) {
            DRPPosition *position = [DRPPosition positionWithI:i j:j];
            
            DRPTileView *tile = [[DRPTileView alloc] initWithCharacter:[_board characterAtPosition:position]];
            tile.position = position;
            tile.center = [self centerForPosition:position];
            [self.view addSubview:tile];
            
            _tiles[position] = tile;
            tile.delegate = self;
        }
    }
    
    _currentPlayedWord = [[DRPPlayedWord alloc] init];
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
        [_tiles[position] removeFromSuperview];
    }
}

- (void)transitionTile:(DRPTileView *)tile toPosition:(DRPPosition *)position
{
    [UIView animateWithDuration:0.4 animations:^{
        tile.center = [self centerForPosition:position];
    }];
}

@end
