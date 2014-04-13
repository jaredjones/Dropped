//
//  DRPMenuCollectionViewCell.m
//  dropped
//
//  Created by Brad Zeis on 2/6/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMenuCollectionViewCell.h"
#import "DRPTileView.h"
#import "FRBSwatchist.h"
#import "DRPUtility.h"

@interface DRPMenuCollectionViewCell ()

@property DRPTileView *tile;
@property UILabel *label;

@end

@implementation DRPMenuCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tile = [[DRPTileView alloc] initWithCharacter:nil];
        self.tile.frame = self.tileFrame;
        self.tile.enabled = NO;
        self.tile.highlighted = YES;
        self.tile.scaleCharacter = NO;
        [self.contentView addSubview:self.tile];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.font = [FRBSwatchist fontForKey:@"page.cueEmphasizedFont"];
        self.label.textColor = [FRBSwatchist colorForKey:@"colors.black"];
        self.label.frame = self.labelFrame;
        [self.contentView addSubview:self.label];
    }
    return self;
}

// Data is an NSDictionary: { "color" : DRPColor, "text" : NSString }
- (void)configureWithUserData:(NSDictionary *)userData
{
    DRPCharacter *character = [DRPCharacter characterWithCharacter:[(NSString *)userData[@"text"] substringToIndex:1]];
    character.color = [userData[@"color"] intValue];
    
    self.tile.character = character;
    self.label.text = userData[@"text"];
}

#pragma mark Layout

- (CGRect)tileFrame
{
    CGRect frame = CGRectZero;
    frame.origin.x = [FRBSwatchist floatForKey:@"board.tileMargin"] + [FRBSwatchist floatForKey:@"board.tileLength"] / 2;
    frame.size.width = [FRBSwatchist floatForKey:@"board.tileLength"];
    frame.size.height = [FRBSwatchist floatForKey:@"board.tileLength"];
    return frame;
}

- (CGRect)labelFrame
{
    // TODO: label not centered correctly
    return CGRectMake([FRBSwatchist floatForKey:@"list.textOffsetX"],
                      labelOffset(self.label.font, [FRBSwatchist floatForKey:@"board.tileLength"] / 2),
                      self.contentView.bounds.size.width - [FRBSwatchist floatForKey:@"list.textOffsetX"],
                      [FRBSwatchist floatForKey:@"board.tileLength"]);
}

@end
