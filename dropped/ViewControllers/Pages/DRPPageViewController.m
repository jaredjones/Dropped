//
//  DRPPageViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/5/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageViewController.h"
#import "DRPMainViewController.h"
#import "DRPCueKeeper.h"
#import "FRBSwatchist.h"

@interface DRPPageViewController ()

@property (readwrite) UIScrollView *scrollView;

@end

@implementation DRPPageViewController

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
    // Need a reference to the mainViewController. This is easier than a static reference
    _mainViewController = (DRPMainViewController *)parent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadScrollView];
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.delegate = self;
    
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
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
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

#pragma mark DRPPage

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    
}

- (void)didMoveToCurrent
{
    [self.mainViewController.cueKeeper updateWithPage:self];
}

- (void)willMoveFromCurrent
{
    self.topCueVisible = NO;
    self.bottomCueVisible = NO;
}

- (void)didMoveFromCurrent
{
    
}

#pragma mark Cues
// TODO: remove
- (void)resetCues
{
}

#pragma mark ScrollViewDelegate

- (DRPPageDirection)scrollViewShouldEmphasizeCue:(UIScrollView *)scrollView
{
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStatePossible) return DRPPageDirectionNil;
    
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat threshold = [FRBSwatchist floatForKey:@"page.transitionThreshold"];
    
    if (offset <= -threshold)
        return DRPPageDirectionUp;
        
    if (offset + scrollView.frame.size.height >= threshold + scrollView.contentSize.height)
        return DRPPageDirectionDown;
    
    return DRPPageDirectionNil;
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldTransitionInDirection:(DRPPageDirection)direction
{
    if (direction == DRPPageDirectionUp)
        return [scrollView.panGestureRecognizer velocityInView:self.view].y >= 0;
    
    if (direction == DRPPageDirectionDown)
        return [scrollView.panGestureRecognizer velocityInView:self.view].y <= 0;
        
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![self.mainViewController isCurrentPage:self]) return;
    
    [self.mainViewController.cueKeeper updateWithPage:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Only handle the gesture at the "edges" of the content
    // and only when the drag was started with the appropriate cue visible
    DRPPageDirection direction = [self scrollViewShouldEmphasizeCue:scrollView];
    if ([self scrollView:scrollView shouldTransitionInDirection:direction]) {
        [self.mainViewController transitionToPageInDirection:direction
                                                    userInfo:@{@"velocity" : @([scrollView.panGestureRecognizer velocityInView:scrollView].y)}];
    }
}

#pragma mark Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.mainViewController.cueKeeper updateWithPage:self];
}

@end
