//
//  DRPBoardViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPageMatchViewController.h"

@class DRPTileView, DRPBoard, DRPPlayedWord;

@protocol DRPTileDelegate

- (void)tileWasHighlighted:(DRPTileView *)tile;
- (void)tileWasDehighlighted:(DRPTileView *)tile;
- (void)tileWasSelected:(DRPTileView *)tile;
- (void)tileWasDeselected:(DRPTileView *)tile;

@end

@interface DRPBoardViewController : UIViewController <DRPTileDelegate, UICollisionBehaviorDelegate>

@property id<DRPBoardViewControllerDelegate> delegate;

@property (readonly) NSString *currentWord;
@property (readonly) NSArray *currentPositions;

- (void)loadBoard:(DRPBoard *)board;
- (void)dropPlayedWord:(DRPPlayedWord *)playedWord;

@end
