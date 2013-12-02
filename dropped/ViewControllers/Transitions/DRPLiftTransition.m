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
    [UIView animateWithDuration:1 animations:^{
        
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
