//
//  DRPPageEtCeteraViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/11/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageEtCeteraViewController.h"
#import "DRPMainViewController.h"

@interface DRPPageEtCeteraViewController ()

@property UIImageView *underConstruction;

@end

@implementation DRPPageEtCeteraViewController

- (id)init
{
    self = [super initWithPageID:DRPPageEtCetera];
    if (self) {
        self.topCue = @"Back";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"under_construction.png"];
    self.underConstruction = [[UIImageView alloc] initWithImage:image];
    self.underConstruction.frame = ({
        CGRect frame = CGRectZero;
        frame.size.width = image.size.width / 2;
        frame.size.height = image.size.height / 2;
        frame;
    });
    [self.scrollView addSubview:self.underConstruction];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.underConstruction.center = self.scrollView.center;
}

@end
