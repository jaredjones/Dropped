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
        self.gesturesEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.containerCache = [[NSMutableDictionary alloc] init];
    self.containerCache[@(DRPContainerTypeCurrentWord)] = [[NSMutableArray alloc] init];
    self.containerCache[@(DRPContainerTypeTurnsLeft)] = [[NSMutableArray alloc] init];
}

#pragma mark Layout

- (void)layoutWithFrame:(CGRect)frame
{
    self.view.frame = frame;
    
    // There are two different methods for relayouting out the
    // currentContainer depending on the containerType.
    // No clue why, but these methods "just work"
    if (self.currentContainerType == DRPContainerTypeCurrentWord) {
        self.currentContainer.frame = self.currentFrame;
        [(DRPCurrentWordView *)self.currentContainer repositionTilesAnimated:YES];
        
    } else if (self.currentContainerType == DRPContainerTypeTurnsLeft) {
        self.currentContainer.center = rectCenter(self.view.bounds);
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
    
    if (((NSArray *)self.containerCache[@(containerType)]).count) {
        // Check caches first
        container = ((NSMutableArray *)self.containerCache[@(containerType)]).lastObject;
        [((NSMutableArray *)self.containerCache[@(containerType)]) removeLastObject];
        
    } else if (containerType == DRPContainerTypeTurnsLeft) {
        container = [[UILabel alloc] initWithFrame:self.currentFrame];
        
        ((UILabel *)container).font = [FRBSwatchist fontForKey:@"board.tileFont"];
        ((UILabel *)container).textColor = [FRBSwatchist colorForKey:@"colors.black"];
        ((UILabel *)container).textAlignment = NSTextAlignmentCenter;
        
    } else if (containerType == DRPContainerTypeCurrentWord) {
        container = [[DRPCurrentWordView alloc] initWithFrame:self.currentFrame];
        ((DRPCurrentWordView *)container).delegate = self;
    }
    
    if (container) {
        // Some properties need to be refreshed if pulled from cache
        if (containerType == DRPContainerTypeTurnsLeft) {
            ((UILabel *)container).text = self.turnsLeftString;
        } else if (containerType == DRPContainerTypeCurrentWord) {
            ((DRPCurrentWordView *)container).gesturesEnabled = self.gesturesEnabled;
        }
        
        if (container.superview != self.view) {
            [self.view addSubview:container];
        }
        [self.view bringSubviewToFront:container];
    }
    
    return container;
}

- (void)enqueueContainer:(UIView *)container withType:(DRPContainerType)containerType
{
    if (!container) return;
    [(NSMutableArray *)self.containerCache[@(containerType)] addObject:container];
    
    // Clear tiles out of old DRPCurrentWordViews
    if (containerType == DRPContainerTypeCurrentWord) {
        [(DRPCurrentWordView *)container removeAllCharacters];
    }
}

// Implicitly runs animations between containers
- (void)setCurrentContainerType:(DRPContainerType)containerType
{
    [self setCurrentContainerType:containerType fromDirection:DRPDirectionLeft];
}

- (void)setCurrentContainerType:(DRPContainerType)containerType fromDirection:(DRPDirection)direction
{
    [self setCurrentContainerType:containerType fromDirection:direction withVelocity:0];
}

- (void)setCurrentContainerType:(DRPContainerType)containerType fromDirection:(DRPDirection)direction withVelocity:(CGFloat)velocity
{
    if (self.currentContainer && containerType == self.currentContainerType) {
        if (self.currentContainerType == DRPContainerTypeTurnsLeft) {
            ((UILabel *)self.currentContainer).text = self.turnsLeftString;
            return;
        }
    };
    
    DRPContainerType prevContainerType = self.currentContainerType;
    _currentContainerType = containerType;
    
    UIView *prevContainer = self.currentContainer;
    self.currentContainer = [self dequeueContainerWithType:containerType];
    [self.view bringSubviewToFront:self.currentContainer];
    
    // TODO: fix that velocity
    [self animateOutContainer:prevContainer ofType:prevContainerType inDirection:direction withVelocity:velocity];
    [self animateInContainer:self.currentContainer ofType:self.currentContainerType inDirection:direction withVelocity:velocity];
}

#pragma mark Setting Content

- (void)characterWasHighlighted:(DRPCharacter *)character fromDirection:(DRPDirection)direction
{
    if (self.currentContainerType != DRPContainerTypeCurrentWord) {
        [self setCurrentContainerType:DRPContainerTypeCurrentWord fromDirection:direction];
    }
    [(DRPCurrentWordView *)self.currentContainer characterWasHighlighted:character];
}

- (void)characterWasDehighlighted:(DRPCharacter *)character
{
    [(DRPCurrentWordView *)self.currentContainer characterWasDehighlighted:character];
}

- (void)characterWasRemoved:(DRPCharacter *)character fromDirection:(DRPDirection)direction
{
    [(DRPCurrentWordView *)self.currentContainer characterWasRemoved:character];
}

- (void)setCharacters:(NSArray *)characters fromDirection:(DRPDirection)direction
{
    // If the characters are already set, do nothing
    if (self.currentContainerType == DRPContainerTypeCurrentWord &&
        [(DRPCurrentWordView *)self.currentContainer currentCharactersEqualCharacters:characters]) {
        return;
    }
    
    [self setCurrentContainerType:DRPContainerTypeCurrentWord fromDirection:direction];
    [(DRPCurrentWordView *)self.currentContainer setCharacters:characters];
}

- (void)setTurnsLeft:(NSInteger)turnsLeft isLocalTurn:(BOOL)isLocalTurn fromDirection:(DRPDirection)direction
{
    if (turnsLeft > 0) {
        if (isLocalTurn) {
            self.turnsLeftString = [NSString stringWithFormat:@"%ld Turn%@ Left", (long)turnsLeft, turnsLeft != 1 ? @"s" : @""];
        } else {
            self.turnsLeftString = @"Waiting for Turn";
        }
    } else {
        self.turnsLeftString = @"Game Over";
    }
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
    [self animateInContainer:container ofType:containerType withVelocity:velocity];
}

- (void)animateInContainer:(UIView *)container ofType:(DRPContainerType)containerType withVelocity:(CGFloat)velocity
{
    CGRect destFrame = self.currentFrame;
    container.hidden = NO;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:velocity * 0.001 options:0 animations:^{
        container.frame = destFrame;
    } completion:^(BOOL finished) {
        if (self.currentContainer == container) {
            // Just make sure the container ended up where intended (for rotations during animation)
            container.frame = self.currentFrame;
        }
    }];
}

#pragma mark DRPCurrentWordView

- (void)setGesturesEnabled:(BOOL)gesturesEnabled
{
    _gesturesEnabled = gesturesEnabled;
    
    if (self.currentContainerType == DRPContainerTypeCurrentWord) {
        ((DRPCurrentWordView *)self.currentContainer).gesturesEnabled = gesturesEnabled;
    }
}

- (void)currentWordWasTapped
{
    [self.delegate currentWordWasTapped];
}

- (void)currentWordWasSwipedWithVelocity:(CGFloat)velocity
{
    [self.delegate currentWordWasSwiped];
    
    DRPDirection direction = DRPDirectionLeft;
    if (velocity < 0) {
        direction = DRPDirectionRight;
    } else if (velocity > 0) {
        direction = DRPDirectionLeft;
    }
    [self setCurrentContainerType:DRPContainerTypeTurnsLeft fromDirection:direction withVelocity:fabs(velocity)];
}

- (void)currentWordSwipeFailedWithVelocity:(CGFloat)velocity
{
    [self animateInContainer:self.currentContainer ofType:self.currentContainerType withVelocity:fabs(velocity)];
}

@end
