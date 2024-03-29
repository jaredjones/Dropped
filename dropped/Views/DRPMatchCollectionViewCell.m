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
@property DRPPlayer *remotePlayer;

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
            tile.enabled = NO;
            
            [_tiles addObject:tile];
            [self.contentView addSubview:tile];
        }
        
        // Load Labels
        _opponentLabel = [[UILabel alloc] initWithFrame:[self opponentLabelFrame]];
        _opponentLabel.font = [FRBSwatchist fontForKey:@"page.cueEmphasizedFont"];
        _opponentLabel.textColor = [FRBSwatchist colorForKey:@"colors.black"];
        [self.contentView addSubview:_opponentLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:[self statusLabelFrame]];
        _statusLabel.font = [FRBSwatchist fontForKey:@"page.cueFont"];
        _statusLabel.textColor = [FRBSwatchist colorForKey:@"colors.black"];
        [self.contentView addSubview:_statusLabel];
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)configureWithMatch:(DRPMatch *)match
{
    // Determine match state
    _cellState = [DRPMatchCollectionViewCell cellStateForMatch:match];
    NSArray *highlights = @[({
        @(_cellState == DRPMatchCellStatePlayer1Active && match.localPlayer.turn == 0);
    }), ({
        @(_cellState == DRPMatchCellStatePlayer2Active && match.localPlayer.turn == 1);
    })];
    
    // Reset tiles
    [self removeObservers];
    _players = match.players;
    _remotePlayer = match.remotePlayer;
    [self addObserversForPlayers:_players];
    
    NSArray *colors = [match.board multiplierColorsForTurn:match.currentTurn];
    for (NSInteger i = 0; i < match.players.count; i++) {
        DRPTileView *tile = _tiles[i];
        DRPPlayer *player = [match playerForTurn:i];
        
        tile.character = [DRPCharacter characterWithCharacter:[player firstPrintableAliasCharacter]];
        tile.character.color = [colors[i] intValue];
        
        // Highlight tile
        if ([highlights[i] boolValue]) {
            tile.highlighted = YES;
            tile.permaHighlighted = YES;
        } else {
            tile.highlighted = NO;
            tile.permaHighlighted = NO;
        }
        
        [tile resetAppearence];
        
        // z-order
        if (player != match.winner) {
            [self.contentView sendSubviewToBack:tile];
        }
        
        // TODO: animate the cell over
        tile.frame = [DRPMatchCollectionViewCell tileFrameForTurn:i state:_cellState];
        
        tile.hidden = NO;
    }
    
    // Set Labels
    _opponentLabel.text = match.remotePlayer.alias;
    
    if (match.finished) {
        if (match.tied) {
            _statusLabel.text = @"Tied";
        } else {
            _statusLabel.text = @"Game Over";
        }
    } else if ([match isLocalPlayerTurn]) {
        _statusLabel.text = @"Your Turn!";
    } else {
        _statusLabel.text = @"Waiting for Turn";
    }
}

+ (DRPMatchCellState)cellStateForMatch:(DRPMatch *)match
{
    if (match.finished) {
        if ([match playerForTurn:1].score > [match playerForTurn:0].score) {
            return DRPMatchCellStatePlayer2Won;
        }
        return DRPMatchCellStatePlayer1Won;
    }
    
    if (match.currentPlayer.turn == 0) {
        return DRPMatchCellStatePlayer1Active;
    }
    return DRPMatchCellStatePlayer2Active;
}

#pragma mark Layout

+ (CGRect)tileFrameForTurn:(NSInteger)turn state:(DRPMatchCellState)cellState
{
    CGRect frame = CGRectZero;
    frame.origin.x = turn * ([FRBSwatchist floatForKey:@"board.tileLength"] + [FRBSwatchist floatForKey:@"board.tileMargin"]);
    frame.size.width = [FRBSwatchist floatForKey:@"board.tileLength"];
    frame.size.height = [FRBSwatchist floatForKey:@"board.tileLength"];
    
    // Slide right tile over
    if (turn == 1 && (cellState == DRPMatchCellStatePlayer1Won ||
                      cellState == DRPMatchCellStatePlayer2Won ||
                      cellState == DRPMatchCellStateTie)) {
        // Golden ratio, yo
        frame.origin.x -= [FRBSwatchist floatForKey:@"board.tileLength"] / 1.6;
    }
    
    return frame;
}

// TODO: these magic numbers are totally bullshit
- (CGRect)opponentLabelFrame
{
    return CGRectMake([FRBSwatchist floatForKey:@"list.textOffsetX"],
                      0 + 1,
                      self.contentView.bounds.size.width - [FRBSwatchist floatForKey:@"list.textOffsetX"],
                      [FRBSwatchist floatForKey:@"board.tileLength"] / 2);
}

- (CGRect)statusLabelFrame
{
    return CGRectMake([FRBSwatchist floatForKey:@"list.textOffsetX"],
                      [FRBSwatchist floatForKey:@"board.tileLength"] / 2 + 3,
                      self.contentView.bounds.size.width - [FRBSwatchist floatForKey:@"list.textOffsetX"],
                      [FRBSwatchist floatForKey:@"board.tileLength"] / 2);
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
            
            if (player == _remotePlayer) {
                _opponentLabel.text = player.alias;
            }
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
