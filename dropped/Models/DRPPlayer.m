//
//  DRPPlayer.m
//  dropped
//
//  Created by Brad Zeis on 11/29/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPlayer.h"

#pragma mark - DRPPlayer

@implementation DRPPlayer

- (instancetype)initWithParticipant:(GKTurnBasedParticipant *)participant turn:(NSInteger)turn
{
    self = [super init];
    if (self) {
        _participant = participant;
        _turn = turn;
    }
    return self;
}

@end
