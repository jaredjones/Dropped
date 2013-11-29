//
//  DRPMatch.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class DRPPlayer, DRPBoard;

@interface DRPMatch : NSObject

@property (readonly) NSString *matchID;

@property (readonly) DRPBoard *board;
@property (readonly) GKTurnBasedMatch *gkMatch;
@property (readonly) NSArray *players;

// Loaded from Cache
- (instancetype)initWithMatchID:(NSString *)matchID;
// Created fresh
- (instancetype)initWithGKMatch:(GKTurnBasedMatch *)gkMatch;

- (DRPPlayer *)localPlayer;
- (DRPPlayer *)currentPlayer;

@end
