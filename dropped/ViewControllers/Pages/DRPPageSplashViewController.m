//
//  DRPPageSplashViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageSplashViewController.h"
#import "DRPMainViewController.h"
#import "FRBSwatchist.h"
#import <GameKit/GameKit.h>

@interface DRPPageSplashViewController ()

@end

@implementation DRPPageSplashViewController

- (id)init
{
    self = [super initWithPageID:DRPPageSplash];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    label.text = @"Splash";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [FRBSwatchist fontForKey:@"page.cueFont"];
    label.center = self.view.center;
    [self.view addSubview:label];
}

#pragma mark DRPPageViewController

- (void)didMoveToCurrent
{
    DRPPageID page = DRPPageList;
    if (![GKLocalPlayer localPlayer].authenticated) {
        page = DRPPageLogIn;
    }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.mainViewController setCurrentPageID:page animated:YES userInfo:nil];
    });
}

@end
