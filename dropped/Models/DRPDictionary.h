//
//  DRPDictionary.h
//  dropped
//
//  Created by Jared Jones on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRPDictionary : NSObject

+ (DRPDictionary *)sharedDictionary;

+ (void)syncDictionary;

+ (NSInteger)getDictionaryVersion;
+ (BOOL)isValidWord:(NSString *)word;
+ (NSInteger)indexPositionForWord:(NSString *)word;
+ (void)testing;

@end
