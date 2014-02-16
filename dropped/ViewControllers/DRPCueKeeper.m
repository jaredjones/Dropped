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

@interface DRPCueKeeper ()

@property UIView *view;
@property UILabel *topCue, *bottomCue;
@property BOOL topEmphasized, bottomEmphasized;

// The DRPCueIndicators are the 6 tiles at the top and bottom
// of the screen that emphasize that something will happen
// when the user releases a drag.
@property DRPCueIndicatorView *topIndicatorView, *bottomIndicatorView;

@end

#pragma mark - DRPCueKeeper

@implementation DRPCueKeeper

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.view = view;
        
        // Load CueIndicators
        self.topIndicatorView = [[DRPCueIndicatorView alloc] initWithPosition:DRPPageDirectionUp];
        [self.view addSubview:self.topIndicatorView];
        
        self.bottomIndicatorView = [[DRPCueIndicatorView alloc] initWithPosition:DRPPageDirectionDown];
        [self.view addSubview:self.bottomIndicatorView];
        
        [self repositionCueIndicators];
    }
    return self;
}

- (UILabel *)cueForPosition:(DRPPageDirection)position
{
    if (!(position == DRPPageDirectionUp || position == DRPPageDirectionDown)) return nil;
    
    return position == DRPPageDirectionUp ? self.topCue : self.bottomCue;
}

- (void)setCue:(UILabel *)cue forPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) self.topCue = cue;
    else self.bottomCue = cue;
}

- (DRPCueIndicatorView *)indicatorForPosition:(DRPPageDirection)position
{
    if (!(position == DRPPageDirectionUp || position == DRPPageDirectionDown)) return nil;
    
    return position == DRPPageDirectionUp ? self.topIndicatorView : self.bottomIndicatorView;
}

// Repositions the cueIndicators after a device orientation change
- (void)repositionCueIndicators
{
    self.topIndicatorView.center = ({
        CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), -self.topIndicatorView.frame.size.height / 2);
        center;
    });
    
    self.bottomIndicatorView.center = ({
        CGPointMake(CGRectGetMidX(self.view.bounds), self.view.bounds.size.height + self.bottomIndicatorView.frame.size.height / 2);
    });
}

#pragma mark Cycling

// Presents a new cue and animates a new cue out if necessary
- (void)cycleInCue:(NSString *)cueText inPosition:(DRPPageDirection)position
{
    // Return early if the position is invalid or the cue text already matches
    if (!(position == DRPPageDirectionUp || position == DRPPageDirectionDown)) return;
    if ([[self cueForPosition:position].text isEqualToString:cueText]) return;
    
    // Out with the old...
    [self cycleOutCueInPosition:position];
    
    // In with the new
    UILabel *cue;
    if (cueText) {
        CGSize size = [cueText sizeWithAttributes:@{NSFontAttributeName : [FRBSwatchist fontForKey:@"page.cueEmphasizedFont"]}];
        cue = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        cue.text = cueText;
        cue.font = [FRBSwatchist fontForKey:@"page.cueFont"];
        [self.view addSubview:cue];
        
        [self setCue:cue forPosition:position];
        [self animateCue:cue inForPosition:position];
        
    } else {
        // If text is nil, don't show a cue _and_ animate out indicators
        [self setCue:nil forPosition:position];
        [self cycleOutIndicatorForPosition:position];
    }
}

- (void)cycleOutCueInPosition:(DRPPageDirection)position
{
    UILabel *cue = [self cueForPosition:position];
    if (cue) {
        [self animateCue:cue outForPosition:position];
    }
}

#pragma mark Cue Animations

- (void)animateCue:(UILabel *)cue inForPosition:(DRPPageDirection)position
{
    if (!cue) return;
    
    cue.center = [self preCenterForPosition:position];
    cue.alpha = 0;
    [UIView animateWithDuration:[FRBSwatchist floatForKey:@"page.cueAnimationDuration"]
                          delay:0
         usingSpringWithDamping:[FRBSwatchist floatForKey:@"page.cueAnimationDamping"]
          initialSpringVelocity:0
                        options:0
                     animations:^{
                         cue.center = ({
                             CGPoint center = [self postCenterForPosition:position];
                             center;
                         });
                         cue.alpha = 1;
                     }
                     completion:nil];
}

- (void)animateCue:(UILabel *)cue outForPosition:(DRPPageDirection)position
{
    if (!cue) return;
    
    [UIView animateWithDuration:[FRBSwatchist floatForKey:@"page.cueAnimationDuration"]
                          delay:0
         usingSpringWithDamping:[FRBSwatchist floatForKey:@"page.cueAnimationDamping"]
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         cue.center = [self preCenterForPosition:position];
                         cue.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [cue removeFromSuperview];
                         
                         // Make sure to clear out the old cue
                         if ([self cueForPosition:position] == cue) {
                             [self setCue:nil forPosition:position];
                         }
                     }];
}

// Start position for cue animations
- (CGPoint)preCenterForPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        return CGPointMake(self.view.bounds.size.width / 2, -[FRBSwatchist floatForKey:@"page.cueOffsetTop"]);
    }
    return CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height + [FRBSwatchist floatForKey:@"page.cueOffsetBottom"]);
}

// End positions for cue animations
- (CGPoint)postCenterForPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        return CGPointMake(self.view.bounds.size.width / 2, [FRBSwatchist floatForKey:@"page.cueOffsetTop"]);
    }
    return CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - [FRBSwatchist floatForKey:@"page.cueOffsetBottom"]);
}

#pragma mark Emphasis

// Emphasizes the cue _and_ animates in the indicator
- (void)emphasizeCueInPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        if (self.topEmphasized) return;
        self.topEmphasized = YES;
        
    } else {
        if (self.bottomEmphasized) return;
        self.bottomEmphasized = YES;
    }
    
    [self cueForPosition:position].font = [FRBSwatchist fontForKey:@"page.cueEmphasizedFont"];
    
    if ([self cueForPosition:position]) {
        [[self indicatorForPosition:position] animateIn];
    }
}

- (void)deemphasizeCueInPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        if (!self.topEmphasized) return;
        self.topEmphasized = NO;
        
    } else {
        if (!self.bottomEmphasized) return;
        self.bottomEmphasized = NO;
    }
    
    [self cueForPosition:position].font = [FRBSwatchist fontForKey:@"page.cueFont"];
    [self cycleOutIndicatorForPosition:position];
}

- (void)cycleOutIndicatorForPosition:(DRPPageDirection)position
{
    [[self indicatorForPosition:position] animateOut];
}

#pragma mark Rotation

- (void)hideIndicators
{
    [self indicatorForPosition:DRPPageDirectionUp].hidden = YES;
    [self indicatorForPosition:DRPPageDirectionDown].hidden = YES;
}

- (void)showIndicators
{
    [self repositionCueIndicators];
    [self indicatorForPosition:DRPPageDirectionUp].hidden = NO;
    [self indicatorForPosition:DRPPageDirectionDown].hidden = NO;
}

#pragma mark Superview

// TODO: see, this is why quasi-ViewControllers are super bad
- (void)sendToBack
{
//    [self.view bringSubviewToFront:self.topCue];
//    [self.view bringSubviewToFront:self.bottomCue];
//    [self.view bringSubviewToFront:self.topIndicatorView];
//    [self.view bringSubviewToFront:self.bottomIndicatorView];
    
    [self.view sendSubviewToBack:self.topCue];
    [self.view sendSubviewToBack:self.bottomCue];
    [self.view sendSubviewToBack:self.topIndicatorView];
    [self.view sendSubviewToBack:self.bottomIndicatorView];
}

@end
