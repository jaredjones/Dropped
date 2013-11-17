//
//  DRPCharacterHistogram.m
//  dropped
//
//  Created by Brad Zeis on 11/17/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCharacterHistogram.h"
#import "DRPPlayedWord.h"
#import "DRPCharacter.h"

#pragma mark - DRPCharacterHistogram

@interface DRPCharacterHistogram ()

@property NSMutableDictionary *letters, *multipliers;
@property NSInteger numberLetters, numberMultipliers;

- (DRPCharacter *)randomCharacter;

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

- (DRPPlayedWord *)playedWordForPositions:(NSArray *)positions activatedMultipliers:(NSArray *)activatedMultipliers additionalMultipliers:(NSArray *)additionMultipliers
{
    DRPPlayedWord *playedWord = [DRPPlayedWord new];
    playedWord.positions = positions;
    playedWord.multipliers = activatedMultipliers;
    playedWord.additionalMultipliers = additionMultipliers;
    
    NSMutableArray *appendedCharacters = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < positions.count; i++) {
        DRPCharacter *character = [self randomCharacter];
        [self addCharacter:character];
        [appendedCharacters addObject:character];
    }
    
    playedWord.appendedCharacters = appendedCharacters;
    
    return playedWord;
}

// Generates a new DRPCharacter based on data in histogram
- (DRPCharacter *)randomCharacter
{
    NSString *alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSInteger c = arc4random_uniform(26);
    return [DRPCharacter characterWithCharacter:[alpha substringWithRange:NSMakeRange(c, 1)]];
}

@end
