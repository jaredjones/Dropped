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
#import "DRPCharacterHistogram.h"
#import "DRPUtility.h"

@interface DRPBoard ()

// Make sure that each DRPCharacter is unique. NO
// structure sharing since each DRPCharacter stores
// its adjacent multiplier DRPCharacter.
// _history is an array of NSDictionaries { DRPPosition : DRPCharacter }
//      (storing history in NSDictionaries is much cleaner because
//       dictionary[invalid_position] == nil instead of a crash. -- Brad)
@property NSMutableArray *history;
// Stores multiplier positions for each turn
@property NSMutableArray *multiplierHistory;
@property NSMutableArray *playedWords;
@property DRPCharacterHistogram *histogram;


// MatchData
// First byte               - version number
// Next 36 bytes            - initial characters
// Next 2 bytes             - multiplier colors
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

@end

#pragma mark - DRPBoard

@implementation DRPBoard

- (instancetype)initWithMatchData:(NSData *)data
{
    self = [super init];
    if (self) {
        
        // Create board from scratch if data is nil
        
        if (data == nil || data.length == 0) {
            [self generateNewBoard];
            
        } else {
            [self loadData:data];
        }
    }
    return self;
}

#pragma mark History Accessors

- (DRPCharacter *)characterAtPosition:(DRPPosition *)position forTurn:(NSInteger)turn
{
    return _history[turn][position];
}

- (DRPCharacter *)characterAtPosition:(DRPPosition *)position
{
    return [_history lastObject][position];
}

- (NSString *)wordForPositions:(NSArray *)positions forTurn:(NSInteger)turn
{
    NSMutableString *word = [NSMutableString stringWithString:@""];
    for (DRPPosition *position in positions) {
        [word appendString:((DRPCharacter *)_history[turn][position]).character];
    }
    return word;
}

- (NSString *)wordForPositions:(NSArray *)positions
{
    return [self wordForPositions:positions forTurn:_history.count - 1];
}

- (DRPPlayedWord *)wordPlayedForTurn:(NSInteger)turn
{
    return _playedWords[turn];
}

// Returns [leftColor, rightColor] (DRPColor cast as NSNumber) for turn
- (NSArray *)multiplierColorsForTurn:(NSInteger)turn
{
    NSArray *multiplierPositions = _multiplierHistory[turn];
    // TODO: make a charactersForPositions:forTurn: method
    NSArray *multipliers = @[[self characterAtPosition:multiplierPositions[0] forTurn:turn],
                             [self characterAtPosition:multiplierPositions[1] forTurn:turn]];
    
    NSNumber *color1 = @(((DRPCharacter *)multipliers[0]).color);
    NSNumber *color2 = @(((DRPCharacter *)multipliers[1]).color);
    
    NSMutableArray *colors = [[NSMutableArray alloc] initWithObjects:color1, nil];
    
    if ( ((DRPPosition *)multiplierPositions[0]).i < ((DRPPosition *)multiplierPositions[1]).i) {
        [colors addObject:color2];
    } else {
        [colors insertObject:color2 atIndex:0];
    }
    
    return colors;
}

- (NSDictionary *)scores
{
    NSMutableDictionary *scores = [NSMutableDictionary dictionaryWithDictionary:@{@0 : @0, @1 : @0}];
    for (NSInteger i = 0; i < _playedWords.count; i++) {
        DRPPlayedWord *playedWord = _playedWords[i];
        scores[@(i % 2)] = @([scores[@(i % 2)] integerValue] + [self scoreForPlayedWord:playedWord forTurn:i]);
    }
    return scores;
}

- (NSInteger)scoreForPlayedWord:(DRPPlayedWord *)playedWord forTurn:(NSInteger)turn
{
    NSInteger multiplier = 0;
    for (DRPPosition *position in playedWord.multipliers) {
        multiplier += [self characterAtPosition:position forTurn:turn].multiplier;
    }
    
    multiplier = multiplier == 0 ? 1 : multiplier;
    return multiplier * playedWord.positions.count;
}

- (NSInteger)currentTurn
{
    return _playedWords.count;
}

#pragma mark Move Submission

// These methods assume that a move is being
// appended into history. Call only appendMoveForPositions:
// directly.

- (DRPPlayedWord *)appendMoveForPositions:(NSArray *)positions
{
    // Generate DRPPlayedWord for move
    DRPPlayedWord *playedWord = [DRPPlayedWord new];
    playedWord.positions = positions;
    playedWord.multipliers = [self multipliersActivatedForPositions:positions];
    playedWord.additionalMultipliers = [self additionalMultipliersForPositions:positions];
    
    NSMutableArray *droppedMultipliers = [NSMutableArray arrayWithArray:playedWord.multipliers];
    [droppedMultipliers addObjectsFromArray:playedWord.additionalMultipliers];
    for (DRPPosition *position in droppedMultipliers) {
        [_histogram unregisterColor:[self characterAtPosition:position].color];
    }
    
    playedWord.appendedCharacters = [_histogram appendedCharactersForPositions:positions
                                                            droppedMultipliers:[NSSet setWithArray:droppedMultipliers].allObjects
                                                                   multipliers:[_multiplierHistory lastObject]];
    
    // Add Move to History
    NSMutableDictionary *historyItem = [self deepCopyHistoryItem:[_history lastObject]];
    [self applyDiff:playedWord toHistoryItem:historyItem];
    [self appendHistoryItem:historyItem];
    [_playedWords addObject:playedWord];
    
    return playedWord;
}

- (NSArray *)multipliersActivatedForPositions:(NSArray *)positions
{
    // First, loop through each DRPPosition and count
    // the number of times each multiplier is adjacent
    NSMutableDictionary *multiplierAdjacentCount = [[NSMutableDictionary alloc] init];
    for (DRPPosition *position in positions) {
        DRPCharacter *character = [self characterAtPosition:position];
        if (character.adjacentMultiplier) {
            if (!multiplierAdjacentCount[character.adjacentMultiplier]) {
                multiplierAdjacentCount[character.adjacentMultiplier] = @(0);
            }
            NSNumber *count = @([multiplierAdjacentCount[character.adjacentMultiplier] intValue] + 1);
            multiplierAdjacentCount[character.adjacentMultiplier] = count;
        }
    }
    
    // Make a list of the multipliers that have
    // enough adjacent DRPCharacters selected
    NSMutableArray *activatedMultipliers = [[NSMutableArray alloc] init];
    for (DRPCharacter *multiplier in multiplierAdjacentCount) {
        if ([multiplierAdjacentCount[multiplier] intValue] >= multiplier.multiplier) {
            
            // Find the DRPPosition of multiplier
            // This is necessary since DRPCharacters don't hold position information
            DRPPosition *multiplierPosition;
            for (DRPPosition *position in [_multiplierHistory lastObject]) {
                if ([self characterAtPosition:position] == multiplier) {
                    multiplierPosition = position;
                }
            }
            
            [activatedMultipliers addObject:multiplierPosition];
        }
    }
    
    return activatedMultipliers;
}

// Multipliers can't sit in the bottom left and right corners.
// These 2 methods detect when a move would cause a multiplier
// to reach that position. It must be dropped and replaced in
// the turn.
- (NSArray *)additionalMultipliersForPositions:(NSArray *)positions
{
    NSMutableArray *additionMultipliers = [[NSMutableArray alloc] init];
    DRPPosition *m = [self additionMultiplierForPositions:positions inColumn:0];
    if (m) {
        [additionMultipliers addObject:m];
    }
    m = [self additionMultiplierForPositions:positions inColumn:5];
    if (m) {
        [additionMultipliers addObject:m];
    }
    
    return additionMultipliers;
}

- (DRPPosition *)additionMultiplierForPositions:(NSArray *)positions inColumn:(NSInteger)column
{
    DRPPosition *multiplier;
    for (NSInteger j = 5; j >= 0; j--) {
        DRPPosition *position = [DRPPosition positionWithI:column j:j];
        if ([positions containsObject:position]) {
            continue;
        }
        
        if ([self characterAtPosition:position].multiplier) {
            multiplier = position;
        }
        break;
    }
    return multiplier;
}

#pragma mark MatchData Loading

- (void)generateNewBoard
{
    _history = [[NSMutableArray alloc] init];
    _multiplierHistory = [[NSMutableArray alloc] init];
    _playedWords = [[NSMutableArray alloc] init];
    _histogram = [[DRPCharacterHistogram alloc] init];
    
    NSDictionary *initialState = [_histogram generateNewBoard];
    [self updateAdjacentMultipliersForHistoryItem:initialState];
    [self appendHistoryItem:initialState];
}

// These methods care very much about state. Do not call any
// of them directly except loadData.

- (void)loadData:(NSData *)data
{
    NSInteger dataVersion = 0;
    [data getBytes:&dataVersion length:1];
    
    _history = [[NSMutableArray alloc] init];
    _multiplierHistory = [[NSMutableArray alloc] init];
    _playedWords = [[NSMutableArray alloc] init];
    _histogram = [[DRPCharacterHistogram alloc] init];
    
    [self loadInitialState:[data subdataWithRange:NSMakeRange(1, data.length - 1)]];
    [self loadTurns:[data subdataWithRange:NSMakeRange(39, data.length - 39)]];
}

// Load the state of the board at the beginning of the match
// Just loads first 36 characters
- (void)loadInitialState:(NSData *)data
{
    NSString *initialState = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 36)]
                                                   encoding:NSUTF8StringEncoding];
    NSData *initialMultiplierColors = [data subdataWithRange:NSMakeRange(36, 2)];
    
    NSMutableDictionary *firstTurn = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 0; j < 6; j++) {
            NSString *c = [initialState substringWithRange:NSMakeRange(i + 6 * j, 1)];
            DRPCharacter *character = [DRPCharacter characterWithCharacter:c];
            
            if (character.multiplier) {
                DRPColor color = DRPColorNil;
                [initialMultiplierColors getBytes:&color length:1];
                initialMultiplierColors = [initialMultiplierColors subdataWithRange:NSMakeRange(1, initialMultiplierColors.length - 1)];
                character.color = color;
                [_histogram registerColor:color];
            }
            
            firstTurn[[DRPPosition positionWithI:i j:j]] = character;
        }
    }
    
    [self updateAdjacentMultipliersForHistoryItem:firstTurn];
    [self appendHistoryItem:firstTurn];
}

- (void)loadTurns:(NSData *)turnsData
{
    NSInteger numberTurns = 0;
    [turnsData getBytes:&numberTurns length:1];
    if (numberTurns == 0) {
        return;
    }
    
    NSMutableData *mturnsData = [NSMutableData dataWithData:[turnsData subdataWithRange:NSMakeRange(1, turnsData.length - 1)]];
    
    for (NSInteger turn = 0; turn < numberTurns; turn++) {
        // Each call to loadTurn:forTurn: modifies mturnsData until no data is left
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
    
    NSInteger appendedCharactersLength = numberPositions + numberMultipliers + numberAdditional;
    playedWord.appendedCharacters = [self loadCharactersFromData:turnData numberCharacters:appendedCharactersLength];
    [turnData setData:[turnData subdataWithRange:NSMakeRange(appendedCharactersLength, turnData.length - appendedCharactersLength)]];
    
    for (DRPPosition *position in [playedWord.multipliers arrayByAddingObjectsFromArray:playedWord.additionalMultipliers]) {
        DRPCharacter *character = [self characterAtPosition:position];
        [_histogram unregisterColor:character.color];
    }
    
    for (DRPCharacter *character in playedWord.appendedCharacters) {
        // Load colors
        if (character.multiplier) {
            DRPColor color = DRPColorNil;
            [turnData getBytes:&color length:1];
            if (turnData.length > 1) {
                // Don't worry about setting data at the end of the rope
                [turnData setData:[turnData subdataWithRange:NSMakeRange(1, turnData.length - 1)]];
            }
            
            character.color = color;
            [_histogram registerColor:color];
        }
    }
    
    [_playedWords addObject:playedWord];
    
    // Apply diff to new history item
    NSMutableDictionary *historyItem = [self deepCopyHistoryItem:[_history lastObject]];
    [self applyDiff:playedWord toHistoryItem:historyItem];
    [self appendHistoryItem:historyItem];
}

// Called when new data is downloaded from Game Center
// and history needs to be updated without reloading
// the entire game
- (void)appendNewData:(NSData *)newData
{
    NSInteger numberNewDataTurns = 0;
    [newData getBytes:&numberNewDataTurns range:NSMakeRange(1 + 36 + 2, 1)];
    
    if (numberNewDataTurns <= _playedWords.count) return;
    
    NSInteger numberNewTurns = numberNewDataTurns - _playedWords.count;
    NSMutableData *mnewData = [NSMutableData dataWithData:[newData subdataWithRange:NSMakeRange(40, newData.length - 40)]];
    
    for (NSInteger i = 0; i < numberNewDataTurns; i++) {
        if (i < numberNewDataTurns - numberNewTurns) {
            // Turn is already loaded, advance to next one
            // See big comment at top of file for explanation
            NSInteger m = 0, j = 0, k = 0;
            [mnewData getBytes:&m range:NSMakeRange(0, 1)];
            [mnewData getBytes:&j range:NSMakeRange(1, 1)];
            [mnewData getBytes:&k range:NSMakeRange(2, 1)];
            
            NSInteger turnLength = 3 + 3 * m + 4 * (j + k);
            [mnewData setData:[mnewData subdataWithRange:NSMakeRange(turnLength, mnewData.length - turnLength)]];
            continue;
        }
        
        [self loadTurn:mnewData];
    }
}

#pragma mark MatchData Dumping

- (NSData *)matchData
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    // Version Number
    NSInteger version = 1;
    [data appendBytes:&version length:1];
    
    // Initial State
    NSMutableDictionary *firstTurn = _history[0];
    for (NSInteger j = 0; j < 6; j++) {
        for (NSInteger i = 0; i < 6; i++) {
            DRPPosition *position = [DRPPosition positionWithI:i j:j];
            DRPCharacter *character = firstTurn[position];
            [data appendData:[character.character dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    for (NSInteger i = 0; i < 2; i++) {
        DRPPosition *multiplierPosition = _multiplierHistory[0][i];
        DRPColor multiplierColor = [self characterAtPosition:multiplierPosition forTurn:0].color;
        [data appendBytes:&multiplierColor length:1];
    }
    
    // Turns
    NSInteger numberTurns = _playedWords.count;
    [data appendBytes:&numberTurns length:1];
    
    for (DRPPlayedWord *playedWord in _playedWords) {
        // Add the position counts to the data
        NSInteger numberPositions = playedWord.positions.count;
        NSInteger numberActivated = playedWord.multipliers.count;
        NSInteger numberAdditional = playedWord.additionalMultipliers.count;
        [data appendBytes:&numberPositions length:1];
        [data appendBytes:&numberActivated length:1];
        [data appendBytes:&numberAdditional length:1];
        
        // positions contains ALL of the positions in the move (characters and multipliers)
        // add them all to the data
        NSMutableArray *positions = [[NSMutableArray alloc] init];
        [positions addObjectsFromArray:playedWord.positions];
        [positions addObjectsFromArray:playedWord.multipliers];
        [positions addObjectsFromArray:playedWord.additionalMultipliers];
        
        for (DRPPosition *position in positions) {
            NSInteger i = position.i, j = position.j;
            [data appendBytes:&i length:1];
            [data appendBytes:&j length:1];
        }
        
        // Add the appended characters and calculate new multiplier colors
        NSMutableData *multiplierColorData = [[NSMutableData alloc] init];
        for (DRPCharacter *character in playedWord.appendedCharacters) {
            [data appendData:[character.character dataUsingEncoding:NSUTF8StringEncoding]];
            
            // found a multiplier
            if (character.multiplier) {
                DRPColor color = character.color;
                [multiplierColorData appendBytes:&color length:1];
            }
        }
        
        [data appendData:multiplierColorData];
    }
    
    return data;
}

#pragma mark History Manipulation

- (void)appendHistoryItem:(NSDictionary *)item
{
    [_history addObject:item];
    [_multiplierHistory addObject:[self multipliersInHistoryItem:item]];
}

- (NSMutableDictionary *)deepCopyHistoryItem:(NSDictionary *)item
{
    NSMutableDictionary *copied = [[NSMutableDictionary alloc] initWithCapacity:6];
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 0; j < 6; j++) {
            DRPPosition *position = [DRPPosition positionWithI:i j:j];
            DRPCharacter *old = item[position];
            DRPCharacter *newCharacter = [DRPCharacter characterWithCharacter:old.character];
            newCharacter.color = old.color;
            copied[position] = newCharacter;
        }
    }
    return copied;
}

- (void)applyDiff:(DRPPlayedWord *)playedWord toHistoryItem:(NSMutableDictionary *)item
{
    NSDictionary *diff = playedWord.diff;
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 5; j >= -6; j--) {
            DRPPosition *startPosition = [DRPPosition positionWithI:i j:j];
            if (j >= 0) {
                DRPPosition *endPosition = diff[startPosition];
                if (endPosition) {
                    item[endPosition] = item[startPosition];
                }
            } else {
                NSArray *end = diff[startPosition];
                if (end) {
                    DRPCharacter *character = end[0];
                    DRPPosition *endPosition = end[1];
                    item[endPosition] = character;
                } else {
                    break;
                }
            }
        }
    }
    
    [self updateAdjacentMultipliersForHistoryItem:item];
}

- (void)updateAdjacentMultipliersForHistoryItem:(NSDictionary *)item
{
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 0; j < 6; j++) {
            DRPPosition *position = [DRPPosition positionWithI:i j:j];
            DRPCharacter *character = item[position];
            
            if (!character.multiplier) continue;
            
            for (DRPDirection dir = 0; dir < 8; dir++) {
                DRPPosition *adjacent = [position positionInDirection:dir];
                DRPCharacter *adjacentCharacter = item[adjacent];
                adjacentCharacter.adjacentMultiplier = character;
            }
        }
    }
}

- (NSArray *)multipliersInHistoryItem:(NSDictionary *)item
{
    NSMutableArray *multipliers = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger j = 0; j < 6; j++) {
            DRPPosition *position = [DRPPosition positionWithI:i j:j];
            DRPCharacter *character = item[position];
            if (character.multiplier) {
                [multipliers addObject:position];
            }
        }
    }
    return multipliers;
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

- (void)prettyPrintHistoryItem:(NSDictionary *)item
{
    NSMutableString *string = [NSMutableString stringWithString:@"\n"];
    for (NSInteger j = 0; j < 6; j++) {
        for (NSInteger i = 0; i < 6; i++) {
            DRPPosition *position = [DRPPosition positionWithI:i j:j];
            [string appendString:((DRPCharacter *)item[position]).character];
            [string appendString:@" "];
        }
        [string appendString:@"\n"];
    }
    NSLog(@"%@", string);
}

@end
