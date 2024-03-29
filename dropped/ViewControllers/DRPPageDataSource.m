//
//  DRPPageDataSource.m
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageDataSource.h"

#import "DRPPageViewController.h"
#import "DRPPageListViewController.h"
#import "DRPPageMatchmakerViewController.h"
#import "DRPPageSplashViewController.h"
#import "DRPPageLogInViewController.h"
#import "DRPPageEtCeteraViewController.h"
#import "DRPPageMatchViewController.h"

@interface DRPPageDataSource ()

@property NSMutableDictionary *pages;
@property NSDictionary *neighbors, *directions;

@end

#pragma mark - DRPPageDataSource

@implementation DRPPageDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pages = [[NSMutableDictionary alloc] init];
        
        // Neighbors are DRPPages that you can directly *drag* to.
        // Format: { currentPage : [upPage, downPage] }
        _neighbors = @{@(DRPPageList)       : @[@(DRPPageMatchMaker), @(DRPPageEtCetera)],
                       @(DRPPageMatch)      : @[[NSNull null], @(DRPPageList)],
                       @(DRPPageEtCetera)   : @[@(DRPPageList), [NSNull null]]};
        
        // Directions stores directions from a DRPPage to another DRPPage
        // Look, Jared! A graph problem!
        _directions = @{@(DRPPageSplash)     : @{@(DRPPageLogIn)    : @(DRPPageDirectionUp),
                                                 @(DRPPageList)     : @(DRPPageDirectionUp)},
                        @(DRPPageLogIn)      : @{@(DRPPageList)     : @(DRPPageDirectionUp)},
                        @(DRPPageList)       : @{@(DRPPageLogIn)    : @(DRPPageDirectionUp),
                                                 @(DRPPageMatch)    : @(DRPPageDirectionUp),
                                                 @(DRPPageEtCetera) : @(DRPPageDirectionDown)},
                        @(DRPPageMatchMaker) : @{@(DRPPageList)     : @(DRPPageDirectionDown),
                                                 @(DRPPageMatch)    : @(DRPPageDirectionUp)},
                        @(DRPPageMatch)      : @{@(DRPPageList)     : @(DRPPageDirectionDown)},
                        @(DRPPageEtCetera)   : @{@(DRPPageList)     : @(DRPPageDirectionUp)}};
    }
    return self;
}

- (DRPPageViewController *)pageForPageID:(DRPPageID)pageID
{
    if (_pages[@(pageID)]) {
        return _pages[@(pageID)];
    }
    
    DRPPageViewController *viewController;
    
    if (pageID == DRPPageSplash) {
        viewController = [[DRPPageSplashViewController alloc] init];
        
    } else if (pageID == DRPPageLogIn) {
        viewController = [[DRPPageLogInViewController alloc] init];
        
    } else if (pageID == DRPPageList) {
        viewController = [[DRPPageListViewController alloc] init];
        
    } else if (pageID == DRPPageMatchMaker) {
        viewController = [[DRPPageMatchmakerViewController alloc] init];
        
    } else if (pageID == DRPPageMatch) {
        viewController = [[DRPPageMatchViewController alloc] init];
        
    }
    else if (pageID == DRPPageEtCetera) {
        viewController = [[DRPPageEtCeteraViewController alloc] init];
    }
    
    if (!viewController) return nil;
    
    _pages[@(pageID)] = viewController;
    return _pages[@(pageID)];
}

- (DRPPageID)pageIDInDirection:(DRPPageDirection)direction from:(DRPPageID)pageID
{
    NSNumber *page = _neighbors[@(pageID)][direction];
    return (!page || page == (id)[NSNull null]) ? DRPPageNil : [page intValue];
}

- (DRPPageDirection)directionFromPage:(DRPPageID)start to:(DRPPageID)end
{
    return [_directions[@(start)][@(end)] intValue];
}

@end
