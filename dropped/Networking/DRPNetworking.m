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
@property (readwrite) NSString *deviceID;
@property (readwrite) NSString *userID;
@property (readwrite) NSString *APNSToken;

@property NSURL *deviceURL;
@property NSMutableDictionary *cachedAliases;

// Social
@property FBSession *fbSession;

@end

@implementation DRPNetworking

// TODO: send APNS token to server
// TODO: add error checking to completion handlers

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
    NSMutableDictionary *requestBody = [(json ?: @{}) mutableCopy];
    requestBody[@"deviceID"] = self.deviceID ?: @"";
    requestBody[@"userID"] = self.userID ?: @"";
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    
    if ([FRBSwatchist boolForKey:@"debug.printNetworkingActivity"]) {
        NSLog(@"OpCode %ld (request): %@", (long)opCode, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    }
    
    // Be free, little packets
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if ([FRBSwatchist boolForKey:@"debug.printNetworkingActivity"]) {
                                   NSLog(@"OpCode %ld (response): %@", (long)opCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                               }
                               
                               // If there is no response body, that means there was a networking issue
                               // In every other case, there will be a message body
                               if (data.length == 0) {
                                   completion(nil, [NSError errorWithDomain:@"URLConnectionFailed" code:0 userInfo:@{}]);
                                   
                               } else if (connectionError) {
                                   completion(nil, connectionError);
                                   
                               } else if (data) {
                                   NSError *error;
                                   NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   completion(responseBody, error);
                               }
    }];
}

#pragma mark DeviceID

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

#pragma mark APNSToken

- (void)setAPNSToken:(NSString *)APNSToken withCompletion:(void (^)())completion
{
    self.APNSToken = APNSToken;
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    args[@"pass"] = self.pass;
    if (self.APNSToken) {
        args[@"APNSToken"] = self.APNSToken;
    }
    
    [self networkRequestOpcode:DRPNetworkingSetAPNSToken arguments:args withCompletion:^(NSDictionary *response, NSError *error) {
        if (completion) {
            completion();
        }
    }];
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

- (void)currentMatchIDsWithCompletion:(void (^)(NSArray *))completion {
    [self networkRequestOpcode:DRPNetworkingGetMatchIDs arguments:nil withCompletion:^(NSDictionary *response, NSError *error) {
        completion(response[@"matchIDs"]);
    }];
}

- (void)requestMatchWithFriend:(NSString *)userID withCompletion:(void (^)(NSString *, NSInteger))completion {
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    if (userID) {
        args[@"friendID"] = userID;
    }
    args[@"pass"] = self.pass;
    
    [self networkRequestOpcode:DRPNetworkingRequestMatch arguments:args withCompletion:^(NSDictionary *response, NSError *error) {
        NSLog(@"request match %@", response);
        completion(response[@"matchID"], [response[@"localPlayerTurn"] integerValue]);
    }];
}

- (void)matchDataForMatchID:(NSString *)matchID withCompletion:(void (^)(NSData *, NSInteger, NSString *))completion {
    [self networkRequestOpcode:DRPNetworkingGetMatchData arguments:@{@"matchID" : matchID } withCompletion:^(NSDictionary *response, NSError *error) {
        
        // TODO: what do when the matchData received back is NULL? (means there was a server issue)
        
        completion(coerceObject(response[@"matchData"], ^id(id argument) { return [(NSString *)argument dataUsingEncoding:NSUTF8StringEncoding]; }),
                   [response[@"localPlayerTurn"] integerValue],
                   coerceObject(response[@"remotePlayerAlias"], nil));
    }];
}

- (void)submitMatchData:(NSData *)matchData forMatchID:(NSString *)matchID advanceTurn:(BOOL)advanceTurn withCompletion:(void (^)())completion {
    
    NSDictionary *args = @{@"pass" : self.pass,
                           @"matchData" : [[NSString alloc] initWithData:matchData encoding:NSUTF8StringEncoding],
                           @"matchID" : matchID,
                           @"advanceTurn" : @((int)advanceTurn)};
    
    [self networkRequestOpcode:DRPNetworkingSubmitMatchTurn arguments:args withCompletion:^(NSDictionary *response, NSError *error) {
        if (completion) {
            completion();
        }
    }];
    
}

- (void)concedeMatchID:(NSString *)matchID withCompletion:(void (^)())completion {
}

@end
