//
//  DRPCueView.m
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCueView.h"

@interface DRPCueView ()

@property UILabel *topCue, *bottomCue;

@end

@implementation DRPCueView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#pragma mark Cycling

- (void)cycleInCue:(NSString *)cue inPosition:(DRPPageDirection)direction
{
    
}

- (void)cycleOutCueInPosition:(DRPPageDirection)direction
{
    
}

@end
