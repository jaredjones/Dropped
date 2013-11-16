//
//  DRPBoard.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPTile, DRPPosition;

@interface DRPBoard : NSObject

- (instancetype)initWithMatchData:(NSData *)data;

- (DRPTile *)tileAtPosition:(DRPPosition *)position forTurn:(NSInteger)turn;
- (DRPTile *)tileAtPosition:(DRPPosition *)position;

@end
