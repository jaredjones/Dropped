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

@property DRPPageDirection position;

@end

@implementation DRPCueIndicatorView

- (instancetype)initWithPosition:(DRPPageDirection)position
{
    self = [super initWithFrame:({
        CGFloat width = [FRBSwatchist floatForKey:@"board.boardWidth"];
        CGFloat height = [FRBSwatchist floatForKey:@"board.tileLength"];
        CGRectMake(0, 0, width, height);
    })];
    if (self) {
        self.position = position;
        
        for (NSInteger i = 0; i < 6; i++) {
            
            [self addSubview:({
                DRPTileView *tileView = [[DRPTileView alloc] initWithCharacter:nil];
                tileView.center = [DRPCueIndicatorView centerForPosition:i];
//                tileView.permaHighlighted = YES;
                tileView.userInteractionEnabled = NO;
                [tileView resetAppearence];
                tileView;
            })];
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

@end
