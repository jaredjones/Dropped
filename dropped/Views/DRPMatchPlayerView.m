//
//  DRPMatchPlayerView.m
//  dropped
//
//  Created by Brad Zeis on 1/2/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMatchPlayerView.h"
#import "DRPTileView.h"
#import "DRPCharacter.h"
#import "FRBSwatchist.h"
#import "DRPUtility.h"
#import "DRPPlayer.h"

@interface DRPMatchPlayerView ()

@property DRPTileView *tile;
@property UILabel *score, *alias;

@property DRPDirection alignment;
@property DRPColor tileColor;

@property DRPPlayer *player;

@end

@implementation DRPMatchPlayerView

- (instancetype)initWithAlignment:(DRPDirection)alignment
{
    self = [super initWithFrame:({
        CGRect frame = CGRectZero;
        frame.size = self.frameSize;
        frame;
    })];
    if (self) {
        self.alignment = alignment;
        [self loadViews];
    }
    return self;
}

- (void)dealloc
{
    [self.player removeObserver:self forKeyPath:@"alias"];
}

#pragma mark View Loading

- (CGSize)frameSize
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (runningPhone5()) {
            return CGSizeMake(160, 135);
        }
        return CGSizeMake(160, 75);
    }
    return CGSizeMake(384, 232);
}

- (void)loadViews
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (runningPhone5()) {
            [self loadViewsWithTile:YES];
        } else {
            [self loadViewsWithTile:NO];
        }
    } else {
        [self loadViewsWithTile:YES];
    }
}

- (void)loadViewsWithTile:(BOOL)withTile
{
    NSTextAlignment textAlignment = self.alignment == DRPDirectionLeft ? NSTextAlignmentLeft : NSTextAlignmentRight;
    CGFloat y = [FRBSwatchist floatForKey:@"board.boardPadding"];
    
    if (withTile) {
        self.tile = ({
            DRPTileView *tile = [DRPTileView dequeueResusableTile];
            tile.center = ({
                CGFloat l = [FRBSwatchist floatForKey:@"board.tileLength"];
                CGFloat padding = [FRBSwatchist floatForKey:@"board.boardPadding"];
                CGFloat x = self.alignment == DRPDirectionLeft ? padding + l / 2 : self.bounds.size.width - padding - l / 2;
                CGPoint center = CGPointMake(x, l / 2 + y);
                center;
            });
            
            tile.selected = YES;
            tile.permaSelected = YES;
            tile.delegate = self;
            [self addSubview:tile];
            tile;
        });
        
        y += self.tile.frame.size.height + [FRBSwatchist floatForKey:@"board.tileMargin"];
    }
    
    self.score = ({
        UIFont *font = [FRBSwatchist fontForKey:@"board.tileFont"];
        UILabel *label = [[UILabel alloc] initWithFrame:({
            CGFloat height = [FRBSwatchist floatForKey:@"board.tileLength"];
            CGRect frame = CGRectMake(0, y + labelOffset(font, height), self.bounds.size.width, height);
            CGRectInset(frame, [FRBSwatchist floatForKey:@"board.boardPadding"], 0);
        })];
        label.font = font;
        label.textColor = [FRBSwatchist colorForKey:@"colors.black"];
        label.textAlignment = textAlignment;
        [self addSubview:label];
        label;
    });
    
    y += self.score.frame.size.height + [FRBSwatchist floatForKey:@"board.tileMargin"];
    
    self.alias = ({
        UIFont *font = [FRBSwatchist fontForKey:@"page.cueFont"];
        UILabel *label = [[UILabel alloc] initWithFrame:({
            CGFloat height = [FRBSwatchist floatForKey:@"board.tileLength"] / 2;
            CGRect frame = CGRectMake(0, y - labelOffset(font, height), self.bounds.size.width, height);
            CGRectInset(frame, [FRBSwatchist floatForKey:@"board.boardPadding"], 0);
        })];
        label.font = font;
        label.textColor = [FRBSwatchist colorForKey:@"colors.black"];
        label.textAlignment = textAlignment;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:label];
        label;
    });
}

#pragma mark Key-Value Observing

- (void)observePlayer:(DRPPlayer *)player
{
    [self.player removeObserver:self forKeyPath:@"alias"];
    
    self.player = player;
    [self.player addObserver:self forKeyPath:@"alias" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player) {
        if ([keyPath isEqualToString:@"alias"]) {
            [self updatePlayerAlias:coerceObject(change[NSKeyValueChangeNewKey], nil)];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updatePlayerAlias:(NSString *)alias
{
    self.alias.text = self.player.alias;
    self.tile.character = [self playerTileCharacter];
}

- (DRPCharacter *)playerTileCharacter
{
    return ({
        DRPCharacter *character = [DRPCharacter characterWithCharacter:[self.player firstPrintableAliasCharacter]];
        character.color = self.tileColor;
        character;
    });
}

#pragma mark Manual Property Setting

- (void)setIsCurrentPlayer:(BOOL)isCurrentPlayer withColor:(DRPColor)color
{
    // Make sure to save the tile color so if self.tile.character is changed the color stays the same
    self.tileColor = color;
    
    self.tile.character.color = self.tileColor;
    self.tile.permaHighlighted = isCurrentPlayer;
    [self.tile resetAppearence];
}

- (void)resetScore:(NSInteger)score
{
    NSString *scoreString = [NSString stringWithFormat:@"%ld", (long)score];
    self.score.text = scoreString;
    
    CGSize size = [scoreString sizeWithAttributes:@{NSFontAttributeName : self.score.font}];
    
    self.score.center = ({
        CGPoint center = self.score.center;

        if (self.alignment == DRPDirectionLeft) {
            if (size.width <= [FRBSwatchist floatForKey:@"board.tileLength"]) {
                center.x = [FRBSwatchist floatForKey:@"board.tileLength"] / 2 - size.width / 2;
                
            } else {
                center.x = [FRBSwatchist floatForKey:@"board.boardPadding"];
            }
            
        } else {
            if (size.width <= [FRBSwatchist floatForKey:@"board.tileLength"]) {
                center.x = -[FRBSwatchist floatForKey:@"board.tileLength"] / 2 + size.width / 2;
                
            } else {
                center.x = 0;
            }
        }
        
        center.x += (self.bounds.size.width) / 2;
        center;
    });
}

#pragma mark DRPTileViewDelegate

- (void)tileWasHighlighted:(DRPTileView *)tile
{
    // Intentionally left blank
}

- (void)tileWasSelected:(DRPTileView *)tile
{
    [self.delegate tile:tile wasTappedFromMatchPlayerView:self];
}

- (void)tileWasDehighlighted:(DRPTileView *)tile
{
    // Intentionally left blank
}

- (void)tileWasDeselected:(DRPTileView *)tile
{
    // Intentionally left blank
}

- (void)setTileEnabled:(BOOL)enabled
{
    self.tile.enabled = enabled;
}

@end
