//
//  DRPCueKeeper.m
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCueKeeper.h"

@interface DRPCueKeeper ()

@property UILabel *topCue, *bottomCue;

@end

@implementation DRPCueKeeper

#pragma mark Cycling

- (void)cycleInCue:(NSString *)cue inPosition:(DRPPageDirection)position
{
    
}

- (void)cycleOutCueInPosition:(DRPPageDirection)position
{
    
}

#pragma mark Styling

- (void)emphasizeCueInPosition:(DRPPageDirection)position
{
    
}

- (void)deemphasizeCueInPosition:(DRPPageDirection)position
{
    
}

#pragma mark Superview

- (void)bringToFront
{
    [_view bringSubviewToFront:_topCue];
    [_view bringSubviewToFront:_bottomCue];
}

@end
