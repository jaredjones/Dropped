//
//  DRPBoardViewController.m
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPBoardViewController.h"

#import "DRPBoard.h"
#import "DRPPosition.h"
#import "DRPCharacter.h"

@interface DRPBoardViewController ()

@property NSMutableDictionary *tiles;

@end

@implementation DRPBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark Loading

- (void)loadBoard:(DRPBoard *)board
{
}

- (CGPoint)centerForPosition:(DRPPosition *)position
{
    return CGPointZero;
}

#pragma mark DRPTileDelegate

- (void)tileWasSelected:(DRPTileView *)tile
{
    
}

- (void)tileWasDeselected:(DRPTileView *)character
{
    
}

@end
