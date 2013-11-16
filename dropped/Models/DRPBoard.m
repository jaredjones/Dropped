//
//  DRPBoard.m
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPBoard.h"
#import "DRPPosition.h"
#import "DRPCharacter.h"

@interface DRPBoard ()

// Maps { turn : 2d array of DRPCharacters }
// Make sure that each DRPCharacter is unique. NO
// structure sharing.
@property NSMutableDictionary *history;
@property NSMutableArray *playedWords;

// MatchData
// First byte               - version number
// Next 36 bytes            - initial characters
// Next 1 byte              - number of turns (n) taken so far
// Following n sequences
//      First byte                  - number of characters (m) in move
//      Second byte                 - number of activated multipliers (j) in move
//      Third byte                  - number of additional multipliers (k) that were
//                                    dropped in the move but did not affect score
//                                    (dropped because they would end up in the bottom
//                                    corners where they could not be activated)
//      Next (2 * (m+j+k)) bytes    - positions (i j), 2 bytes each. Positions from
//                                    0 to (2 * m) were used in the played word, the
//                                    rest are the additional dropped tiles
//      Next (m + j + k) bytes      - appended characters. Stored "bottom up" in
//                                    column order
//      Next (j + k) bytes          - colors for multipliers in appended bytes. Since
//                                    there are always 2 multipliers on the board at
//                                    a given time, we know that the appended characters
//                                    must "replace" each dropped multiplier
//
//      - Multipliers use values "3", "4", or "5" in
//        appended characters, NOT bytes
//      - Total length of sequence is (3 + 3 * m + 4 * (j + k)) bytes
//

- (NSData *)dumpToMatchData;

@end

#pragma mark - DRPBoard

@implementation DRPBoard

- (instancetype)initWithMatchData:(NSData *)data
{
    self = [super init];
    if (self) {
        
        if (data == nil) {
            NSString *d = @"\0ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJ\0";
            data = [d dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return self;
}

#pragma mark History Accessors

- (DRPCharacter *)characterAtPosition:(DRPPosition *)position forTurn:(NSInteger)turn
{
    return nil;
}

- (DRPCharacter *)characterAtPosition:(DRPPosition *)position
{
    return nil;
}

- (NSString *)wordForPositions:(NSArray *)positions forTurn:(NSInteger)turn
{
    return nil;
}

- (NSString *)wordForPositions:(NSArray *)positions
{
    return nil;
}

- (DRPPlayedWord *)wordPlayedForTurn:(NSInteger)turn
{
    return nil;
}

#pragma mark Move Submission

- (DRPPlayedWord *)appendMoveForPositions:(NSArray *)positions
{
    return nil;
}

#pragma mark MatchData Loading

#pragma mark MatchData Dumping

- (NSData *)dumpToMatchData
{
    return nil;
}

@end
