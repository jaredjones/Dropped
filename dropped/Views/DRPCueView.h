//
//  DRPCueView.h
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DRPPageViewController.h"

@interface DRPCueView : UIView

- (void)cycleInCue:(NSString *)cue inPosition:(DRPPageDirection)position;
- (void)cycleOutCueInPosition:(DRPPageDirection)position;

- (void)emphasizeCueInPosition:(DRPPageDirection)position;
- (void)deemphasizeCueInPosition:(DRPPageDirection)position;

@end
