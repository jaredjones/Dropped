//
//  DRPCharacterHistogram.m
//  dropped
//
//  Created by Brad Zeis on 11/17/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCharacterHistogram.h"
#import "DRPPlayedWord.h"
#import "DRPPosition.h"
#import "DRPCharacter.h"

#pragma mark - DRPCharacterHistogram

@interface DRPCharacterHistogram ()

@property NSMutableDictionary *letters, *multipliers;
@property NSInteger numberLetters, numberMultipliers;
@property NSDictionary *letterPercentages;
@property NSArray *keys;

@end

@implementation DRPCharacterHistogram

- (instancetype)init
{
    self = [super init];
    if (self) {
        _letters = [[NSMutableDictionary alloc] init];
        _multipliers = [[NSMutableDictionary alloc] init];
        _letterPercentages = @{@"A" : @8.4966, @"B" : @2.0720, @"C" : @4.5388, @"D" : @3.3844, @"E" : @11.1607, @"F" : @1.8121, @"G" : @2.4705, @"H" : @3.0034, @"I" : @7.5448, @"J" : @0.1965, @"K" : @1.1016, @"L" : @5.4893, @"M" : @3.0129, @"N" : @6.6544, @"O" : @7.1635, @"P" : @3.1671, @"Q" : @0.1962, @"R" : @7.5809, @"S" : @5.7351, @"T" : @6.9509, @"U" : @3.6308, @"V" : @1.0074, @"W" : @1.2899, @"X" : @0.2902, @"Y" : @1.7779, @"Z" : @0.2722};
        _keys = _letterPercentages.allKeys;
    }
    return self;
}

#pragma mark Character Generation

// Generates a new DRPCharacter based on data in histogram
#define ARC4RANDOM_MAX 0x100000000
- (DRPCharacter *)randomCharacter
{
    double r = ((double)arc4random() / ARC4RANDOM_MAX) * 100.0f;
    double sum = 0.0;
    
    NSString *prev = nil;
    for (NSString *letter in _keys)
    {
        sum += [_letterPercentages[letter] doubleValue];
         prev = letter;
        if (sum > r)
            break;
    }
    
    return [DRPCharacter characterWithCharacter:prev];
}

- (DRPCharacter *)randomMultiplier
{
    //3-5
    //60 30 10
    NSInteger multiplier = arc4random_uniform(3) + 3;
    
    DRPCharacter *character = [DRPCharacter characterWithMulitplier:multiplier];
    character.color = arc4random_uniform(DRPColorNil);
    return character;
}

#pragma mark AppendedCharacters Generation

- (NSArray *)appendedCharactersForPositions:(NSArray *)positions
                         droppedMultipliers:(NSArray *)droppedMultipliers
                                multipliers:(NSArray *)multipliers
{
    // First, sort the positions of selected and dropped characters into a nested array
    // [ [positions in column 0], [positions in column 1], ...]
    NSMutableArray *dropped = [NSMutableArray arrayWithArray:positions];
    [dropped addObjectsFromArray:droppedMultipliers];
    NSArray *sortedPositions = [self sortedPositionsFromPositions:dropped];
    
    // Compute any new multipliers to add to appendedCharacters
    // Mutate sortedPositions in place
    [self insertNewMultipliersInSortedPositions:sortedPositions
                             droppedMultipliers:droppedMultipliers
                                    multipliers:multipliers];
    
    // Generate the rest of the appendedCharacters and
    // convert to flat array
    return [self appendedCharactersForSortedPositions:sortedPositions];
}

- (NSArray *)sortedPositionsFromPositions:(NSArray *)positions
{
    NSArray *sorted = [positions sortedArrayUsingComparator:^NSComparisonResult(DRPPosition *a, DRPPosition *b) {
        if (a.i < b.i) {
            return NSOrderedAscending;
        } else if (a.i == a.i && a.j < b.j) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    NSInteger p = 0;
    
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 6; i++) {
        NSMutableArray *positions = [[NSMutableArray alloc] init];
        [columns addObject:positions];
        
        while (p < sorted.count && ((DRPPosition *)sorted[p]).i == i) {
            [positions addObject:sorted[p]];
            p++;
        }
    }
    return columns;
}

- (void)insertNewMultipliersInSortedPositions:(NSArray *)positions
                           droppedMultipliers:(NSArray *)droppedMultipliers
                                  multipliers:(NSArray *)multipliers
{
    if (!droppedMultipliers.count) return;
    
    NSInteger occupiedColumn = -1;
    // If only one multiplier is being dropped, find the column
    // of the multiplier staying on the board
    if (droppedMultipliers.count == 1) {
        for (DRPPosition *occupied in multipliers) {
            if (![droppedMultipliers containsObject:occupied]) {
                occupiedColumn = occupied.i;
            }
        }
    }
    
    // Keep a list of valid columns to place a multiplier in
    // Determine which columns can receive multipliers
    NSMutableArray *validColumns = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 6; i++) {
        if (((NSArray *)positions[i]).count) {
            [validColumns addObject:@(i)];
        }
    }
    
    // Generate the new multipliers by picking a valid column
    for (NSInteger i = 0; i < droppedMultipliers.count; i++) {
        // First, remove any columns that are invalidated because
        // they are too close to an occupied column
        validColumns = [self removeInvalidColumnsFromArray:validColumns
                                         forOccupiedColumn:occupiedColumn];
        
        NSInteger newColumn = [validColumns[arc4random_uniform(validColumns.count)] integerValue];
        
        DRPCharacter *multiplier = [self randomMultiplier];
        NSInteger rows = ((NSMutableArray *)positions[newColumn]).count;
        ((NSMutableArray *)positions[newColumn])[arc4random_uniform(rows)] = multiplier;
        occupiedColumn = newColumn;
    }
}

- (NSMutableArray *)removeInvalidColumnsFromArray:(NSArray *)validColumns forOccupiedColumn:(NSInteger)occupiedColumn
{
    if (occupiedColumn == -1) return (NSMutableArray *)validColumns;
    
    NSRange range;
    if (occupiedColumn < 3) {
        range = NSMakeRange(0, occupiedColumn + 3);
    } else {
        range = NSMakeRange(occupiedColumn - 1, 5);
    }
    
    NSMutableArray *new = [[NSMutableArray alloc] init];
    for (NSNumber *n in validColumns) {
        if (!NSLocationInRange([n integerValue], range)) {
            [new addObject:n];
        }
    }
    return new;
}

- (NSArray *)appendedCharactersForSortedPositions:(NSArray *)sortedPositions
{
    NSMutableArray *appendedCharacters = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 6; i++) {
        for (NSInteger p = 0; p < ((NSMutableArray *)sortedPositions[i]).count; p++) {
            // Reuse newly added multipliers (they were added in a previous step)
            if ([sortedPositions[i][p] isKindOfClass:[DRPCharacter class]]) {
                DRPCharacter *multiplier = sortedPositions[i][p];
                // [self addMultiplier:multiplier];
                [appendedCharacters addObject:multiplier];
            } else {
                // Add new character
                DRPCharacter *character = [self randomCharacter];
                [appendedCharacters addObject:character];
            }
        }
    }
    return appendedCharacters;
}

@end
