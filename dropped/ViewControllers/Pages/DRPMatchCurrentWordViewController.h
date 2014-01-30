//
//  DRPMatchCurrentWordViewController.h
//  dropped
//
//  Created by Brad Zeis on 1/30/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPosition.h"

@class DRPCharacter;

typedef NS_ENUM(NSInteger, DRPContainerType) {
    DRPContainerTypeNil,
    DRPContainerTypeTurnsLeft,
    DRPContainerTypeCurrentWord
};

@protocol DRPCurrentWordViewControllerDelegate

- (void)currentWordWasTapped;
- (void)currentWordWasSwiped;

@end

@interface DRPMatchCurrentWordViewController : UIViewController

- (void)layoutWithFrame:(CGRect)frame;

- (void)characterWasHighlighted:(DRPCharacter *)character fromDirection:(DRPDirection)direction;
- (void)characterWasDehighlighted:(DRPCharacter *)character;
- (void)characterWasRemoved:(DRPCharacter *)character fromDirection:(DRPDirection)direction;

- (void)setCharacters:(NSArray *)characters fromDirection:(DRPDirection)direction;
- (void)setTurnsLeft:(NSInteger)turnsLeft isLocalTurn:(BOOL)isLocalTurn fromDirection:(DRPDirection)direction;

@end
