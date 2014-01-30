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

@property (nonatomic) DRPContainerType currentContainerType;
@property UIView *currentContainer;
@property NSMutableDictionary *containerCache;

@property NSString *turnsLeftString;

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
    
    _containerCache = [[NSMutableDictionary alloc] init];
    _containerCache[@(DRPContainerTypeCurrentWord)] = [[NSMutableArray alloc] init];
    _containerCache[@(DRPContainerTypeTurnsLeft)] = [[NSMutableArray alloc] init];
}

#pragma mark Layout

- (void)layoutWithFrame:(CGRect)frame
{
    self.view.frame = frame;
    
    self.currentContainer.frame = self.currentFrame;
}

// Container frames
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

// Convenience methods for calculating start/end frames for containers
- (CGRect)frameFromDirection:(DRPDirection)direction
{
    
    if (direction == DRPDirectionLeft) {
        return self.leftFrame;
    }
    return self.rightFrame;
}

- (CGRect)frameToDirection:(DRPDirection)direction
{
    if (direction == DRPDirectionLeft) {
        return self.rightFrame;
    }
    return self.leftFrame;
}

#pragma mark Containers

- (DRPContainerType)containerTypeOfContainer:(UIView *)container
{
    if ([container isKindOfClass:[DRPCurrentWordView class]]) {
        return DRPContainerTypeCurrentWord;
    }
    return DRPContainerTypeTurnsLeft;
}

- (UIView *)dequeueContainerWithType:(DRPContainerType)containerType
{
    UIView *container;
    
    if (((NSArray *)_containerCache[@(containerType)]).count) {
        // Check caches first
        container = ((NSMutableArray *)_containerCache[@(containerType)]).lastObject;
        [((NSMutableArray *)_containerCache[@(containerType)]) removeLastObject];
        
    } else if (containerType == DRPContainerTypeTurnsLeft) {
        container = [[UILabel alloc] initWithFrame:self.currentFrame];
        
        // TODO: UILabel properties
        
        ((UILabel *)container).text = _turnsLeftString;
        container.backgroundColor = [UIColor greenColor];
        
    } else if (containerType == DRPContainerTypeCurrentWord) {
        container = [[DRPCurrentWordView alloc] initWithFrame:self.currentFrame];
        container.backgroundColor = [UIColor orangeColor];
    }
    
    if (container) {
        if (container.superview != self.view) {
            [self.view addSubview:container];
        }
        [self.view bringSubviewToFront:container];
    }
    
    return container;
}

// Implicitly runs animations between containers
- (void)setCurrentContainerType:(DRPContainerType)containerType fromDirection:(DRPDirection)direction
{
    if (containerType == _currentContainerType) return;
    
    _currentContainerType = containerType;
    
    _currentContainer = [self dequeueContainerWithType:containerType];
    [self.view bringSubviewToFront:_currentContainer];
    
    // TODO: run animation
}

#pragma mark Setting Content

- (void)characterWasHighlighted:(DRPCharacter *)character fromDirection:(DRPDirection)direction
{
    if (_currentContainerType != DRPContainerTypeCurrentWord) {
        [self setCurrentContainerType:DRPContainerTypeCurrentWord fromDirection:direction];
    }
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
    [self setCurrentContainerType:DRPContainerTypeCurrentWord fromDirection:direction];
    // TODO: set the characters of the container
}

- (void)setTurnsLeft:(NSInteger)turnsLeft isLocalTurn:(BOOL)isLocalTurn fromDirection:(DRPDirection)direction
{
    _turnsLeftString = [NSString stringWithFormat:@"%ld turns left", (long)turnsLeft];
    [self setCurrentContainerType:DRPContainerTypeTurnsLeft fromDirection:direction];
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
