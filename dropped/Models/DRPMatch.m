//
//  DRPMatch.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPMatch.h"
#import "DRPPlayer.h"
#import "DRPBoard.h"

#import "DRPNetworking.h"
#import "FRBSwatchist.h"

@interface DRPMatch ()

@property (readwrite) DRPBoard *board;
@property (readwrite) NSInteger localPlayerTurn;
@property (readwrite) NSMutableArray *players;

@end

#pragma mark - DRPMatch

@implementation DRPMatch

// TODO: make sure the generation methods fail gracefully

+ (void)matchWithMatchID:(NSString *)matchID completion:(void (^)(DRPMatch *))completion
{
    DRPMatch *match = [[DRPMatch alloc] initWithMatchID:matchID];
    // TODO: return early if the match was cached
    
    [match reloadMatchDataWithCompletion:^(BOOL newTurns) {
        completion(match);
    }];
}

+ (void)newMatchWithCompletion:(void (^)(DRPMatch *))completion
{
    [[DRPNetworking sharedNetworking] requestMatchWithFriend:nil withCompletion:^(NSString *matchID, NSInteger localPlayerTurn) {
        // No matchID, serious error. Return early
        if (!matchID) {
            completion(nil);
        }
        
        DRPMatch *match = [[DRPMatch alloc] initWithMatchID:matchID];
        
        [match reloadMatchDataWithCompletion:^(BOOL newTurns) {
            // Make sure to save the matchData if the board was just generated
            if (localPlayerTurn == 0) {
                [match saveMatchData];
            }
            
            completion(match);
        }];
    }];
}

- (instancetype)initWithMatchID:(NSString *)matchID
{
    self = [super init];
    if (self) {
        _matchID = matchID;
        // TODO: load match from cache if possible
    }
    return self;
}

#pragma mark Server Interaction

- (void)loadPlayers
{
    self.players = [[NSMutableArray alloc] initWithCapacity:2];
    for (NSInteger i = 0; i < 2; i++) {
        ((NSMutableArray *)self.players)[i] = [[DRPPlayer alloc] initWithTurn:i isLocalPlayer:i == self.localPlayerTurn];
    }
}

- (void)reloadMatchDataWithCompletion:(void(^)(BOOL newTurns))completion
{
    __block NSString *localAlias;
    [[DRPNetworking sharedNetworking] aliasForDeviceIDOrUserID:[DRPNetworking sharedNetworking].deviceID withUserID:[DRPNetworking sharedNetworking].userID withCompletion:^(NSString *alias) {
        localAlias = alias;
    }];
    
    [[DRPNetworking sharedNetworking] matchDataForMatchID:self.matchID withCompletion:^(NSData *matchData, NSInteger localPlayerTurn, NSString *remotePlayerAlias) {
        BOOL newTurns;
        
        // Load boardData
        // If this is the first time the matchData is loaded, initialize a DRPBoard and load the players
        if (!self.board) {
            self.board = [[DRPBoard alloc] initWithMatchData:matchData];
            self.localPlayerTurn = localPlayerTurn;
            [self loadPlayers];
            newTurns = YES;
            
        } else {
            NSInteger turns = self.board.currentTurn;
            [self.board appendNewData:matchData];
            newTurns = self.board.currentTurn > turns;
        }
        
        if (localAlias){
            self.localPlayer.alias = localAlias;
            self.localPlayer.aliasLoaded = YES;
        }else{
            self.localPlayer.alias = @"You";
        }
        
        // Reset remotePlayer.alias
        if (remotePlayerAlias) {
            self.remotePlayer.alias = remotePlayerAlias;
            self.remotePlayer.aliasLoaded = YES;
            
        } else {
            // Only generate a random opponent synonym once
            self.remotePlayer.alias = self.remotePlayer.alias ?: [DRPPlayer opponentSynonym];
        }
        
        [self reloadPlayerScores];
        
        completion(newTurns);
    }];
}

- (void)submitTurnForPositions:(NSArray *)positions
{
    // Add move to history (assumed correct, don't do further error checking)
    [self.board appendMoveForPositions:positions];
    NSData *data = self.board.matchData;

    [[DRPNetworking sharedNetworking] submitMatchData:data forMatchID:self.matchID advanceTurn:YES withCompletion:^{
        // TODO: post UI stuff
        [[NSNotificationCenter defaultCenter] postNotificationName:DRPReceivedMatchTurnNotificationName
                                                            object:nil
                                                          userInfo:@{@"matchID" : self.matchID}];
    }];
}

- (void)saveMatchData
{
    [[DRPNetworking sharedNetworking] submitMatchData:self.board.matchData forMatchID:self.matchID advanceTurn:NO withCompletion:^{
    }];
}

#pragma mark Match Data

- (NSInteger)numberOfTurns
{
    return 10;
}

- (NSInteger)currentTurn
{
    return self.board.currentTurn;
}

- (NSInteger)turnsLeft
{
    return self.numberOfTurns - self.currentTurn;
}

- (BOOL)finished
{
    return self.turnsLeft == 0;
}

- (BOOL)tied
{
    return ((DRPPlayer *)self.players[0]).score == ((DRPPlayer *)self.players[1]).score;
}

#pragma mark Players

- (DRPPlayer *)localPlayer
{
    return self.players[self.localPlayerTurn];
}

- (DRPPlayer *)remotePlayer
{
    return [self playerForTurn:([self localPlayer].turn + 1) % 2];
}

- (DRPPlayer *)currentPlayer
{
    return self.players[self.board.currentTurn % 2];
}

- (DRPPlayer *)winner
{
    if (!self.finished) return nil;
    
    if (((DRPPlayer *)self.players[0]).score > ((DRPPlayer *)self.players[1]).score) {
        return self.players[0];
    }
    return self.players[1];
}

- (DRPPlayer *)playerForTurn:(NSInteger)turn
{
    return self.players[turn % 2];
}

- (BOOL)isLocalPlayerTurn
{
    return self.currentPlayer == self.localPlayer;
}

- (void)reloadPlayerScores
{
    NSDictionary *scores = self.board.scores;
    for (NSInteger i = 0; i < 2; i++) {
        ((DRPPlayer *)self.players[i]).score = [scores[@(i)] integerValue];
    }
}

@end
