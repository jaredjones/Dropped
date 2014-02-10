//
//  DRPPageViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/5/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

// DRPPageViewController is each individual "page" in the app.
// The DRPMainViewController handles transitions between pages.

// DRPPageID each uniquely identify a DRPPageViewController
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
    DRPPageDirectionNil
};

@class DRPMainViewController;

@interface DRPPageViewController : UIViewController <UIScrollViewDelegate>

- (instancetype)initWithPageID:(DRPPageID)pageID;

@property (readonly) DRPPageID pageID;
@property (readonly) DRPMainViewController *mainViewController;

@property NSString *topCue, *bottomCue;

// Each DRPPageViewController has a fullscreen scrollView embedded in it
// Everything in the page should be added to the scrollView for MAXIMUM INTERACTIVITY
@property UIScrollView *scrollView;

@property BOOL topCueVisible, bottomCueVisible;

// DRPMainViewController handles transitions and calls these methods when appropriate
- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo;
- (void)didMoveToCurrent;
- (void)willMoveFromCurrent;
- (void)didMoveFromCurrent;

// Called to show/hide cues
// It's used internally by DRPPageViewController every time the scrollView is scrolled
- (void)resetCues;
- (void)hideCues;

@end
