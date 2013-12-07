//
//  DRPLiftTransition.m
//  dropped
//
//  Created by Brad Zeis on 12/2/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPLiftTransition.h"

@implementation DRPLiftTransition

- (void)execute
{
    [UIView animateWithDuration:.48 delay:0 usingSpringWithDamping:1 initialSpringVelocity:self.startingVelocity / -100 options:0 animations:^{
        CGRect frame = self.start.view.frame;
        frame.origin.y = -frame.size.height;
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
