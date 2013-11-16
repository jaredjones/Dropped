//
//  DRPPosition.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRPPosition : NSObject <NSCopying>

@property (readonly) NSInteger i, j;

+ (instancetype)positionWithI:(NSInteger)i j:(NSInteger)j;
- (instancetype)initWithI:(NSInteger)i j:(NSInteger)j;

@end
