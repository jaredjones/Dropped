//
//  DRPPageMatchViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageViewController.h"

@class DRPCharacter;

@protocol DRPBoardViewControllerDelegate

- (void)characterAddedToCurrentWord:(DRPCharacter *)character;
- (void)characterRemovedFromCurrentWord:(DRPCharacter *)character;

@end

@protocol DRPCurrentWordViewDelegate

- (void)currentWordViewTapped;
- (void)currentWordViewSwiped;

@end

@interface DRPPageMatchViewController : DRPPageViewController <DRPBoardViewControllerDelegate, DRPCurrentWordViewDelegate>

@end
