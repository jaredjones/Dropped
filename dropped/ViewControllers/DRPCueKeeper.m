//
//  DRPCueKeeper.m
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCueKeeper.h"
#import "DRPCueIndicatorView.h"
#import "FRBSwatchist.h"
#import "DRPSelflessView.h"

@interface DRPCueKeeper ()

// The DRPCueIndicators are the 6 tiles at the top and bottom
// of the screen that emphasize that something will happen
// when the user releases a drag.
@property DRPCueIndicatorView *topIndicatorView, *bottomIndicatorView;

@end

#pragma mark - DRPCueKeeper

@implementation DRPCueKeeper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    self.view = [[DRPSelflessView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
}

- (void)viewDidLoad {
}

- (void)viewWillLayoutSubviews
{
    // TODO: reposition cues and indicators
}

#pragma mark Cue Access

- (void)setCueText:(NSString *)cueText forPosition:(DRPPageDirection)position
{
    
}

#pragma mark Rotation

// TODO: UIViewControllers can do all of this themselves
// TODO: hide cues instantaneously

@end
