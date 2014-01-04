//
//  DRPUtility.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPUtility.h"
#import "FRBSwatchist.h"

static NSDictionary *colors;
UIColor *colorForColor(DRPColor color)
{
    if (!colors) {
        colors = @{@(DRPColorBlue) : @"blue",
                   @(DRPColorGreen) : @"green",
                   @(DRPColorOrange) : @"orange",
                   @(DRPColorPurple) : @"purple",
                   @(DRPColorYellow) : @"yellow",
                   @(DRPColorPink) : @"pink",
                   @(DRPColorRed) : @"red",
                   @(DRPColorNil) : @"white" };
    }
    return [[FRBSwatchist swatchForName:@"colors"] colorForKey:colors[@(color)]];
}

BOOL runningPhone5()
{
    return [UIScreen mainScreen].applicationFrame.size.height > 480;
}
