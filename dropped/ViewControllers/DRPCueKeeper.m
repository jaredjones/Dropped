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
@property DRPCueIndicatorView *topIndicatorView, *bottomIndicatorView;

@end

#pragma mark - DRPCueKeeper

@implementation DRPCueKeeper

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        _view = view;
        
        // Load CueIndicators
        _topIndicatorView = [[DRPCueIndicatorView alloc] initWithPosition:DRPPageDirectionUp];
        [_view addSubview:_topIndicatorView];
        
        _bottomIndicatorView = [[DRPCueIndicatorView alloc] initWithPosition:DRPPageDirectionDown];
        [_view addSubview:_bottomIndicatorView];
        
        [self repositionCueIndicators];
    }
    return self;
}

- (UILabel *)cueForPosition:(DRPPageDirection)position
{
    if (!(position == DRPPageDirectionUp || position == DRPPageDirectionDown)) return nil;
    
    return position == DRPPageDirectionUp ? _topCue : _bottomCue;
}

- (void)setCue:(UILabel *)cue forPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) _topCue = cue;
    else _bottomCue = cue;
}

- (DRPCueIndicatorView *)indicatorForPosition:(DRPPageDirection)position
{
    if (!(position == DRPPageDirectionUp || position == DRPPageDirectionDown)) return nil;
    
    return position == DRPPageDirectionUp ? _topIndicatorView : _bottomIndicatorView;
}

- (void)repositionCueIndicators
{
    _topIndicatorView.center = ({
        CGPoint center = CGPointMake(CGRectGetMidX(_view.bounds), -_topIndicatorView.frame.size.height / 2);
        center;
    });
    
    _bottomIndicatorView.center = ({
        CGPointMake(CGRectGetMidX(_view.bounds), _view.bounds.size.height + _bottomIndicatorView.frame.size.height / 2);
    });
}

#pragma mark Cycling

- (void)cycleInCue:(NSString *)cueText inPosition:(DRPPageDirection)position
{
    if (!(position == DRPPageDirectionUp || position == DRPPageDirectionDown)) return;
    if ([[self cueForPosition:position].text isEqualToString:cueText]) return;
    
    [self cycleOutCueInPosition:position];
    UILabel *cue;
    if (cueText) {
        CGSize size = [cueText sizeWithAttributes:@{NSFontAttributeName : [FRBSwatchist fontForKey:@"page.cueEmphasizedFont"]}];
        cue = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        cue.text = cueText;
        cue.font = [FRBSwatchist fontForKey:@"page.cueFont"];
        [_view addSubview:cue];
        
        [self setCue:cue forPosition:position];
        [self animateCue:cue inForPosition:position];
    } else {
        [self setCue:nil forPosition:position];
    }
}

- (void)cycleOutCueInPosition:(DRPPageDirection)position
{
    UILabel *cue = [self cueForPosition:position];
    if (cue) {
        [self animateCue:cue outForPosition:position];
    }
}

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
                         cue.center = [self preCenterForPosition:position fromCenter:cue.center];
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

- (CGPoint)preCenterForPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        return CGPointMake(_view.bounds.size.width / 2, -[FRBSwatchist floatForKey:@"page.cueOffsetTop"]);
    }
    return CGPointMake(_view.bounds.size.width / 2, _view.bounds.size.height + [FRBSwatchist floatForKey:@"page.cueOffsetBottom"]);
}

- (CGPoint)preCenterForPosition:(DRPPageDirection)position fromCenter:(CGPoint)currentCenter
{
    // Calculated for animations out.
    // This is a special case that keeps the old cues heading in the right direction during an orientation change
    if (position == DRPPageDirectionUp) {
        return CGPointMake(currentCenter.x, currentCenter.y - 2 * [FRBSwatchist floatForKey:@"page.cueOffsetTop"]);
    }
    return CGPointMake(currentCenter.x, currentCenter.y + 2 * [FRBSwatchist floatForKey:@"page.cueOffsetBottom"]);
}

- (CGPoint)postCenterForPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        return CGPointMake(_view.bounds.size.width / 2, [FRBSwatchist floatForKey:@"page.cueOffsetTop"]);
    }
    return CGPointMake(_view.bounds.size.width / 2, _view.bounds.size.height - [FRBSwatchist floatForKey:@"page.cueOffsetBottom"]);
}

#pragma mark Emphasis

- (void)emphasizeCueInPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        if (_topEmphasized) return;
        _topEmphasized = YES;
    } else {
        if (_bottomEmphasized) return;
        _bottomEmphasized = YES;
    }
    [self cueForPosition:position].font = [FRBSwatchist fontForKey:@"page.cueEmphasizedFont"];
    if ([self cueForPosition:position]) {
        [[self indicatorForPosition:position] animateIn];
    }
}

- (void)deemphasizeCueInPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        if (!_topEmphasized) return;
        _topEmphasized = NO;
    } else {
        if (!_bottomEmphasized) return;
        _bottomEmphasized = NO;
    }
    [self cueForPosition:position].font = [FRBSwatchist fontForKey:@"page.cueFont"];
    [[self indicatorForPosition:position] animateOut];
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

- (void)bringToFront
{
    [_view bringSubviewToFront:_topCue];
    [_view bringSubviewToFront:_bottomCue];
    [_view bringSubviewToFront:_topIndicatorView];
    [_view bringSubviewToFront:_bottomIndicatorView];
}

@end
