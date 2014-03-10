//
//  DRPNetworking.h
//  Dropped
//
//  Created by Brad Zeis on 3/8/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DRPNetworkingOpCode) {
    DRPNetworkingGenerateDeviceID = 0,
    DRPNetworkingDeviceIDPairValidation = 6
};

@interface DRPNetworking : NSObject

@property (readonly) NSString *deviceID, *userID;

+ (instancetype)sharedNetworking;

- (void)fetchDeviceIDWithCompletion:(void (^)(BOOL))completion;

- (void)aliasForDeviceID:(NSString *)deviceID withCompletion:(void (^)(NSString *))completion;
- (void)aliasForUserID:(NSString *)userID withCompletion:(void (^)(NSString *))completion;

- (void)setAlias:(NSString *)alias withCompletion:(void (^)(NSString *))completion;

- (void)associateFacebook:(NSString *)userID withCompletion:(void (^)())completion;
- (void)disassociateFacebookWithCompletion:(void (^)())completion;
- (void)facebookFriendsWithCompletion:(void (^)(NSArray *))completion;

- (void)currentMatchIDsWithCompletion:(void (^)(NSArray *))completion;
- (void)requestMatchWithFriend:(NSString *)userID withCompletion:(void (^)(NSString *, BOOL, NSString *))completion;
- (void)matchDataForMatchID:(NSString *)matchID withCompletion:(void (^)(NSData *, NSInteger, NSString *))completion;

- (void)submitMatchData:(NSData *)matchData forMatchID:(NSString *)matchID advanceTurn:(BOOL)advanceTurn withCompletion:(void (^)())completion;
- (void)concedeMatchID:(NSString *)matchID withCompletion:(void (^)())completion;

@end
