//
//  DRPMatchCollectionViewCell.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMatchCollectionViewCell.h"

#import "DRPMatch.h"
#import "DRPPlayer.h"
#import "DRPBoard.h"
#import "DRPCharacter.h"

#import "DRPTileView.h"

#import "FRBSwatchist.h"
#import "DRPUtility.h"

@interface DRPMatchCollectionViewCell ()

@property DRPMatchCellState cellState;

@property NSMutableArray *tiles;
@property UILabel *opponentLabel, *statusLabel;

// Stored from the set DRPMatch to keep references for KVO
@property NSArray *players;

@end

@implementation DRPMatchCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Load tiles
        _tiles = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 2; i++) {
            DRPTileView *tile = [DRPTileView dequeueResusableTile];
            tile.hidden = YES;
            tile.selected = YES;
            tile.permaSelected = YES;
            tile.scaleCharacter = NO;
            
            [_tiles addObject:tile];
            [self.contentView addSubview:tile];
        }
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)configureWithMatch:(DRPMatch *)match
{
    // TODO: determine match state
    
    // Reset tiles
    [self removeObservers];
    _players = match.players;
    [self addObserversForPlayers:_players];
    
    NSArray *colors = [match.board multiplierColorsForTurn:match.currentTurn];
    for (NSInteger i = 0; i < match.players.count; i++) {
        DRPTileView *tile = _tiles[i];
        DRPPlayer *player = [match playerForTurn:i];
        
        tile.character = [DRPCharacter characterWithCharacter:[player firstPrintableAliasCharacter]];
        tile.character.color = [colors[i] intValue];
        
        if (match.localPlayer == match.currentPlayer && match.currentPlayer.turn == i) {
            // To trick the tile into highlighting, you must enable it first
            tile.enabled = YES;
            tile.highlighted = YES;
        } else {
            tile.highlighted = NO;
        }
        
        [tile resetAppearence];
        tile.enabled = NO;
        tile.frame = [DRPMatchCollectionViewCell tileFrameForTurn:i state:_cellState];
        tile.hidden = NO;
    }
    
    // TODO: them labels
    // TODO: add player observer
}

#pragma mark Layout

+ (CGRect)tileFrameForTurn:(NSInteger)turn state:(DRPMatchCellState)cellState
{
    // TODO: When game over should slide right tile over, with winner on top
    CGRect frame = CGRectZero;
    frame.origin.x = turn * ([FRBSwatchist floatForKey:@"board.tileLength"] + [FRBSwatchist floatForKey:@"board.tileMargin"]);
    frame.size.width = [FRBSwatchist floatForKey:@"board.tileLength"];
    frame.size.height = [FRBSwatchist floatForKey:@"board.tileLength"];
    return frame;
}

#pragma mark KVO

- (void)addObserversForPlayers:(NSArray *)players
{
    for (DRPPlayer *player in _players) {
        [player addObserver:self forKeyPath:@"alias" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObservers
{
    for (DRPPlayer *player in _players) {
        [player removeObserver:self forKeyPath:@"alias"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[DRPPlayer class]] && [keyPath isEqualToString:@"alias"]) {
        
        for (NSInteger i = 0; i < _players.count; i++) {
            DRPPlayer *player = _players[i];
            if (player != object) continue;
            
            DRPTileView *tile = _tiles[i];
            
            DRPCharacter *oldCharacter = tile.character;
            DRPCharacter *newCharacter = [DRPCharacter characterWithCharacter:[player firstPrintableAliasCharacter]];
            newCharacter.color = oldCharacter.color;
            tile.character = newCharacter;
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
