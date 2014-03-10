//
//  DRPNetworking.m
//  Dropped
//
//  Created by Brad Zeis on 3/8/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPNetworking.h"
#import "FBSession.h"

@interface DRPNetworking ()

@property NSString *deviceID;
@property NSString *userID;

@property NSString *cachedAlias;

// Social
@property FBSession *fbSession;

@end

@implementation DRPNetworking

// TODO: send APNS token to server

+ (instancetype)sharedNetworking
{
    static DRPNetworking *sharedNetworking;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetworking = [[DRPNetworking alloc] init];
    });
    
    return sharedNetworking;
}

- (void)networkRequestOpcode:(NSInteger)opCode arguments:(NSDictionary *)json withCompletion:(void (^)(NSDictionary *, NSError *))completion
{
    NSString *serverURL = @"http://chaos.uvora.com/dropped/process.php";
    NSURL *requestURL = [NSURL URLWithString:[NSString localizedStringWithFormat:@"%@?o=%ld", serverURL, (long)opCode]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPMethod = @"POST";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    // Serialize NSURLRequest body (JSON)
    // Automatically adds deviceID and userID
    NSMutableDictionary *requestBody = [json mutableCopy];
    requestBody[@"deviceID"] = self.deviceID ?: @"";
    requestBody[@"userID"] = self.userID ?: @"";
    
    // TODO: store with deviceID pass
    NSString *pass = [NSString stringWithFormat:@"%ld", (long)arc4random()];
    requestBody[@"pass"] = pass;
    
    NSError *error;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&error];
    NSLog(@"Request body: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    
    // Be free, little packets
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (error) {
            completion(nil, connectionError);
        } else if (data) {
            
            NSLog(@"Recieved data: %@", data);
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError];
            completion(responseBody, error);
        }
    }];
}

#pragma mark DeviceID

+ (void)fetchDeviceIDWithCompletion:(void (^)())completion {
    
    // Attempt to read cached deviceID (only if not already loaded)
    if (![DRPNetworking sharedNetworking].deviceID) {
        NSURL *deviceURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                                   inDomains:NSUserDomainMask][0] URLByAppendingPathComponent:@"device.plist"];
        [DRPNetworking sharedNetworking].deviceID = [NSDictionary dictionaryWithContentsOfURL:deviceURL][@"deviceID"];
    }
    
    if ([DRPNetworking sharedNetworking].deviceID) {
        // Already have a cached deviceID
        completion();
        
    } else  {
        // Don't have a deviceID locally, generate one
        [[DRPNetworking sharedNetworking] networkRequestOpcode:DRPNetworkingOpCodeGenerateDeviceID
                                                     arguments:@{}
                                                withCompletion:^(NSDictionary *response, NSError *error) {
                                                    // TODO: cache generated deviceID
                                                    
                                                    NSLog(@"Generated deviceID: %@", response[@"deviceID"]);
                                                    completion();
        }];
    }
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
