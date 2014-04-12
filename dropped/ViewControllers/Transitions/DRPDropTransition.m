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
    // TODO: Into a swatch these go. And could probably use some tweaking
    [UIView animateWithDuration:.48
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:self.startingVelocity / 100
                        options:0
                     animations:^{
                         CGRect frame = self.start.view.frame;
                         frame.origin.y = frame.size.height;
                         self.start.view.frame = frame;
                         
                         frame.origin.y = 0;
                         self.destination.view.frame = frame;
                         
                     } completion:^(BOOL finished) {
                         if (self.completion) {
                             self.completion();
                         }
                     }];
}

@end
