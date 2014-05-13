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

NSString *removeDuplicateCharactersInString(NSString *str)
{
    NSMutableSet *uniqueCharacters = [NSMutableSet set];
    NSMutableString *uniqueString = [NSMutableString string];
    [str enumerateSubstringsInRange:NSMakeRange(0, str.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (![uniqueCharacters containsObject:substring]) {
            [uniqueCharacters addObject:substring];
            [uniqueString appendString:substring];
        }
    }];
    return uniqueString;
}

NSString *sortStringAlphabetically(NSString *str)
{
    NSUInteger length = [str length];
    unichar *chars = (unichar *)malloc(sizeof(unichar) * length);
    
    // extract
    [str getCharacters:chars range:NSMakeRange(0, length)];
    
    // sort (for western alphabets only)
    qsort_b(chars, length, sizeof(unichar), ^(const void *l, const void *r) {
        unichar left = *(unichar *)l;
        unichar right = *(unichar *)r;
        return (int)(left - right);
    });
    
    // recreate
    NSString *sorted = [NSString stringWithCharacters:chars length:length];
    
    // clean-up
    free(chars);
    
    return sorted;
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
