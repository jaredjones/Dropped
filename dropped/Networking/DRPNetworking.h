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
    DRPNetworkingDeviceIDPairValidation = 1,
    DRPNetworkingGetAlias = 2,
    DRPNetworkingSetAlias = 3,
    DRPNetworkingSetAPNSToken = 4,
    DRPNetworkingGetMatchIDs = 11,
    DRPNetworkingRequestMatch = 12,
    DRPNetworkingGetMatchData = 13,
    DRPNetworkingSubmitMatchTurn = 14,
    DRPNetworkingConcedeMatch = 15
};

#pragma mark 

#define DRPReceivedMatchTurnNotificationName @"DRPReceivedMatchTurnNotification"

@interface DRPNetworking : NSObject

@property (readonly) NSString *deviceID, *userID, *localAlias;

+ (instancetype)sharedNetworking;

- (void)fetchDeviceIDWithCompletion:(void (^)(BOOL))completion;
- (void)setAPNSToken:(NSString *)APNSToken withCompletion:(void (^)())completion;

- (void)aliasWithCompletion:(void (^)(NSString *))completion;
- (void)aliasForDeviceID:(NSString *)deviceID withUserID:(NSString *)userID withCompletion:(void (^)(NSString *))completion;
- (void)setAlias:(NSString *)alias forDeviceID:(NSString *)deviceID userID:(NSString *)userID withCompletion:(void (^)(NSString *))completion;

- (void)associateFacebook:(NSString *)userID withCompletion:(void (^)())completion;
- (void)disassociateFacebookWithCompletion:(void (^)())completion;
- (void)facebookFriendsWithCompletion:(void (^)(NSArray *))completion;

- (void)currentMatchIDsWithCompletion:(void (^)(NSArray *))completion;
- (void)requestMatchWithFriend:(NSString *)userID withCompletion:(void (^)(NSString *, NSInteger))completion;
- (void)matchDataForMatchID:(NSString *)matchID withCompletion:(void (^)(NSData *, NSInteger, NSString *))completion;

- (void)submitMatchData:(NSData *)matchData forMatchID:(NSString *)matchID advanceTurn:(BOOL)advanceTurn withCompletion:(void (^)())completion;
- (void)concedeMatchID:(NSString *)matchID withCompletion:(void (^)())completion;

@end
