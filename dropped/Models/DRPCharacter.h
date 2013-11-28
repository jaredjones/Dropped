//
//  DRPCharacter.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DRPColor) {
    DRPColorBlue,
    DRPColorGreen,
    DRPColorOrange,
    DRPColorPurple,
    DRPColorYellow,
    DRPColorPink,
    DRPColorRed,
    DRPColorNil
};

@class DRPPosition;

@interface DRPCharacter : NSObject <NSCopying>

@property (readonly) NSString *character;

// -1 if not a multiplier
@property (readonly) NSInteger multiplier;
@property DRPColor color;

// Non-nil if this tile is next to a multiplier
@property DRPCharacter *adjacentMultiplier;

+ (instancetype)characterWithCharacter:(NSString *)character;
+ (instancetype)characterWithMulitplier:(NSInteger)multiplier;

@end
