//
//  DRPBoardViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPPageMatchViewController.h"

@class DRPTileView, DRPBoard;

@protocol DRPTileDelegate

- (void)tileWasHighlighted:(DRPTileView *)tile;
- (void)tileWasSelected:(DRPTileView *)tile;
- (void)tileWasDeselected:(DRPTileView *)character;

@end

@interface DRPBoardViewController : UIViewController <DRPTileDelegate>

@property id<DRPBoardViewControllerDelegate> delegate;

- (void)loadBoard:(DRPBoard *)board;

@end
