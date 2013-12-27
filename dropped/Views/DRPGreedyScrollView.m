//
//  DRPGreedyScrollView.m
//  dropped
//
//  Created by Brad Zeis on 12/27/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPGreedyScrollView.h"

@implementation DRPGreedyScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// This subclass simples cancels all contentView touches,
// regardless of whether the contentView is a UIControl.
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

@end
