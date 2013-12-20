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
@property DRPPlayedWord *currentWord;

@property NSMutableDictionary *tiles;

@end

@implementation DRPBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    _currentWord = [[DRPPlayedWord alloc] init];
}

- (CGPoint)centerForPosition:(DRPPosition *)position
{
    return CGPointMake(160 + 53 * (position.i - 2.5), 160 + 53 * (position.j - 2.5));
}

#pragma mark DRPTileDelegate

- (void)tileWasHighlighted:(DRPTileView *)tile
{
    // highlight tiles around adjacentMultiplier if it is activated
}

- (void)tileWasDehighlighted:(DRPTileView *)tile
{
    // dehighlight tiles around adjacentMultiplier if necessary
}

- (void)tileWasSelected:(DRPTileView *)tile
{
    // add character to current word, update delegate
    _currentWord.positions = [_currentWord.positions arrayByAddingObject:tile.position];
}

- (void)tileWasDeselected:(DRPTileView *)tile
{
    // remove character from current word, update delegate
    _currentWord.positions = [_currentWord.positions arrayByRemovingObject:tile.position];
}

@end
