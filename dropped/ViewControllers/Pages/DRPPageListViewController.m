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

@property BOOL topCueVisible, bottomCueVisible;
@property UIScrollView *scrollView;

@end

@implementation DRPPageListViewController

- (instancetype)init
{
    self = [super initWithPageID:DRPPageList];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
}

#pragma mark DRPPageViewController

- (void)didMoveToCurrent
{
    _topCueVisible = NO;
    _bottomCueVisible = NO;
    [self resetCues];
}

- (void)resetCues
{
    if (_scrollView.contentOffset.y < [FRBSwatchist floatForKey:@"page.cueVisibleThreshold"]) {
        if (!_topCueVisible) {
            [self.mainViewController setCue:@"Pull for New Game" inPosition:DRPPageDirectionUp];
            _topCueVisible = YES;
        }
    } else {
        if (_topCueVisible) {
            [self.mainViewController setCue:nil inPosition:DRPPageDirectionUp];
            _topCueVisible = NO;
        }
    }
    
    if (_scrollView.contentSize.height - (_scrollView.contentOffset.y + _scrollView.frame.size.height) < [FRBSwatchist floatForKey:@"page.cueVisibleThreshold"]) {
        if (!_bottomCueVisible) {
            [self.mainViewController setCue:@"Et Cetera" inPosition:DRPPageDirectionDown];
            _bottomCueVisible = YES;
        }
    } else {
        if (_bottomCueVisible) {
            [self.mainViewController setCue:nil inPosition:DRPPageDirectionDown];
            _bottomCueVisible = NO;
        }
    }
}

#pragma mark ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.dragging) return;
    
    // Let DRPMainViewController know about scrolling
    CGFloat offset = [self scrollViewPanOffset:scrollView];
    if (offset != 0) {
        [self.mainViewController handlePanGesture:scrollView.panGestureRecognizer offset:offset];
    } else if (self.view.frame.origin.y != 0) {
        // Centers the currentPage
        // Without this, you can "catch" a bit of the surrounding pages when dragging
        // back past the scrollview content
        CGFloat offset = -[scrollView.panGestureRecognizer translationInView:self.view].y;
        [self.mainViewController handlePanGesture:scrollView.panGestureRecognizer offset:offset];
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
        [self.mainViewController handlePanGesture:scrollView.panGestureRecognizer offset:offset];
    }
}

@end
