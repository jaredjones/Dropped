//
//  DRPCharacterHistogram.h
//  dropped
//
//  Created by Brad Zeis on 11/17/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPCharacter.h"

@class DRPPlayedWord;

@interface DRPCharacterHistogram : NSObject

- (NSArray *)appendedCharactersForPositions:(NSArray *)positions droppedMultipliers:(NSArray *)droppedMultipliers multipliers:(NSArray *)multipliers;

- (void)registerColor:(DRPColor)color;
- (void)unregisterColor:(DRPColor)color;

@end
