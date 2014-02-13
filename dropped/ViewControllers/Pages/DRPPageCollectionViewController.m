//
//  DRPPageCollectionViewController.m
//  Dropped
//
//  Created by Brad Zeis on 2/13/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPPageCollectionViewController.h"
#import "DRPCollectionViewDataSource.h"
#import "DRPCollectionViewLayout.h"

#import "FRBSwatchist.h"

@interface DRPPageCollectionViewController ()

@property UICollectionView *scrollView;
@property DRPCollectionViewDataSource *dataSource;
@property DRPCollectionViewLayout *layout;

@end

@implementation DRPPageCollectionViewController

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
    self.layout.itemSize = [FRBSwatchist sizeForKey:@"list.itemSize"];
    self.layout.minimumLineSpacing = [FRBSwatchist floatForKey:@"list.lineSpacing"];
    self.layout.minimumInteritemSpacing = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
    self.layout.sectionInset = UIEdgeInsetsMake([FRBSwatchist floatForKey:@"list.sectionInset"], 0,
                                                [FRBSwatchist floatForKey:@"list.sectionInset"], 0);
    
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
    [self resetSectionInsetsAnimated:YES];
}

- (void)resetSectionInsetsAnimated:(BOOL)animated;
{
    // TODO: I _hate_ that fade. Need a longer term solution
    [self.layout recalculateSectionInsetsWithCollectionView:self.scrollView
                                                  cellCount:[self.dataSource collectionView:self.scrollView numberOfItemsInSection:0]];
    [self.scrollView setCollectionViewLayout:self.layout animated:animated];
}

#pragma mark DRPPageViewController

- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo
{
    [super willMoveToCurrentWithUserInfo:userInfo];
    
    // TODO: tmp. There should be a more centralized way to do this
    [self.dataSource reloadMatchesWithCompletion:^{
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

@end
