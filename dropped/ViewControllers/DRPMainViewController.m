//
//  DRPMainViewController.m
//  dropped
//
//  Created by Brad Zeis on 11/30/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPMainViewController.h"
#import "DRPPage.h"
#import "DRPPageDataSource.h"
#import "DRPMainPanGestureRecognizer.h"
#import "DRPTransition.h"

@interface DRPMainViewController ()

@property DRPPageDataSource *dataSource;
@property UIViewController<DRPPage> *currentPage, *upPage, *downPage;

@property DRPMainPanGestureRecognizer *panGestureRecognizer;
@property BOOL panRevealedUpPage, panRevealedDownPage;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _panGestureRecognizer = [[DRPMainPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    [self setCurrentPageID:DRPPageList animated:NO userInfo:nil];
}

#pragma mark Child View Controllers

- (void)setCurrentPageID:(DRPPageID)pageID animated:(BOOL)animated userInfo:(NSDictionary *)userInfo
{
    DRPPageDirection animationDirection = [_dataSource directionFromPage:_currentPage.pageID to:pageID];
    UIViewController<DRPPage> *prevPage = _currentPage;
    if ([prevPage respondsToSelector:@selector(willMoveFromCurrent)]) {
        [prevPage willMoveFromCurrent];
    }
    
    [self loadNewPagesAroundCurrentPageID:pageID userInfo:userInfo];
    [self configurePageViewsAnimated:animated withPreviousPage:prevPage];
    if (animated) {
        DRPTransition *transition = [DRPTransition transitionWithStart:prevPage
                                                           destination:_currentPage
                                                             direction:animationDirection
                                                            completion:^{
            [self decommissionOldPagesWithPreviousPage:prevPage];
            [self repositionPagesAroundCurrentPage];
        }];
        [transition execute];
    } else {
        [self decommissionOldPagesWithPreviousPage:prevPage];
    }
}

// Called to clean up DRPPages sitting around that aren't active
- (void)decommissionOldPagesWithPreviousPage:(id<DRPPage>)prevPage
{
    for (UIView *view in self.view.subviews) {
        if (![view conformsToProtocol:@protocol(DRPPage)]) continue;
        if (!(view == _currentPage.view || view == _upPage.view || view == _downPage.view)) {
            [view removeFromSuperview];
        }
    }
    
    if ([prevPage respondsToSelector:@selector(didMoveFromCurrent)]) {
        [prevPage didMoveFromCurrent];
    }
    
    if ([_currentPage respondsToSelector:@selector(didMoveToCurrent)]) {
        [_currentPage didMoveToCurrent];
    }
}

// Loads the new surround DRPPages and stores them in memory
- (void)loadNewPagesAroundCurrentPageID:(DRPPageID)pageID userInfo:(NSDictionary *)userInfo
{
    _currentPage = [_dataSource pageForPageID:pageID];
    if (_currentPage.parentViewController != self) {
        [_currentPage willMoveToParentViewController:self];
        [self addChildViewController:_currentPage];
        
        if ([_currentPage respondsToSelector:@selector(willMoveToCurrentWithUserInfo:)]) {
            [_currentPage willMoveToCurrentWithUserInfo:userInfo];
        }
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
- (void)configurePageViewsAnimated:(BOOL)animated withPreviousPage:(UIViewController<DRPPage> *)prevPage
{
    [self.view addSubview:_currentPage.view];
    [self.view addSubview:_upPage.view];
    [self.view addSubview:_downPage.view];
    
    if (!animated) {
        _currentPage.view.frame = self.view.frame;
        [self repositionPagesAroundCurrentPage];
    } else {
        // Mess with the layering within parent view
        // to make sure the correct views are visible
        [self.view bringSubviewToFront:_currentPage.view];
        [self.view bringSubviewToFront:prevPage.view];
    }
}

- (void)repositionPagesAroundCurrentPage
{
    CGRect frame = _currentPage.view.frame;
    frame.origin.y -= CGRectGetHeight(frame);
    _upPage.view.frame = frame;
    
    frame.origin.y = CGRectGetMaxY(_currentPage.view.frame);
    _downPage.view.frame = frame;
}

#pragma mark Touch Events

- (void)handlePanGesture:(DRPMainPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // Store the _currentPage offset (from the top of the screen)
        // Needed to prevent jerks when a pan is started in
        // the middle of a transition
        gesture.viewOffset = _currentPage.view.frame.origin.y;
        
        _panRevealedUpPage = NO;
        _panRevealedDownPage = NO;
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        // Reposition DRPPage views
        CGRect frame = self.view.frame;
        frame.origin.y += gesture.viewOffset + [gesture translationInView:self.view].y;
        _currentPage.view.frame = frame;
        [self repositionPagesAroundCurrentPage];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        // Pan ended, animate transition if necessary
        DRPPageDirection transitionDirection = [self panEndTransitionDirectionWithGesture:gesture];
        if (transitionDirection != DRPPageDirectionNil) {
            [self setCurrentPageID:[_dataSource pageIDInDirection:transitionDirection from:_currentPage.pageID]
                          animated:YES
                          userInfo:nil];
        }
    }
}

// Return the
- (DRPPageDirection)panEndTransitionDirectionWithGesture:(DRPMainPanGestureRecognizer *)gesture
{
    if (gesture.viewOffset + [gesture translationInView:self.view].y > 0) {
        return DRPPageDirectionUp;
    } else if (gesture.viewOffset + [gesture translationInView:self.view].y < 0) {
        return DRPPageDirectionDown;
    }
    return DRPPageDirectionNil;
}

@end
