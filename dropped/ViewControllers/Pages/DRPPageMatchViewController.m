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
                                                 selector:@selector(gameCenterReceivedLocalTurn:)
                                                     name:DRPGameCenterReceivedTurnNotificationName
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadBoardViewController];
    [self loadCurrentWordView];
    [self.scrollView bringSubviewToFront:_boardViewController.view];
    [self loadHeaderViewController];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutBoardViewController];
    [self layoutCurrentWordView];
}

- (void)loadScrollView
{
    self.scrollView = [[DRPGreedyScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 0.5);
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
    
    [self layoutBoardViewController];
    [self.scrollView addSubview:_boardViewController.view];
}

- (void)layoutBoardViewController
{
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
}

- (void)loadCurrentWordView
{
    _currentWordView = [[DRPCurrentWordView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [FRBSwatchist floatForKey:@"board.tileLength"])];
    _currentWordView.delegate = self;
    [self.scrollView addSubview:_currentWordView];
}

- (void)layoutCurrentWordView
{
    _currentWordView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, [FRBSwatchist floatForKey:@"board.tileLength"]);
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
            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                center.y += 150;
            } else {
                center.y += 102;
            }
        }
        center;
    });
    [_currentWordView recenter];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    // Clear out old match
    [_currentWordView cycleOutTiles];
    
    
    // Extract DRPMatch, load it up
    _match = userInfo[@"match"];
    if (_match) {
        [_boardViewController loadBoard:_match.board];
        [_headerViewController observePlayers:_match.players];
        [_currentWordView setTurnsLeft:26 - _match.currentTurn];
    
    } else {
        // TODO: How the hell did you get here? Display an error message where the board usually is
    }
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
    NSString *newBottomCue = nil;
    
    if (_boardViewController.currentWord.length == 0) {
        newBottomCue = @"Back";
        
    } else {
        if ([self currentWordIsValid]) {
            newBottomCue = @"Tap to Submit";
            
        } else {
            newBottomCue = @"Swipe to Clear";
        }
    }
    
    if (![newBottomCue isEqualToString:self.bottomCue]) {
        self.bottomCueVisible = NO;
    }
    self.bottomCue = newBottomCue;
    
    [super resetCues];
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

- (void)gameCenterReceivedLocalTurn:(NSNotification *)notification
{
    [self dropPlayedWord:notification.userInfo[@"playedWord"]];
}

- (void)receivedRemoteGameCenterTurn:(NSNotification *)notification
{
}

- (void)dropPlayedWord:(DRPPlayedWord *)playedWord
{
    [_boardViewController dropPlayedWord:playedWord];
    [_currentWordView setTurnsLeft:26 - _match.currentTurn];
    [_currentWordView cycleOutTiles];
    [self resetCues];
}

@end
