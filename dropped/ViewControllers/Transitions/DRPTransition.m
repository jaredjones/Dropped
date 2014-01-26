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
@property (strong) void (^completion)();

@property (readwrite) BOOL active;

- (instancetype)initWithStart:(UIViewController *)start destination:(UIViewController *)destination completion:(void (^)())completion;

@end

@implementation DRPTransition

- (instancetype)initWithStart:(UIViewController *)start destination:(UIViewController *)destination completion:(void (^)())completion
{
    self = [super init];
    if (self) {
        _start = start;
        _destination = destination;
        
        __block DRPTransition *wkself = self;
        _completion = ^void() {
            completion();
            wkself.active = NO;
        };
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

#pragma mark Animation

- (void)execute
{
    
}

#pragma mark Dynamic Animator

static UIDynamicAnimator *sharedAnimator;
+ (void)setReferenceViewForUIDynamics:(UIView *)reference
{
    if (!sharedAnimator)
        sharedAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:reference];
}

+ (UIDynamicAnimator *)sharedDynamicAnimator
{
    return sharedAnimator;
}

@end
