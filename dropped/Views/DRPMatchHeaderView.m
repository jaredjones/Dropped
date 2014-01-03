//
//  DRPMatchHeaderView.m
//  dropped
//
//  Created by Brad Zeis on 1/2/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMatchHeaderView.h"

@implementation DRPMatchHeaderView

- (id)init
{
    self = [super initWithFrame:[DRPMatchHeaderView frame]];
    if (self) {
    }
    return self;
}

+ (CGRect)frame
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if ([UIScreen mainScreen].bounds.size.height > 480) {
            return [DRPMatchHeaderView iphone5Frame];
        }
        return [DRPMatchHeaderView iphone4Frame];
        
    }
    return [DRPMatchHeaderView ipadFrame];
}

+ (CGRect)iphone4Frame
{
    return CGRectZero;
}

+ (CGRect)iphone5Frame
{
    return CGRectMake(0, 0, 320, 5 + 106);
}

+ (CGRect)ipadFrame
{
    return CGRectZero;
}

@end
