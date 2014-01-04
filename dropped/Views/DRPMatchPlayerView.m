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

@interface DRPMatchPlayerView ()

@property DRPTileView *tile;
@property UILabel *score, *alias;

@property DRPDirection alignment;
@property BOOL renderTile;

@end

@implementation DRPMatchPlayerView

- (id)initWithFrame:(CGRect)frame alignment:(DRPDirection)alignment tile:(BOOL)tile
{
    self = [super initWithFrame:frame];
    if (self) {
        _alignment = alignment;
        _renderTile = tile;
        [self loadViews];
    }
    return self;
}

#pragma mark View Loading

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
    NSTextAlignment textAlignment = _alignment == DRPDirectionLeft ? NSTextAlignmentLeft : NSTextAlignmentRight;
    CGFloat y = [FRBSwatchist floatForKey:@"board.boardPadding"];
    
    if (withTile) {
        _tile = ({
            DRPTileView *tile = [DRPTileView dequeueResusableTile];
            tile.center = ({
                CGFloat l = [FRBSwatchist floatForKey:@"board.tileLength"];
                CGFloat padding = [FRBSwatchist floatForKey:@"board.boardPadding"];
                CGFloat x = _alignment == DRPDirectionLeft ? padding + l / 2 : self.bounds.size.width - padding - l / 2;
                CGPoint center = CGPointMake(x, l / 2 + y);
                center;
            });
            
            tile.enabled = NO;
            tile.selected = YES;
            [self addSubview:tile];
            tile;
        });
        _tile.character = [DRPCharacter characterWithCharacter:@"B"];
        
        y += _tile.frame.size.height + [FRBSwatchist floatForKey:@"board.tileMargin"];
    }
    
    _score = ({
        UIFont *font = [FRBSwatchist fontForKey:@"board.tileFont"];
        UILabel *label = [[UILabel alloc] initWithFrame:({
            CGFloat height = [FRBSwatchist floatForKey:@"board.tileLength"];
            CGRect frame = CGRectMake(0, y + labelOffset(font, height), self.bounds.size.width, height);
            CGRectInset(frame, [FRBSwatchist floatForKey:@"board.boardPadding"], 0);
        })];
        label.font = font;
        label.textAlignment = textAlignment;
        [self addSubview:label];
        label;
    });
    _score.text = @"795";
    
    y += _score.frame.size.height + [FRBSwatchist floatForKey:@"board.tileMargin"];
    
    _alias = ({
        UIFont *font = [FRBSwatchist fontForKey:@"page.cueFont"];
        UILabel *label = [[UILabel alloc] initWithFrame:({
            CGFloat height = 17;
            CGRect frame = CGRectMake(0, y, self.bounds.size.width, height);
            CGRectInset(frame, [FRBSwatchist floatForKey:@"board.boardPadding"], 0);
        })];
        label.font = font;
        label.textAlignment = textAlignment;
        [self addSubview:label];
        label;
    });
    _alias.text = @"bradzeis";
}

- (void)observePlayer:(DRPPlayer *)player
{
}

@end
