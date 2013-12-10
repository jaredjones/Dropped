//
//  DRPGameCenterInterface.h
//  dropped
//
//  Created by Brad Zeis on 12/9/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DRPGameCenterLocalPlayerAuthenticatedNotificationName @"DRPGameCenterLocalPlayerAuthenticatedNotification"

@interface DRPGameCenterInterface : NSObject

+ (void)authenticateLocalPlayer;
+ (UIViewController *)authenticationViewController;

@end