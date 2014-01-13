//
//  DRPPageListViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageListViewController.h"
#import "DRPMainViewController.h"
#import "DRPPageListDataSource.h"
#import "DRPPageCollectionViewLayout.h"
#import "DRPMatchCollectionViewCell.h"
#import "FRBSwatchist.h"

@interface DRPPageListViewController ()

@property UICollectionView *scrollView;
@property DRPPageListDataSource *dataSource;
@property DRPPageCollectionViewLayout *layout;

@end

@implementation DRPPageListViewController

- (instancetype)init
{
    self = [super initWithPageID:DRPPageList];
    if (self) {
        self.topCue = @"Pull for New Game";
        self.bottomCue = @"Et Cetera";
    }
    return self;
}

#pragma mark View Loading

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadScrollView
{
    _layout = [[DRPPageCollectionViewLayout alloc] init];
    _layout.itemSize = CGSizeMake(300, 50);
    _layout.minimumLineSpacing = 15;
    _layout.sectionInset = UIEdgeInsetsMake(35, 0, 35, 0);
    
    _dataSource = [[DRPPageListDataSource alloc] init];
    
    self.scrollView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_layout];
    self.scrollView.dataSource = _dataSource;
    self.scrollView.delegate = self;
    
    [self.scrollView registerClass:[DRPMatchCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.scrollView];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    [_dataSource reloadMatchesWithCompletion:^{
        [self.scrollView reloadData];
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

@end
