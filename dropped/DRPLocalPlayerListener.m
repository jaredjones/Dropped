//
//  DRPLocalPlayerListener.m
//  dropped
//
//  Created by Brad Zeis on 1/12/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

#import "DRPLocalPlayerListener.h"
#import "DRPGameCenterInterface.h"

@implementation DRPLocalPlayerListener

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)gkMatch didBecomeActive:(BOOL)didBecomeActive
{
    NSLog(@"aw yiss");
    
    // This is where turn notifications are sent. Pretty big deal.
    if (![player.playerID isEqualToString:gkMatch.currentParticipant.playerID]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DRPGameCenterReceivedTurnEventNotificationName
                                                        object:nil
                                                      userInfo:@{@"gkMatch" : gkMatch}];
}

@end
