//
//  DRPPosition.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DRPDirection) {
    DRPDirectionRight,
    DRPDirectionUpRight,
    DRPDirectionUp,
    DRPDirectionUpLeft,
    DRPDirectionLeft,
    DRPDirectionDownLeft,
    DRPDirectionDown,
    DRPDirectionDownRight,
    DRPDirectionNil
};

@interface DRPPosition : NSObject <NSCopying>

@property (readonly) NSInteger i, j;

+ (instancetype)positionWithI:(NSInteger)i j:(NSInteger)j;
- (instancetype)initWithI:(NSInteger)i j:(NSInteger)j;

- (DRPPosition *)positionInDirection:(DRPDirection)direction;

@end
