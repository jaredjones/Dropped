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

// Data source provides a clean mapping from pageID -> DRPPageViewController
@property DRPPageDataSource *dataSource;
@property DRPPageViewController *currentPage, *upPage, *downPage;

// Keeps track of cue state/animations
@property DRPCueKeeper *cueKeeper;

// If there isn't a strong reference to the running DRPTransition,
// things go wonky
@property DRPTransition *currentTransition;

@end

#pragma mark - DRPMainViewController

@implementation DRPMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataSource = [[DRPPageDataSource alloc] init];
    }
    return self;
}

#pragma mark Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DRPTransition setReferenceViewForUIDynamics:self.view];
    self.view.backgroundColor = [FRBSwatchist colorForKey:@"colors.white"];
    
    // Because DRPCueKeeper is now a UIViewController, initialization can happen
    // here
    self.cueKeeper = [[DRPCueKeeper alloc] init];
    [self.cueKeeper willMoveToParentViewController:self];
    [self addChildViewController:self.cueKeeper];
    [self.view addSubview:self.cueKeeper.view];
    
    [self setCurrentPageID:DRPPageSplash animated:NO userInfo:nil];
}


- (void)viewWillLayoutSubviews
{
//    // CueKeeper initialization
//    // This is here because the view's frame is not always properly initialized
//    // when viewDidLoad is called.
//    if (!self.cueKeeper) {
//        self.cueKeeper = [[DRPCueKeeper alloc] initWithView:self.view];
//        [self setCurrentPageID:DRPPageSplash animated:NO userInfo:nil];
//    }
}

#pragma mark DRPPageViewControllers

- (BOOL)isCurrentPage:(DRPPageViewController *)page
{
    return page == self.currentPage;
}

- (void)setCurrentPageID:(DRPPageID)pageID animated:(BOOL)animated userInfo:(NSDictionary *)userInfo
{
    if (pageID == DRPPageNil) return;
    if (self.currentPage && self.currentPage.pageID == pageID) return;
    
    DRPPageDirection animationDirection = [_dataSource directionFromPage:self.currentPage.pageID to:pageID];
    if (!self.currentPage) {
        animationDirection = DRPPageDirectionNil;
    }
    
    // Compute and Configure new Pages based on direction
    DRPPageViewController *prevPage = self.currentPage;
    
    // Note: resets self.currentPage
    [self loadNewPagesAroundCurrentPageID:pageID];
    [self configurePageViewsForAnimationWithPreviousPage:prevPage animated:animated];
    
    [prevPage willMoveFromCurrent];
    [self.currentPage willMoveToCurrentWithUserInfo:userInfo];
    
    // Transition to new Page
    void (^animationCompletion)() = ^{
        [self decommissionOldPagesWithPreviousPage:prevPage];
        [self repositionPagesAroundCurrentPage];
        self.upPage.view.hidden = YES;
        self.downPage.view.hidden = YES;
    };
    
    // Only run animation if the page is not already in place
    if (animated && self.currentPage.view.frame.origin.y != 0) {
        self.currentTransition = [DRPTransition transitionWithStart:prevPage
                                                        destination:self.currentPage
                                                          direction:animationDirection
                                                         completion:animationCompletion];
        
        // The "velocity" of the drag is stored so there are no instaneous
        // velocity jerks in the animation
        self.currentTransition.startingVelocity = [userInfo[@"velocity"] floatValue];
        
        // Hide cues and cueIndicators during transition
        [self.cueKeeper setCueText:nil forPosition:DRPPageDirectionUp];
        [self.cueKeeper setCueText:nil forPosition:DRPPageDirectionDown];
        
        self.currentPage.view.hidden = NO;
        [self.currentTransition execute];
        
    } else {
        animationCompletion();
    }
}

// Just a convenience method
- (void)transitionToPageInDirection:(DRPPageDirection)direction userInfo:(NSDictionary *)userInfo
{
    [self setCurrentPageID:[self.dataSource pageIDInDirection:direction from:self.currentPage.pageID]
                  animated:YES
                  userInfo:userInfo];
}

// Loads the new surrounding DRPPages
// Adds them to the mainViewController if they haven't been added already
- (void)loadNewPagesAroundCurrentPageID:(DRPPageID)pageID
{
    self.currentPage = [self.dataSource pageForPageID:pageID];
    self.upPage = [_dataSource pageForPageID:[self.dataSource pageIDInDirection:DRPPageDirectionUp from:pageID]];
    self.downPage = [self.dataSource pageForPageID:[self.dataSource pageIDInDirection:DRPPageDirectionDown from:pageID]];
    
    // Add pages as childViewControllers
    for (DRPPageViewController *page in @[self.currentPage ?: [NSNull null],
                                          self.upPage ?: [NSNull null],
                                          self.downPage ?: [NSNull null]]) {
        if (page != (id)[NSNull null] && page.parentViewController != self) {
            [self addChildViewController:page];
        }
    }
}

// Reposition the DRPPage UIViews appropriately
// Slightly different rules if animating to new page
- (void)configurePageViewsForAnimationWithPreviousPage:(DRPPageViewController *)prevPage animated:(BOOL)animated
{
    [self.view addSubview:self.currentPage.view];
    [self.view addSubview:self.upPage.view];
    [self.view addSubview:self.downPage.view];
    
    if (!animated) {
        self.currentPage.view.frame = self.view.bounds;
        
    } else {
        // Mess with the layering within parent view
        // to make sure the correct views are visible
        [self.view bringSubviewToFront:self.currentPage.view];
        [self.view bringSubviewToFront:prevPage.view];
        [self.view bringSubviewToFront:self.cueKeeper.view];
        
        self.upPage.view.hidden = YES;
        self.downPage.view.hidden = YES;
        prevPage.view.hidden = NO;
        
        self.currentPage.view.frame = ({
            DRPPageDirection direction = [self.dataSource directionFromPage:prevPage.pageID to:self.currentPage.pageID];
            
            CGRect frame = prevPage.view.frame;
            if (direction == DRPPageDirectionUp) {
                frame.origin.y -= self.currentPage.view.frame.size.height;
                
            } else if (direction == DRPPageDirectionDown) {
                frame.origin.y += prevPage.view.frame.size.height;
            }
            
            frame;
        });
    }
    
    [self repositionPagesAroundCurrentPage];
}

- (void)repositionPagesAroundCurrentPage
{
    CGRect frame = self.currentPage.view.frame;
    frame.origin.y -= CGRectGetHeight(frame);
    self.upPage.view.frame = frame;
    
    frame.origin.y = CGRectGetMaxY(self.currentPage.view.frame);
    self.downPage.view.frame = frame;
}

// Called to clean up DRPPages sitting around that aren't active
// Essentially removes all non-critical views so they can't possible get in the way
- (void)decommissionOldPagesWithPreviousPage:(DRPPageViewController *)prevPage
{
    // TODO: should probably keep an NSSet of priveleged UIViews
    for (UIView *view in self.view.subviews) {
        if (!(view == self.currentPage.view || view == self.upPage.view || view == self.downPage.view || view == self.cueKeeper.view)) {
            [view removeFromSuperview];
        }
    }
    
    [prevPage didMoveFromCurrent];
    [self.currentPage didMoveToCurrent];
}

#pragma mark Rotation

- (BOOL)shouldAutorotate
{
    // Only allow autorotation while the transition isn't running
    return !self.currentTransition.active;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

// Hide cues during autorotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

@end
