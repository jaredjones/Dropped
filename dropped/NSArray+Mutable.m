//
//  NSArray+Mutable.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "NSArray+Mutable.h"

@implementation NSArray (Mutable)

+ (NSArray *)arrayWithArrays:(NSArray *)arrays, ...
{
    va_list args;
    va_start(args, arrays);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSArray *arg = arrays; arg != nil; arg = va_arg(args, NSArray *)) {
        [result addObjectsFromArray:arg];
    }
    
    va_end(args);
    return result;
}

- (NSArray *)arrayByRemovingObject:(id)object
{
    NSInteger index = [self indexOfObject:object];
    if (index == NSNotFound) return self;
    
    NSArray *firstHalf = [self subarrayWithRange:NSMakeRange(0, index)];
    NSArray *secondHalf = [self subarrayWithRange:NSMakeRange(index + 1, self.count - index - 1)];
    return [firstHalf arrayByAddingObjectsFromArray:secondHalf];
};

- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)array
{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF IN %@", array]];
}

@end
