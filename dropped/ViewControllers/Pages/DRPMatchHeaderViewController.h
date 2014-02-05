//
//  DRPMatchHeaderViewController.h
//  dropped
//
//  Created by Brad Zeis on 1/3/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPMatchPlayerView.h"

@protocol DRPHeaderViewControllerDelegate <NSObject>

- (void)headerViewTappedPlayerTileForTurn:(NSInteger)turn;

@end

@interface DRPMatchHeaderViewController : UIViewController <DRPMatchPlayerViewDelegate>

@property id<DRPHeaderViewControllerDelegate> delegate;

- (void)observePlayers:(NSArray *)players;
- (void)setCurrentPlayerTurn:(NSInteger)turn multiplierColors:(NSArray *)colors;
- (void)setScores:(NSDictionary *)scores;

@end
