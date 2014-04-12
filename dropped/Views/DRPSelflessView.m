//
//  DRPSelflessView.m
//  Dropped
//
//  Created by Brad Zeis on 4/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPSelflessView.h"

@implementation DRPSelflessView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    return result == self ? nil : result;
}

@end
