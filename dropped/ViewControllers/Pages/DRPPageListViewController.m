//
//  DRPPageListViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageListViewController.h"
#import "DRPMainViewController.h"

#import "DRPCollectionViewDataSource.h"
#import "DRPCollectionViewLayout.h"

#import "DRPMatchCollectionViewCell.h"
#import "DRPMatch.h"

#import "DRPGameCenterInterface.h"
#import "FRBSwatchist.h"

@interface DRPPageListViewController ()

@property UICollectionView *scrollView;
@property DRPCollectionViewDataSource *dataSource;
@property DRPCollectionViewLayout *layout;

@end

@implementation DRPPageListViewController

- (instancetype)init
{
    self = [super initWithPageID:DRPPageList];
    if (self) {
        self.topCue = @"Pull for New Game";
        self.bottomCue = @"Et Cetera";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedRemoteGameCenterTurn:)
                                                     name:DRPGameCenterReceivedRemoteTurnNotificationName
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
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self resetSectionInsetsAnimated:YES];
}

- (void)resetSectionInsetsAnimated:(BOOL)animated;
{
    // TODO: I _hate_ that fade. Need a longer term solution
    [_layout recalculateSectionInsetsWithCollectionView:self.scrollView
                                              cellCount:[_dataSource collectionView:self.scrollView numberOfItemsInSection:0]];
    [self.scrollView setCollectionViewLayout:_layout animated:animated];
}

- (void)loadScrollView
{
    self.layout = [[DRPCollectionViewLayout alloc] init];
    self.layout.itemSize = [FRBSwatchist sizeForKey:@"list.itemSize"];
    self.layout.minimumLineSpacing = [FRBSwatchist floatForKey:@"list.lineSpacing"];
    self.layout.minimumInteritemSpacing = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
    self.layout.sectionInset = UIEdgeInsetsMake([FRBSwatchist floatForKey:@"list.sectionInset"], 0,
                                                [FRBSwatchist floatForKey:@"list.sectionInset"], 0);
    
    self.dataSource = [[DRPCollectionViewDataSource alloc] init];
    
    self.scrollView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
    self.scrollView.dataSource = self.dataSource;
    self.scrollView.delegate = self;
    
    [self.scrollView registerClass:[DRPMatchCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.scrollView];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    // TODO: tmp. There should be a more centralized way to do this
    [_dataSource reloadMatchesWithCompletion:^{
        [self.scrollView reloadData];
        [self resetSectionInsetsAnimated:NO];
    }];
}

- (void)didMoveToCurrent
{
    [super didMoveToCurrent];
}

- (void)didMoveFromCurrent
{
    [super didMoveFromCurrent];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRPMatch *match = [_dataSource matchForIndexPath:indexPath];
    if (!match) return;
    
    [self.mainViewController setCurrentPageID:DRPPageMatch animated:YES userInfo:@{@"match" : match}];
}

#pragma mark Game Center Notifications

- (void)receivedRemoteGameCenterTurn:(NSNotification *)notification
{
    // This check is to prevent reloadMatchDataWithCompletion: from being called twice
    if (![self.mainViewController isCurrentPage:self]) return;
    
    GKTurnBasedMatch *gkMatch = notification.userInfo[@"gkMatch"];
    DRPMatch *match = [self.dataSource matchForMatchID:gkMatch.matchID];
    if (!match) return;
    
    // TODO: is this getting called twice? Definitely check
    [match reloadMatchDataWithCompletion:^(BOOL newTurns) {
        // TODO: ugh, this is a bad way to update the cells
        [self.scrollView reloadData];
    }];
}

@end
