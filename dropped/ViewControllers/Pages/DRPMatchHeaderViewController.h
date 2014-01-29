//
//  DRPMatchHeaderViewController.h
//  dropped
//
//  Created by Brad Zeis on 1/3/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRPMatchHeaderViewController : UIViewController

- (void)observePlayers:(NSArray *)players;
- (void)setCurrentPlayerTurn:(NSInteger)turn multiplierColors:(NSArray *)colors;

@end
