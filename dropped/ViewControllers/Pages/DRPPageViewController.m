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
    _scrollView.delaysContentTouches = NO;
    _scrollView.delegate = self;
    
    // This is vital for performant orientation changes
    // Note that extra care must be taken to ensure views
    // are not visible outside of the scrollView, otherwise
    // they will be potentially visible during the orientation
    // change
    self.scrollView.clipsToBounds = NO;
}

- (void)viewWillLayoutSubviews
{
    [self layoutScrollView];
}

#pragma mark Views

- (void)loadScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 0.5);
    [self.view addSubview:_scrollView];
}

- (void)layoutScrollView
{
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = ({
        CGSize size = self.scrollView.frame.size;
        size.height += 0.5;
        size;
    });
}

- (void)resetCues
{
    CGFloat offset = _scrollView.contentOffset.y;
    CGFloat threshold = [FRBSwatchist floatForKey:@"page.transitionThreshold"];
    
    if (offset <= threshold) {
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

    if (offset + _scrollView.frame.size.height >= _scrollView.contentSize.height - threshold) {
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

- (void)hideCues
{
    [_mainViewController setCue:nil inPosition:DRPPageDirectionUp];
    [_mainViewController setCue:nil inPosition:DRPPageDirectionDown];
    _topCueVisible = NO;
    _bottomCueVisible = NO;
}

#pragma mark DRPPage

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

- (DRPPageDirection)scrollViewShouldEmphasizeCue:(UIScrollView *)scrollView
{
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStatePossible) return DRPPageDirectionNil;
    
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat threshold = [FRBSwatchist floatForKey:@"page.transitionThreshold"];
    
    if (offset <= -threshold) {
        return DRPPageDirectionUp;
        
    } else if (offset + scrollView.frame.size.height >= threshold + scrollView.contentSize.height) {
        return DRPPageDirectionDown;
    }
    return DRPPageDirectionNil;
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldTransitionInDirection:(DRPPageDirection)direction
{
    if (direction == DRPPageDirectionUp) {
        return [scrollView.panGestureRecognizer velocityInView:self.view].y >= 0;
    } else if (direction == DRPPageDirectionDown) {
        return [scrollView.panGestureRecognizer velocityInView:self.view].y <= 0;
    }
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.mainViewController.currentPageID != self.pageID) return;
    
    [_mainViewController emphasizeCueInPosition:[self scrollViewShouldEmphasizeCue:scrollView]];
    [self resetCues];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Only handle the gesture at the "edges" of the content
    // and only when the drag was started with the appropriate cue visible
    DRPPageDirection direction = [self scrollViewShouldEmphasizeCue:scrollView];
    if ([self scrollView:scrollView shouldTransitionInDirection:direction]) {
        [_mainViewController transitionToPageInDirection:direction
                                                userInfo:@{@"velocity" : @([scrollView.panGestureRecognizer velocityInView:scrollView].y)}];
    }
}

#pragma mark Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self hideCues];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resetCues];
}

@end
