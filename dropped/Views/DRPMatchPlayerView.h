//
//  DRPMatchPlayerView.h
//  dropped
//
//  Created by Brad Zeis on 1/2/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPosition.h"

@class DRPPlayer;

@interface DRPMatchPlayerView : UIView

- (instancetype)initWithOrigin:(CGPoint)origin alignment:(DRPDirection)alignment;
- (void)observePlayer:(DRPPlayer *)player;

@end
