//
//  DRPGreedyScrollView.m
//  dropped
//
//  Created by Brad Zeis on 12/27/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPGreedyScrollView.h"

@implementation DRPGreedyScrollView

// This subclass simples cancels all contentView touches,
// regardless of whether the contentView is a UIControl.
// This is used for the DRPMatchPageViewController, though I think
// I'll take it out because it's confusing for the user
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

@end
