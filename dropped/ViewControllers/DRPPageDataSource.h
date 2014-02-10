//
//  DRPPageDataSource.h
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPPageViewController.h"

// Works very much like UIPageViewControllerDataSource, i.e. it
// maps pageID (page number) to initialized DRPPageViewControllers.

// Also provides methods to determine relationships between pages.

@interface DRPPageDataSource : NSObject

- (DRPPageViewController *)pageForPageID:(DRPPageID)pageID;
- (DRPPageID)pageIDInDirection:(DRPPageDirection)direction from:(DRPPageID)pageID;
- (DRPPageDirection)directionFromPage:(DRPPageID)start to:(DRPPageID)end;

@end
