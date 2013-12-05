//
//  DRPPageViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/5/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageViewController.h"

@interface DRPPageViewController ()

@end

@implementation DRPPageViewController
@synthesize pageID=_pageID;

- (id)initWithPageID:(DRPPageID)pageID
{
    self = [super init];
    if (self) {
        _pageID = pageID;
    }
    return self;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    _mainViewController = (DRPMainViewController *)parent;
}

#pragma mark DRPPage

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    
}

- (void)didMoveToCurrent
{
    
}

- (void)willMoveFromCurrent
{
    
}

- (void)didMoveFromCurrent
{
    
}

@end
