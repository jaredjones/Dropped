//
//  DRPMatchHeaderViewController.m
//  dropped
//
//  Created by Brad Zeis on 1/3/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMatchHeaderViewController.h"
#import "DRPMatchPlayerView.h"
#import "DRPPosition.h"
#import "FRBSwatchist.h"
#import "DRPUtility.h"

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
    
    self.view.backgroundColor = [FRBSwatchist colorForKey:@"colors.white"];
    
    // TODO: load DRPMatchPlayerViews
    
    [self.view addSubview:[[DRPMatchPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height)
                                                          alignment:DRPDirectionLeft
                                                               tile:YES]];
    
    [self.view addSubview:[[DRPMatchPlayerView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height)
                                                          alignment:DRPDirectionRight
                                                               tile:YES]];
}

#pragma mark View Loading

+ (CGRect)frame
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (runningPhone5()) {
            return [DRPMatchHeaderViewController phone5Frame];
        }
        return [DRPMatchHeaderViewController phone4Frame];
        
    }
    return [DRPMatchHeaderViewController padFrame];
}

+ (CGRect)phone4Frame
{
    return CGRectMake(0, 0, 320, 480 / 2 - 160 + -5);
}

+ (CGRect)phone5Frame
{
    return CGRectMake(0, 0, 320, 568 / 2 - 160 + 11);
}

+ (CGRect)padFrame
{
    return CGRectZero;
}

#pragma mark Player Observing

- (void)observePlayers:(NSArray *)players
{
    
}

@end
