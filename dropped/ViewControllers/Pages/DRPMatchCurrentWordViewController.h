//
//  DRPMatchCurrentWordViewController.h
//  dropped
//
//  Created by Brad Zeis on 1/30/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPosition.h"
#import "DRPCurrentWordView.h"

// Handles the state and animations of the words at the bottom of the match page.

// Operates on the idea of a "container", which is simply a UIView subclass. There
// are two types:
//      - TurnsLeft (which is just a UILabel)
//      - CurrentWord (DRPCurrentWordView, much more complex)
//
// There is only one currentContainer at a time. It is set internally by calling
// the setCurrentContainerType setters, which handles all of the animations and
// state change.

@class DRPCharacter;

typedef NS_ENUM(NSInteger, DRPContainerType) {
    DRPContainerTypeTurnsLeft,
    DRPContainerTypeCurrentWord,
    DRPContainerTypeNil
};

// The DRPPageMatchViewController needs to know when the user interacts with
// the currentWord container (to submit moves/clear the board and such)
@protocol DRPCurrentWordViewControllerDelegate

- (void)currentWordWasTapped;
- (void)currentWordWasSwiped;

@end

@interface DRPMatchCurrentWordViewController : UIViewController <DRPCurrentWordViewDelegate>

@property id<DRPCurrentWordViewControllerDelegate> delegate;

@property (nonatomic) BOOL gesturesEnabled;

- (void)layoutWithFrame:(CGRect)frame;

// These methods are called by the DRPPageMatchViewController in response to user
// interaction with the board
- (void)characterWasHighlighted:(DRPCharacter *)character fromDirection:(DRPDirection)direction;
- (void)characterWasDehighlighted:(DRPCharacter *)character;
- (void)characterWasRemoved:(DRPCharacter *)character fromDirection:(DRPDirection)direction;

// Convenience methods for the DRPPageMatchViewController
- (void)setCharacters:(NSArray *)characters fromDirection:(DRPDirection)direction;
- (void)setTurnsLeft:(NSInteger)turnsLeft isLocalTurn:(BOOL)isLocalTurn fromDirection:(DRPDirection)direction;

@end
