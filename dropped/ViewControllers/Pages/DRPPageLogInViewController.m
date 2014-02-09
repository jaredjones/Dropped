//
//  DRPPageLogInViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPMainViewController.h"
#import "DRPPageLogInViewController.h"
#import "DRPGameCenterInterface.h"
#import "FRBSwatchist.h"
#import "DRPUtility.h"

@interface DRPPageLogInViewController ()

@property UIButton *signInButton;

@end

@implementation DRPPageLogInViewController

- (id)init
{
    self = [super initWithPageID:DRPPageLogIn];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localPlayerAuthenticated)
                                                     name:DRPGameCenterLocalPlayerAuthenticatedNotificationName
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadSignInButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutSignInButton];
}

- (void)loadScrollView
{
    // Intentionally left blank
}

- (void)loadSignInButton
{
    _signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _signInButton.frame = CGRectMake(0, 0, 320, 200);
    _signInButton.center = rectCenter(self.view.bounds);
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Sign In with Game Center"
                                                                attributes:@{NSFontAttributeName : [FRBSwatchist fontForKey:@"page.cueFont"]}];
    
    [_signInButton setAttributedTitle:title forState:UIControlStateNormal];
    [_signInButton setTitleColor:[FRBSwatchist colorForKey:@"colors.black"] forState:UIControlStateNormal];
    [_signInButton addTarget:self action:@selector(signInButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_signInButton];
}

- (void)layoutSignInButton
{
    _signInButton.center = rectCenter(self.view.bounds);
}

#pragma mark Touch Events

- (void)signInButtonPressed:(id)sender
{
    if ([DRPGameCenterInterface authenticationViewController]) {
        [self presentViewController:[DRPGameCenterInterface authenticationViewController] animated:YES completion:nil];
    } else {
        // Dumb user hit Cancel. Only option now is to sign in through Game Center app.
        // Fuck, I hate Game Center
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter://"]];
    }
}

#pragma mark Notifications

- (void)localPlayerAuthenticated
{
    if (self.mainViewController.currentPageID == self.pageID) {
        [self.mainViewController setCurrentPageID:DRPPageList animated:YES userInfo:nil];
    }
}

#pragma mark Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutSignInButton];
}

@end
