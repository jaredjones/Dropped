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
#import "DRPPlayedWord.h"

@interface DRPBoard ()

// Make sure that each DRPCharacter is unique. NO
// structure sharing.
@property NSMutableArray *history;
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

- (void)loadData:(NSData *)data;
- (void)loadInitialState:(NSData *)data;
- (void)loadTurns:(NSData *)data;
- (void)loadTurn:(NSMutableData *)data;

- (NSData *)dumpToMatchData;

- (NSMutableArray *)deepCopyHistoryItem:(NSArray *)item;
- (void)applyDiff:(DRPPlayedWord *)playedWord toHistoryItem:(NSMutableArray *)item;

- (NSArray *)loadPositionsFromData:(NSData *)data numberPositions:(NSInteger)length;
- (NSArray *)loadCharactersFromData:(NSData *)data numberCharacters:(NSInteger)length;
- (void)prettyPrintHistoryItem:(NSArray *)item;

@end

#pragma mark - DRPBoard

@implementation DRPBoard

- (instancetype)initWithMatchData:(NSData *)data
{
    self = [super init];
    if (self) {
        
        if (data == nil) {
            // Test data uses \ddd for non-ASCII characters
            NSMutableString *d = [NSMutableString stringWithString:@"\001ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJ"];
            
            // 1 turn
            [d appendString:@"\001"];
            
            // 3 characters, 0 multipliers, 0 additional
            [d appendString:@"\003\000\000"];
            // Positions
            [d appendString:@"\000\001\000\003\000\004A45\003\005"];
            
            data = [d dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        [self loadData:data];
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

// These methods care very much about state. Do not call any
// of them directly except loadData.

- (void)loadData:(NSData *)data
{
    NSInteger dataVersion = 0;
    [data getBytes:&dataVersion length:1];
    
    _history = [[NSMutableArray alloc] init];
    _playedWords = [[NSMutableArray alloc] init];
    
    [self loadInitialState:[data subdataWithRange:NSMakeRange(1, data.length - 1)]];
    [self loadTurns:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
}

// Load the state of the board at the beginning of the match
// Just loads first 36 characters
- (void)loadInitialState:(NSData *)data
{
    NSString *initialState = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 36)]
                                                   encoding:NSUTF8StringEncoding];
    
    NSMutableArray *firstTurn = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < 6; i++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        
        for (NSInteger j = 0; j < 6; j++) {
            NSString *c = [initialState substringWithRange:NSMakeRange(i + 6 * j, 1)];
            DRPCharacter *character = [DRPCharacter characterWithCharacter:c];
            [column addObject:character];
        }
        
        [firstTurn addObject:column];
    }
    
    [_history addObject:firstTurn];
}

- (void)loadTurns:(NSData *)turnsData
{
    NSInteger numberTurns = 0;
    [turnsData getBytes:&numberTurns length:1];
    if (numberTurns == 0) return;
    
    NSMutableData *mturnsData = [NSMutableData dataWithData:[turnsData subdataWithRange:NSMakeRange(1, turnsData.length - 1)]];
    
    for (NSInteger turn = 0; turn < numberTurns; turn++) {
        // Each call to loadTurn:forTurn: modifies mturnsData until
        // no data is left
        [self loadTurn:mturnsData];
    }
}

// Append a new turn into history
// 1. Loads a DRPPlayedWord to represent the move
// 2. Copies the last history item
// 3. Steps forward on the copy using DRPPlayedWord
// 4. Adds the now different history item to history
- (void)loadTurn:(NSMutableData *)turnData
{
    NSInteger numberPositions = 0;
    NSInteger numberMultipliers = 0;
    NSInteger numberAdditional = 0;
    [turnData getBytes:&numberPositions range:NSMakeRange(0, 1)];
    [turnData getBytes:&numberMultipliers range:NSMakeRange(1, 1)];
    [turnData getBytes:&numberAdditional range:NSMakeRange(2, 1)];
    [turnData setData:[turnData subdataWithRange:NSMakeRange(3, turnData.length - 3)]];
    
    // Create DRPPlayedWord
    DRPPlayedWord *playedWord = [DRPPlayedWord new];
    
    playedWord.positions = [self loadPositionsFromData:turnData numberPositions:numberPositions];
    [turnData setData:[turnData subdataWithRange:NSMakeRange(2 * numberPositions, turnData.length - 2 * numberPositions)]];
    
    playedWord.multipliers = [self loadPositionsFromData:turnData numberPositions:numberMultipliers];
    [turnData setData:[turnData subdataWithRange:NSMakeRange(2 * numberMultipliers, turnData.length - 2 * numberMultipliers)]];
    
    playedWord.additionalMultipliers = [self loadPositionsFromData:turnData numberPositions:numberAdditional];
    [turnData setData:[turnData subdataWithRange:NSMakeRange(2 * numberAdditional, turnData.length - 2 * numberAdditional)]];
    
    playedWord.appendedCharacters = [self loadCharactersFromData:turnData numberCharacters:numberPositions];
    [turnData setData:[turnData subdataWithRange:NSMakeRange(numberPositions, turnData.length - numberPositions)]];
    
    for (DRPCharacter *character in playedWord.appendedCharacters) {
        NSLog(@"%@", character.character);
        if (character.multiplier != -1) {
            NSInteger color = 0;
            [turnData getBytes:&color length:1];
            [turnData setData:[turnData subdataWithRange:NSMakeRange(1, turnData.length - 1)]];
            // TODO: Characters need a COLOR property
        }
    }
    
    // Apply diff to new history item
    NSMutableArray *historyItem = [self deepCopyHistoryItem:[_history lastObject]];
    [self applyDiff:playedWord toHistoryItem:historyItem];
    [_history addObject:historyItem];
}

#pragma mark MatchData Dumping

- (NSData *)dumpToMatchData
{
    return nil;
}

#pragma mark History Manipulation

- (NSMutableArray *)deepCopyHistoryItem:(NSArray *)item
{
    NSMutableArray *copied = [[NSMutableArray alloc] initWithCapacity:6];
    for (NSInteger i = 0; i < 6; i++) {
        NSMutableArray *column = [[NSMutableArray alloc] initWithCapacity:6];
        
        for (NSInteger j = 0; j < 6; j++) {
            DRPCharacter *old = (DRPCharacter *)item[i][j];
            DRPCharacter *newCharacter = [DRPCharacter characterWithCharacter:old.character];
            [column addObject:newCharacter];
        }
        
        [copied addObject:column];
    }
    return copied;
}

- (void)applyDiff:(DRPPlayedWord *)playedWord toHistoryItem:(NSMutableArray *)item
{
    NSDictionary *diff = playedWord.diff;
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 5; j >= -6; j--) {
            DRPPosition *startPosition = [DRPPosition positionWithI:i j:j];
            if (j >= 0) {
                DRPPosition *endPosition = diff[startPosition];
                if (endPosition) {
                    item[endPosition.i][endPosition.j] = item[startPosition.i][startPosition.j];
                }
            } else {
                NSArray *end = diff[startPosition];
                if (end) {
                    DRPCharacter *character = end[0];
                    DRPPosition *endPosition = end[1];
                    item[endPosition.i][endPosition.j] = character;
                } else {
                    break;
                }
            }
        }
    }
}

#pragma mark Utility

- (NSArray *)loadPositionsFromData:(NSData *)data numberPositions:(NSInteger)length
{
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    for (NSInteger n = 0; n < length; n++) {
        NSInteger i = 0, j = 0;
        [data getBytes:&i range:NSMakeRange(2 * n, 1)];
        [data getBytes:&j range:NSMakeRange(2 * n + 1, 1)];
        DRPPosition *position = [DRPPosition positionWithI:i j:j];
        [positions addObject:position];
    }
    return positions;
}

- (NSArray *)loadCharactersFromData:(NSData *)data numberCharacters:(NSInteger)length
{
    NSMutableArray *characters = [[NSMutableArray alloc] init];
    for (NSInteger n = 0; n < length; n++) {
        NSString *c = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(n, 1)]
                                            encoding:NSUTF8StringEncoding];
        DRPCharacter *character = [DRPCharacter characterWithCharacter:c];
        [characters addObject:character];
    }
    return characters;
}

- (void)prettyPrintHistoryItem:(NSArray *)item
{
    NSMutableString *string = [NSMutableString stringWithString:@"\n"];
    for (NSInteger j = 0; j < 6; j++) {
        for (NSInteger i = 0; i < 6; i++) {
            [string appendString:((DRPCharacter *)item[i][j]).character];
            [string appendString:@" "];
        }
        [string appendString:@"\n"];
    }
    NSLog(@"%@", string);
}

@end
