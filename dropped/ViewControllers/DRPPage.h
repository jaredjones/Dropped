//
//  DRPPage.h
//  dropped
//
//  Created by Brad Zeis on 12/1/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DRPPageID) {
    DRPPageSplash,
    DRPPageLogIn,
    DRPPageMatch,
    DRPPageGKMatchMaker,
    DRPPageList,
    DRPPageEtCetera,
    DRPPageNil
};

typedef NS_ENUM(NSInteger, DRPPageDirection) {
    DRPPageDirectionUp,
    DRPPageDirectionDown
};

@protocol DRPPage <NSObject>

// Must "@synthesize pageID=_pageID" when conforming to DRPPage
@property (readonly) DRPPageID pageID;

@optional
- (void)willMoveToCurrentWithUserInfo:(NSDictionary *)userInfo;
- (void)didMoveToCurrent;

- (void)willMoveFromCurrent;
- (void)didMoveFromCurrent;

@end
