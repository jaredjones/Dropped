//
//  DRPCueKeeper.m
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCueKeeper.h"
#import "DRPSelflessView.h"
#import "DRPCueIndicatorView.h"
#import "FRBSwatchist.h"

@interface DRPCueKeeper ()

// The DRPCueIndicators are the 6 tiles at the top and bottom
// of the screen that emphasize that something will happen
// when the user releases a drag.
@property NSDictionary *indicators;

@property (nonatomic, copy) CGFloat (^easing)(CGFloat);

@end

#pragma mark - DRPCueKeeper

@implementation DRPCueKeeper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.easing = ^(CGFloat t) {
            t = t - 1;
            return 1 - t * t;
        };
    }
    return self;
}

- (void)loadView
{
    self.view = [[DRPSelflessView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    // Initialize Cues/Indicators
    self.indicators = @{@(DRPPageDirectionUp) : [[DRPCueIndicatorView alloc] initWithPosition:DRPPageDirectionUp],
                        @(DRPPageDirectionDown) : [[DRPCueIndicatorView alloc] initWithPosition:DRPPageDirectionDown]};
    
    for (UIView *view in self.indicators.allValues) {
        [self.view addSubview:view];
    }
}

- (void)viewDidLoad {
}

- (void)viewWillLayoutSubviews
{
    // TODO: reposition cues and indicators
    [self recenterIndicatorForPosition:DRPPageDirectionUp];
    [self recenterIndicatorForPosition:DRPPageDirectionDown];
}

#pragma mark Indicators

- (DRPCueIndicatorView *)indicatorForPosition:(DRPPageDirection)position
{
    return self.indicators[@(position)];
}

- (CGPoint)indicatorCenterForPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        return CGPointMake(CGRectGetMidX(self.view.bounds),
                           -[FRBSwatchist floatForKey:@"board.tileLength"] / 2);
    } else if (position == DRPPageDirectionDown) {
        return CGPointMake(CGRectGetMidX(self.view.bounds),
                           CGRectGetMaxY(self.view.bounds) + [FRBSwatchist floatForKey:@"board.tileLength"] / 2);
    }
    return CGPointZero;
}

- (void)recenterIndicatorForPosition:(DRPPageDirection)position
{
    [self indicatorForPosition:position].center = [self indicatorCenterForPosition:position];
}

#pragma mark Cue Access

- (void)setCueText:(NSString *)cueText forPosition:(DRPPageDirection)position
{
}

- (void)updateWithPage:(DRPPageViewController *)page
{
    [self updateIndicatorsWithPage:page];
    // TODO: set cue position relative to indicators
}

- (void)updateIndicatorsWithPage:(DRPPageViewController *)page
{
    // When the user is dragging the page's scrollView, set the
    // indicators appropriately
    CGFloat contentOffset = page.scrollView.contentOffset.y;
    CGFloat percent = 0;
    DRPPageDirection activePosition = DRPPageDirectionNil;
    
    if (contentOffset <= 0) {
        percent = MIN(1, -contentOffset / [FRBSwatchist floatForKey:@"page.indicatorMaxDrag"]);
        activePosition = DRPPageDirectionUp;
        
    } else if (contentOffset >= page.scrollView.contentSize.height - page.scrollView.bounds.size.height) {
        percent = MIN(1, contentOffset / [FRBSwatchist floatForKey:@"page.indicatorMaxDrag"]);
        activePosition = DRPPageDirectionDown;
    }
    
    if ((page.scrollView.dragging || page.scrollView.decelerating) && activePosition != DRPPageDirectionNil) {
        [self indicatorForPosition:activePosition].center = ({
            CGPoint center = [self indicatorCenterForPosition:activePosition];
            center.y += 25 * (activePosition == DRPPageDirectionUp ? 1 : -1) * self.easing(percent);
            center;
        });
        
        // Make sure the other indicator is fully offscreen
        [self recenterIndicatorForPosition:!activePosition];
        
    } else {
        [self recenterIndicatorForPosition:DRPPageDirectionUp];
        [self recenterIndicatorForPosition:DRPPageDirectionDown];
    }
}

#pragma mark Rotation

// TODO: Now that DRPCueKeeper is a UIViewController, it can do this itself
// TODO: hide cues instantaneously

@end
