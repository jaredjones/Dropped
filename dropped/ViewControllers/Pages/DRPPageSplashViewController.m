//
//  DRPPageSplashViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageSplashViewController.h"
#import "DRPMainViewController.h"

#import "DRPNetworking.h"

#import "FRBSwatchist.h"
#import "DRPUtility.h"

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
    self.logo = [[UIImageView alloc] initWithImage:image];
    self.logo.frame = ({
        CGRect frame = CGRectZero;
        frame.size.width = image.size.width / 2;
        frame.size.height = image.size.height / 2;
        frame;
    });
    [self.view addSubview:self.logo];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // tmp
    self.logo.center = rectCenter(self.view.bounds);
}

- (void)loadScrollView
{
    // Intentionally left blank so the scrollView won't load
}

#pragma mark DRPPageViewController

- (void)didMoveToCurrent
{
    // Attempt to Log user in
    [[DRPNetworking sharedNetworking] fetchDeviceIDWithCompletion:^(BOOL foundDeviceID) {
        
        if (!foundDeviceID) {
            // TODO: Critical error, must be network problems on either end. Show some sort of apologetic message
            
            // TODO: If the user has logged in before, let them play around with their cached matches. We'll need to sync them up when they reconnect
            
        } else {
            // Register APNSToken
            
            // TODO: move this to after the user creates their first match
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert];
            
            // TODO: if an alias is not set, prompt user to set an alias
            
            [self transtionToPage:DRPPageLogIn];
        }
    }];
}

- (void)transtionToPage:(DRPPageID)pageID
{
    [self.mainViewController setCurrentPageID:pageID animated:YES userInfo:nil];
}

@end
