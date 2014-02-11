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
    DRPCharacter *c = [[DRPCharacter alloc] init];
    c.character = character;
    c.multiplier = [character intValue];
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
