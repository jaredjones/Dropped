//
//  DRPPageMatchViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageViewController.h"
#import "DRPMatchHeaderViewController.h"
#import "DRPBoardViewController.h"
#import "DRPMatchCurrentWordViewController.h"

// The DRPPageMatchViewController is actually pretty complicated. It's got 3 childViewControllers:
//
// - DRPMatchHeaderViewController       - the scores/player tiles in the corners
// - DRPMatchBoardViewController        - the board full of tappable tiles
// - DRPMatchCurrentWordViewController  - the slidey words down at the bottom
//
// The reason for all the separation is _precisely_ to avoid a "megaclass." Each of the viewControllers
// does its own, self-contained thing. Communication is done through the delegate protocols conformed
// to below.

@interface DRPPageMatchViewController : DRPPageViewController <DRPHeaderViewControllerDelegate, DRPBoardViewControllerDelegate, DRPCurrentWordViewControllerDelegate>

@end
