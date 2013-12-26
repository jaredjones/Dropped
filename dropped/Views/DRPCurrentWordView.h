//
//  DRPCurrentWordView.h
//  dropped
//
//  Created by Brad Zeis on 12/25/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPageMatchViewController.h"

@interface DRPCurrentWordView : UIView

@property id<DRPCurrentWordViewDelegate> delegate;

- (void)characterWasHighlighted:(DRPCharacter *)character;
- (void)characterWasDehighlighted:(DRPCharacter *)character;
- (void)characterRemovedFromCurrentWord:(DRPCharacter *)character;

- (void)removeAllCharactersFromCurrentWord;

@end
