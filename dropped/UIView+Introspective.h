//
//  UIView+Introspective.h
//  dropped
//
//  Created by Brad Zeis on 1/9/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Introspective)

- (BOOL)hasAnimationsRunning;
- (void)setPositionToPresentationPosition;

@end
