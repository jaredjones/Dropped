//
//  DRPUtility.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPCharacter.h"

UIColor *colorForColor(DRPColor color);
BOOL runningPhone5();
CGFloat labelOffset(UIFont *font, CGFloat height);
CGPoint rectCenter(CGRect rect);
NSString *firstPrintableCharacter(NSString *alias);
