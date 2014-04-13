//
//  DRPTileView.h
//  dropped
//
//  Created by Brad Zeis on 12/10/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRPTileView, DRPCharacter, DRPPosition;

@protocol DRPTileViewDelegate

- (void)tileWasHighlighted:(DRPTileView *)tile;
- (void)tileWasDehighlighted:(DRPTileView *)tile;
- (void)tileWasSelected:(DRPTileView *)tile;
- (void)tileWasDeselected:(DRPTileView *)tile;

@end

@interface DRPTileView : UIControl <NSCopying>

// Modifying changes the glyph displayed in the tile.
// If the character is a multiplier, the tile will
// automatically set its fillColor
@property (nonatomic) DRPCharacter *character;

// When YES, interacting with the tile doesn't change its control
// state (highlighted, selected)
@property BOOL maintainControlState;

// Scales the glyph down when the user interacts with the tile
@property (nonatomic) BOOL scaleCharacter;

// When YES, the fillColor will be clearColor
@property BOOL transparentFill;

// The DRPBoardViewController needs to keep track of the position
// of each tile. This property isn't used for anything else
@property DRPPosition *position;

@property id<DRPTileViewDelegate> delegate;

- (instancetype)initWithCharacter:(DRPCharacter *)character;

+ (DRPTileView *)dequeueResusableTile;
+ (void)queueReusableTile:(DRPTileView *)tile;

- (void)resetAppearence;
+ (CGFloat)advancementForCharacter:(NSString *)character;

@end
