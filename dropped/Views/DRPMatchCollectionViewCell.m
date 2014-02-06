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

- (void)configureWithMatch:(DRPMatch *)match
{
    // TODO: deterine match state
    
    // Reset tiles
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
        }
        
        [tile resetAppearence];
        tile.enabled = NO;
        tile.frame = [DRPMatchCollectionViewCell tileFrameForTurn:i state:_cellState];
        tile.hidden = NO;
    }
    
    // TODO: them labels
}

#pragma mark Layout

+ (CGRect)tileFrameForTurn:(NSInteger)turn state:(DRPMatchCellState)cellState
{
    CGRect frame = CGRectZero;
    frame.origin.x = turn * ([FRBSwatchist floatForKey:@"board.tileLength"] + [FRBSwatchist floatForKey:@"board.tileMargin"]);
    frame.size.width = [FRBSwatchist floatForKey:@"board.tileLength"];
    frame.size.height = [FRBSwatchist floatForKey:@"board.tileLength"];
    return frame;
}

@end
