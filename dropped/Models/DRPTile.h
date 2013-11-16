//
//  DRPTile.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPPosition;

@interface DRPTile : NSObject

@property (readonly) DRPPosition *position;
@property (readonly) NSString *character;

+ (instancetype)tileWithPosition:(DRPPosition *)position character:(NSString *)character;
- (instancetype)initWithPosition:(DRPPosition *)position character:(NSString *)character;

@end
