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

#import "FRBSwatchist.h"

@interface DRPTransition ()

@property UIViewController *start, *destination;
@property (copy) void (^completion)();

@property (readwrite) BOOL active;

- (instancetype)initWithStart:(UIViewController *)start destination:(UIViewController *)destination completion:(void (^)())completion;

@end

@implementation DRPTransition

- (instancetype)initWithStart:(UIViewController *)start destination:(UIViewController *)destination completion:(void (^)())completion
{
    self = [super init];
    if (self) {
        self.start = start;
        self.destination = destination;
        
        // The transition completion mostly just calls the passed in completion
        // handler, but it also needs to set the active state of the transition
        __block DRPTransition *wkself = self;
        self.completion = ^void() {
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
static UIGravityBehavior *sharedGravity;
+ (void)setReferenceViewForUIDynamics:(UIView *)reference
{
    if (!sharedAnimator) {
        sharedAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:reference];
        
        sharedGravity = [[UIGravityBehavior alloc] init];
        sharedGravity.magnitude = [FRBSwatchist floatForKey:@"animation.gravity"];
        [sharedAnimator addBehavior:sharedGravity];
    }
}

+ (UIDynamicAnimator *)sharedDynamicAnimator
{
    return sharedAnimator;
}

+ (UIGravityBehavior *)sharedGravityBehavior
{
    return sharedGravity;
}

@end
