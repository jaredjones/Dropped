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
#import "FRBSwatchist.h"

@interface DRPMatch ()

@property (readwrite) GKTurnBasedMatch *gkMatch;
@property BOOL gameCenterMatch;

@property (readwrite) DRPBoard *board;
@property (readwrite) NSMutableArray *players;

@end

#pragma mark - DRPMatch

@implementation DRPMatch

// TODO: should probably kill this one, it's not used yet
- (instancetype)initWithMatchID:(NSString *)matchID
{
    self = [super init];
    if (self) {
        _matchID = matchID;
        
        // Load from cache based on matchID (pull nsdata out)
        // -- matchData
        // self.board = new board with cached data
        
        // Load Game Center match
        if (self.gameCenterMatch) {
            [GKTurnBasedMatch loadMatchWithID:self.matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
                self.gkMatch = match;
                [self loadGKPlayers];
                [self reloadMatchDataWithCompletion:nil];
            }];
        }
    }
    return self;
}

// TODO: closing app before taking a turn randomizes the board each time
- (instancetype)initWithGKMatch:(GKTurnBasedMatch *)gkMatch
{
    self = [super init];
    if (self) {
        self.gkMatch = gkMatch;
        _matchID = self.gkMatch.matchID;
        self.gameCenterMatch = YES;
        
        // Initialize new board from scratch
        [self loadGKPlayers];
        self.board = [[DRPBoard alloc] initWithMatchData:self.gkMatch.matchData];
        [self reloadPlayerScores];
        
        // Make sure matchData is saved as soon as the board is generated
        // so it isn't regenerated later if the first player doesn't make
        // a move immediately.
        if (self.board.currentTurn == 0) {
            [self saveMatchData];
        }
    }
    return self;
}

#pragma mark Game Center

- (void)loadGKPlayers
{
    self.players = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 2; i++) {
        [(NSMutableArray *)self.players addObject:[[DRPPlayer alloc] initWithParticipant:self.gkMatch.participants[i] turn:i]];
    }
    [self reloadPlayerAliases];
}

- (void)reloadPlayerAliases
{
    NSMutableArray *identifiers = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 2; i++) {
        DRPPlayer *player = self.players[i];
        
        if (player.participant.playerID) {
            [identifiers addObject:((DRPPlayer *)self.players[i]).participant.playerID];
            
        } else {
            // Load stock alias "PlayerN"
            player.alias = [NSString stringWithFormat:@"player%ld", (long)i+1];
        }
    }
    
    [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error) {
        // UI that cares about player aliases will use KVO to find out about updates
        for (NSInteger i = 0; i < players.count; i++) {
            [self playerForPlayerID:((GKPlayer *)players[i]).playerID].alias = ((GKPlayer *)players[i]).alias;
        }
    }];
}

- (void)reloadMatchDataWithCompletion:(void(^)(BOOL newTurns))completion
{
    [self.gkMatch loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        NSInteger turns = self.board.currentTurn;
        [self.board appendNewData:matchData];
        [self reloadPlayerScores];
        
        if (completion) {
            BOOL newTurns = self.board.currentTurn > turns;
            completion(newTurns);
        }
        
        // TODO: might as well reload aliases
    }];
}

- (void)submitTurnForPositions:(NSArray *)positions
{
    // Add move to history (assumed correct, don't do further error checking)
    DRPPlayedWord *playedWord = [self.board appendMoveForPositions:positions];
    
    // Send move off to Game Center
    NSArray *participants = @[self.currentPlayer.participant];
    NSData *data = self.board.matchData;
    
    if (!self.finished) {
        [self.gkMatch endTurnWithNextParticipants:participants turnTimeout:GKTurnTimeoutNone matchData:data completionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"endTurn error: %@", error.localizedDescription);
                return;
            }
            
            [self postTurnSubmissionNotificationsWithPlayedWord:playedWord];
        }];
        
    } else {
        // Game Finished
        // Set match outcomes
        for (DRPPlayer *player in self.players) {
            if (self.tied) {
                player.participant.matchOutcome = GKTurnBasedMatchOutcomeTied;
            } else if (self.winner == player) {
                player.participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
            } else {
                player.participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }
        }
        
        [self.gkMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"endTurn error: %@", error.localizedDescription);
                return;
            }
            
            [self postTurnSubmissionNotificationsWithPlayedWord:playedWord];
        }];
    }
}

- (void)postTurnSubmissionNotificationsWithPlayedWord:(DRPPlayedWord *)playedWord
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DRPGameCenterReceivedLocalTurnNotificationName
                                                        object:nil
                                                      userInfo:@{@"playedWord" : playedWord}];
    
    [self reloadPlayerScores];
}

- (void)saveMatchData
{
    [self.gkMatch saveCurrentTurnWithMatchData:self.board.matchData completionHandler:^(NSError *error) {
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

#pragma mark Player

- (DRPPlayer *)localPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if ([((DRPPlayer *)self.players[0]).participant.playerID isEqualToString:localPlayer.playerID]) {
        return self.players[0];
    }
    return self.players[1];
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

- (DRPPlayer *)playerForPlayerID:(NSString *)playerID
{
    for (NSInteger i = 0; i < 2; i++) {
        if ([((DRPPlayer *)self.players[i]).participant.playerID isEqualToString:playerID]) {
            return self.players[i];
        }
    }
    return nil;
}

- (void)reloadPlayerScores
{
    NSDictionary *scores = self.board.scores;
    for (NSInteger i = 0; i < 2; i++) {
        ((DRPPlayer *)self.players[i]).score = [scores[@(i)] integerValue];
    }
}

@end
