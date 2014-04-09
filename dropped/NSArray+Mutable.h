//
//  NSArray+Mutable.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Mutable)

+ (NSArray *)arrayWithArrays:(NSArray *)arrays, ... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *)arrayByRemovingObject:(id)object;
- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)array;
- (NSArray *)filter:(BOOL (^)(id elt))predicate;

@end
