//
//  DRPPageDataSource.m
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageDataSource.h"

@interface DRPPageDataSource ()

@property NSMutableDictionary *pages;

@end

#pragma mark - DRPPageDataSource

@implementation DRPPageDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (UIViewController<DRPPage> *)pageForPageID:(DRPPageID)pageID
{
    if (_pages[@(pageID)]) {
        return _pages[@(pageID)];
    }
    
    UIViewController *viewController;
    
    if (pageID == DRPPageList) {
        viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    }
    //    else if ...
    
    if (!viewController) return nil;
    
    _pages[@(pageID)] = viewController;
    return _pages[@(pageID)];
}

- (DRPPageID)pageIDInDirection:(DRPPageDirection)direction from:(DRPPageID)pageID
{
    return 0;
}

- (DRPPageDirection)directionFromPage:(DRPPageID)start to:(DRPPageID)end
{
    return 0;
}

@end
