//
//  DRPCurrentWordView.h
//  dropped
//
//  Created by Brad Zeis on 12/25/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRPCharacter;

@interface DRPCurrentWordView : UIView

- (void)characterWasHighlighted:(DRPCharacter *)character;
- (void)characterWasDehighlighted:(DRPCharacter *)character;
- (void)characterWasRemoved:(DRPCharacter *)character;

- (NSInteger)characterCount;

- (void)repositionTiles;

@end
