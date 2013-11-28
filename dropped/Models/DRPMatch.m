//
//  DRPMatch.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPMatch.h"
#import "DRPBoard.h"

@interface DRPMatch ()

@property BOOL gameCenterMatch;

@end

@implementation DRPMatch

- (instancetype)initWithMatchID:(NSString *)matchID
{
    self = [super init];
    if (self) {
        _matchID = matchID;
        
        // Load from cache (pull nsdata out)
        // -- matchData
        // -- players
        // _board = new board with cached data
        
        // Load Game Center match
        if (_gameCenterMatch) {
            [GKTurnBasedMatch loadMatchWithID:_matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
                _gkMatch = match;
                [self reloadMatchData];
                [self reloadPlayerAliases];
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
        // Initialize new board from scratch
        _board = [[DRPBoard alloc] initWithMatchData:nil];
    }
    return self;
}

#pragma mark - Game Center

- (void)reloadMatchData
{
    [_gkMatch loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        [_board appendNewData:matchData];
        // Post NSNotification if new turns available
    }];
}

- (void)reloadPlayerAliases
{
    [GKPlayer loadPlayersForIdentifiers:nil withCompletionHandler:^(NSArray *players, NSError *error) {
        // Post NSNotification
    }];
}

- (void)submitTurnForPositions:(NSArray *)positions
{
    // Add move to history (assumed correct, don't do further error checking)
    [_board appendMoveForPositions:positions];
    
    // Send move off to Game Center
    NSArray *paricipants = @[];
    NSData *data = _board.matchData;
    [_gkMatch endTurnWithNextParticipants:paricipants turnTimeout:GKTurnTimeoutNone matchData:data completionHandler:^(NSError *error) {
        // Post NSNotification to signal ViewControllers
    }];
}

@end
