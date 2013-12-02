//
//  DRPTransition.m
//  dropped
//
//  Created by Brad Zeis on 12/2/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPTransition.h"
#import "DRPDropTransition.h"
#import "DRPLiftTransition.h"

@interface DRPTransition ()

@property UIViewController *start, *destination;
@property (copy) void (^completion)();

- (instancetype)initWithStart:(UIViewController *)start destination:(UIViewController *)destination completion:(void (^)())completion;

@end

@implementation DRPTransition

- (instancetype)initWithStart:(UIViewController *)start destination:(UIViewController *)destination completion:(void (^)())completion
{
    self = [super init];
    if (self) {
        _start = start;
        _destination = destination;
        _completion = completion;
    }
    return self;
}

+ (id)transitionWithStart:(UIViewController *)start destination:(UIViewController *)destination direction:(DRPPageDirection)direction completion:(void (^)())completion
{
    if (direction == DRPPageDirectionUp) {
        return [[DRPDropTransition alloc] initWithStart:start destination:destination completion:completion];
    } else if (direction == DRPPageDirectionDown) {
        return [[DRPLiftTransition alloc] initWithStart:start destination:destination completion:completion];
    }
    return nil;
}

- (void)execute
{
    
}

@end
