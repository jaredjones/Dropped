//
//  DRPPlayer.m
//  dropped
//
//  Created by Brad Zeis on 11/29/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPlayer.h"
#import "DRPUtility.h"

#pragma mark - DRPPlayer

@implementation DRPPlayer

- (instancetype)initWithParticipant:(GKTurnBasedParticipant *)participant turn:(NSInteger)turn
{
    self = [super init];
    if (self) {
        self.participant = participant;
        self.turn = turn;
    }
    return self;
}

- (BOOL)hasParticipant
{
    return self.participant.playerID != nil;
}

- (NSString *)firstPrintableAliasCharacter
{
    return [self hasParticipant] ? firstPrintableCharacter(self.alias) : @"hash";
}

@end
