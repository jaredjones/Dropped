//
//  DRPNetworking.m
//  Dropped
//
//  Created by Brad Zeis on 3/8/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPNetworking.h"

@implementation DRPNetworking

+ (void)generateDeviceIDWithCompletion:(void (^)())completion {
}

#pragma mark Aliases

+ (void)aliasForDeviceID:(NSString *)deviceID withCompletion:(void (^)(NSString *))completion {
}

+ (void)aliasForUserID:(NSString *)userID withCompletion:(void (^)(NSString *))completion {
}

+ (void)setAlias:(NSString *)alias withCompletion:(void (^)(NSString *))completion {
}

#pragma mark Facebook

+ (void)associateFacebook:(NSString *)userID withCompletion:(void (^)())completion {
}

+ (void)disassociateFacebookWithCompletion:(void (^)())completion {
}

+ (void)facebookFriendsWithCompletion:(void (^)(NSArray *))completion {
}

#pragma mark Matches

+ (void)requestMatchWithFriend:(NSString *)userID withCompletion:(void (^)(NSString *, BOOL, NSString *))completion {
}

+ (void)matchData:(NSString *)matchID withCompletion:(void (^)(NSData *))completion {
}

+ (void)submitMatchData:(NSData *)matchData forMatchID:(NSString *)matchID withCompletion:(void (^)())completion {
}

+ (void)concedeMatchID:(NSString *)matchID withCompletion:(void (^)())completion {
}

@end
