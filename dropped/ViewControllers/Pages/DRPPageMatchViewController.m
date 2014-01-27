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
#import "DRPMatchHeaderViewController.h"

#import "DRPMatch.h"
#import "DRPBoard.h"
#import "DRPPlayedWord.h"

#import "DRPGameCenterInterface.h"
#import "DRPDictionary.h"
#import "DRPGreedyScrollView.h"

#import "FRBSwatchist.h"
#import "DRPUtility.h"

@interface DRPPageMatchViewController ()

@property DRPMatchHeaderViewController *headerViewController;
@property DRPBoardViewController *boardViewController;
@property DRPCurrentWordView *currentWordView;

@property BOOL isCurrentWordValid;

@property DRPMatch *match;
@property NSInteger renderedTurn;

@end

@implementation DRPPageMatchViewController

- (id)init
{
    self = [super initWithPageID:DRPPageMatch];
    if (self) {
        self.bottomCue = @"Back";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gameCenterReceivedLocalTurn:)
                                                     name:DRPGameCenterReceivedLocalTurnNotificationName
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedRemoteGameCenterTurn:)
                                                     name:DRPGameCenterReceivedRemoteTurnNotificationName
                                                object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Loading/Layout

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
    
    // Clear out played words and selected tiles
    [_currentWordView cycleOutTiles];
    _isCurrentWordValid = NO;
    // TODO: unselect any tiles previously selected
    
    
    // Extract DRPMatch, load it up
    if (!userInfo[@"match"]) {
        // TODO: How the hell did you get here? Return to List page
    }
    
    DRPMatch *prevMatch = _match;
    _match = userInfo[@"match"];
    
    // tmp
    prevMatch = nil;
    
    if (_match != prevMatch) {
        
        _renderedTurn = MAX(_match.currentTurn - 1, 0);
        // tmp
        _renderedTurn = 0;
        
        [_boardViewController loadBoard:_match.board atTurn:_renderedTurn];
        [_currentWordView setTurnsLeft:26 - _match.currentTurn];
        
        [_headerViewController observePlayers:_match.players];
        
    } else {
        // TODO: fast-forward to current turn
        [_currentWordView setTurnsLeft:26 - _match.currentTurn];
        
    }
}

- (void)didMoveToCurrent
{
    [super didMoveToCurrent];
    
    [self advanceRenderedTurnToTurn:_match.currentTurn];
}

- (void)resetCues
{
    NSString *newBottomCue = nil;
    
    if (_boardViewController.currentWord.length == 0) {
        newBottomCue = @"Back";
        
    } else {
        if (_isCurrentWordValid) {
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

#pragma mark Turn Transitions

- (void)advanceRenderedTurnToTurn:(NSInteger)turn
{
    // TODO: this should do snazzy things with currentWordView (later)
    // TODO: tiles shouldn't be enabled while turn transitions are running
    
    // This is essentially recursion that pauses between each
    // iteration (because each iteration is asynchronous)
    if (self.mainViewController.currentPageID == self.pageID && _renderedTurn < turn) {
        [self advanceRenderedTurnWithCompletion:^{
            [self advanceRenderedTurnToTurn:turn];
        }];
    }
}

// Steps the _renderedTurn one turn forward
- (void)advanceRenderedTurnWithCompletion:(void (^)())completion
{
    if (_renderedTurn < _match.currentTurn) {
        [_boardViewController dropPlayedWord:[_match.board wordPlayedForTurn:_renderedTurn] fromTurn:_renderedTurn withCompletion:^{
            _renderedTurn++;
            completion();
        }];
    }
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterAddedToCurrentWord:(DRPCharacter *)character
{
    _isCurrentWordValid = [self validateCurrentWord];
    [self resetCues];
}

- (void)characterRemovedFromCurrentWord:(DRPCharacter *)character
{
    _isCurrentWordValid = [self validateCurrentWord];
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

- (BOOL)validateCurrentWord
{
    return _boardViewController.currentPositions.count >=3 && [DRPDictionary isValidWord:_boardViewController.currentWord];
}

#pragma mark DRPCurrentWordViewDelegate

- (void)currentWordViewTapped
{
    if (_isCurrentWordValid) {
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
    GKTurnBasedMatch *gkMatch = notification.userInfo[@"gkMatch"];
    if (![_match.gkMatch.matchID isEqualToString:gkMatch.matchID]) return;
    
    [_match reloadMatchDataWithCompletion:^(BOOL newTurns) {
        if (newTurns) {
            // ugh, this call needs to be better
            [self dropPlayedWord:nil];
        }
    }];
}

- (void)dropPlayedWord:(DRPPlayedWord *)playedWord
{
    [self advanceRenderedTurnToTurn:_match.currentTurn];
    
    // TODO: this is creaky, incorporate into advanceRenderedTurnToTurn:
    [_currentWordView setTurnsLeft:26 - _match.currentTurn];
    [_currentWordView cycleOutTiles];
    [self resetCues];
}

@end
