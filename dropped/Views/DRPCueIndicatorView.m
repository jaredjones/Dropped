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
    self = [super initWithFrame:({
        CGFloat width = [FRBSwatchist floatForKey:@"board.boardWidth"];
        CGFloat height = [FRBSwatchist floatForKey:@"board.tileLength"];
        CGRectMake(0, 0, width, height);
    })];
    if (self) {
        _tileViews = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < 6; i++) {
            DRPTileView *tileView = [[DRPTileView alloc] initWithCharacter:nil];
            tileView.center = [DRPCueIndicatorView centerForPosition:i];
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

+ (CGPoint)centerForPosition:(NSInteger)i
{
    CGFloat padding = [FRBSwatchist floatForKey:@"board.boardPadding"];
    CGFloat margin = [FRBSwatchist floatForKey:@"board.tileMargin"];
    CGFloat tileLength = [FRBSwatchist floatForKey:@"board.tileLength"];
    
    return CGPointMake((padding + tileLength / 2) + (tileLength + margin) * i, tileLength / 2);
}

- (void)animateIn
{
    CGFloat offset = 2 * [FRBSwatchist floatForKey:@"board.tileStrokeWidth"];
    offset = _position == DRPPageDirectionUp ? offset : -offset;
    for (NSInteger i = 0; i < 6; i++) {
        DRPTileView *tileView = _tileViews[i];
        CGPoint center = ({
            CGPoint center = [DRPCueIndicatorView centerForPosition:i];
            center.y += offset;
            center;
        });
        
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
        CGPoint center = [DRPCueIndicatorView centerForPosition:i];
        
        [UIView animateWithDuration:[FRBSwatchist floatForKey:@"page.cueIndicatorAnimationDuration"]
                              delay:.03
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ tileView.center = center; }
                         completion:nil];
    }
}

@end
