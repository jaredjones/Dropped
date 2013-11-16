//
//  DRPMatch.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPMatch.h"
#import "DRPBoard.h"

@implementation DRPMatch

- (instancetype)initWithGKMatch:(GKTurnBasedMatch *)gkMatch
{
    self = [super init];
    if (self) {
        _gkMatch = gkMatch;
        // matchData loading will be async
        _board = [[DRPBoard alloc] initWithMatchData:gkMatch.matchData];
    }
    return self;
}

@end
