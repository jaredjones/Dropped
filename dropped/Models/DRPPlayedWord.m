//
//  DRPPlayedWord.m
//  dropped
//
//  Created by Brad Zeis on 11/16/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPlayedWord.h"
#import "DRPPosition.h"

@implementation DRPPlayedWord

// Diff
//  {
//      start_position : end_position,
//      start_position (appendedCharacter, has negative j) : [DRPCharacter, end_position]
//  }
- (NSDictionary *)diff
{
    NSMutableDictionary *diff = [[NSMutableDictionary alloc] init];
    
    NSInteger appendedCharactersUsed = 0;
    for (NSInteger i = 0; i < 6; i++) {
        NSInteger droppedPositionsHandledInColumn = 0;
        
        for (NSInteger j = 5; j >= 0; j--) {
            DRPPosition *endPosition = [DRPPosition positionWithI:i j:j];
            
            // Start at the end position (at the bottom), and look up
            // for the closest possible character
            // Keep track of number of dropped positions handled in this
            // column
            NSMutableArray *droppedPositions = [[NSMutableArray alloc] init];
            
            for (NSInteger k = 0; k <= 6; k++) {
                NSInteger startJ = j - k - droppedPositionsHandledInColumn;
                DRPPosition *startPosition = [DRPPosition positionWithI:i j:startJ];
                // Skip over captured positions, but make a note so
                // the offset can be adjusted for the next position
                if ([_positions containsObject:startPosition]) {
                    [droppedPositions addObject:startPosition];
                    continue;
                }
                
                // Found the start position! Sweet!
                if (startPosition.j >= 0) {
                    if (![startPosition isEqual:endPosition]) {
                        diff[startPosition] = endPosition;
                    }
                } else {
                    // Spilled over the top (because of dropped positions),
                    // so grab the character from _appendedCharacters
                    diff[startPosition] = @[_appendedCharacters[appendedCharactersUsed],
                                            endPosition];
                    appendedCharactersUsed++;
                }
                break;
            }
            
            droppedPositionsHandledInColumn += droppedPositions.count;
        }
    }
    
    return diff;
}

- (NSInteger)score
{
    return 0;
}

@end
