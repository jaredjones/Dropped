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
#import "DRPMove.h"

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
            NSString *d = @"ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJ\0";
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
        
        // Load moves
        _moves = [[NSMutableArray alloc] init];
        
        NSInteger numberTurns = 0;
        NSData *numberTurnsSubdata = [data subdataWithRange:NSMakeRange(36, 1)];
        [numberTurnsSubdata getBytes:&numberTurns length:1];
        
        NSInteger offset = 37;
        for (NSInteger turn = 0; turn < numberTurns; turn++) {
            NSInteger numberCharacters = 0;
            [data getBytes:&numberTurns range:NSMakeRange(offset, 1)];
            offset += 1;
            
            DRPMove *move = [[DRPMove alloc] init];
            [_moves addObject:move];
            
            for (NSInteger c = 0; c < numberCharacters; c++) {
                NSInteger i = 0, j = 0;
                [data getBytes:&i range:NSMakeRange(offset + 2 * c, 1)];
                [data getBytes:&j range:NSMakeRange(offset + 2 * c + 1, 1)];
                
                DRPPosition *position = [DRPPosition positionWithI:i j:j];
                
                NSData *characterData = [data subdataWithRange:NSMakeRange(offset + 2 *numberCharacters + c, 1)];
                NSString *character = [[NSString alloc] initWithData:characterData
                                                            encoding:NSUTF8StringEncoding];
                
                // Create tile, simulate dropping, load into history
                DRPTile *tile = [DRPTile tileWithPosition:position character:character];
                [move appendTile:tile];
            }
            
            offset += 3 * numberCharacters;
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
}

@end
