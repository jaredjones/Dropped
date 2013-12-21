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
    // drop tilesviews
    
    [self resetCurrentWord];
}

@end
