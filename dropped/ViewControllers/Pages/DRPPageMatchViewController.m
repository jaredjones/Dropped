//
//  DRPPageMatchViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageMatchViewController.h"
#import "DRPBoardViewController.h"
#import "DRPMatch.h"
#import "DRPPlayedWord.h"

@interface DRPPageMatchViewController ()

@property DRPBoardViewController *boardViewController;
@property DRPMatch *match;

@end

@implementation DRPPageMatchViewController

- (id)init
{
    self = [super initWithPageID:DRPPageMatch];
    if (self) {
        self.bottomCue = @"Back";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadBoardViewController];
}

- (void)loadBoardViewController
{
    _boardViewController = [[DRPBoardViewController alloc] initWithNibName:nil bundle:nil];
    _boardViewController.delegate = self;
    
    [_boardViewController willMoveToParentViewController:self];
    [self addChildViewController:_boardViewController];
    
    _boardViewController.view.center = self.view.center;
    [self.view addSubview:_boardViewController.view];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    // extract match, load it up
    _match = [[DRPMatch alloc] initWithGKMatch:nil];
    [_boardViewController loadBoard:_match.board];
}

#pragma mark DRPBoardViewControllerDelegate

- (void)characterAddedToCurrentWord:(DRPCharacter *)character
{
    // change bottom cue
}

- (void)characterRemovedFromCurrentWord:(DRPCharacter *)character
{
    // change bottom cue
    // if no characters left, change DRPPlayedWordView message
}

#pragma mark DRPPlayedWordViewDelegate

- (void)playedWordViewTapped
{
    [_match submitTurnForPositions:_boardViewController.currentPositions];
    // register for nsnotification to find out when GC receives move
}

- (void)playedWordViewSwiped
{
}

@end