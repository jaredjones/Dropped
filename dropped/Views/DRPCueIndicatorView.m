//
//  DRPCueIndicatorView.m
//  dropped
//
//  Created by Brad Zeis on 12/10/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPCueIndicatorView.h"
#import "DRPTileView.h"
#import "FRBSwatchist.h"

@interface DRPCueIndicatorView ()

@property NSMutableArray *tileViews;

@end

@implementation DRPCueIndicatorView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 50)];
    if (self) {
        
        _tileViews = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 6; i++) {
            DRPTileView *tileView = [[DRPTileView alloc] initWithCharacter:nil];
            tileView.center = CGPointMake(27.5 + 53 * i, 25);
            tileView.strokeOpacity = 1;
            tileView.userInteractionEnabled = NO;
            [self addSubview:tileView];
            [_tileViews addObject:tileView];
        }
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

#pragma mark Animations

- (void)animateIn
{
    CGFloat offset = _position == DRPPageDirectionUp ? 6 : -6;
    for (NSInteger i = 0; i < 6; i++) {
        DRPTileView *tileView = _tileViews[i];
        CGPoint center = CGPointMake(27.5 + 53 * i, 25 + offset);
        
        [UIView animateWithDuration:[FRBSwatchist floatForKey:@"page.cueIndicatorAnimationDuration"]
                              delay:[FRBSwatchist floatForKey:@"page.cueIndicatorAnimationDelay"] * i
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ tileView.center = center; }
                         completion:nil];
    }
}

- (void)animateOut
{
    for (NSInteger i = 0; i < 6; i++) {
        DRPTileView *tileView = _tileViews[i];
        CGPoint center = CGPointMake(27.5 + 53 * i, 25);
        
        [UIView animateWithDuration:[FRBSwatchist floatForKey:@"page.cueIndicatorAnimationDuration"]
                              delay:.03
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ tileView.center = center; }
                         completion:nil];
    }
}

@end
