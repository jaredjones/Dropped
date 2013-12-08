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

- (void)setCurrentPageID:(DRPPageID)pageID animated:(BOOL)animated userInfo:(NSDictionary *)userInfo;
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture offset:(CGFloat)offset;

@end
