//
//  DRPPageMatchViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageViewController.h"
#import "DRPMatchCurrentWordViewController.h"

@protocol DRPBoardViewControllerDelegate

- (void)characterWasAddedToCurrentWord:(DRPCharacter *)character;
- (void)characterWasRemovedFromCurrentWord:(DRPCharacter *)character;

- (void)characterWasHighlighted:(DRPCharacter *)character;
- (void)characterWasDehighlighted:(DRPCharacter *)character;

@end

@interface DRPPageMatchViewController : DRPPageViewController <DRPBoardViewControllerDelegate, DRPCurrentWordViewControllerDelegate>

@end
