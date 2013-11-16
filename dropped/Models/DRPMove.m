//
//  DRPMove.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPMove.h"
#import "DRPTile.h"

@interface DRPMove ()

@property (nonatomic) NSMutableArray *tiles;

@end

@implementation DRPMove

- (instancetype)init
{
    self = [self init];
    if (self) {
        _word = @"";
    }
    return self;
}

#pragma mark - Manipulation

- (void)appendTile:(DRPTile *)tile
{
    [_tiles addObject:tile];
    _word = [_word stringByAppendingString:tile.character];
}

- (void)removeTile:(DRPTile *)tile
{
    NSInteger position = [_tiles indexOfObject:tile];
    if (position >= 0 && position < [_tiles count]) {
        [_tiles removeObjectAtIndex:position];
        _word = [_word stringByReplacingCharactersInRange:NSMakeRange(position, 1) withString:@""];
    }
}

- (NSArray *)tiles
{
    return (NSArray *)_tiles;
}

@end
