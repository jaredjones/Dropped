//
//  UIView+Introspective.m
//  dropped
//
//  Created by Brad Zeis on 1/9/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "UIView+Introspective.h"

@implementation UIView (Introspective)

- (BOOL)hasAnimationsRunning
{
    return self.layer.animationKeys.count > 0;
}

- (void)setPositionToPresentationPosition
{
    self.layer.position = ((CALayer *)self.layer.presentationLayer).position;
}

@end
