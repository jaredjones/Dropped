//
//  DRPCharacter.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCharacter.h"

#pragma mark - DRPCharacter

@interface DRPCharacter ()

@property NSString *character;
@property NSInteger multiplier;

@end

// TODO: make "canonical" versions of DRPCharacter, much the same way there are canonical DRPPositions. Make new characters for multipliers and those with adjacentMultipliers.

@implementation DRPCharacter

+ (instancetype)characterWithCharacter:(NSString *)character
{
    if ([character isEqualToString:@"3"])
        return [DRPCharacter characterWithMulitplier:3];
    if ([character isEqualToString:@"4"])
        return [DRPCharacter characterWithMulitplier:4];
    if ([character isEqualToString:@"5"])
        return [DRPCharacter characterWithMulitplier:5];
    
    
    DRPCharacter *c = [[DRPCharacter alloc] init];
    c.character = character;
    c.multiplier = 0;
    c.color = DRPColorNil;
    return c;
}

+ (instancetype)characterWithMulitplier:(NSInteger)multiplier
{
    DRPCharacter *c = [[DRPCharacter alloc] init];
    
    if (multiplier > 2 && multiplier < 6) {
        c.character = [NSString stringWithFormat:@"%li", (long)multiplier];
    } else {
        c = nil;
    }
    
    c.multiplier = multiplier;
    c.color = DRPColorNil;
    return c;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<DRPCharacter: %@>", _character];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
