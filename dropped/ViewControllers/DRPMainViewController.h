//
//  DRPMainViewController.h
//  dropped
//
//  Created by Brad Zeis on 11/30/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPageViewController.h"

@interface DRPMainViewController : UIViewController

- (DRPPageID)currentPageID;
- (void)setCurrentPageID:(DRPPageID)pageID animated:(BOOL)animated userInfo:(NSDictionary *)userInfo;
- (void)transitionToPageInDirection:(DRPPageDirection)direction userInfo:(NSDictionary *)userInfo;

- (void)setCue:(NSString *)cue inPosition:(DRPPageDirection)position;
- (void)emphasizeCueInPosition:(DRPPageDirection)position;

@end
