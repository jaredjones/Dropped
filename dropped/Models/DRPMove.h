//
//  DRPMove.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPTile;

@interface DRPMove : NSObject

@property (readonly) NSString *word;

- (void)appendTile:(DRPTile *)tile;
- (void)removeTile:(DRPTile *)tile;

- (NSArray *)tiles;

@end
