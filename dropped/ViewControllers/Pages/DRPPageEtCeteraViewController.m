//
//  DRPPageEtCeteraViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/11/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageEtCeteraViewController.h"
#import "DRPMainViewController.h"

@interface DRPPageEtCeteraViewController ()

@end

@implementation DRPPageEtCeteraViewController

- (id)init
{
    self = [super initWithPageID:DRPPageEtCetera];
    if (self) {
    }
    return self;
}

- (void)didMoveToCurrent
{
    [self.mainViewController setCue:@"Back" inPosition:DRPPageDirectionUp];
}

@end
