//
//  DRPTransition.h
//  dropped
//
//  Created by Brad Zeis on 12/2/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPPageViewController.h"

@interface DRPTransition : NSObject

@property (readonly) UIViewController *start, *destination;
@property (readonly, strong) void (^completion)();
@property CGFloat startingVelocity;

@property (readonly) BOOL active;

+ (void)setReferenceView:(UIView *)reference;
+ (UIDynamicAnimator *)sharedDynamicAnimator;

+ (DRPTransition *)transitionWithStart:(UIViewController *)start destination:(UIViewController *)destination direction:(DRPPageDirection)direction completion:(void (^)())completion;

- (void)execute;

@end
