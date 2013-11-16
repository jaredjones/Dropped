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
