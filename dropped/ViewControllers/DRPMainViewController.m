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

@interface DRPMainViewController ()

@property DRPPageDataSource *dataSource;
@property UIViewController<DRPPage> *currentPage, *upPage, *downPage;

// DEBUG
@property UIButton *upButton, *downButton;

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
    
    // Load pages
    [self setCurrentPageID:DRPPageList animated:NO userInfo:nil];
}

#pragma mark Child View Controllers

- (void)setCurrentPageID:(DRPPageID)pageID animated:(BOOL)animated userInfo:(NSDictionary *)userInfo
{
    DRPPageDirection animationDirection = [_dataSource directionFromPage:_currentPage.pageID to:pageID];
    id<DRPPage> prevPage = _currentPage;
    if ([prevPage respondsToSelector:@selector(willMoveFromCurrent)]) {
        [prevPage willMoveFromCurrent];
    }
    
    [self loadNewPagesAroundCurrentPageID:pageID userInfo:userInfo];
    [self configurePageViewsAnimated:animated];
    if (animated) {
        // run transition (and decommission in completion block)
        [self transitionInDirection:animationDirection completion:^{
            [self decommissionOldPagesWithPreviousPage:prevPage];
        }];
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
- (void)configurePageViewsAnimated:(BOOL)animated
{
    [self.view addSubview:_currentPage.view];
    [self.view addSubview:_upPage.view];
    [self.view addSubview:_downPage.view];
    
    if (!animated) {
        _currentPage.view.frame = self.view.frame;
    }
    
    CGRect frame = _currentPage.view.frame;
    frame.origin.y -= CGRectGetHeight(frame);
    _upPage.view.frame = frame;
    
    frame.origin.y = CGRectGetMaxY(_currentPage.view.frame);
    _downPage.view.frame = frame;
}

#pragma mark Transitions

// Assumes _*Page are set correctly
// Uses _currentPage to calculate positions
- (void)transitionInDirection:(DRPPageDirection)direction completion:(void (^)())completion
{
    
}

@end
