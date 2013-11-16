//
//  DRPBoard.h
//  dropped
//
//  Created by Brad Zeis on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRPPosition, DRPCharacter;

@interface DRPBoard : NSObject

- (instancetype)initWithMatchData:(NSData *)data;

#pragma mark History

- (DRPCharacter *)characterAtPosition:(DRPPosition *)position forTurn:(NSInteger)turn;
- (DRPCharacter *)characterAtPosition:(DRPPosition *)position;
- (NSString *)wordForPositions:(NSArray *)positions forTurn:(NSInteger)turn;
- (NSString *)wordForPositions:(NSArray *)positions;

- (NSArray *)positionsPlayedForTurn:(NSInteger)turn;
- (NSArray *)appendedCharactersForTurn:(NSInteger)turn;

#pragma mark Move Submission

// Creates a new history entry and submits move to Game Center
- (NSDictionary *)submitMoveForPositions:(NSArray *)positions;

// This is needed by the ViewControllers to play back previous moves
- (NSDictionary *)diffForPositions:(NSArray *)positions appendedCharacters:(NSArray *)characters;

@end
