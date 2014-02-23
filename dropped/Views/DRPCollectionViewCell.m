//
//  DRPCollectionViewCell.m
//  Dropped
//
//  Created by Brad Zeis on 2/13/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPCollectionViewCell.h"
#import "FRBSwatchist.h"

@implementation DRPCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [FRBSwatchist colorForKey:@"colors.white"];
    }
    return self;
}

- (void)configureWithUserData:(id)userData
{
}

@end
