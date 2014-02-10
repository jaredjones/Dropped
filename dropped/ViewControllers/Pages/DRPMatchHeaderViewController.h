//
//  DRPMatchHeaderViewController.h
//  dropped
//
//  Created by Brad Zeis on 1/3/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPMatchPlayerView.h"

// Essentially just a container for the player tiles/scores/aliases
// in the top corners of the match screen.
//
// Also provides a white mask to block new tiles that drop down from
// above the board.

@protocol DRPHeaderViewControllerDelegate <NSObject>

- (void)headerViewTappedPlayerTileForTurn:(NSInteger)turn;

@end

@interface DRPMatchHeaderViewController : UIViewController <DRPMatchPlayerViewDelegate>

@property id<DRPHeaderViewControllerDelegate> delegate;

// The playerViews use Key Value Observing to update the player
// tile when the player alias changes
- (void)observePlayers:(NSArray *)players;

// These are called by DRPPageMatchViewController to update _both_
// of the playerViews with the desired state
- (void)setCurrentPlayerTurn:(NSInteger)turn multiplierColors:(NSArray *)colors;
- (void)setScores:(NSDictionary *)scores;

@end
