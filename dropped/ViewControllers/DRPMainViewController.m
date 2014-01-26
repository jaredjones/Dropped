//
//  DRPMainViewController.m
//  dropped
//
//  Created by Brad Zeis on 11/30/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPMainViewController.h"
#import "DRPPageViewController.h"
#import "DRPPageDataSource.h"
#import "DRPTransition.h"
#import "DRPCueKeeper.h"

#import "DRPCueIndicatorView.h"

#import "FRBSwatchist.h"

@interface DRPMainViewController ()

@property DRPPageDataSource *dataSource;
@property DRPPageViewController *currentPage, *upPage, *downPage;
@property DRPCueKeeper *cueKeeper;

@property DRPTransition *currentTransition;

@end

#pragma mark - DRPMainViewController

@implementation DRPMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [[DRPPageDataSource alloc] init];
    }
    return self;
}

#pragma mark Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DRPTransition setReferenceViewForUIDynamics:self.view];
    self.view.backgroundColor = [UIColor whiteColor];
}


- (void)viewWillLayoutSubviews
{
    // Only load views when everything is unitialized
    // This code is a little gross, but it's pretty darn functional
    if (!_cueKeeper) {
        _cueKeeper = [[DRPCueKeeper alloc] initWithView:self.view];
        [self setCurrentPageID:DRPPageSplash animated:NO userInfo:nil];
    }
}

#pragma mark Child View Controllers

- (DRPPageID)currentPageID
{
    return _currentPage.pageID;
}

- (void)setCurrentPageID:(DRPPageID)pageID animated:(BOOL)animated userInfo:(NSDictionary *)userInfo
{
    if (pageID == DRPPageNil) return;
    
    DRPPageDirection animationDirection = [_dataSource directionFromPage:_currentPage.pageID to:pageID];
    if (!_currentPage) {
        animationDirection = DRPPageDirectionNil;
    }
    
    // Compute and Configure new Pages based on direction
    // Only load new surrounding Pages when transitioning to a new Page
    DRPPageViewController *prevPage = _currentPage;
    [prevPage willMoveFromCurrent];
    
    [self loadNewPagesAroundCurrentPageID:pageID];
    [self configurePageViewsForAnimationWithPreviousPage:prevPage animated:animated];
    [_currentPage willMoveToCurrentWithUserInfo:userInfo];
    
    // Transition to new Page
    // Only run animation if necessary
    if (animated && _currentPage.view.frame.origin.y != 0) {
        _currentTransition = [DRPTransition transitionWithStart:prevPage
                                                    destination:_currentPage
                                                      direction:animationDirection
                                                     completion:^{
                                                         [self decommissionOldPagesWithPreviousPage:prevPage];
                                                         [self repositionPagesAroundCurrentPage];
                                                         _upPage.view.hidden = YES;
                                                         _downPage.view.hidden = YES;
                                                     }];
        
        // The "velocity" of the drag is stored so there are no instaneous
        // velocity jerks in the animation
        _currentTransition.startingVelocity = [userInfo[@"velocity"] floatValue];
        
        // Reset cues
        [self setCue:nil inPosition:DRPPageDirectionUp];
        [self setCue:nil inPosition:DRPPageDirectionDown];
        [_cueKeeper cycleOutIndicatorForPosition:DRPPageDirectionUp];
        [_cueKeeper cycleOutIndicatorForPosition:DRPPageDirectionDown];
        
        _currentPage.view.hidden = NO;
        [_currentTransition execute];
        
    } else {
        [self decommissionOldPagesWithPreviousPage:prevPage];
        _upPage.view.hidden = YES;
        _downPage.view.hidden = YES;
    }
}

// Convenience method
- (void)transitionToPageInDirection:(DRPPageDirection)direction userInfo:(NSDictionary *)userInfo
{
    [self setCurrentPageID:[_dataSource pageIDInDirection:direction from:_currentPage.pageID] animated:YES userInfo:userInfo];
}

// Loads the new surround DRPPages and stores them in memory
- (void)loadNewPagesAroundCurrentPageID:(DRPPageID)pageID
{
    _currentPage = [_dataSource pageForPageID:pageID];
    if (_currentPage.parentViewController != self) {
        [_currentPage willMoveToParentViewController:self];
        [self addChildViewController:_currentPage];
    }
    
    _upPage = [_dataSource pageForPageID:[_dataSource pageIDInDirection:DRPPageDirectionUp from:pageID]];
    if (_upPage && _upPage.parentViewController != self) {
        [_upPage willMoveToParentViewController:self];
        [self addChildViewController:_upPage];
    }
    
    _downPage = [_dataSource pageForPageID:[_dataSource pageIDInDirection:DRPPageDirectionDown from:pageID]];
    if (_downPage && _downPage.parentViewController != self) {
        [_downPage willMoveToParentViewController:self];
        [self addChildViewController:_downPage];
    }
}

// Reposition the DRPPage UIViews appropriately
// Slightly different rules if animating to new page
- (void)configurePageViewsForAnimationWithPreviousPage:(DRPPageViewController *)prevPage animated:(BOOL)animated
{
    [self.view addSubview:_currentPage.view];
    [self.view addSubview:_upPage.view];
    [self.view addSubview:_downPage.view];
    
    if (!animated) {
        _currentPage.view.frame = self.view.bounds;
        [self repositionPagesAroundCurrentPage];
    } else {
        // Mess with the layering within parent view
        // to make sure the correct views are visible
        [self.view bringSubviewToFront:_currentPage.view];
        [self.view bringSubviewToFront:prevPage.view];
        _upPage.view.hidden = YES;
        _downPage.view.hidden = YES;
        prevPage.view.hidden = NO;
        
        DRPPageDirection direction = [_dataSource directionFromPage:prevPage.pageID to:_currentPage.pageID];
        if (direction == DRPPageDirectionUp) {
            CGRect frame = prevPage.view.frame;
            frame.origin.y -= _currentPage.view.frame.size.height;
            _currentPage.view.frame = frame;
        } else if (direction == DRPPageDirectionDown) {
            CGRect frame = prevPage.view.frame;
            frame.origin.y += prevPage.view.frame.size.height;
            _currentPage.view.frame = frame;
        }
        
        [self repositionPagesAroundCurrentPage];
    }
    [_cueKeeper bringToFront];
}

- (void)repositionPagesAroundCurrentPage
{
    CGRect frame = _currentPage.view.frame;
    frame.origin.y -= CGRectGetHeight(frame);
    _upPage.view.frame = frame;
    
    frame.origin.y = CGRectGetMaxY(_currentPage.view.frame);
    _downPage.view.frame = frame;
}

// Called to clean up DRPPages sitting around that aren't active
- (void)decommissionOldPagesWithPreviousPage:(DRPPageViewController *)prevPage
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UILabel class]]) continue;
        if ([view isKindOfClass:[DRPCueIndicatorView class]]) continue;
        if (!(view == _currentPage.view || view == _upPage.view || view == _downPage.view)) {
            [view removeFromSuperview];
        }
    }
    
    [prevPage didMoveFromCurrent];
    [_currentPage didMoveToCurrent];
}

#pragma mark Cues

- (void)setCue:(NSString *)cue inPosition:(DRPPageDirection)position
{
    [_cueKeeper cycleInCue:cue inPosition:position];
}

- (void)emphasizeCueInPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp || position == DRPPageDirectionDown) {
        [_cueKeeper emphasizeCueInPosition:position];
        [_cueKeeper deemphasizeCueInPosition:!position];
    } else {
        [_cueKeeper deemphasizeCueInPosition:DRPPageDirectionUp];
        [_cueKeeper deemphasizeCueInPosition:DRPPageDirectionDown];
    }
}

#pragma mark Rotation

- (BOOL)shouldAutorotate
{
    return !_currentTransition.active;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_cueKeeper hideIndicators];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_cueKeeper showIndicators];
}

@end
