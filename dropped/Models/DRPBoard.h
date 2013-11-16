//
//  DRPBoard.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPPosition, DRPCharacter, DRPPlayedWord;

@interface DRPBoard : NSObject

- (instancetype)initWithMatchData:(NSData *)data;

#pragma mark History

- (DRPCharacter *)characterAtPosition:(DRPPosition *)position forTurn:(NSInteger)turn;
- (DRPCharacter *)characterAtPosition:(DRPPosition *)position;
- (NSString *)wordForPositions:(NSArray *)positions forTurn:(NSInteger)turn;
- (NSString *)wordForPositions:(NSArray *)positions;

- (DRPPlayedWord *)wordPlayedForTurn:(NSInteger)turn;

#pragma mark Move Submission

// Creates a new history entry. GC submission is handled by DRPMatch.
- (DRPPlayedWord *)appendMoveForPositions:(NSArray *)positions;

@end
