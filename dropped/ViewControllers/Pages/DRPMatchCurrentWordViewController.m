//
//  DRPMatchCurrentWordViewController.m
//  dropped
//
//  Created by Brad Zeis on 1/30/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMatchCurrentWordViewController.h"
#import "DRPCurrentWordView.h"

@interface DRPMatchCurrentWordViewController ()

@property UIView *currentContainer;

// TODO: make sure turnsLabel is vertically aligned

@end

@implementation DRPMatchCurrentWordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // tmp
    self.view.backgroundColor = [UIColor yellowColor];
    
    
    _currentContainer = [[DRPCurrentWordView alloc] initWithFrame:self.currentFrame];
    [self.view addSubview:_currentContainer];
}

#pragma mark Layout

- (void)layoutWithFrame:(CGRect)frame
{
    self.view.frame = frame;
    
    self.currentContainer.frame = self.currentFrame;
}

- (CGRect)currentFrame
{
    return self.view.bounds;
}

- (CGRect)leftFrame
{
    return CGRectOffset(self.currentFrame, -self.view.bounds.size.width, 0);
}

- (CGRect)rightFrame
{
    return CGRectOffset(self.currentFrame, self.view.bounds.size.width, 0);
}

#pragma mark Setting Content

- (void)characterWasHighlighted:(DRPCharacter *)character fromDirection:(DRPDirection)direction
{
    [(DRPCurrentWordView *)_currentContainer characterWasHighlighted:character];
}

- (void)characterWasDehighlighted:(DRPCharacter *)character
{
    [(DRPCurrentWordView *)_currentContainer characterWasDehighlighted:character];
}

- (void)characterWasRemoved:(DRPCharacter *)character fromDirection:(DRPDirection)direction
{
    [(DRPCurrentWordView *)_currentContainer characterWasRemoved:character];
}

- (void)setCharacters:(NSArray *)characters fromDirection:(DRPDirection)direction
{
    
}

- (void)setTurnsLeft:(NSInteger)turnsLeft isLocalTurn:(BOOL)isLocalTurn fromDirection:(DRPDirection)direction
{
    
}

#pragma mark Animations

//// Following two methods deal with the swipeclears
//- (void)swipeAwayContainer:(UIView *)container withVelocity:(CGFloat)velocity
//{
//    CGRect destFrame = velocity < 0 ? self.leftFrame : self.rightFrame;
//    
//    [UIView animateWithDuration:0.4
//                          delay:0
//         usingSpringWithDamping:0.8
//          initialSpringVelocity:velocity * .05
//                        options:0
//                     animations:^{
//                         container.frame = destFrame;
//                     }
//                     completion:^(BOOL finished) {
//                         if (!finished) return;
//                         
//                         if (_tileContainerNeedsClearing) {
//                             [self removeAllCharactersFromCurrentWord];
//                         }
//                         
//                         if (_currentContainer != container) {
//                             container.hidden = YES;
//                         }
//                     }];
//    
//    if (container == _tileContainer) {
//        _tileContainerNeedsClearing = YES;
//    }
//}
//
//- (void)snapBackContainer:(UIView *)container withVelocity:(CGFloat)velocity
//{
//    if (container.hasAnimationsRunning) {
//        [container setPositionToPresentationPosition];
//        [container.layer removeAllAnimations];
//    }
//    container.hidden = NO;
//    
//    [UIView animateWithDuration:0.4
//                          delay:0
//         usingSpringWithDamping:0.8
//          initialSpringVelocity:velocity * 0.001
//                        options:0
//                     animations:^{
//                         container.frame = self.bounds;
//                     }
//                     completion:^(BOOL finished) {
//                         if (!finished) return;
//                     }];
//}

@end
