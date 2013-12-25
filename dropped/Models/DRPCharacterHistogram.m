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

@property NSDictionary *letterPercentages, *multiplierPercentages;
@property NSArray *letters, *multipliers;

// colorsUsed keeps track of the cycle of colors
// currentColors are the colors of the multipliers on the board
@property NSMutableDictionary *colorsUsed, *currentColors;

@end

@implementation DRPCharacterHistogram

- (instancetype)init
{
    self = [super init];
    if (self) {
        _letterPercentages = @{@"A" : @8.4966, @"B" : @2.0720, @"C" : @4.5388, @"D" : @3.3844, @"E" : @11.1607, @"F" : @1.8121, @"G" : @2.4705, @"H" : @3.0034, @"I" : @7.5448, @"J" : @0.1965, @"K" : @1.1016, @"L" : @5.4893, @"M" : @3.0129, @"N" : @6.6544, @"O" : @7.1635, @"P" : @3.1671, @"Q" : @0.1962, @"R" : @7.5809, @"S" : @5.7351, @"T" : @6.9509, @"U" : @3.6308, @"V" : @1.0074, @"W" : @1.2899, @"X" : @0.2902, @"Y" : @1.7779, @"Z" : @0.2722};
        _letters = _letterPercentages.allKeys;
        
        _multiplierPercentages = @{@"3" : @60, @"4" : @30, @"5" : @10};
        _multipliers = _multiplierPercentages.allKeys;
        
        _colorsUsed = [[NSMutableDictionary alloc] init];
        _currentColors = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Character Generation

// Generates a new DRPCharacter based on data in histogram
- (NSString *)randomCharacterFromKeys:(NSArray *)keys percentages:(NSDictionary *)percentages
{
    float r = ((float)rand() / (float)RAND_MAX) * 100.0f;
    float sum = 0.0;
    
    NSString *prev = nil;
    for (NSString *key in keys)
    {
        sum += [percentages[key] doubleValue];
        prev = key;
        if (sum > r)
            break;
    }
    
    return prev;
}

- (DRPCharacter *)randomCharacter
{
    return [DRPCharacter characterWithCharacter:[self randomCharacterFromKeys:_letters percentages:_letterPercentages]];
}

- (DRPCharacter *)randomMultiplier
{
//    DRPCharacter *character = [DRPCharacter characterWithCharacter:[self randomCharacterFromKeys:_multipliers percentages:_multiplierPercentages]];
    
    // Force 3 multipliers to make testing easier
    DRPCharacter *character = [DRPCharacter characterWithMulitplier:3];
    character.color = [self randomColor];
    return character;
}

#pragma mark Colors

- (DRPColor)randomColor
{
    DRPColor color;
    do {
        color = arc4random_uniform(DRPColorRed);
    } while (_colorsUsed[@(color)] || _currentColors[@(color)]);
    
    [self registerColor:color];
    return color;
}

- (void)registerColor:(DRPColor)color
{
    if (_colorsUsed.count >= 6) {
        [_colorsUsed removeAllObjects];
    } else if (_colorsUsed.count == 5) {
        for (NSNumber *color in _currentColors) {
            if (!_colorsUsed[color]) {
                [_colorsUsed removeAllObjects];
            }
        }
    }
    
    _colorsUsed[@(color)] = @YES;
    _currentColors[@(color)] = @YES;
}

- (void)unregisterColor:(DRPColor)color
{
    [_currentColors removeObjectForKey:@(color)];
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
        if (a.i < b.i) return NSOrderedAscending;
        if (a.i > b.i) return NSOrderedDescending;
        if (a.j < b.j) return NSOrderedAscending;
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
        [self registerColor:multiplier.color];
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
        range = NSMakeRange(occupiedColumn - 2, 5);
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
