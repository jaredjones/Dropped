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

- (UIViewController<DRPPage> *)pageForPageID:(DRPPageID)pageID
{
    if (_pages[@(pageID)]) {
        return _pages[@(pageID)];
    }
    
    UIViewController *viewController;
    
    if (pageID == DRPPageList) {
        viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        viewController.view.backgroundColor = [UIColor lightGrayColor];
        
    } else if (pageID == DRPPageMatchMaker) {
        viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        viewController.view.backgroundColor = [UIColor orangeColor];
        
    } else if (pageID == DRPPageMatch) {
        viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        viewController.view.backgroundColor = [UIColor yellowColor];
    }
    else if (pageID == DRPPageEtCetera) {
        viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        viewController.view.backgroundColor = [UIColor greenColor];
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
