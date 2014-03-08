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

@property (readwrite) UIScrollView *scrollView;

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
    [self.scrollView bringSubviewToFront:self.boardViewController.view];
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
    self.headerViewController = [[DRPMatchHeaderViewController alloc] init];
    self.headerViewController.delegate = self;

    [self addChildViewController:self.headerViewController];
    [self.scrollView addSubview:self.headerViewController.view];
}

- (void)loadBoardViewController
{
    self.boardViewController = [[DRPBoardViewController alloc] initWithNibName:nil bundle:nil];
    self.boardViewController.delegate = self;

    [self addChildViewController:self.boardViewController];

    [self layoutBoardViewController];
    [self.scrollView addSubview:self.boardViewController.view];
}

- (void)layoutBoardViewController
{
    self.boardViewController.view.center = ({
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
    self.currentWordViewController = [[DRPMatchCurrentWordViewController alloc] initWithNibName:nil bundle:nil];
    self.currentWordViewController.delegate = self;

    [self addChildViewController:self.currentWordViewController];

    [self layoutCurrentWordViewController];
    [self.scrollView addSubview:self.currentWordViewController.view];
}

- (void)layoutCurrentWordViewController
{
    [self.currentWordViewController layoutWithFrame:({
        CGSize size = CGSizeMake(self.view.bounds.size.width, [FRBSwatchist floatForKey:@"board.tileLength"]);
        CGPoint center = ({
            CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                         CGRectGetMaxY(self.boardViewController.view.frame) - size.height / 2);

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
    self.isCurrentWordValid = NO;


    // Extract DRPMatch, load it up
    if (!userInfo[@"match"]) {
        // TODO: How the hell did you get here? Return to List page
    }

    DRPMatch *prevMatch = self.match;
    self.match = userInfo[@"match"];

    if (self.match != prevMatch) {
        [self.headerViewController observePlayers:self.match.players];
    }

    // Fast forward to current turn
    NSInteger startTurn = MAX(self.match.currentTurn - 1, 0);
    if ([FRBSwatchist boolForKey:@"debug.playBackEntireMatch"]) {
        startTurn = 0;
    }

    [self loadTurn:startTurn];

    // Set initial currentWordView
    if (self.match.currentTurn > 0) {
        // If there have been turns, set the currentWordView to _renderedTurn's word
        NSArray *characters = [self.match.board charactersForPositions:[self.match.board wordPlayedForTurn:self.renderedTurn].positions
                                                               forTurn:self.renderedTurn];
        [self.currentWordViewController setCharacters:characters
                                    fromDirection:[self currentWordDirectionForPlayer:[self.match playerForTurn:self.renderedTurn]]];
    } else {
        // If it's the first turn, set the currentWordView to the turnsLeft label
        [self.currentWordViewController setTurnsLeft:self.match.turnsLeft
                                     isLocalTurn:self.match.isLocalPlayerTurn
                                   fromDirection:[self currentWordDirectionForPlayer:self.match.currentPlayer]];
    }

    [self.match reloadPlayerAliases];
}

- (void)loadTurn:(NSInteger)turn
{
    self.renderedTurn = turn;
    [self.boardViewController loadBoard:self.match.board atTurn:self.renderedTurn];
    [self setHeaderViewControllerTurn:self.renderedTurn];
}

- (void)didMoveToCurrent
{
    [super didMoveToCurrent];

    [self advanceRenderedTurnToTurn:self.match.currentTurn];
}

- (void)resetCues
{
    NSString *newBottomCue = nil;

    if (self.boardViewController.currentPlayedWord.positions.count == 0) {
        newBottomCue = @"Back";

    } else {
        if (self.isCurrentWordValid) {
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
    if (self.boardViewController.boardEnabled) {
        self.boardViewController.boardEnabled = NO;
    }
    if (self.currentWordViewController.gesturesEnabled) {
        self.currentWordViewController.gesturesEnabled = NO;
    }

    // This is essentially recursion that pauses between each
    // iteration (because each iteration is asynchronous)
    if ([self.mainViewController isCurrentPage:self] && self.renderedTurn <= turn) {
        [self stepRenderedTurnWithCompletion:^{
            [self advanceRenderedTurnToTurn:turn];
        }];

        // Turns are done advancing, reenable the board and the currentWordView
        // TODO: Doesn't keep board disabled when the match is finished
        if (self.renderedTurn == turn && !self.match.finished) {
            self.boardViewController.boardEnabled = YES;
            self.currentWordViewController.gesturesEnabled = YES;
        }
    }
}

// Steps the _renderedTurn one turn forward
- (void)stepRenderedTurnWithCompletion:(void (^)())completion
{
    DRPDirection direction = [self currentWordDirectionForPlayer:[self.match playerForTurn:self.renderedTurn]];

    if (self.renderedTurn < self.match.currentTurn) {
        // Slide in currentWordView containing _renderedTurn's word
        NSArray *characters = [self.match.board charactersForPositions:[self.match.board wordPlayedForTurn:self.renderedTurn].positions
                                                           forTurn:self.renderedTurn];
        [self.currentWordViewController setCharacters:characters fromDirection:direction];

        // Drop the played word
        [self.boardViewController dropPlayedWord:[self.match.board wordPlayedForTurn:self.renderedTurn]
                                        fromTurn:self.renderedTurn
                                  withCompletion:^{
            self.renderedTurn++;
            completion();
        }];

    } else if (self.renderedTurn == self.match.currentTurn) {

        // Caught up to turn, show the turnsLeft container
        [self.currentWordViewController setTurnsLeft:self.match.turnsLeft
                                         isLocalTurn:self.match.isLocalPlayerTurn
                                       fromDirection:direction];
        [self resetCues];
    }

    [self setHeaderViewControllerTurn:self.renderedTurn];
}

// Following two methods manipulate the headerViewController at various times during playback
- (void)setHeaderViewControllerTurn:(NSInteger)turn
{

    [self.headerViewController setCurrentPlayerTurn:turn < self.match.numberOfTurns ? [self.match playerForTurn:turn].turn : -1
                               multiplierColors:[self.match.board multiplierColorsForTurn:turn]];

    [self.headerViewController setScores:[self.match.board scoresForTurn:MIN(turn + 1, self.match.currentTurn)]];
}

// Modifies the score of the currentPlayer as they're tapping out a word
- (void)setHeaderViewControllerScoresWithCurrentWord:(DRPPlayedWord *)currentWord
{
    NSMutableDictionary *scores = [self.match.board.scores mutableCopy];

    NSInteger currentTurn = self.match.currentPlayer.turn;
    NSInteger newScore = [scores[@(currentTurn)] intValue] + [self.match.board scoreForPlayedWord:currentWord forTurn:self.match.currentTurn];
    scores[@(currentTurn)] = @(newScore);

    [self.headerViewController setScores:scores];
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterWasAddedToCurrentWord:(DRPCharacter *)character
{
    self.isCurrentWordValid = [self validateCurrentWord];
    [self setHeaderViewControllerScoresWithCurrentWord:self.boardViewController.currentPlayedWord];
    [self resetCues];
}

- (void)characterWasRemovedFromCurrentWord:(DRPCharacter *)character
{
    DRPDirection direction = [self currentWordDirectionForPlayer:self.match.currentPlayer];
    self.isCurrentWordValid = [self validateCurrentWord];
    [self setHeaderViewControllerScoresWithCurrentWord:self.boardViewController.currentPlayedWord];
    [self resetCues];
    [self.currentWordViewController characterWasRemoved:character fromDirection:direction];

    // Explicitly transition to turnsLeft label
    // Do this here so _boardViewController wins when there's a disparity in the current word
    if (self.boardViewController.currentPlayedWord.positions.count == 0) {
        [self.currentWordViewController setTurnsLeft:self.match.turnsLeft isLocalTurn:self.match.isLocalPlayerTurn fromDirection:direction];
    }
}

- (void)characterWasHighlighted:(DRPCharacter *)character
{
    [self.currentWordViewController characterWasHighlighted:character fromDirection:[self currentWordDirectionForPlayer:self.match.currentPlayer]];
}

- (void)characterWasDehighlighted:(DRPCharacter *)character
{
    [self.currentWordViewController characterWasDehighlighted:character];
}

- (BOOL)validateCurrentWord
{
    NSString *word = [self.match.board wordForPositions:self.boardViewController.currentPlayedWord.positions];
    return self.boardViewController.currentPlayedWord.positions.count >=3 && [DRPDictionary isValidWord:word];
}

#pragma mark DRPCurrentWordViewControllerDelegate

- (void)currentWordWasTapped
{
    if (self.isCurrentWordValid) {
        [self.match submitTurnForPositions:self.boardViewController.currentPlayedWord.positions];
    }
}

- (void)currentWordWasSwiped
{
    [self.boardViewController deselectCurrentWord];
    [self setHeaderViewControllerTurn:self.match.currentTurn];
    [self resetCues];
}

#pragma mark Remote Turns

- (void)gameCenterReceivedLocalTurn:(NSNotification *)notification
{
    [self advanceRenderedTurnToTurn:self.match.currentTurn];
}

- (void)receivedRemoteGameCenterTurn:(NSNotification *)notification
{
    GKTurnBasedMatch *gkMatch = notification.userInfo[@"gkMatch"];
    if (![self.match.gkMatch.matchID isEqualToString:gkMatch.matchID]) return;

    [self.match reloadMatchDataWithCompletion:^(BOOL newTurns) {
        if (newTurns) {
            // TODO: make sure the match is not being replayed when this happens
            [self advanceRenderedTurnToTurn:self.match.currentTurn];
        }
    }];
}

#pragma mark DRPHeaderViewControllerDelegate

- (void)headerViewTappedPlayerTileForTurn:(NSInteger)turn
{
    // Make sure the board is not currently playing back
    if (self.renderedTurn != self.match.currentTurn) {
        return;
    }

    // Play back those turns, yo
    NSInteger startTurn = self.match.currentTurn;

    if (turn == self.match.currentPlayer.turn) {
        startTurn = startTurn - 2;
    } else {
        startTurn = startTurn - 1;
    }

    // load turn and replay
    if (self.match.currentTurn > startTurn && startTurn >= 0) {
        [self loadTurn:startTurn];
        [self advanceRenderedTurnToTurn:self.match.currentTurn];
    }
}

@end
