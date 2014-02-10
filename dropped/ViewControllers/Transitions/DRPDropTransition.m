//
//  DRPDropTransition.m
//  dropped
//
//  Created by Brad Zeis on 12/2/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPDropTransition.h"
#import "FRBSwatchist.h"

@interface DRPDropTransition ()

@property UICollisionBehavior *collision;
@property UIDynamicItemBehavior *item;

@end

@implementation DRPDropTransition

- (void)execute
{
    // Gravity Behavior
    for (id<UIDynamicItem> item in [DRPTransition sharedGravityBehavior].items) {
        [[DRPTransition sharedGravityBehavior] removeItem:item];
    }
    
    [[DRPTransition sharedGravityBehavior] addItem:self.start.view];
    [[DRPTransition sharedGravityBehavior] addItem:self.destination.view];

    // Collision Behavior
    self.collision = [[UICollisionBehavior alloc] initWithItems:@[self.destination.view]];
    [self.collision addBoundaryWithIdentifier:@"bottom"
                                    fromPoint:CGPointMake(0, self.destination.view.frame.size.height)
                                      toPoint:CGPointMake(self.destination.view.frame.size.width,
                                                          self.destination.view.frame.size.height)];
    self.collision.collisionDelegate = self;
    [[DRPTransition sharedDynamicAnimator] addBehavior:self.collision];
    
    // Item Behavior
    self.item = [[UIDynamicItemBehavior alloc] initWithItems:@[self.start.view, self.destination.view]];
    CGPoint velocity = CGPointMake(0, self.startingVelocity);
    [self.item addLinearVelocity:velocity forItem:self.start.view];
    [self.item addLinearVelocity:velocity forItem:self.destination.view];
    [[DRPTransition sharedDynamicAnimator] addBehavior:self.item];
}

- (void)cleanup
{
    [[DRPTransition sharedGravityBehavior] removeItem:self.start.view];
    [[DRPTransition sharedGravityBehavior] removeItem:self.destination.view];
    
    [[DRPTransition sharedDynamicAnimator] removeBehavior:_collision];
    [[DRPTransition sharedDynamicAnimator] removeBehavior:_item];
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
    [self cleanup];
}

@end
