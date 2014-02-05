//
//  DRPPageMatchViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageMatchViewController.h"
#import "DRPMainViewController.h"

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
    _currentWordViewController.delegate = self;
    
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
    [self setHeaderViewControllerTurn:_renderedTurn];
    
    // Set initial currentWordView
    if (_match.currentTurn > 0) {
        // If there have been turns, set the currentWordView to _renderedTurn's word
        NSArray *characters = [_match.board charactersForPositions:[_match.board wordPlayedForTurn:_renderedTurn].positions
                                                           forTurn:_renderedTurn];
        [_currentWordViewController setCharacters:characters
                                    fromDirection:[self currentWordDirectionForPlayer:[_match playerForTurn:_renderedTurn]]];
    } else {
        // If it's the first turn, set the currentWordView to the turnsLeft label
        [_currentWordViewController setTurnsLeft:_match.turnsLeft
                                     isLocalTurn:_match.isLocalPlayerTurn
                                   fromDirection:[self currentWordDirectionForPlayer:_match.currentPlayer]];
    }
    
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
    
    if (_boardViewController.currentPlayedWord.positions.count == 0) {
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

- (DRPDirection)currentWordDirectionForPlayer:(DRPPlayer *)player
{
    if (player.turn == 0) {
        return DRPDirectionLeft;
    }
    return DRPDirectionRight;
}

- (void)advanceRenderedTurnToTurn:(NSInteger)turn
{
    // Make sure user can't mess with anything on the board
    // while the turns are advancing
    if (_boardViewController.boardEnabled) {
        _boardViewController.boardEnabled = NO;
    }
    if (_currentWordViewController.gesturesEnabled) {
        _currentWordViewController.gesturesEnabled = NO;
    }
    
    // This is essentially recursion that pauses between each
    // iteration (because each iteration is asynchronous)
    if (self.mainViewController.currentPageID == self.pageID && _renderedTurn <= turn) {
        [self stepRenderedTurnWithCompletion:^{
            [self advanceRenderedTurnToTurn:turn];
            
            // Turns are done advancing, reenable the board and the currentWordView 
            if (_renderedTurn == turn) {
                _boardViewController.boardEnabled = YES;
                _currentWordViewController.gesturesEnabled = YES;
            }
        }];
    }
}

// Steps the _renderedTurn one turn forward
- (void)stepRenderedTurnWithCompletion:(void (^)())completion
{
    DRPDirection direction = [self currentWordDirectionForPlayer:[_match playerForTurn:_renderedTurn]];
    
    if (_renderedTurn < _match.currentTurn) {
        // Slide in currentWordView containing _renderedTurn's word
        NSArray *characters = [_match.board charactersForPositions:[_match.board wordPlayedForTurn:_renderedTurn].positions
                                                           forTurn:_renderedTurn];
        [_currentWordViewController setCharacters:characters fromDirection:direction];
        
        // Drop the played word
        [_boardViewController dropPlayedWord:[_match.board wordPlayedForTurn:_renderedTurn] fromTurn:_renderedTurn withCompletion:^{
            _renderedTurn++;
            completion();
        }];
        
    } else if (_renderedTurn == _match.currentTurn) {
        // Caught up to turn, show the turnsLeft container
        [_currentWordViewController setTurnsLeft:_match.turnsLeft isLocalTurn:_match.isLocalPlayerTurn fromDirection:direction];
        
        [self resetCues];
    }
    
    [self setHeaderViewControllerTurn:_renderedTurn];
}

- (void)setHeaderViewControllerTurn:(NSInteger)turn
{
    [_headerViewController setCurrentPlayerTurn:[_match playerForTurn:turn].turn
                               multiplierColors:[_match.board multiplierColorsForTurn:turn]];
    
    [_headerViewController setScores:[_match.board scoresForTurn:MIN(turn + 1, _match.currentTurn)]];
}

- (void)setHeaderViewControllerScoresWithCurrentWord:(DRPPlayedWord *)currentWord
{
    NSMutableDictionary *scores = [_match.board.scores mutableCopy];
    
    NSInteger currentTurn = _match.currentPlayer.turn;
    NSInteger newScore = [scores[@(currentTurn)] intValue] + [_match.board scoreForPlayedWord:currentWord forTurn:_match.currentTurn];
    scores[@(currentTurn)] = @(newScore);
    
    [_headerViewController setScores:scores];
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterWasAddedToCurrentWord:(DRPCharacter *)character
{
    _isCurrentWordValid = [self validateCurrentWord];
    [self setHeaderViewControllerScoresWithCurrentWord:_boardViewController.currentPlayedWord];
    [self resetCues];
}

- (void)characterWasRemovedFromCurrentWord:(DRPCharacter *)character
{
    _isCurrentWordValid = [self validateCurrentWord];
    [self setHeaderViewControllerScoresWithCurrentWord:_boardViewController.currentPlayedWord];
    [self resetCues];
    [_currentWordViewController characterWasRemoved:character fromDirection:DRPDirectionLeft];
    
    // Explicitly transition to turnsLeft label
    // Do this here so _boardViewController wins when there's a disparity in the current word
    if (_boardViewController.currentPlayedWord.positions.count == 0) {
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
    NSString *word = [_match.board wordForPositions:_boardViewController.currentPlayedWord.positions];
    return _boardViewController.currentPlayedWord.positions.count >=3 && [DRPDictionary isValidWord:word];
}

#pragma mark DRPCurrentWordViewControllerDelegate

- (void)currentWordWasTapped
{
    if (_isCurrentWordValid) {
        [_match submitTurnForPositions:_boardViewController.currentPlayedWord.positions];
    }
}

- (void)currentWordWasSwiped
{
    [_boardViewController deselectCurrentWord];
    [self setHeaderViewControllerTurn:_match.currentTurn];
    [self resetCues];
}

- (void)gameCenterReceivedLocalTurn:(NSNotification *)notification
{
    [self advanceRenderedTurnToTurn:_match.currentTurn];
}

- (void)receivedRemoteGameCenterTurn:(NSNotification *)notification
{
    GKTurnBasedMatch *gkMatch = notification.userInfo[@"gkMatch"];
    if (![_match.gkMatch.matchID isEqualToString:gkMatch.matchID]) return;
    
    [_match reloadMatchDataWithCompletion:^(BOOL newTurns) {
        if (newTurns) {
            // TODO: make sure the match is not being replayed when this happens
            [self advanceRenderedTurnToTurn:_match.currentTurn];
        }
    }];
}

#pragma mark DRPHeaderViewControllerDelegate

- (void)headerViewTappedPlayerTileForTurn:(NSInteger)turn
{
    // TODO: replay that last turn, yo
}

@end
