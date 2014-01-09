//
//  NSArray+Mutable.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "NSArray+Mutable.h"

@implementation NSArray (Mutable)

- (NSArray *)arrayByRemovingObject:(id)object
{
    NSInteger index = [self indexOfObject:object];
    if (index == NSNotFound) return self;
    
    NSArray *firstHalf = [self subarrayWithRange:NSMakeRange(0, index)];
    NSArray *secondHalf = [self subarrayWithRange:NSMakeRange(index + 1, self.count - index - 1)];
    return [firstHalf arrayByAddingObjectsFromArray:secondHalf];
};

@end
