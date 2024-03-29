//
//  DRPMatch.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define DRPGameCenterReceivedLocalTurnNotificationName @"DRPGameCenterReceivedLocalTurnNotification"

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

- (NSInteger)numberOfTurns;
- (NSInteger)currentTurn;
- (NSInteger)turnsLeft;
- (BOOL)finished;
- (BOOL)tied;

- (DRPPlayer *)localPlayer;
- (DRPPlayer *)remotePlayer;
- (DRPPlayer *)currentPlayer;
- (DRPPlayer *)winner;
- (DRPPlayer *)playerForTurn:(NSInteger)turn;
- (BOOL)isLocalPlayerTurn;

- (void)reloadPlayerAliases;
- (void)reloadMatchDataWithCompletion:(void(^)(BOOL newTurns))completion;
- (void)submitTurnForPositions:(NSArray *)positions;

@end
