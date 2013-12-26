//
//  DRPTileView.h
//  dropped
//
//  Created by Brad Zeis on 12/10/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPBoardViewController.h"

@class DRPCharacter, DRPPosition;

@interface DRPTileView : UIControl <NSCopying>

- (instancetype)initWithCharacter:(DRPCharacter *)character;

@property (nonatomic) DRPCharacter *character;
@property (nonatomic) CGFloat strokeOpacity;
@property DRPPosition *position;

@property id<DRPTileDelegate> delegate;

- (void)resetAppearence;

+ (CGFloat)advancementForCharacter:(NSString *)character;

@end
