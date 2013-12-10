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

#import "DRPCharacter.h"
#import "DRPTileView.h"

@interface DRPPageLogInViewController ()

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

- (void)viewDidLoad
{
    UIButton *signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signInButton.frame = CGRectMake(0, 0, 200, 200);
    signInButton.center = self.view.center;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Sign In"
                                                                attributes:@{NSFontAttributeName : [FRBSwatchist fontForKey:@"page.cueFont"]}];
    
    [signInButton setAttributedTitle:title forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signInButton addTarget:self action:@selector(signInButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signInButton];
    
    NSArray *letters = @[@"A", @"B", @"C", @"D", @"E", @"F"];
    for (NSInteger i = 0; i < 6; i++) {
        DRPTileView *tile = [[DRPTileView alloc] initWithCharacter:[DRPCharacter characterWithCharacter:letters[i]]];
        tile.center = CGPointMake(27.5 + 53 * i, 27.5);
        [self.view addSubview:tile];
    }
}

- (void)signInButtonPressed:(id)sender
{
    if ([DRPGameCenterInterface authenticationViewController]) {
        [self presentViewController:[DRPGameCenterInterface authenticationViewController] animated:YES completion:nil];
    } else {
        // Dumb user hit Cancel. Only option now is to sign in through
        // Game Center app.
        // Fuck, I hate Game Center
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }
}

#pragma mark Notifications

- (void)localPlayerAuthenticated
{
    if (self.mainViewController.currentPageID == self.pageID) {
        [self.mainViewController setCurrentPageID:DRPPageList animated:YES userInfo:nil];
    }
}

@end
