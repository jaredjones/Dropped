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

@property NSURL *deviceURL;
@property NSMutableDictionary *cachedAliases;

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

// Generic server request function
// Builds arguments and calls a completion handler with parsed response
- (void)networkRequestOpcode:(NSInteger)opCode arguments:(NSDictionary *)json withCompletion:(void (^)(NSDictionary *, NSError *))completion
{
    NSString *serverURL = @"http://chaos.uvora.com/dropped/hphp/process.php";
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

// opcode 0, recieves pass
- (void)fetchDeviceIDWithCompletion:(void (^)(BOOL))completion
{    
    // Attempt to read cached deviceID (only if not already loaded)
    if ([FRBSwatchist boolForKey:@"debug.purgeDeviceID"]) {
        [self purgeDeviceIDPair];
    } else if (!self.deviceID) {
        [self loadSavedDeviceIDPair];
    }
    
    if (self.deviceID) {
        // Already have a saved deviceID
        // Generate a new deviceID/pass pair if the saved pair is invalid
        [self validateDeviceIDPairWithCompletion:^(BOOL valid, NSError *error) {
            if (error) {
                // If there was an error, assume the network is not reachable or the server is down
                completion(NO);
                
            } else if (!valid) {
                // Purge and start over with a newly generated pair
                [self purgeDeviceIDPair];
                [self fetchDeviceIDWithCompletion:completion];
                
            } else {
                // Success!
                NSLog(@"Loaded deviceID: %@", [DRPNetworking sharedNetworking].deviceID);
                completion(YES);
            }
        }];
        
    } else  {
        // Device didn't load deviceID, generate a new one on the server
        // Pass is generated locally
        self.pass = generateUUID();
        
        // Don't have a deviceID locally, let the server generate one
        // Assume that deviceID/pass pairs generated by the server are valid
        [self networkRequestOpcode:DRPNetworkingGenerateDeviceID
                         arguments:@{@"pass" : self.pass}
                    withCompletion:^(NSDictionary *response, NSError *error) {
                        if (!error) {
                            self.deviceID = response[@"deviceID"];
                            [self saveDeviceIDPair];
                            
                            NSLog(@"Generated new deviceID: %@", self.deviceID);
                        }
                        completion(!error);
        }];
    }
}

// opcode 6, recieves deviceID/pass
- (void)validateDeviceIDPairWithCompletion:(void (^)(BOOL, NSError *))completion
{
    [self networkRequestOpcode:DRPNetworkingDeviceIDPairValidation
                     arguments:@{@"pass" : self.pass}
                withCompletion:^(NSDictionary *response, NSError *error) {
                    // Pair is only valid when validPair == 1
                    completion([response[@"validPair"] integerValue] == 1, error);
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

// opcode 1, recieves deviceID only
- (void)aliasForDeviceID:(NSString *)deviceID withCompletion:(void (^)(NSString *))completion {
}

- (void)aliasForUserID:(NSString *)userID withCompletion:(void (^)(NSString *))completion {
}

// opcode 3, receives deviceID/pass and alias
// opcode 4, recieves userID/pass and alias
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

// opcode 5, recieves deviceID/pass and userID
- (void)requestMatchWithFriend:(NSString *)userID withCompletion:(void (^)(NSString *, BOOL, NSString *))completion {
}

// opcode 7, recieves matchID, deviceID, userID -> matchData, isLocalPlayerTurn, remotePlayerAlias
- (void)matchData:(NSString *)matchID withCompletion:(void (^)(NSData *))completion {
}

- (void)submitMatchData:(NSData *)matchData forMatchID:(NSString *)matchID withCompletion:(void (^)())completion {
}

- (void)concedeMatchID:(NSString *)matchID withCompletion:(void (^)())completion {
}

@end
