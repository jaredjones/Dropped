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

@property NSArray *playerViews;

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
    
    [self loadPlayerViews];
}

- (void)loadPlayerViews
{
    _playerViews = @[({
        UIView *view = [[DRPMatchPlayerView alloc] initWithAlignment:DRPDirectionLeft];
        [self.view addSubview:view];
        view;
    }), ({
        UIView *view = [[DRPMatchPlayerView alloc] initWithAlignment:DRPDirectionRight];
        [self.view addSubview:view];
        view;
    })];
    
    for (NSInteger i = 0; i < 2; i++) {
        UIView *view = _playerViews[i];
        view.frame = ({
            CGRect frame = view.frame;
            frame.origin = [self originForPlayerView:i forInterfaceOrientation:self.interfaceOrientation];
            frame;
        });
    }
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

- (CGPoint)originForPlayerView:(NSInteger)i forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIView *view = _playerViews[i];
    if (i == 0) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            return CGPointMake(0, 0);
            
        } else {
            return CGPointMake(0, 0);
        }
    } else if (i == 1) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            return CGPointMake(self.view.frame.size.width / 2, 0);
            
        } else {
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                return CGPointMake(1024 - view.frame.size.width, 0);
            }
            return CGPointMake(self.view.frame.size.width / 2, 0);
        }
    }
    return CGPointZero;
}

#pragma mark Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) return;
    
    self.view.frame = [DRPMatchHeaderViewController padFrameForInterfaceOrientation:toInterfaceOrientation];
    [self resetPlayerViewLocationForInterfaceOrientation:toInterfaceOrientation];
}

- (void)resetPlayerViewLocationForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    for (NSInteger i = 0; i < 2; i++) {
        ((UIView *)_playerViews[i]).frame = ({
            CGRect frame = ((UIView *)_playerViews[i]).frame;
            frame.origin = [self originForPlayerView:i forInterfaceOrientation:toInterfaceOrientation];
            frame;
        });
    }
}

#pragma mark Player Observing

- (void)observePlayers:(NSArray *)players
{
    for (NSInteger i = 0; i < 2; i++) {
        [(DRPMatchPlayerView *)_playerViews[i] observePlayer:players[i]];
    }
}

@end
