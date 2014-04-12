//
//  DRPMainViewController.h
//  dropped
//
//  Created by Brad Zeis on 11/30/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPageViewController.h"

@class DRPCueKeeper;

// Root-level container UIViewController. Much like UIPageViewController,
// handles DRPPageViewController state and transitions.

@interface DRPMainViewController : UIViewController

@property (readonly) DRPCueKeeper *cueKeeper;

- (BOOL)isCurrentPage:(DRPPageViewController *)page;
- (void)setCurrentPageID:(DRPPageID)pageID animated:(BOOL)animated userInfo:(NSDictionary *)userInfo;
- (void)transitionToPageInDirection:(DRPPageDirection)direction userInfo:(NSDictionary *)userInfo;

@end
