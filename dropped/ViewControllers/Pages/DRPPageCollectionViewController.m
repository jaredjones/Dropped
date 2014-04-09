//
//  DRPPageCollectionViewController.m
//  Dropped
//
//  Created by Brad Zeis on 2/13/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPPageCollectionViewController.h"
#import "DRPMainViewController.h"

#import "DRPCollectionViewDataSource.h"
#import "DRPCollectionDataItem.h"
#import "DRPCollectionViewLayout.h"

@interface DRPPageCollectionViewController ()

@property (readwrite) UICollectionView *scrollView;
@property (readwrite) DRPCollectionViewDataSource *dataSource;
@property DRPCollectionViewLayout *layout;

@end

@implementation DRPPageCollectionViewController
@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    self.layout = [[DRPCollectionViewLayout alloc] init];
    
    self.scrollView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    self.dataSource = [[DRPCollectionViewDataSource alloc] init];
    [self initDataSource];
    
    self.scrollView.dataSource = self.dataSource;
    self.scrollView.delegate = self;
    
    [self registerCellIdentifiers];
    
    [self.view addSubview:self.scrollView];
}

- (void)initDataSource
{
}

- (void)registerCellIdentifiers
{
}

#pragma mark UIViewController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    [self.dataSource reloadDataForCollectionView:self.scrollView];
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
    if (![self.mainViewController isCurrentPage:self]) return;
    
    DRPCollectionDataItem *dataItem = [self.dataSource dataItemForIndexPath:indexPath];
    if (dataItem.selected) {
        dataItem.selected(dataItem.userData);
    }
}

#pragma mark ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    // TODO: make sure the cues are "pushed away" with the top/bottom cells
}

@end
