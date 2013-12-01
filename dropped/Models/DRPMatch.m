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

@interface DRPMatch ()

@property BOOL gameCenterMatch;

@end

#pragma mark - DRPMatch

@implementation DRPMatch

- (instancetype)initWithMatchID:(NSString *)matchID
{
    self = [super init];
    if (self) {
        _matchID = matchID;
        
        // Load from cache based on matchID (pull nsdata out)
        // -- matchData
        // _board = new board with cached data
        
        // Load Game Center match
        if (_gameCenterMatch) {
            [GKTurnBasedMatch loadMatchWithID:_matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
                _gkMatch = match;
                [self loadGKPlayers];
                [self reloadMatchData];
            }];
        }
    }
    return self;
}

- (instancetype)initWithGKMatch:(GKTurnBasedMatch *)gkMatch
{
    self = [super init];
    if (self) {
        _gkMatch = gkMatch;
        _matchID = _gkMatch.matchID;
        _gameCenterMatch = YES;
        
        // Initialize new board from scratch
        [self loadGKPlayers];
        _board = [[DRPBoard alloc] initWithMatchData:_gkMatch.matchData];
        [self reloadPlayerScores];
    }
    return self;
}

#pragma mark Game Center

- (void)loadGKPlayers
{
    _players = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 2; i++) {
        [(NSMutableArray *)_players addObject:[[DRPPlayer alloc] initWithParticipant:_gkMatch.participants[i] turn:i]];
    }
    [self reloadPlayerAliases];
}

- (void)reloadPlayerAliases
{
    NSMutableArray *identifiers = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 2; i++) {
        if (((DRPPlayer *)_players[i]).participant) {
            [identifiers addObject:((DRPPlayer *)_players[i]).participant.playerID];
        }
    }
    
    [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error) {
        // UI that cares about player aliases will use KVO to find out about updates
        for (NSInteger i = 0; i < players.count; i++) {
            [self playerForPlayerID:((GKPlayer *)players[i]).playerID].alias = ((GKPlayer *)players[i]).alias;
        }
    }];
}

- (void)reloadMatchData
{
    [_gkMatch loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        NSInteger turns = _board.currentTurn;
        [_board appendNewData:matchData];
        [self reloadPlayerScores];
        
        // Post NSNotification if new turns available
        if (_board.currentTurn > turns) {
            
        }
    }];
}

- (void)submitTurnForPositions:(NSArray *)positions
{
    // Add move to history (assumed correct, don't do further error checking)
    [_board appendMoveForPositions:positions];
    
    // Send move off to Game Center
    NSArray *paricipants = @[self.currentPlayer];
    NSData *data = _board.matchData;
    [_gkMatch endTurnWithNextParticipants:paricipants turnTimeout:GKTurnTimeoutNone matchData:data completionHandler:^(NSError *error) {
        // Post NSNotification to signal ViewControllers
    }];
}

#pragma mark Player

- (DRPPlayer *)localPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if ([((DRPPlayer *)_players[0]).participant.playerID isEqualToString:localPlayer.playerID]) {
        return _players[0];
    }
    return _players[1];
}

- (DRPPlayer *)currentPlayer
{
    return _players[_board.currentTurn % 2];
}

- (DRPPlayer *)playerForPlayerID:(NSString *)playerID
{
    for (NSInteger i = 0; i < 2; i++) {
        if ([((DRPPlayer *)_players[i]).participant.playerID isEqualToString:playerID]) {
            return _players[i];
        }
    }
    return nil;
}

- (void)reloadPlayerScores
{
    NSDictionary *scores = _board.scores;
    for (NSInteger i = 0; i < 2; i++) {
        ((DRPPlayer *)_players[i]).score = [scores[@(i)] integerValue];
    }
}

@end
