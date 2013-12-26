//
//  DRPPageMatchViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageMatchViewController.h"
#import "DRPBoardViewController.h"
#import "DRPCurrentWordView.h"
#import "DRPMatch.h"
#import "DRPPlayedWord.h"
#import "DRPDictionary.h"

@interface DRPPageMatchViewController ()

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
    
    [self loadCurrentWordView];
    [self loadBoardViewController];
}

- (void)loadBoardViewController
{
    _boardViewController = [[DRPBoardViewController alloc] initWithNibName:nil bundle:nil];
    _boardViewController.delegate = self;
    
    [_boardViewController willMoveToParentViewController:self];
    [self addChildViewController:_boardViewController];
    
    CGPoint center = self.scrollView.center;
    center.y += 9;
    _boardViewController.view.center = center;
    [self.scrollView addSubview:_boardViewController.view];
}

- (void)loadCurrentWordView
{
    _currentWordView = [[DRPCurrentWordView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    _currentWordView.delegate = self;
    
    // positions approximate for now
    CGPoint center = self.scrollView.center;
    center.y += 9 + 160 + 25 + 3;
    _currentWordView.center = center;
    
    [self.scrollView addSubview:_currentWordView];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    // extract DRPMatch, load it up
    _match = [[DRPMatch alloc] initWithGKMatch:nil];
    [_boardViewController loadBoard:_match.board];
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterAddedToCurrentWord:(DRPCharacter *)character
{
    // change bottom cue
    
    [_currentWordView characterAddedToCurrentWord:character];
    
    // DEBUG: "submit" first word found
    if (_boardViewController.currentPositions.count >= 3 && [DRPDictionary isValidWord:_boardViewController.currentWord]) {
        [self currentWordViewTapped];
    }
}

- (void)characterRemovedFromCurrentWord:(DRPCharacter *)character
{
    // change bottom cue
    // if no characters left, change DRPPlayedWordView message
    
    [_currentWordView characterRemovedFromCurrentWord:character];
}

#pragma mark DRPCurrentWordViewDelegate

- (void)currentWordViewTapped
{
    [_match submitTurnForPositions:_boardViewController.currentPositions];
    // register for nsnotification to find out when GC receives move
}

- (void)currentWordViewSwiped
{
}

- (void)gameCenterReceivedTurn:(NSNotification *)notification
{
    [_boardViewController dropPlayedWord:notification.userInfo[@"playedWord"]];
}

@end
