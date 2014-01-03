//
//  DRPMatchHeaderViewController.m
//  dropped
//
//  Created by Brad Zeis on 1/3/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMatchHeaderViewController.h"
#import "DRPMatchPlayerView.h"

@interface DRPMatchHeaderViewController ()

@property NSMutableArray *playerViews;

@end

@implementation DRPMatchHeaderViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[DRPMatchHeaderViewController frame]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    // TODO: load DRPMatchPlayerViews
}

#pragma mark View Loading

+ (CGRect)frame
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if ([UIScreen mainScreen].bounds.size.height > 480) {
            return [DRPMatchHeaderViewController iphone5Frame];
        }
        return [DRPMatchHeaderViewController iphone4Frame];
        
    }
    return [DRPMatchHeaderViewController ipadFrame];
}

+ (CGRect)iphone4Frame
{
    return CGRectZero;
}

+ (CGRect)iphone5Frame
{
    return CGRectMake(0, 0, 320, 5 + 106);
}

+ (CGRect)ipadFrame
{
    return CGRectZero;
}

#pragma mark Player Observing

- (void)observePlayers:(NSArray *)players
{
    
}

@end
