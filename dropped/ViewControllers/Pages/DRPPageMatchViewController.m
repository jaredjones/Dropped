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
#import "DRPMatchHeaderView.h"

@interface DRPPageMatchViewController ()

@property DRPMatchHeaderView *headerView;
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
    
    [self loadHeaderView];
    [self loadCurrentWordView];
    [self loadBoardViewController];
}

- (void)loadScrollView
{
    self.scrollView = [[DRPGreedyScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 0.5);
    [self.view addSubview:self.scrollView];
}

- (void)loadHeaderView
{
    _headerView = [[DRPMatchHeaderView alloc] init];
    _headerView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_headerView];
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
    
    self.scrollView.canCancelContentTouches = YES;
}

- (void)loadCurrentWordView
{
    _currentWordView = [[DRPCurrentWordView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    _currentWordView.delegate = self;
    
    // positions approximate for now
    CGPoint center = self.scrollView.center;
    center.y += 9 + 160 + 25 + 3 + 14;
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
