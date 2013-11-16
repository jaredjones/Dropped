//
//  DRPBoard.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPBoard.h"
#import "DRPPosition.h"
#import "DRPTile.h"

@interface DRPBoard ()

@property NSMutableDictionary *boardTiles;
@property NSMutableArray *moves;

@end

@implementation DRPBoard

- (instancetype)initWithMatchData:(NSData *)data
{
    self = [super init];
    if (self) {
        
        if (data == nil) {
            NSString *d = @"ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJb";
            data = [d dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        // Read History (it's good for you)
        // First 36 bytes - initial state
        // Next 1 byte - the number of turns taken so far
        // Following n sequences
        //      First byte - the number of characters (m) in move
        //      Next 2 * m bytes - positions (i j)
        //      Next m bytes     - Replacement letters
        NSData *initialBoardStateData = [data subdataWithRange:NSMakeRange(0, 36)];
        NSString *initialBoardState = [[NSString alloc] initWithBytes:initialBoardStateData.bytes
                                                               length:36
                                                             encoding:NSUTF8StringEncoding];
        
        _boardTiles = [[NSMutableDictionary alloc] init];
        // Load initial board state
        for (NSInteger i = 0; i < 6; i++) {
            for (NSInteger j = 0; j < 6; j++) {
                DRPPosition *position = [DRPPosition positionWithI:i j:j];
                NSString *character = [initialBoardState substringWithRange:NSMakeRange(i + 6 * j, 1)];
                
                NSMutableArray *history = [[NSMutableArray alloc] init];
                [history addObject:@[@(0), character]];
                _boardTiles[position] = history;
            }
        }
    }
    return self;
}

- (DRPTile *)tileAtPosition:(DRPPosition *)position forTurn:(NSInteger)turn
{
    return nil;
}

- (DRPTile *)tileAtPosition:(DRPPosition *)position
{
    return nil;
//    return _boardTiles[position];
}

@end
