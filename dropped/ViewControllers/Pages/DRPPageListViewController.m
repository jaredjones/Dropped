//
//  DRPPageListViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageListViewController.h"
#import "DRPMainViewController.h"
#import "FRBSwatchist.h"

@interface DRPPageListViewController ()

@property BOOL topCueVisible, bottomCueVisible, topCueVisibleOnDragStart, bottomCueVisibleOnDragStart;
@property UIScrollView *scrollView;

@end

@implementation DRPPageListViewController

- (instancetype)init
{
    self = [super initWithPageID:DRPPageList];
    if (self) {
        self.topCue = @"Pull for New Game";
        self.bottomCue = @"Et Cetera";
    }
    return self;
}

#pragma mark DRPPageViewController

- (void)didMoveToCurrent
{
    [super didMoveToCurrent];
}

- (void)didMoveFromCurrent
{
    [super didMoveFromCurrent];
}

@end
