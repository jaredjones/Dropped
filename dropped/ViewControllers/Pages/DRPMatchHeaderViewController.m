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
    self.view = [[UIView alloc] initWithFrame:self.headerFrame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [FRBSwatchist colorForKey:@"colors.white"];
    self.view.backgroundColor = [UIColor yellowColor];
    
    
    // TODO: load real DRPMatchPlayerViews
    [self.view addSubview:[[DRPMatchPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height)
                                                          alignment:DRPDirectionLeft
                                                               tile:YES]];
    
    [self.view addSubview:[[DRPMatchPlayerView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height)
                                                          alignment:DRPDirectionRight
                                                               tile:YES]];
}

#pragma mark View Loading

- (CGRect)headerFrame
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (runningPhone5()) {
            return [DRPMatchHeaderViewController phone5Frame];
        }
        return [DRPMatchHeaderViewController phone4Frame];
        
    }
    return [DRPMatchHeaderViewController padFrameForInterfaceOrientation:self.interfaceOrientation];
}

+ (CGRect)phone4Frame
{
    return CGRectMake(0, 0, 320, 480 / 2 - [FRBSwatchist floatForKey:@"board.boardWidth"] / 2 + [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPhone4"]);
}

+ (CGRect)phone5Frame
{
    return CGRectMake(0, 0, 320, 568 / 2 - [FRBSwatchist floatForKey:@"board.boardWidth"] / 2 + [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPhone5"]);
}

+ (CGRect)padFrameForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        return CGRectMake(0, 0, 768, 1024 / 2 - [FRBSwatchist floatForKey:@"board.boardWidth"] / 2 + [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPad"]);
    }
    return CGRectMake(0, 0, 1024, 768 / 2 - [FRBSwatchist floatForKey:@"board.boardWidth"] / 2 + [FRBSwatchist floatForKey:@"board.boardVerticalOffsetPadLandscape"]);
}

#pragma mark Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) return;
    
    self.view.frame = [DRPMatchHeaderViewController padFrameForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark Player Observing

- (void)observePlayers:(NSArray *)players
{
    
}

@end
