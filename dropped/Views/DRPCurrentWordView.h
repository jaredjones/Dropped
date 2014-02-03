//
//  DRPCurrentWordView.h
//  dropped
//
//  Created by Brad Zeis on 12/25/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRPCharacter;

@protocol DRPCurrentWordViewDelegate

- (void)currentWordWasTapped;
- (void)currentWordWasSwipedWithVelocity:(CGFloat)velocity;
- (void)currentWordSwipeFailedWithVelocity:(CGFloat)velocity;

@end

@interface DRPCurrentWordView : UIView

@property id<DRPCurrentWordViewDelegate> delegate;

- (void)characterWasHighlighted:(DRPCharacter *)character;
- (void)characterWasDehighlighted:(DRPCharacter *)character;
- (void)characterWasRemoved:(DRPCharacter *)character;

- (void)removeAllCharacters;

- (NSInteger)characterCount;

- (void)repositionTiles;

@end
