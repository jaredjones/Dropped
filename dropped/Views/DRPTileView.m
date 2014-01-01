//
//  DRPTileView.m
//  dropped
//
//  Created by Brad Zeis on 12/10/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPTileView.h"
#import "DRPCharacter.h"
#import "FRBSwatchist.h"
#import "DRPUtility.h"
#import <CoreText/CoreText.h>

@interface DRPTileView ()

@property CAShapeLayer *strokeLayer, *glyphLayer;
@property UIColor *color;

@end

static NSMutableArray *queuedTiles;

static NSMutableDictionary *glyphCache;
static NSMutableDictionary *glyphScaleTransformCache;
static NSMutableDictionary *glyphAdvancesCache;

#pragma mark - DRPTileView

@implementation DRPTileView

- (id)initWithCharacter:(DRPCharacter *)character
{
    self = [super initWithFrame:CGRectMake(0, 0, 50, 50)];
    if (self) {
        [self loadStrokeLayer];
        
        // Make sure to call the setter method, it has side effects
        [self setCharacter:character];
        
        _scaleCharacter = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)loadStrokeLayer
{
    _strokeLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *strokePath = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, 1.5, 1.5)];
    _strokeLayer.path = strokePath.CGPath;
    _strokeLayer.lineWidth = 3;
    _strokeLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor;
    _strokeLayer.strokeColor = [UIColor blackColor].CGColor;
    _strokeLayer.opacity = 0;
    [self.layer addSublayer:_strokeLayer];
}

- (void)loadGlyphLayer
{
    if (!_character) return;
    
    [_glyphLayer removeFromSuperlayer];
    _glyphLayer = [[CAShapeLayer alloc] init];
    _glyphLayer.path = [DRPTileView pathForCharacter:_character.character].CGPath;
    _glyphLayer.fillColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:_glyphLayer];
}

#pragma mark Reusable DRPTileViews

+ (DRPTileView *)dequeueResusableTile
{
    if (!queuedTiles) queuedTiles = [[NSMutableArray alloc] init];
    if (!queuedTiles.count) return [[DRPTileView alloc] initWithCharacter:nil];
    
    DRPTileView *tile = [queuedTiles lastObject];
    tile.scaleCharacter = YES;
    tile.enabled = YES;
    tile.selected = NO;
    tile.highlighted = NO;
    [queuedTiles removeLastObject];
    return tile;
}

+ (void)queueReusableTile:(DRPTileView *)tile
{
    if (!queuedTiles) queuedTiles = [[NSMutableArray alloc] init];
    [queuedTiles addObject:tile];
}

#pragma mark Properties

- (void)setCharacter:(DRPCharacter *)character
{
    _character = character;
    [self loadGlyphLayer];
    
    // Load other stuff
    // if (character.adjacentMultiplier) { ... }
    if (character.adjacentMultiplier) {
        _color = colorForColor(character.adjacentMultiplier.color);
    } else {
        _color = colorForColor(character.color);
    }
    
    if (character.multiplier) {
        self.backgroundColor = _color;
        _glyphLayer.fillColor = [FRBSwatchist colorForKey:@"colors.white"].CGColor;
    }
    
    [self resetTargets];
    [self resetAppearence];
}

- (CGFloat)strokeOpacity
{
    return _strokeLayer.opacity;
}

- (void)setStrokeOpacity:(CGFloat)opacity
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    anim.values = @[@(opacity)];
    self.strokeLayer.opacity = opacity;
    anim.duration = 0;
    [_strokeLayer addAnimation:anim forKey:@"opacity"];
}

#pragma mark Touch Events

- (void)touchDown
{
    [_delegate tileWasHighlighted:self];
    [self resetAppearence];
}

- (void)touchUpInside
{
    if (self.highlighted) {
        self.selected = !self.selected;
    }
    self.highlighted = NO;
    
    if (self.selected) {
        [_delegate tileWasSelected:self];
    } else {
        [_delegate tileWasDeselected:self];
    }
    
    [_delegate tileWasDehighlighted:self];
    
    [self resetAppearence];
}

- (void)touchUpOutside
{
    self.highlighted = NO;
    [_delegate tileWasDehighlighted:self];
    [self resetAppearence];
}

- (void)touchCancel
{
    self.highlighted = NO;
    [_delegate tileWasDehighlighted:self];
    [self resetAppearence];
}

- (void)resetAppearence
{
    // Stroke Opacity
    if (self.highlighted || (self.selected && !_character.multiplier)) {
        self.strokeOpacity = 1;
    } else {
        self.strokeOpacity = 0;
    }
    
    // Color
    if (self.highlighted ||
        (self.selected && (_character.adjacentMultiplier.multiplierActive || (!self.enabled && _character.adjacentMultiplier))) ||
        _character.multiplier) {
        self.backgroundColor = _color;
    } else {
        self.backgroundColor = [FRBSwatchist colorForKey:@"colors.white"];
    }
    
    // Transform
    if (self.highlighted && _scaleCharacter) {
        _glyphLayer.transform = [glyphScaleTransformCache[_character.character] CATransform3DValue];
    } else {
        _glyphLayer.transform = CATransform3DIdentity;
    }
}

// Multipliers shouldn't have any targets
// This method cleanly resets targets between
// different character assignments
- (void)resetTargets
{
    if (_character.multiplier) {
        [self removeTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [self removeTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self removeTarget:self action:@selector(touchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [self removeTarget:self action:@selector(touchCancel) forControlEvents:UIControlEventTouchCancel];
        
    } else if (!([self actionsForTarget:self forControlEvent:UIControlEventTouchDown]).count) {
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(touchCancel) forControlEvents:UIControlEventTouchCancel];
    }
}

#pragma mark Glyph Loading

+ (UIBezierPath *)pathForCharacter:(NSString *)character
{
    // Find correct character first
    if ([character isEqualToString:@"3"]) character = @"three";
    if ([character isEqualToString:@"4"]) character = @"four";
    if ([character isEqualToString:@"5"]) character = @"five";
    
    if (glyphCache[character]) return glyphCache[character];
    
    //// Load Glyph
    // Create a Core Text font reference
    CTFontRef font = CTFontCreateWithName(CFSTR("Rokkitt"), 48, NULL);
    
    // Get the glyph index for a named character in the font
    CFStringRef glyphName = (__bridge CFStringRef)character;
    CGGlyph aGlyph = CTFontGetGlyphWithName(font, glyphName);
    
    // Compute glyph advancement
    CGSize advancement = CGSizeZero;
    const CGGlyph glyphs[] = { aGlyph };
    CTFontGetAdvancesForGlyphs(font, kCTFontOrientationHorizontal, glyphs, &advancement, 1);
    
    // Find a reference to the Core Graphics path for the glyph
    CGPathRef glyphPath = CTFontCreatePathForGlyph(font, aGlyph, NULL);
    
    // Create a bezier path from the CG path (autoreleased)
    UIBezierPath *glyphBezierPath = [UIBezierPath bezierPath];
    [glyphBezierPath moveToPoint:CGPointZero];
    [glyphBezierPath appendPath:[UIBezierPath bezierPathWithCGPath:glyphPath]];
    
    CGPathRelease(glyphPath);
    CFRelease(font);
    
    //// Apply Transforms
    CGRect glyphBounds = glyphBezierPath.bounds;
    
    // Identity transform
    CGAffineTransform flipLetterTransform = CGAffineTransformMakeScale(1, -1);
    [glyphBezierPath applyTransform:flipLetterTransform];
    
    CGPoint offset = [[FRBSwatchist swatchForName:@"tileOffset"] pointForKey:character];
    CGFloat dx = -glyphBounds.origin.x + 25 - glyphBounds.size.width / 2 + offset.x;
    CGFloat dy = -glyphBounds.origin.y + 25 + glyphBounds.size.height / 2 + offset.y;
    CGAffineTransform letterTransform = CGAffineTransformMakeTranslation(dx, dy);
    [glyphBezierPath applyTransform:letterTransform];
    
    // Scale Transform
    offset = [[FRBSwatchist swatchForName:@"tileScalingOffset"] pointForKey:character];
    dx = -glyphBounds.size.width - glyphBounds.origin.x - offset.x;
    dy = -glyphBounds.size.height - glyphBounds.origin.y - offset.y;
    
    CATransform3D scaleTransform = CATransform3DIdentity;
    scaleTransform = CATransform3DTranslate(scaleTransform, -dx, -dy, 0);
    scaleTransform = CATransform3DScale(scaleTransform, .82, .82, 1);
    scaleTransform = CATransform3DTranslate(scaleTransform, dx, dy, 0);
    
    // Cache Path/Transform
    if (!glyphCache) {
        glyphCache = [[NSMutableDictionary alloc] init];
        glyphScaleTransformCache = [[NSMutableDictionary alloc] init];
        glyphAdvancesCache = [[NSMutableDictionary alloc] init];
    }
    glyphCache[character] = glyphBezierPath;
    glyphScaleTransformCache[character] = [NSValue valueWithCATransform3D:scaleTransform];
    glyphAdvancesCache[character] = @(advancement.width);
    
    return glyphBezierPath;
}

+ (CGFloat)advancementForCharacter:(NSString *)character
{
    if (!glyphAdvancesCache[character]) {
        [DRPTileView pathForCharacter:character];
    }
    
    return [glyphAdvancesCache[character] floatValue];
}

@end
