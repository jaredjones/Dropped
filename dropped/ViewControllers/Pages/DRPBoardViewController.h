//
//  DRPBoardViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPTileView.h"

@class DRPTileView, DRPBoard, DRPPlayedWord, DRPCharacter;

@protocol DRPBoardViewControllerDelegate

// These methods are called on the delegate when the user
// taps around on the board tiles

- (void)characterWasAddedToCurrentWord:(DRPCharacter *)character;
- (void)characterWasRemovedFromCurrentWord:(DRPCharacter *)character;

- (void)characterWasHighlighted:(DRPCharacter *)character;
- (void)characterWasDehighlighted:(DRPCharacter *)character;

@end

@interface DRPBoardViewController : UIViewController <DRPTileViewDelegate, UICollisionBehaviorDelegate>

@property id<DRPBoardViewControllerDelegate> delegate;

// This is not the actual DRPPlayedWord that'll get passed
// to the DRPMatch to submit a word. Instead, it acts just
// as a container for the state of the board tiles/multipliers
@property (readonly) DRPPlayedWord *currentPlayedWord;

// Simply enables/disables all of the tiles on the board.
// Handy for disabling during dropping words
@property (nonatomic) BOOL boardEnabled;

- (void)loadBoard:(DRPBoard *)board atTurn:(NSInteger)turn;
- (void)dropPlayedWord:(DRPPlayedWord *)playedWord fromTurn:(NSInteger)turn withCompletion:(void(^)())completion;

- (void)deselectCurrentWord;

@end
