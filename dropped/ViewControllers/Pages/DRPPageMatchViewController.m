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
#import "DRPMatchHeaderViewController.h"
#import "DRPMatchCurrentWordViewController.h"

#import "DRPMatch.h"
#import "DRPPlayer.h"
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
@property DRPMatchCurrentWordViewController *currentWordViewController;

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
    [self loadCurrentWordViewController];
    [self.scrollView bringSubviewToFront:_boardViewController.view];
    [self loadHeaderViewController];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutBoardViewController];
    [self layoutCurrentWordViewController];
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

- (void)loadCurrentWordViewController
{
    _currentWordViewController = [[DRPMatchCurrentWordViewController alloc] initWithNibName:nil bundle:nil];
    
    [_currentWordViewController willMoveToParentViewController:self];
    [self addChildViewController:_currentWordViewController];
    
    [self layoutCurrentWordViewController];
    [self.scrollView addSubview:_currentWordViewController.view];
}

- (void)layoutCurrentWordViewController
{
    [_currentWordViewController layoutWithFrame:({
        CGSize size = CGSizeMake(self.view.bounds.size.width, [FRBSwatchist floatForKey:@"board.tileLength"]);
        CGPoint center = ({
            CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(_boardViewController.view.frame) - size.height / 2);
            
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
        CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height);
    })];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    // Clear out played words and selected tiles
    _isCurrentWordValid = NO;
    // TODO: unselect any tiles previously selected
    
    
    // Extract DRPMatch, load it up
    if (!userInfo[@"match"]) {
        // TODO: How the hell did you get here? Return to List page
    }
    
    DRPMatch *prevMatch = _match;
    _match = userInfo[@"match"];
    
    if (_match != prevMatch) {
        [_headerViewController observePlayers:_match.players];
    }
    
    // Fast forward to current turn
    _renderedTurn = MAX(_match.currentTurn - 1, 0);
    if ([FRBSwatchist boolForKey:@"debug.playBackEntireMatch"]) {
        _renderedTurn = 0;
    }
    
    [_boardViewController loadBoard:_match.board atTurn:_renderedTurn];
    [_headerViewController setCurrentPlayerTurn:_match.currentPlayer.turn multiplierColors:[_match.board multiplierColorsForTurn:_match.currentTurn]];
    [_currentWordViewController setTurnsLeft:_match.turnsLeft isLocalTurn:_match.isLocalPlayerTurn fromDirection:DRPDirectionLeft];
    
    // TODO: reload player aliases
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

- (void)characterWasAddedToCurrentWord:(DRPCharacter *)character
{
    _isCurrentWordValid = [self validateCurrentWord];
    [self resetCues];
}

- (void)characterWasRemovedFromCurrentWord:(DRPCharacter *)character
{
    _isCurrentWordValid = [self validateCurrentWord];
    [self resetCues];
    [_currentWordViewController characterWasRemoved:character fromDirection:DRPDirectionLeft];
    
    // Explicitly transition to turnsLeft label
    // Do this here so _boardViewController wins when there's a disparity in the current word
    if (_boardViewController.currentPositions.count == 0) {
        [_currentWordViewController setTurnsLeft:_match.turnsLeft isLocalTurn:_match.isLocalPlayerTurn fromDirection:DRPDirectionLeft];
    }
}

- (void)characterWasHighlighted:(DRPCharacter *)character
{
    [_currentWordViewController characterWasHighlighted:character fromDirection:DRPDirectionLeft];
}

- (void)characterWasDehighlighted:(DRPCharacter *)character
{
    [_currentWordViewController characterWasDehighlighted:character];
}

- (BOOL)validateCurrentWord
{
    return _boardViewController.currentPositions.count >=3 && [DRPDictionary isValidWord:_boardViewController.currentWord];
}

#pragma mark DRPCurrentWordViewControllerDelegate

- (void)currentWordWasTapped
{
    if (_isCurrentWordValid) {
        [_match submitTurnForPositions:_boardViewController.currentPositions];
    }
}

- (void)currentWordWasSwiped
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
            // TODO: make sure the match is not being replayed when this happens
            [self dropPlayedWord:nil];
        }
    }];
}

- (void)dropPlayedWord:(DRPPlayedWord *)playedWord
{
    [self advanceRenderedTurnToTurn:_match.currentTurn];
    
    // TODO: this is creaky, incorporate into advanceRenderedTurnToTurn:
    [_headerViewController setCurrentPlayerTurn:_match.currentPlayer.turn multiplierColors:[_match.board multiplierColorsForTurn:_match.currentTurn]];
    [_currentWordViewController setTurnsLeft:_match.turnsLeft isLocalTurn:_match.isLocalPlayerTurn fromDirection:DRPDirectionLeft];
    [self resetCues];
}

@end
