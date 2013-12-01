//
//  DRPPageListViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageListViewController.h"

@interface DRPPageListViewController ()

@end

@implementation DRPPageListViewController
@synthesize pageID=_pageID;

- (instancetype)initWithPageID:(DRPPageID)pageID
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _pageID = pageID;
    }
    return self;
}

@end
