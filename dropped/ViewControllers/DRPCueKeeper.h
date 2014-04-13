//
//  DRPCueKeeper.h
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPPageViewController.h"

// DRPCueKeeper is responsible for storing cue state (the directions at
// the top/bottom of the screen) and animating transitions between cues.

// The DRPCueKeeper is a UIViewController that's in front of all of the
// DRPPageViewControllers. The DRPCueKeeper's view ignores all touches
// on itself and instead passes them to either the cues (so they act like
// buttons) or the current DRPPageViewController.

// There are two pairs of cues and indicators. The cues are the text
// buttons at the top and bottom of the screen. The indicators are the
// 6 tiles just off the screen that indicate

@class DRPPageViewController;

@interface DRPCueKeeper : UIViewController

- (void)setCueText:(NSString *)cueText forPosition:(DRPPageDirection)position;

// This method sets the offsets of any cues/indicators if the scrollView
// has scrolled adequately
- (void)updateWithPage:(DRPPageViewController *)page;

@end
