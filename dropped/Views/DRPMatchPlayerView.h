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

@class DRPPlayer;

@interface DRPMatchPlayerView : UIView

- (instancetype)initWithAlignment:(DRPDirection)alignment;
- (void)observePlayer:(DRPPlayer *)player;

- (void)setIsCurrentPlayer:(BOOL)isCurrentPlayer withColor:(DRPColor)color;

@end
