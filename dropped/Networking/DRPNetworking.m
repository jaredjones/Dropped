//
//  DRPNetworking.m
//  Dropped
//
//  Created by Brad Zeis on 3/8/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPNetworking.h"
#import "FRBSwatchist.h"
#import "DRPUtility.h"

#import "FBSession.h"

@interface DRPNetworking ()

@property NSString *pass;
@property NSString *deviceID;
@property NSString *userID;

@property NSString *cachedAlias;
@property NSURL *deviceURL;

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
        sharedNetworking.deviceURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                                             inDomains:NSUserDomainMask][0] URLByAppendingPathComponent:@"device.plist"];
    });
    
    return sharedNetworking;
}

- (void)networkRequestOpcode:(NSInteger)opCode arguments:(NSDictionary *)json withCompletion:(void (^)(NSDictionary *, NSError *))completion
{
    NSString *serverURL = @"http://chaos.uvora.com/dropped/process.php";
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?o=%ld", serverURL, (long)opCode]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPMethod = @"POST";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    // Serialize NSURLRequest body (JSON)
    // Automatically adds deviceID and userID
    NSMutableDictionary *requestBody = [json mutableCopy];
    requestBody[@"deviceID"] = self.deviceID ?: @"";
    requestBody[@"userID"] = self.userID ?: @"";
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    
    // Be free, little packets
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   completion(nil, connectionError);
                                   
                               } else if (data) {
                                   NSError *error;
                                   NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   completion(responseBody, error);
                               }
    }];
}

#pragma mark DeviceID

- (void)fetchDeviceIDWithCompletion:(void (^)())completion {
    
    // Attempt to read cached deviceID (only if not already loaded)
    if ([FRBSwatchist boolForKey:@"debug.purgeDeviceID"]) {
        [self purgeDeviceIDPair];
    } if (!self.deviceID) {
        [self loadSavedDeviceIDPair];
    }
    
    if (self.deviceID) {
        // Already have a saved deviceID
        // Generate a new deviceID/pass pair if the saved pair is invalid
        [self validateDeviceIDPairWithCompletion:^(BOOL valid) {
            if (!valid) {
                [self purgeDeviceIDPair];
                [self fetchDeviceIDWithCompletion:completion];
                
            } else {
                NSLog(@"Loaded deviceID: %@", [DRPNetworking sharedNetworking].deviceID);
                completion();
            }
        }];
        
    } else  {
        // Device didn't load deviceID, generate a new one on the server
        // Pass is generated locally
        self.pass = generateUUID();
        
        // Don't have a deviceID locally, let the server generate one
        [self networkRequestOpcode:DRPNetworkingGenerateDeviceID
                         arguments:@{@"pass" : self.pass}
                    withCompletion:^(NSDictionary *response, NSError *error) {
                        self.deviceID = response[@"deviceID"];
                        [self saveDeviceIDPair];
                        
                        NSLog(@"Generated new deviceID: %@", self.deviceID);
                        completion();
        }];
    }
}

- (void)validateDeviceIDPairWithCompletion:(void (^)(BOOL))completion
{
    [[DRPNetworking sharedNetworking] networkRequestOpcode:DRPNetworkingDeviceIDPairValidation
                                                 arguments:@{@"pass" : [DRPNetworking sharedNetworking].pass}
                                            withCompletion:^(NSDictionary *response, NSError *error) {
                                                // Pair is only valid when validPair == 1
                                                completion([response[@"validPair"] integerValue] == 1);
    }];
}

- (void)loadSavedDeviceIDPair
{
    NSDictionary *devicePair = [NSDictionary dictionaryWithContentsOfURL:self.deviceURL];
    
    [DRPNetworking sharedNetworking].deviceID = devicePair[@"deviceID"];
    [DRPNetworking sharedNetworking].pass = devicePair[@"pass"];
}

- (void)saveDeviceIDPair
{
    NSDictionary *devicePair = @{@"deviceID" : self.deviceID, @"pass" : self.pass};
    [devicePair writeToURL:self.deviceURL atomically:YES];
}

- (void)purgeDeviceIDPair
{
    [[NSFileManager defaultManager] removeItemAtURL:self.deviceURL error:nil];
    self.deviceID = nil;
    self.pass = nil;
}

#pragma mark Aliases

- (void)aliasForDeviceID:(NSString *)deviceID withCompletion:(void (^)(NSString *))completion {
}

- (void)aliasForUserID:(NSString *)userID withCompletion:(void (^)(NSString *))completion {
}

- (void)setAlias:(NSString *)alias withCompletion:(void (^)(NSString *))completion {
}

#pragma mark Facebook

- (void)associateFacebook:(NSString *)userID withCompletion:(void (^)())completion {
}

- (void)disassociateFacebookWithCompletion:(void (^)())completion {
}

- (void)facebookFriendsWithCompletion:(void (^)(NSArray *))completion {
}

#pragma mark Matches

- (void)requestMatchWithFriend:(NSString *)userID withCompletion:(void (^)(NSString *, BOOL, NSString *))completion {
}

- (void)matchData:(NSString *)matchID withCompletion:(void (^)(NSData *))completion {
}

- (void)submitMatchData:(NSData *)matchData forMatchID:(NSString *)matchID withCompletion:(void (^)())completion {
}

- (void)concedeMatchID:(NSString *)matchID withCompletion:(void (^)())completion {
}

@end
