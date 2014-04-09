//
//  DRPPlayer.h
//  dropped
//
//  Created by Brad Zeis on 11/29/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRPPlayer : NSObject

@property (readonly) BOOL isLocalPlayer;
@property NSString *alias;
@property BOOL aliasLoaded;

// Either 0 or 1 (played first or second)
@property (readonly) NSInteger turn;
@property NSInteger score;

- (instancetype)initWithTurn:(NSInteger)turn isLocalPlayer:(BOOL)isLocalPlayer;

+ (NSString *)opponentSynonym;
- (NSString *)firstPrintableAliasCharacter;

@end
