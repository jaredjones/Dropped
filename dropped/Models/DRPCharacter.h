//
//  DRPCharacter.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPPosition;

@interface DRPCharacter : NSObject

@property (readonly) NSString *character;

// -1 if not a multiplier
@property (readonly) NSInteger multiplier;
// Non-nil if this tile is next to a multiplier
@property DRPCharacter *adjacentMultiplier;

+ (instancetype)characterWithCharacter:(NSString *)character;
+ (instancetype)characterWithMulitplier:(NSInteger)multiplier;

@end
