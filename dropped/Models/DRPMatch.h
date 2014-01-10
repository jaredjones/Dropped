//
//  DRPMatch.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define DRPGameCenterReceivedTurnNotificationName @"DRPGameCenterReceivedTurnNotification"

@class DRPPlayer, DRPBoard, DRPPlayedWord;

@interface DRPMatch : NSObject

@property (readonly) NSString *matchID;

@property (readonly) DRPBoard *board;
@property (readonly) GKTurnBasedMatch *gkMatch;
@property (readonly) NSArray *players;

// Loaded from Cache
- (instancetype)initWithMatchID:(NSString *)matchID;
// Created fresh
- (instancetype)initWithGKMatch:(GKTurnBasedMatch *)gkMatch;

- (NSInteger)currentTurn;

- (DRPPlayer *)localPlayer;
- (DRPPlayer *)currentPlayer;

- (void)submitTurnForPositions:(NSArray *)positions;

@end
