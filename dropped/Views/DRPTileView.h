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

@property (nonatomic) DRPCharacter *character;
@property (nonatomic) CGFloat strokeOpacity;
@property DRPPosition *position;

@property (nonatomic) BOOL permaHighlighted;
@property (nonatomic) BOOL scaleCharacter;

// TODO: need a perma-highlight option

@property id<DRPTileViewDelegate> delegate;

- (instancetype)initWithCharacter:(DRPCharacter *)character;

+ (DRPTileView *)dequeueResusableTile;
+ (void)queueReusableTile:(DRPTileView *)tile;

- (void)resetAppearence;
+ (CGFloat)advancementForCharacter:(NSString *)character;

@end
