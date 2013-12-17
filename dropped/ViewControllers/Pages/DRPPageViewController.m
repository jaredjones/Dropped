//
//  DRPPageViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/5/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageViewController.h"
#import "DRPMainViewController.h"
#import "FRBSwatchist.h"

@interface DRPPageViewController ()

@property BOOL topCueVisible, bottomCueVisible, topCueVisibleOnDragStart, bottomCueVisibleOnDragStart;
@property UIScrollView *scrollView;

@end

@implementation DRPPageViewController
@synthesize pageID=_pageID;

- (id)initWithPageID:(DRPPageID)pageID
{
    self = [super init];
    if (self) {
        _pageID = pageID;
    }
    return self;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    _mainViewController = (DRPMainViewController *)parent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadScrollView];
    _scrollView.delegate = self;
}

#pragma mark DRPPage

- (void)loadScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_scrollView];
}

- (void)resetCues
{
    if (_scrollView.contentOffset.y < [FRBSwatchist floatForKey:@"page.cueVisibleThreshold"]) {
        if (!_topCueVisible) {
            [_mainViewController setCue:_topCue inPosition:DRPPageDirectionUp];
            _topCueVisible = YES;
        }
    } else {
        if (_topCueVisible) {
            [_mainViewController setCue:nil inPosition:DRPPageDirectionUp];
            _topCueVisible = NO;
        }
    }
    
    if (_scrollView.contentSize.height - (_scrollView.contentOffset.y + _scrollView.frame.size.height) < [FRBSwatchist floatForKey:@"page.cueVisibleThreshold"]) {
        if (!_bottomCueVisible) {
            [_mainViewController setCue:_bottomCue inPosition:DRPPageDirectionDown];
            _bottomCueVisible = YES;
        }
    } else {
        if (_bottomCueVisible) {
            [_mainViewController setCue:nil inPosition:DRPPageDirectionDown];
            _bottomCueVisible = NO;
        }
    }
}

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    
}

- (void)didMoveToCurrent
{
    [self resetCues];
}

- (void)willMoveFromCurrent
{
    _topCueVisible = NO;
    _bottomCueVisible = NO;
}

- (void)didMoveFromCurrent
{
    
}

#pragma mark ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _topCueVisibleOnDragStart = _topCueVisible;
    _bottomCueVisibleOnDragStart = _bottomCueVisible;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.mainViewController.currentPageID != self.pageID) return;
    
    // Let DRPMainViewController know about scrolling
    CGFloat offset = [self scrollViewPanOffset:scrollView];
    if (offset != 0) {
        if ((scrollView.contentOffset.y < 0 && _topCueVisibleOnDragStart) ||
            (scrollView.contentOffset.y > 0 && _bottomCueVisibleOnDragStart)) {
            [self.mainViewController handlePanGesture:scrollView.panGestureRecognizer offset:offset panPages:NO];
        }
    } else if (self.view.frame.origin.y != 0) {
        // Centers the currentPage
        // Without this, you can "catch" a bit of the surrounding pages when dragging
        // back past the scrollview content
        CGFloat offset = -[scrollView.panGestureRecognizer translationInView:self.view].y;
        [self.mainViewController handlePanGesture:scrollView.panGestureRecognizer offset:offset panPages:NO];
    }
    
    [self resetCues];
}

// Returns the offset to pass to handlePanGesture:offset:
// when scrolling at the "edges" of the content.
// Returns 0 otherwise
- (CGFloat)scrollViewPanOffset:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        return -[scrollView.panGestureRecognizer translationInView:self.view].y - scrollView.contentOffset.y;
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > 0) {
        return -[scrollView.panGestureRecognizer translationInView:self.view].y - (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height);
    }
    return 0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offset = [self scrollViewPanOffset:scrollView];
    if (offset != 0) {
        // Only handle the gesture at the "edges" of the content
        // and only when the drag was started with the appropriate cue visible
        if ((scrollView.contentOffset.y < 0 && _topCueVisibleOnDragStart) ||
            (scrollView.contentOffset.y > 0 && _bottomCueVisibleOnDragStart)) {
            [self.mainViewController handlePanGesture:scrollView.panGestureRecognizer offset:offset panPages:NO];
        }
    }
}

@end
