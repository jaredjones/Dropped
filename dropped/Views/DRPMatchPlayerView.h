//
//  DRPMatchPlayerView.h
//  dropped
//
//  Created by Brad Zeis on 1/2/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPosition.h"
#import "DRPCharacter.h"
#import "DRPTileView.h"

@class DRPPlayer, DRPTileView, DRPMatchPlayerView;

@protocol DRPMatchPlayerViewDelegate

- (void)tile:(DRPTileView *)tile wasTappedFromMatchPlayerView:(DRPMatchPlayerView *)matchPlayerView;

@end

@interface DRPMatchPlayerView : UIView <DRPTileViewDelegate>

@property id<DRPMatchPlayerViewDelegate> delegate;

- (instancetype)initWithAlignment:(DRPDirection)alignment;
- (void)observePlayer:(DRPPlayer *)player;

- (void)setIsCurrentPlayer:(BOOL)isCurrentPlayer withColor:(DRPColor)color;
- (void)resetScore:(NSInteger)score;

- (void)setTileEnabled:(BOOL)enabled;

@end
