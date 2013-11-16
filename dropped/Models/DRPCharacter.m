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
    if ([character isEqualToString:@"3"] || [character isEqualToString:@"three"]) {
        return [DRPCharacter characterWithMulitplier:3];
    } else if ([character isEqualToString:@"4"] || [character isEqualToString:@"four"]) {
        return [DRPCharacter characterWithMulitplier:4];
    } else if ([character isEqualToString:@"5"] || [character isEqualToString:@"five"]) {
        return [DRPCharacter characterWithMulitplier:5];
    }
    
    DRPCharacter *c = [DRPCharacter new];
    c.character = character;
    c.multiplier = -1;
    return c;
}

+ (instancetype)characterWithMulitplier:(NSInteger)multiplier
{
    DRPCharacter *c = [DRPCharacter new];
    switch (multiplier) {
        case 3:
            c.character = @"three";
            break;
        case 4:
            c.character = @"four";
            break;
        case 5:
            c.character = @"five";
            break;
        default:
            c = nil;
            break;
    }
    c.multiplier = multiplier;
    return c;
}

@end
