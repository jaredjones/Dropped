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
    [self loadViewsPhone5];
}

- (void)loadViewsPhone5
{
    _tile = [DRPTileView dequeueResusableTile];
    _tile.center = _alignment == DRPDirectionLeft ? CGPointMake(30, 30) : CGPointMake(self.frame.size.width - 30, 30);
    _tile.enabled = NO;
    _tile.selected = YES;
    _tile.character = [DRPCharacter characterWithCharacter:@"B"];
    [_tile resetAppearence];
    [self addSubview:_tile];
    
    UIFont *font = [FRBSwatchist fontForKey:@"page.tileFont"];
    CGFloat offset = -font.ascender + font.capHeight / 2 + 50 / 2 - 1;
    
    _score = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 58 + offset, 160, 50), 5, 0)];
    _score.font = [FRBSwatchist fontForKey:@"page.tileFont"];
    _score.textAlignment = _alignment == DRPDirectionLeft ? NSTextAlignmentLeft : NSTextAlignmentRight;
    _score.text = @"795";
    [self addSubview:_score];
    
    _alias =[[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 111, 160, 17), 5, 0)];
    _alias.font = [FRBSwatchist fontForKey:@"page.cueFont"];
    _alias.textAlignment = _alignment == DRPDirectionLeft ? NSTextAlignmentLeft : NSTextAlignmentRight;
    _alias.text = @"bradzeis";
    [self addSubview:_alias];
}

- (void)observePlayer:(DRPPlayer *)player
{
}

@end
