//
//  DRPMainViewController.h
//  dropped
//
//  Created by Brad Zeis on 11/30/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPageViewController.h"

// Rootlevel container ViewController. Much like UIPageViewController,
// handles DRPPageViewController state and transitions.

@interface DRPMainViewController : UIViewController

- (BOOL)isCurrentPage:(DRPPageViewController *)page;
- (void)setCurrentPageID:(DRPPageID)pageID animated:(BOOL)animated userInfo:(NSDictionary *)userInfo;
- (void)transitionToPageInDirection:(DRPPageDirection)direction userInfo:(NSDictionary *)userInfo;

// Methods to interact directly with top/bottom cues
// The rest of the app calls these methods to manipulate cues
- (void)setCue:(NSString *)cue inPosition:(DRPPageDirection)position;
- (void)emphasizeCueInPosition:(DRPPageDirection)position;

@end
