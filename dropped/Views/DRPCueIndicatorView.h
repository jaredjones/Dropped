//
//  DRPCueIndicatorView.h
//  dropped
//
//  Created by Brad Zeis on 12/10/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPageViewController.h"

@interface DRPCueIndicatorView : UIView

@property DRPPageDirection position;

- (void)animateIn;
- (void)animateOut;

@end
