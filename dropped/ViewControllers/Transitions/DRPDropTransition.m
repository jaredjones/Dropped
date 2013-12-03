//
//  DRPDropTransition.m
//  dropped
//
//  Created by Brad Zeis on 12/2/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPDropTransition.h"

@interface DRPDropTransition ()

@property UIGravityBehavior *gravity;
@property UICollisionBehavior *collision;

@end

@implementation DRPDropTransition

- (void)execute
{
    _gravity = [[UIGravityBehavior alloc] initWithItems:@[self.start.view, self.destination.view]];
    _gravity.magnitude = 3.2;
    [[DRPTransition sharedDynamicAnimator] addBehavior:_gravity];

    _collision = [[UICollisionBehavior alloc] initWithItems:@[self.destination.view]];
    [_collision addBoundaryWithIdentifier:@"bottom"
                                fromPoint:CGPointMake(0, self.destination.view.frame.size.height)
                                  toPoint:CGPointMake(self.destination.view.frame.size.width,
                                                      self.destination.view.frame.size.height)];
    _collision.collisionDelegate = self;
    [[DRPTransition sharedDynamicAnimator] addBehavior:_collision];
}

- (void)interrupt
{
    [[DRPTransition sharedDynamicAnimator] removeBehavior:_gravity];
    [[DRPTransition sharedDynamicAnimator] removeBehavior:_collision];
}

#pragma mark Collision Behavior Delegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(UIView *)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    CGRect frame = item.frame;
    frame.origin = CGPointZero;
    item.frame = frame;
    
    if (self.completion) {
        self.completion();
    }
    [self interrupt];
}

@end
