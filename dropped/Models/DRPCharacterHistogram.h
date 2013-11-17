//
//  DRPCharacterHistogram.h
//  dropped
//
//  Created by Brad Zeis on 11/17/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPCharacter, DRPPlayedWord;

@interface DRPCharacterHistogram : NSObject

- (void)addCharacters:(NSArray *)characters;
- (void)addCharacter:(DRPCharacter *)character;

- (DRPPlayedWord *)playedWordForPositions:(NSArray *)positions activatedMultipliers:(NSArray *)activatedMultipliers additionalMultipliers:(NSArray *)additionMultipliers;

@end
