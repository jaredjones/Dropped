//
//  DRPPosition.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPosition.h"

@implementation DRPPosition

+ (instancetype)positionWithI:(NSInteger)i j:(NSInteger)j
{
    return [[DRPPosition alloc] initWithI:i j:j];
}

- (instancetype)initWithI:(NSInteger)i j:(NSInteger)j
{
    self = [super init];
    if (self) {
        _i = i;
        _j = j;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<(%ld %ld)>",
            (long)self.i, (long)self.j];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + _i;
    result = prime * result + _j;
    return result;
}

@end
