//
//  DRPPageDataSource.h
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPPageViewController.h"

#define DEBUG_NO_MATCHMAKER true

@interface DRPPageDataSource : NSObject

- (DRPPageViewController *)pageForPageID:(DRPPageID)pageID;
- (DRPPageID)pageIDInDirection:(DRPPageDirection)direction from:(DRPPageID)pageID;
- (DRPPageDirection)directionFromPage:(DRPPageID)start to:(DRPPageID)end;

@end
