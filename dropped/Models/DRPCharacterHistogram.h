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

- (NSArray *)appendedCharactersForPositions:(NSArray *)positions droppedMultipliers:(NSArray *)droppedMultipliers multipliers:(NSArray *)multipliers;

@end
