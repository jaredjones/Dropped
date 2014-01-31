//
//  DRPMatchCurrentWordViewController.m
//  dropped
//
//  Created by Brad Zeis on 1/30/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMatchCurrentWordViewController.h"
#import "DRPCurrentWordView.h"
#import "FRBSwatchist.h"
#import "DRPUtility.h"

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
    
    _containerCache = [[NSMutableDictionary alloc] init];
    _containerCache[@(DRPContainerTypeCurrentWord)] = [[NSMutableArray alloc] init];
    _containerCache[@(DRPContainerTypeTurnsLeft)] = [[NSMutableArray alloc] init];
}

#pragma mark Layout

- (void)layoutWithFrame:(CGRect)frame
{
    self.view.frame = frame;
    
    // There are two different methods for relayouting out the
    // currentContainer depending on the containerType.
    // No clue why, but these methods "just work"
    if (_currentContainerType == DRPContainerTypeCurrentWord) {
        self.currentContainer.frame = self.currentFrame;
        [(DRPCurrentWordView *)_currentContainer repositionTiles];
        
    } else if (_currentContainerType == DRPContainerTypeTurnsLeft) {
        _currentContainer.center = rectCenter(self.view.bounds);
    }
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
        
        ((UILabel *)container).font = [FRBSwatchist fontForKey:@"board.tileFont"];
        ((UILabel *)container).textColor = [FRBSwatchist colorForKey:@"colors.black"];
        ((UILabel *)container).textAlignment = NSTextAlignmentCenter;
        
        ((UILabel *)container).text = _turnsLeftString;
        
    } else if (containerType == DRPContainerTypeCurrentWord) {
        container = [[DRPCurrentWordView alloc] initWithFrame:self.currentFrame];
    }
    
    if (container) {
        if (container.superview != self.view) {
            [self.view addSubview:container];
        }
        [self.view bringSubviewToFront:container];
    }
    
    return container;
}

- (void)enqueueContainer:(UIView *)container withType:(DRPContainerType)containerType
{
    [(NSMutableArray *)_containerCache[@(containerType)] addObject:container];
}

// Implicitly runs animations between containers
- (void)setCurrentContainerType:(DRPContainerType)containerType fromDirection:(DRPDirection)direction
{
    if (containerType == _currentContainerType) return;
    
    DRPContainerType prevContainerType = _currentContainerType;
    _currentContainerType = containerType;
    
    UIView *prevContainer = _currentContainer;
    _currentContainer = [self dequeueContainerWithType:containerType];
    [self.view bringSubviewToFront:_currentContainer];
    
    // TODO: fix that velocity
    [self animateOutContainer:prevContainer ofType:prevContainerType inDirection:direction withVelocity:0];
    [self animateInContainer:_currentContainer ofType:_currentContainerType inDirection:direction withVelocity:0];
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

- (void)animateOutContainer:(UIView *)container ofType:(DRPContainerType)containerType inDirection:(DRPDirection)direction withVelocity:(CGFloat)velocity
{
    CGRect destFrame = [self frameToDirection:direction];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:velocity * .05 options:0 animations:^{
        container.frame = destFrame;
    } completion:^(BOOL finished) {
        container.hidden = YES;
        
        [self enqueueContainer:container withType:containerType];
    }];
}

- (void)animateInContainer:(UIView *)container ofType:(DRPContainerType)containerType inDirection:(DRPDirection)direction withVelocity:(CGFloat)velocity
{
    container.frame = [self frameFromDirection:direction];
    CGRect destFrame = self.currentFrame;
    
    container.hidden = NO;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:velocity * 0.001 options:0 animations:^{
        container.frame = destFrame;
    } completion:^(BOOL finished) {
        if (_currentContainer != container) {
            // TODO: animate out, yo
            
        } else {
            // Just make sure the container ended up where intended (for rotations during animation)
            container.frame = self.currentFrame;
        }
    }];
}

@end
