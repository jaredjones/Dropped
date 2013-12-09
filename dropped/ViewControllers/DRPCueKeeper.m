//
//  DRPCueKeeper.m
//  dropped
//
//  Created by Brad Zeis on 12/8/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCueKeeper.h"
#import "FRBSwatchist.h"

@interface DRPCueKeeper ()

@property UILabel *topCue, *bottomCue;

@end

#pragma mark - DRPCueKeeper

@implementation DRPCueKeeper

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

#pragma mark Cycling

- (void)cycleInCue:(NSString *)cueText inPosition:(DRPPageDirection)position
{
    if (!(position == DRPPageDirectionUp || position == DRPPageDirectionDown)) return;
    if ([[self cueForPosition:position].text isEqualToString:cueText]) return;
    
    UILabel *cue;
    if (cueText) {
        UIFont *font = [FRBSwatchist fontForKey:@"page.cueFont"];
        CGSize size = [cueText sizeWithAttributes:@{NSFontAttributeName : font}];
        cue = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        cue.text = cueText;
        cue.font = font;
        [_view addSubview:cue];
        
        [self animateCue:cue inForPosition:position];
    }
    
    [self setCue:cue forPosition:position];
}

- (void)cycleOutCueInPosition:(DRPPageDirection)position
{
    UILabel *cue = [self cueForPosition:position];
    if (cue) {
        [self animateCue:cue outForPosition:position];
    }
}

- (void)animateCue:(UILabel *)cue outForPosition:(DRPPageDirection)position
{
    [UIView animateWithDuration:[FRBSwatchist floatForKey:@"page.cueAnimationDuration"]
                          delay:0
         usingSpringWithDamping:[FRBSwatchist floatForKey:@"page.cueAnimationDamping"]
          initialSpringVelocity:0
                        options:0
                     animations:^{ cue.center = [self preCenterForPosition:position]; }
                     completion:^(BOOL finished) { [cue removeFromSuperview]; }];
}

- (void)animateCue:(UILabel *)cue inForPosition:(DRPPageDirection)position
{
    cue.center = [self preCenterForPosition:position];
    [UIView animateWithDuration:[FRBSwatchist floatForKey:@"page.cueAnimationDuration"]
                          delay:0
         usingSpringWithDamping:[FRBSwatchist floatForKey:@"page.cueAnimationDamping"]
          initialSpringVelocity:0
                        options:0
                     animations:^{ cue.center = [self postCenterForPosition:position]; }
                     completion:nil];
}

- (CGPoint)preCenterForPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        return CGPointMake(_view.frame.size.width / 2, -[FRBSwatchist floatForKey:@"page.cueOffset"]);
    }
    return CGPointMake(_view.frame.size.width / 2, _view.frame.size.height + [FRBSwatchist floatForKey:@"page.cueOffset"]);
}

- (CGPoint)postCenterForPosition:(DRPPageDirection)position
{
    if (position == DRPPageDirectionUp) {
        return CGPointMake(_view.frame.size.width / 2, [FRBSwatchist floatForKey:@"page.cueOffset"]);
    }
    return CGPointMake(_view.frame.size.width / 2, _view.frame.size.height - [FRBSwatchist floatForKey:@"page.cueOffset"]);
}

#pragma mark Styling

- (void)emphasizeCueInPosition:(DRPPageDirection)position
{
    [self cueForPosition:position].font = [FRBSwatchist fontForKey:@"page.cueEmphasizedFont"];
}

- (void)deemphasizeCueInPosition:(DRPPageDirection)position
{
    [self cueForPosition:position].font = [FRBSwatchist fontForKey:@"page.cueFont"];
}

#pragma mark Superview

- (void)bringToFront
{
    [_view bringSubviewToFront:_topCue];
    [_view bringSubviewToFront:_bottomCue];
}

@end
