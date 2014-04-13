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
UIColor *colorForDRPColor(DRPColor color)
{
    if (!colors) {
        colors = @{@(DRPColorBlue) : @"blue",
                   @(DRPColorGreen) : @"green",
                   @(DRPColorOrange) : @"orange",
                   @(DRPColorPurple) : @"purple",
                   @(DRPColorYellow) : @"yellow",
                   @(DRPColorPink) : @"pink",
                   @(DRPColorRed) : @"red",
                   @(DRPColorGray) : @"gray",
                   @(DRPColorFacebook) : @"facebook",
                   @(DRPColorNil) : @"white",};
    }
    return [[FRBSwatchist swatchForName:@"colors"] colorForKey:colors[@(color)]];
}

BOOL runningPhone5()
{
    return [UIScreen mainScreen].applicationFrame.size.height > 480;
}

CGFloat labelOffset(UIFont *font, CGFloat height)
{
    return -font.ascender + (font.capHeight / 2) + (height / 2) - 1;
}

CGPoint rectCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

NSString *firstPrintableCharacter(NSString *alias)
{
    return [[alias substringToIndex:1] uppercaseString];
}

NSString *generateUUID() {
    CFUUIDRef uniqueID = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uniqueID);
    CFRelease(uniqueID);
    return uuidString;
}

id coerceObject(id argument, id (^block)(id)) {
    if (argument == [NSNull null]) {
        return nil;
    }
    if (block) {
        return block(argument);
    }
    return argument;
}
