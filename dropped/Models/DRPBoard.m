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

// Stores
@property NSMutableArray *positions, *appendedCharacters;

// MatchData
// First byte - version number
// Next 36 bytes - initial state
// Next 1 byte - the number of turns taken so far
// Following n sequences
//      First byte - the number of characters (m) in move
//      Next 2 * m bytes - positions (i j)
//      Next m bytes     - Appended characters
//
//      Multipliers use values "3", "4", or "5", NOT bytes
//      If multipliers are present, there are an additional
//      1 or 2 bytes after the appended characters to represent
//      color
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
        
        // Read History (it's good for you)
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

- (NSArray *)positionsPlayedForTurn:(NSInteger)turn
{
    return nil;
}

- (NSArray *)appendedCharactersForTurn:(NSInteger)turn
{
    return nil;
}

#pragma mark Move Submission

- (NSDictionary *)submitMoveForPositions:(NSArray *)positions
{
    return [self diffForPositions:positions appendedCharacters:nil];
}

- (NSDictionary *)diffForPositions:(NSArray *)positions appendedCharacters:(NSArray *)characters
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
