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
#import "DRPUtility.h"
#import <GameKit/GameKit.h>

@interface DRPPageSplashViewController ()

@property UILabel *label;

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
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _label.text = @"DROPPED";
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [FRBSwatchist fontForKey:@"page.cueFont"];
    [self.view addSubview:_label];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // tmp
    _label.center = rectCenter(self.view.bounds);
}

- (void)loadScrollView
{
    // Intentionally left blank
}

#pragma mark DRPPageViewController

- (void)didMoveToCurrent
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        DRPPageID page = DRPPageList;
        if (![GKLocalPlayer localPlayer].authenticated) {
            page = DRPPageLogIn;
        }
        
        [self.mainViewController setCurrentPageID:page animated:YES userInfo:nil];
    });
}

@end
