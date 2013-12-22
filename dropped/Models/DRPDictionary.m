//
//  DRPDictionary.m
//  dropped
//
//  Created by Jared Jones on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPDictionary.h"
#import <FMDatabase.h>
#import <FMResultSet.h>
#import <FMDatabaseAdditions.h>

@interface DRPDictionary()

@property (strong, atomic) NSString *databasePath;
@property (strong, atomic) FMDatabase *database;

@end

@implementation DRPDictionary

+ (DRPDictionary *)sharedDictionary
{
    static DRPDictionary *sharedDictionary = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedDictionary = [DRPDictionary alloc];
        sharedDictionary = [sharedDictionary initWithDatabase:@"Dropped"
                                                withExtension:@"db"
                                                withDirectory:@"Database"];
    });
    
    return sharedDictionary;
}

- (instancetype)initWithDatabase:(NSString *)filePath withExtension:(NSString *)ext withDirectory:(NSString *)dirPath
{
    self = [super init];
    if (self){
        _databasePath = [[NSBundle mainBundle] pathForResource:filePath ofType:ext inDirectory:dirPath];
        _database = [[FMDatabase alloc]initWithPath:_databasePath];
        
        if (![_database openWithFlags:SQLITE_OPEN_READONLY]) {
            // FMDatabase doesn't throw exceptions when it can't
            // open the database, it just returns a BOOL
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [_database close];
}

+ (BOOL)isValidWord:(NSString *)word
{
    return [DRPDictionary indexPositionForWord:word.lowercaseString] > 0;
}

+ (NSInteger)indexPositionForWord:(NSString *)word
{
    return [[DRPDictionary sharedDictionary].database intForQuery:@"SELECT * FROM words WHERE word = ?;", word];
}

@end
