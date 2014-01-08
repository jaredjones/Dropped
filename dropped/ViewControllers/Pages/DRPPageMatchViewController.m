//
//  DRPPageMatchViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageMatchViewController.h"
#import "DRPMainViewController.h"
#import "DRPBoardViewController.h"
#import "DRPCurrentWordView.h"
#import "DRPMatch.h"
#import "DRPPlayedWord.h"
#import "DRPDictionary.h"
#import "DRPGreedyScrollView.h"
#import "DRPMatchHeaderViewController.h"
#import "FRBSwatchist.h"
#import "DRPUtility.h"

@interface DRPPageMatchViewController ()

@property DRPMatchHeaderViewController *headerViewController;
@property DRPBoardViewController *boardViewController;
@property DRPCurrentWordView *currentWordView;

@property DRPMatch *match;

@end

@implementation DRPPageMatchViewController

- (id)init
{
    self = [super initWithPageID:DRPPageMatch];
    if (self) {
        self.bottomCue = @"Back";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gameCenterReceivedTurn:)
                                                     name:DRPGameCenterReceivedTurnNotificationName
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadBoardViewController];
    [self loadCurrentWordView];
    [self loadHeaderViewController];
}

- (void)loadScrollView
{
    self.scrollView = [[DRPGreedyScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 0.5);
    self.scrollView.canCancelContentTouches = YES;
    [self.view addSubview:self.scrollView];
}

- (void)loadHeaderViewController
{
    _headerViewController = [[DRPMatchHeaderViewController alloc] init];
    
    [_headerViewController willMoveToParentViewController:self];
    [self addChildViewController:_headerViewController];
    [self.scrollView addSubview:_headerViewController.view];
}

- (void)loadBoardViewController
{
    _boardViewController = [[DRPBoardViewController alloc] initWithNibName:nil bundle:nil];
    _boardViewController.delegate = self;
    
    [_boardViewController willMoveToParentViewController:self];
    [self addChildViewController:_boardViewController];
    
    _boardViewController.view.center = ({
        CGPoint center = self.scrollView.center;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            if (runningPhone5()) {
                center.y += [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPhone5"];
            } else {
                center.y += [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPhone4"];
            }
        } else {
            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                center.y += [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPad"];
            } else {
                center.y += [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPadLandscape"];
            }
        }
        center;
    });
    [self.scrollView addSubview:_boardViewController.view];
}

- (void)loadCurrentWordView
{
    _currentWordView = [[DRPCurrentWordView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [FRBSwatchist floatForKey:@"board.tileLength"])];
    _currentWordView.delegate = self;
    [self repositionCurrentWordViewForInterfaceOrientation:self.interfaceOrientation];
    [self.scrollView addSubview:_currentWordView];
}

- (void)repositionCurrentWordViewForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    _currentWordView.frame = CGRectMake(0, 0, self.view.bounds.size.width, [FRBSwatchist floatForKey:@"board.tileLength"]);
    _currentWordView.center = ({
        CGFloat height = _currentWordView.frame.size.height;
        CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(_boardViewController.view.frame) - height / 2);
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            if (runningPhone5()) {
                center.y += 68;
            } else {
                center.y += 53;
            }
        } else {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
                center.y += 150;
            } else {
                center.y += 102;
            }
        }
        center;
    });
    [_currentWordView repositionCurrentContainer];
}

#pragma mark Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    _boardViewController.view.center = ({
        CGPoint center = self.view.center;
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            center.y += [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPad"];
        } else {
            center.y += [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPadLandscape"];
        }
        center;
    });
    
    [self repositionCurrentWordViewForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    // extract DRPMatch, load it up
    _match = [[DRPMatch alloc] initWithGKMatch:nil];
    [_boardViewController loadBoard:_match.board];
    
    [_currentWordView removeAllCharactersFromCurrentWord];
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterAddedToCurrentWord:(DRPCharacter *)character
{
    [self resetCues];
}

- (void)characterRemovedFromCurrentWord:(DRPCharacter *)character
{
    [self resetCues];
    [_currentWordView characterRemovedFromCurrentWord:character];
}

- (void)characterWasHighlighted:(DRPCharacter *)character
{
    [_currentWordView characterWasHighlighted:character];
}

- (void)characterWasDehighlighted:(DRPCharacter *)character
{
    [_currentWordView characterWasDehighlighted:character];
}

- (BOOL)currentWordIsValid
{
    return _boardViewController.currentPositions.count >=3 && [DRPDictionary isValidWord:_boardViewController.currentWord];
}

- (void)resetCues
{
    if (_boardViewController.currentWord.length == 0) {
        [self.mainViewController setCue:@"Back" inPosition:DRPPageDirectionDown];
        
    } else {
        if ([self currentWordIsValid]) {
            [self.mainViewController setCue:@"Tap to Submit" inPosition:DRPPageDirectionDown];
        } else {
            [self.mainViewController setCue:@"Swipe to Clear" inPosition:DRPPageDirectionDown];
        }
    }
}

#pragma mark DRPCurrentWordViewDelegate

- (void)currentWordViewTapped
{
    if ([self currentWordIsValid]) {
        [_match submitTurnForPositions:_boardViewController.currentPositions];
    }
}

- (void)currentWordViewSwiped
{
    [_boardViewController deselectCurrentWord];
    [self resetCues];
}

- (void)gameCenterReceivedTurn:(NSNotification *)notification
{
    [_boardViewController dropPlayedWord:notification.userInfo[@"playedWord"]];
    [_currentWordView removeAllCharactersFromCurrentWord];
    [self resetCues];
}

@end
