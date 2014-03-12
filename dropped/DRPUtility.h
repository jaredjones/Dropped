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
CGPoint rectCenter(CGRect rect);
NSString *firstPrintableCharacter(NSString *alias);
NSString *generateUUID();

id coerceObject(id argument, id (^block)(id));

// TODO: this function sucks
CGFloat labelOffset(UIFont *font, CGFloat height);
