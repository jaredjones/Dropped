//
//  DRPTileView.h
//  dropped
//
//  Created by Brad Zeis on 12/10/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRPCharacter;

@interface DRPTileView : UIControl

- (instancetype)initWithCharacter:(DRPCharacter *)character;

@property (nonatomic) DRPCharacter *character;
@property (nonatomic) CGFloat strokeOpacity;

@end
