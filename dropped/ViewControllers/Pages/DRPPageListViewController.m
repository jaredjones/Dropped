//
//  DRPPageListViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageListViewController.h"
#import "DRPMainViewController.h"

@interface DRPPageListViewController ()

@end

@implementation DRPPageListViewController

- (instancetype)init
{
    self = [super initWithPageID:DRPPageList];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
}

#pragma mark ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.dragging) return;
    
    // Let DRPMainViewController know about scrolling
    CGFloat offset = [self scrollViewPanOffset:scrollView];
    if (offset != 0) {
        [self.mainViewController handlePanGesture:scrollView.panGestureRecognizer offset:offset];
    } else {
    }
}

- (CGFloat)scrollViewPanOffset:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        return -[scrollView.panGestureRecognizer translationInView:self.view].y - scrollView.contentOffset.y;
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > 0) {
        return -[scrollView.panGestureRecognizer translationInView:self.view].y - (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height);
    }
    return 0;
}

@end
