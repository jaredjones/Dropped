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

@property UIImageView *logo;

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
    UIImage *image = [UIImage imageNamed:@"logo.png"];
    _logo = [[UIImageView alloc] initWithImage:image];
    _logo.frame = ({
        CGRect frame = CGRectZero;
        frame.size.width = image.size.width / 2;
        frame.size.height = image.size.height / 2;
        frame;
    });
    [self.view addSubview:_logo];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // tmp
    _logo.center = rectCenter(self.view.bounds);
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
