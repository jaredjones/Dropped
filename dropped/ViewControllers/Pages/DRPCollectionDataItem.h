//
//  DRPCollectionDataItem.h
//  Dropped
//
//  Created by Brad Zeis on 2/13/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRPCollectionDataItem : NSObject

@property NSString *itemID, *cellIdentifier;
@property id userData;
@property (copy) void (^selected)(id userData);

@end
