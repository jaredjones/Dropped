//
//  DRPMatch.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class DRPBoard;

@interface DRPMatch : NSObject

@property (readonly) DRPBoard *board;

@property (readonly) GKTurnBasedMatch *gkMatch;

- (instancetype)initWithGKMatch:(GKTurnBasedMatch *)gkMatch;

@end
