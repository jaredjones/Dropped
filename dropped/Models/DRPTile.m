//
//  DRPTile.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPTile.h"

@implementation DRPTile

+ (instancetype)tileWithPosition:(DRPPosition *)position character:(NSString *)character
{
    return [[DRPTile alloc] initWithPosition:position character:character];
}

- (instancetype)initWithPosition:(DRPPosition *)position character:(NSString *)character
{
    self = [super init];
    if (self) {
        _position = position;
        _character = character;
    }
    return self;
}

@end
