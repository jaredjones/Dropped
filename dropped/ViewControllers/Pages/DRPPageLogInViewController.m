//
//  DRPPageLogInViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageLogInViewController.h"
#import "FRBSwatchist.h"

@interface DRPPageLogInViewController ()

@end

@implementation DRPPageLogInViewController

- (id)init
{
    self = [super initWithPageID:DRPPageLogIn];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    label.text = @"Log In";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [FRBSwatchist fontForKey:@"page.cueFont"];
    label.center = self.view.center;
    [self.view addSubview:label];
}

@end
