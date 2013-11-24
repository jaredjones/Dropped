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

@end

@implementation DRPCharacterHistogram

- (instancetype)init
{
    self = [super init];
    if (self) {
        _letters = [[NSMutableDictionary alloc] init];
        _multipliers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Updating Histogram

- (void)addCharacters:(NSArray *)characters
{
    for (DRPCharacter *character in characters) {
        [self addCharacter:character];
    }
}

- (void)addCharacter:(DRPCharacter *)character
{
    
}

#pragma mark Character Generation

// Generates a new DRPCharacter based on data in histogram
- (DRPCharacter *)randomCharacter
{
    NSString *alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSInteger c = arc4random_uniform(26);
    return [DRPCharacter characterWithCharacter:[alpha substringWithRange:NSMakeRange(c, 1)]];
}

- (DRPCharacter *)randomMultiplier
{
    return [DRPCharacter characterWithMulitplier:arc4random_uniform(3) + 3];
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
    
    // Generate and insert new random multiplier in valid columns
    for (DRPPosition *droppedPosition in droppedMultipliers) {
        NSInteger newColumn;
        while (true) {
            newColumn = [self columnForNewMultiplierWithOccupiedColumn:occupiedColumn];
            NSInteger rows = ((NSMutableArray *)positions[newColumn]).count;
            if (rows > 0) {
                DRPCharacter *multiplier = [self randomMultiplier];
                ((NSMutableArray *)positions[newColumn])[arc4random_uniform(rows)] = multiplier;
                break;
            }
            // Keep trying if row is invalid
            // Don't worry, Jared. "Computers are fast." - Novak
        }
        occupiedColumn = newColumn;
    }
}

// Returns a random result
// If called with -1, there are no multipliers on the board
- (NSInteger)columnForNewMultiplierWithOccupiedColumn:(NSInteger)occupiedColumn
{
    if (occupiedColumn == -1) {
        return arc4random_uniform(6);
    }
    // The key here is that there will always be one
    // multiplier in columns 0-2 and the other in
    // columns 3-5 since there has to be 2 columns
    // between them
    NSInteger range, offset;
    if (occupiedColumn >= 3) {
        range = occupiedColumn - 2;
        offset = 0;
    } else {
        range = 3 - occupiedColumn;
        offset = 5 - occupiedColumn;
    }
    return MAX(arc4random_uniform(range) + offset, 5);
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
                [self addCharacter:character];
                [appendedCharacters addObject:character];
            }
        }
    }
    return appendedCharacters;
}

@end
