//
//  DRPPlayer.m
//  dropped
//
//  Created by Brad Zeis on 11/29/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPlayer.h"
#import "DRPUtility.h"
#import "DRPNetworking.h"

#pragma mark - DRPPlayer

@implementation DRPPlayer

- (instancetype)initWithTurn:(NSInteger)turn isLocalPlayer:(BOOL)isLocalPlayer
{
    self = [super init];
    if (self) {
        _turn = turn;
        _isLocalPlayer = isLocalPlayer;
    }
    return self;
}

+ (NSString *)opponentSynonym
{
    // TODO: moar better
    static NSArray *opponentSynomyms;
    if (!opponentSynomyms) {
        opponentSynomyms = @[@"Foe",
                             @"Enemy",
                             @"Opponent",
                             @"Opposer",
                             @"Adversary",
                             @"Rival",
                             @"Combatant",
                             @"Competitor",
                             @"Contender"];
    }
    
    return opponentSynomyms[arc4random_uniform(opponentSynomyms.count)];
}

- (NSString *)firstPrintableAliasCharacter
{
    return (self.alias && self.aliasLoaded) ? firstPrintableCharacter(self.alias) : @"hash";
}

@end
