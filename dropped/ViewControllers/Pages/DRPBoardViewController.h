//
//  DRPBoardViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DRPPageMatchViewController.h"
#import "DRPTileView.h"

@class DRPTileView, DRPBoard, DRPPlayedWord, DRPCharacter;

@protocol DRPBoardViewControllerDelegate

- (void)characterWasAddedToCurrentWord:(DRPCharacter *)character;
- (void)characterWasRemovedFromCurrentWord:(DRPCharacter *)character;

- (void)characterWasHighlighted:(DRPCharacter *)character;
- (void)characterWasDehighlighted:(DRPCharacter *)character;

@end

@interface DRPBoardViewController : UIViewController <DRPTileViewDelegate, UICollisionBehaviorDelegate>

@property id<DRPBoardViewControllerDelegate> delegate;

@property (readonly) DRPPlayedWord *currentPlayedWord;
@property (nonatomic) BOOL boardEnabled;

- (void)loadBoard:(DRPBoard *)board atTurn:(NSInteger)turn;
- (void)dropPlayedWord:(DRPPlayedWord *)playedWord fromTurn:(NSInteger)turn withCompletion:(void(^)())completion;

- (void)deselectCurrentWord;

@end
