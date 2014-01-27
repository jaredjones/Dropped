//
//  DRPPlayedWord.h
//  dropped
//
//  Created by Brad Zeis on 11/16/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRPPlayedWord : NSObject

// Array of DRPPosition
@property NSArray *positions;

// The rest are arrays of DRPCharacters
@property NSArray *appendedCharacters;
@property NSArray *multipliers, *additionalMultipliers;

- (NSInteger)tileCount;
- (NSDictionary *)diff;

@end
