//
//  DRPMatchCollectionViewCell.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPMatchCollectionViewCell.h"
#import "DRPMatch.h"
#import "FRBSwatchist.h"

@implementation DRPMatchCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _label.font = [FRBSwatchist fontForKey:@"page.cueFont"];
        _label.textColor = [FRBSwatchist colorForKey:@"colors.black"];
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)configureWithDRPMatch:(DRPMatch *)match
{
    _label.text = match.matchID;
}

@end
