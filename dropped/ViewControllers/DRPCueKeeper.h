//
//  DRPCueKeeper.h
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPPageViewController.h"

@interface DRPCueKeeper : NSObject

- (instancetype)initWithView:(UIView *)view;

- (void)cycleInCue:(NSString *)cueText inPosition:(DRPPageDirection)position;
- (void)cycleOutCueInPosition:(DRPPageDirection)position;

- (void)emphasizeCueInPosition:(DRPPageDirection)position;
- (void)deemphasizeCueInPosition:(DRPPageDirection)position;

- (void)bringToFront;

@end
