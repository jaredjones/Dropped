//
//  DRPPageMatchmakerViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageMatchmakerViewController.h"

@interface DRPPageMatchmakerViewController ()

@end

@implementation DRPPageMatchmakerViewController

- (id)init
{
    self = [super initWithPageID:DRPPageMatchMaker];
    if (self) {
        self.view.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
}

@end
