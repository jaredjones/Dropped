//
//  DRPPageViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/5/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DRPPageID) {
    DRPPageSplash,
    DRPPageLogIn,
    DRPPageMatch,
    DRPPageMatchMaker,
    DRPPageList,
    DRPPageEtCetera,
    DRPPageNil
};

typedef NS_ENUM(NSInteger, DRPPageDirection) {
    DRPPageDirectionUp,
    DRPPageDirectionDown,
    DRPPageDirectionSame,
    DRPPageDirectionNil
};

@class DRPMainViewController;

@interface DRPPageViewController : UIViewController <UIScrollViewDelegate>

- (instancetype)initWithPageID:(DRPPageID)pageID;

@property (readonly) DRPPageID pageID;
@property (readonly) DRPMainViewController *mainViewController;
@property NSString *topCue, *bottomCue;
@property UIScrollView *scrollView;

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo;
- (void)didMoveToCurrent;

- (void)willMoveFromCurrent;
- (void)didMoveFromCurrent;

- (void)resetCues;
- (void)hideCues;

- (CGRect)targetBoundsForRotatingToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
