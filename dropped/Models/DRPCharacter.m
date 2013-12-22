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

@implementation DRPCharacter

+ (instancetype)characterWithCharacter:(NSString *)character
{
    if ([character isEqualToString:@"three"] || [character isEqualToString:@"3"]) {
        return [DRPCharacter characterWithMulitplier:3];
    } else if ([character isEqualToString:@"four"] || [character isEqualToString:@"4"]) {
        return [DRPCharacter characterWithMulitplier:4];
    } else if ([character isEqualToString:@"five"] || [character isEqualToString:@"5"]) {
        return [DRPCharacter characterWithMulitplier:5];
    }
    
    DRPCharacter *c = [DRPCharacter new];
    c.character = character;
    c.multiplier = 0;
    c.color = DRPColorNil;
    return c;
}

+ (instancetype)characterWithMulitplier:(NSInteger)multiplier
{
    DRPCharacter *c = [DRPCharacter new];
    switch (multiplier) {
        case 3:
            c.character = @"3";
            break;
        case 4:
            c.character = @"4";
            break;
        case 5:
            c.character = @"5";
            break;
        default:
            c = nil;
            break;
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

- (BOOL)isEqual:(DRPCharacter *)object {
    if (![_character isEqual:object.character]) {
        return NO;
    }
    if (_multiplier != object.multiplier) {
        return NO;
    }
    return _adjacentMultiplier == object.adjacentMultiplier;
}

@end
