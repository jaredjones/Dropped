//
//  DRPPosition.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPosition.h"

#pragma mark - DRPPosition

@implementation DRPPosition

static NSMutableDictionary *positionCache;
+ (instancetype)positionWithI:(NSInteger)i j:(NSInteger)j
{
    if (!positionCache) {
        positionCache = [[NSMutableDictionary alloc] init];
    }
    
    NSNumber *hash = @([DRPPosition hashForI:i j:j]);
    if (!positionCache[hash]) {
        positionCache[hash] = [[DRPPosition alloc] initWithI:i j:j];
    }
    return positionCache[hash];
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

+ (NSUInteger)hashForI:(NSInteger)i j:(NSInteger)j
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + i;
    result = prime * result + j;
    return result;
}

- (NSUInteger)hash
{
    return [DRPPosition hashForI:self.i j:self.j];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    } else if (self.i == ((DRPPosition *)object).i &&
               self.j == ((DRPPosition *)object).j) {
        return YES;
    }
    return NO;
}

#pragma mark Direction

- (DRPPosition *)positionInDirection:(DRPDirection)direction
{
    if (direction == DRPDirectionRight)
        return [DRPPosition positionWithI:self.i + 1 j:self.j];
    
    if (direction == DRPDirectionUpRight)
        return [DRPPosition positionWithI:self.i + 1 j:self.j - 1];
    
    if (direction == DRPDirectionUp)
        return [DRPPosition positionWithI:self.i j:self.j - 1];
    
    if (direction == DRPDirectionUpLeft)
        return [DRPPosition positionWithI:self.i - 1 j:self.j - 1];
    
    if (direction == DRPDirectionLeft)
        return [DRPPosition positionWithI:self.i - 1 j:self.j];
    
    if (direction == DRPDirectionDownLeft)
        return [DRPPosition positionWithI:self.i - 1 j:self.j + 1];

    if (direction == DRPDirectionDown)
        return [DRPPosition positionWithI:self.i j:self.j + 1];

    if (direction == DRPDirectionDownRight)
        return [DRPPosition positionWithI:self.i + 1 j:self.j + 1];

    return nil;
}

@end
