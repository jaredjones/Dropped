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
@property DRPColor color;

@end

static NSMutableArray *queuedTiles;

static NSMutableDictionary *glyphCache;
static NSMutableDictionary *glyphScaleTransformCache;
static NSMutableDictionary *glyphAdvancesCache;

#pragma mark - DRPTileView

@implementation DRPTileView

- (id)initWithCharacter:(DRPCharacter *)character
{
    self = [super initWithFrame:({
        CGFloat l = [FRBSwatchist floatForKey:@"board.tileLength"];
        CGRectMake(0, 0, l, l);
    })];
    if (self) {
        [self loadStrokeLayer];
        self.character = character;
        self.scaleCharacter = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)loadStrokeLayer
{
    self.strokeLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *strokePath = ({
        CGFloat strokeWidth = [FRBSwatchist floatForKey:@"board.tileStrokeWidth"];
        [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, strokeWidth / 2, strokeWidth / 2)
                                   cornerRadius:[FRBSwatchist floatForKey:@"board.tileCornerRadius"]];
    });
    self.strokeLayer.path = strokePath.CGPath;
    self.strokeLayer.lineWidth = [FRBSwatchist floatForKey:@"board.tileStrokeWidth"];
    self.strokeLayer.fillColor = [UIColor clearColor].CGColor;
    self.strokeLayer.strokeColor = [FRBSwatchist colorForKey:@"colors.black"].CGColor;
    [self.layer addSublayer:self.strokeLayer];
}

- (void)loadGlyphLayer
{
    [self.glyphLayer removeFromSuperlayer];
    
    // Hide glyphLayer if character is nil
    if (!self.character || !self.character.character) return;
    
    self.glyphLayer = [[CAShapeLayer alloc] init];
    self.glyphLayer.path = [DRPTileView pathForCharacter:self.character.character].CGPath;
    self.glyphLayer.fillColor = [FRBSwatchist colorForKey:@"colors.black"].CGColor;
    [self.layer addSublayer:self.glyphLayer];
}

#pragma mark Reusable DRPTileViews

+ (DRPTileView *)dequeueResusableTile
{
    if (!queuedTiles) queuedTiles = [[NSMutableArray alloc] init];
    if (!queuedTiles.count) return [[DRPTileView alloc] initWithCharacter:nil];
    
    DRPTileView *tile = [queuedTiles lastObject];
    tile.enabled = YES;
    tile.selected = NO;
    tile.highlighted = NO;
    
    tile.transform = CGAffineTransformIdentity;
    tile.center = CGPointZero;
    
    tile.userInteractionEnabled = YES;
    tile.scaleCharacter = YES;
    tile.maintainControlState = NO;
    
    tile.position = nil;
    
    [queuedTiles removeLastObject];
    return tile;
}

+ (void)queueReusableTile:(DRPTileView *)tile
{
    if (!queuedTiles) queuedTiles = [[NSMutableArray alloc] init];
    [queuedTiles addObject:tile];
    [tile removeFromSuperview];
}

#pragma mark Properties

- (void)setCharacter:(DRPCharacter *)character
{
    _character = character;
    [self loadGlyphLayer];
    
    [self resetAppearence];
}

- (void)recalculateColor
{
    DRPColor colorCode = DRPColorNil;
    if (self.character.adjacentMultiplier) {
        colorCode = self.character.adjacentMultiplier.color;
    } else if (self.character) {
        colorCode = self.character.color;
    }
    
    self.color = colorCode;
}

- (BOOL)hasWhiteBackground
{
    return self.color == DRPColorNil;
}

// These methods are for setting properties of the layers without the implicit animations
- (void)setStrokeColor:(UIColor *)color
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    anim.values = @[(id)color.CGColor];
    self.strokeLayer.strokeColor = color.CGColor;
    anim.duration = 0;
    [self.strokeLayer addAnimation:anim forKey:@"strokeColor"];
}

- (void)setFillColor:(UIColor *)color
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    anim.values = @[(id)color.CGColor];
    self.strokeLayer.fillColor = color.CGColor;
    anim.duration = 0;
    [self.strokeLayer addAnimation:anim forKey:@"fillColor"];
}

- (void)setGlyphColor:(UIColor *)color
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    anim.values = @[(id)color.CGColor];
    self.glyphLayer.fillColor = color.CGColor;
    anim.duration = 0;
    [self.glyphLayer addAnimation:anim forKey:@"fillColor"];
}

#pragma mark Touch Events

- (void)touchEvent:(void (^)())eventBlock beganTouch:(BOOL)beganTouch {
    
    if (!self.enabled) {
        return;
    }
    
    // Store current state in case it needs to be reverted
    // because maintainControlState is set
    BOOL wasHighlighted = self.highlighted;
    BOOL wasSelected = self.selected;
    
    eventBlock();
    
    // Run delegate methods
    if (self.highlighted) {
        [self.delegate tileWasHighlighted:self];
        
    } else if (wasHighlighted && !self.highlighted) {
        [self.delegate tileWasDehighlighted:self];
    }
    
    if (!wasSelected && self.selected) {
        [self.delegate tileWasSelected:self];
        
    } else if (wasSelected && !self.selected) {
        [self.delegate tileWasDeselected:self];
    }
    
    
    [self resetAppearence];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchEvent:^{
        self.highlighted = YES;
    } beganTouch:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.bounds, location)) {
        // Touch up inside
        [self touchEvent:^{
            if (self.highlighted) {
                self.selected = !self.selected;
            }
            self.highlighted = NO;
        } beganTouch:NO];
        
    } else {
        // Touch up outside
        [self touchEvent:^{
            self.highlighted = NO;
        } beganTouch:NO];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchEvent:^{
        self.highlighted = NO;
    } beganTouch:NO];
}

- (void)resetAppearence
{
    [self recalculateColor];
    
    // Stroke Color
    [self setStrokeColor:({
        UIColor *color;
        
        if (self.transparentFill) {
            color = [UIColor clearColor];
        } else if (self.highlighted || (self.selected && !self.character.multiplier)) {
            color = [FRBSwatchist colorForKey:@"colors.black"];
        } else if (self.character.multiplier) {
            color = colorForDRPColor(self.color);
        } else {
            color = [UIColor clearColor];
        }
        
        color;
    })];
    
    // Fill color
    if (self.highlighted ||
        (self.selected && self.character.adjacentMultiplier.multiplierActive) ||
        self.character.multiplier) {
        
        [self setFillColor:colorForDRPColor(self.color)];
        
        // glyphColor is always white when the fillColor isn't white
        if (!self.hasWhiteBackground) {
            self.glyphColor = [FRBSwatchist colorForKey:@"colors.white"];
        }
        
    } else {
        [self setFillColor:[FRBSwatchist colorForKey:@"colors.white"]];
        self.glyphColor = [FRBSwatchist colorForKey:@"colors.black"];
    }
    
    // Transform
    if (self.highlighted && self.scaleCharacter) {
        self.glyphLayer.transform = [glyphScaleTransformCache[self.character.character] CATransform3DValue];
    } else {
        self.glyphLayer.transform = CATransform3DIdentity;
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
    UIFont *tileFont = [FRBSwatchist fontForKey:@"board.tileFont"];
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)tileFont.fontName, tileFont.pointSize, NULL);
    
    // Get the glyph index for a named character in the font
    CFStringRef glyphName = (__bridge CFStringRef)character;
    CGGlyph aGlyph = CTFontGetGlyphWithName(font, glyphName);
    
    // TODO: this is a horrible, terrible hack. Should be punishable by death
    // Can't figure out the glyphName for hash programmatically, but I did manage to guess it correctly
    if ([character isEqualToString:@"hash"]) {
        aGlyph = 9;
    }
    
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
    CGFloat hw = [FRBSwatchist floatForKey:@"board.tileLength"] / 2;
    CGFloat dx = -glyphBounds.origin.x + hw - glyphBounds.size.width / 2 + offset.x;
    CGFloat dy = -glyphBounds.origin.y + hw + glyphBounds.size.height / 2 + offset.y;
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
