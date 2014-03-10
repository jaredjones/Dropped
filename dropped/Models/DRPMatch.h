//
//  DRPMatch.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPPlayer, DRPBoard, DRPPlayedWord;

@interface DRPMatch : NSObject

@property (readonly) NSString *matchID;

@property (readonly) DRPBoard *board;
@property (readonly) NSArray *players;
@property (readonly) NSInteger localPlayerTurn;

// Takes a trip to the server to load matchData
+ (void)matchWithMatchID:(NSString *)matchID completion:(void (^)(DRPMatch *))completion;
+ (void)newMatchWithCompletion:(void (^)(DRPMatch *))completion;

// Shit ton of convenience methods that require menial calculation
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

// Server Interaction
- (void)reloadMatchDataWithCompletion:(void(^)(BOOL newTurns))completion;
- (void)submitTurnForPositions:(NSArray *)positions;

@end
