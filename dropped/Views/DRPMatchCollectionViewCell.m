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

// Stored from the set DRPMatch to keep references around for KVO comparisons
@property NSArray *players;
@property DRPPlayer *remotePlayer;

@end

@implementation DRPMatchCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Load tiles
        self.tiles = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 2; i++) {
            DRPTileView *tile = [DRPTileView dequeueResusableTile];
            tile.hidden = YES;
            tile.selected = YES;
            tile.scaleCharacter = NO;
            tile.enabled = NO;
            
            [self.tiles addObject:tile];
            [self.contentView addSubview:tile];
        }
        
        // Load Labels
        self.opponentLabel = [[UILabel alloc] initWithFrame:[self opponentLabelFrame]];
        self.opponentLabel.font = [FRBSwatchist fontForKey:@"page.cueEmphasizedFont"];
        self.opponentLabel.textColor = [FRBSwatchist colorForKey:@"colors.black"];
        [self.contentView addSubview:self.opponentLabel];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:[self statusLabelFrame]];
        self.statusLabel.font = [FRBSwatchist fontForKey:@"page.cueFont"];
        self.statusLabel.textColor = [FRBSwatchist colorForKey:@"colors.black"];
        [self.contentView addSubview:self.statusLabel];
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)configureWithUserData:(DRPMatch *)match
{
    // Determine match state
    // Keep track of which tile to highlight (only highlight local player tiles)
    self.cellState = [DRPMatchCollectionViewCell cellStateForMatch:match];
    NSArray *highlights = @[({
        @(self.cellState == DRPMatchCellStatePlayer1Active && match.localPlayer.turn == 0);
    }), ({
        @(self.cellState == DRPMatchCellStatePlayer2Active && match.localPlayer.turn == 1);
    })];
    
    // Reset tiles
    [self removeObservers];
    self.players = match.players;
    self.remotePlayer = match.remotePlayer;
    [self addObserversForPlayers:self.players];
    
    NSArray *colors = [match.board multiplierColorsForTurn:match.currentTurn];
    for (NSInteger i = 0; i < match.players.count; i++) {
        DRPTileView *tile = self.tiles[i];
        DRPPlayer *player = [match playerForTurn:i];
        
        tile.character = [DRPCharacter characterWithCharacter:[player firstPrintableAliasCharacter]];
        tile.character.color = [colors[i] intValue];
        
        // Highlight tile
        if ([highlights[i] boolValue]) {
            tile.highlighted = YES;
        } else {
            tile.highlighted = NO;
        }
        
        [tile resetAppearence];
        
        // Make sure match winner is on top
        if (player != match.winner) {
            [self.contentView sendSubviewToBack:tile];
        }
        
        // TODO: animate the cell over
        tile.frame = [DRPMatchCollectionViewCell tileFrameForTurn:i state:self.cellState];
        
        tile.hidden = NO;
    }
    
    // Set Labels
    self.opponentLabel.text = match.remotePlayer.alias;
    
    if (match.finished) {
        if (match.tied) {
            self.statusLabel.text = @"Tied";
        } else {
            self.statusLabel.text = @"Game Over";
        }
    } else if ([match isLocalPlayerTurn]) {
        self.statusLabel.text = @"Your Turn!";
    } else {
        self.statusLabel.text = @"Waiting for Turn";
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
    for (DRPPlayer *player in self.players) {
        [player addObserver:self forKeyPath:@"alias" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObservers
{
    for (DRPPlayer *player in self.players) {
        [player removeObserver:self forKeyPath:@"alias"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[DRPPlayer class]] && [keyPath isEqualToString:@"alias"]) {
        
        for (NSInteger i = 0; i < self.players.count; i++) {
            DRPPlayer *player = self.players[i];
            if (player != object) continue;
            
            DRPTileView *tile = self.tiles[i];
            
            DRPCharacter *oldCharacter = tile.character;
            DRPCharacter *newCharacter = [DRPCharacter characterWithCharacter:[player firstPrintableAliasCharacter]];
            newCharacter.color = oldCharacter.color;
            tile.character = newCharacter;
            
            if (player == self.remotePlayer) {
                self.opponentLabel.text = player.alias;
            }
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
