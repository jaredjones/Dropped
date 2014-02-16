//
//  DRPCueKeeper.h
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPPageViewController.h"

// This is a bit of a quasi-UIViewController since it shares its view
// with DRPMainViewController.

// TODO: this maybe should be a full-fledged UIViewController with its own view. See Brent Simmons' blog post about the responder chain

// DRPCueKeeper is responsible for storing cue state (the directions at
// the top/bottom of the screen) and animating transitions between cues.

@interface DRPCueKeeper : NSObject

- (instancetype)initWithView:(UIView *)view;

- (void)cycleInCue:(NSString *)cueText inPosition:(DRPPageDirection)position;
- (void)cycleOutCueInPosition:(DRPPageDirection)position;

- (void)emphasizeCueInPosition:(DRPPageDirection)position;
- (void)deemphasizeCueInPosition:(DRPPageDirection)position;
- (void)cycleOutIndicatorForPosition:(DRPPageDirection)position;

- (void)hideIndicators;
- (void)showIndicators;

- (void)sendToBack;

@end
