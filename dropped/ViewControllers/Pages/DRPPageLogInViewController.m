//
//  DRPPageLogInViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPMainViewController.h"
#import "DRPPageLogInViewController.h"

#import "DRPCollectionViewDataSource.h"
#import "DRPCollectionDataItem.h"
#import "DRPMenuCollectionViewCell.h"

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
    }
    return self;
}

#pragma mark View Loading

- (void)initDataSource
{
    [self.dataSource loadData:^NSArray *{
        return @[({
            DRPCollectionDataItem *dataItem = [[DRPCollectionDataItem alloc] init];
            dataItem.itemID = @"Facebook";
            dataItem.cellIdentifier = @"menuCell";
            dataItem.userData = @{@"color" : @(DRPColorFacebook), @"text" : @"Facebook"};
            dataItem.selected = ^(id userData) {
                [self signInButtonPressed];
            };
            dataItem;
        }), ({
            DRPCollectionDataItem *dataItem = [[DRPCollectionDataItem alloc] init];
            dataItem.itemID = @"No Thanks";
            dataItem.cellIdentifier = @"menuCell";
            dataItem.userData = @{@"color" : @(DRPColorNil), @"text" : @"No Thanks"};
            dataItem.selected = ^(id userData) {
                [self skipSignInButtonPressed];
            };
            dataItem;
        })];
    }];
}

- (void)registerCellIdentifiers
{
    [self.scrollView registerClass:[DRPMenuCollectionViewCell class] forCellWithReuseIdentifier:@"menuCell"];
}

#pragma mark Touch Events

- (void)signInButtonPressed
{
    NSLog(@"Facebook signin not supported yet.");
}

- (void)skipSignInButtonPressed
{
    [self localPlayerAuthenticated];
}

#pragma mark Notifications

- (void)localPlayerAuthenticated
{
    if ([self.mainViewController isCurrentPage:self]) {
        [self.mainViewController setCurrentPageID:DRPPageList animated:YES userInfo:nil];
    }
}

@end
