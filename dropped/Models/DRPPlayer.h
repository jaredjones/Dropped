//
//  DRPPlayer.h
//  dropped
//
//  Created by Brad Zeis on 11/29/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface DRPPlayer : NSObject

@property GKTurnBasedParticipant *participant;
@property NSString *alias;

// Either 0 or 1 (played first or second)
@property NSInteger turn;
@property NSInteger score;

- (instancetype)initWithParticipant:(GKTurnBasedParticipant *)participant turn:(NSInteger)turn;

- (NSString *)firstPrintableAliasCharacter;

@end
