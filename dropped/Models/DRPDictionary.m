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

@property (strong, nonatomic) NSString *databasePath;
@property (strong, nonatomic) FMDatabase *database;

@end

@implementation DRPDictionary

static DRPDictionary *sharedDictionary = NULL;

+ (DRPDictionary *)sharedDictionary
{
    if (!sharedDictionary){
        sharedDictionary = [[DRPDictionary alloc] initWithDatabase:@"Dropped"
                                                     withExtension:@"db"
                                                     withDirectory:@"Database"];
    }
    return sharedDictionary;
}

- (instancetype)initWithDatabase: (NSString*) filePath withExtension: (NSString *)ext withDirectory: (NSString *) dirPath
{
    self = [super init];
    if (self){
        _databasePath = [[NSBundle mainBundle] pathForResource:filePath ofType:ext inDirectory:dirPath];
        _database = [[FMDatabase alloc]initWithPath:_databasePath];
        
        @try {
            [_database open];
        }
        @catch (NSException *exception) {
            NSLog(@"An exception occurred with open the DB: %@", exception.name);
            NSLog(@"Here are some details: %@", exception.reason);
            return nil;
        }
        @finally {
            //DO NOTHING
        }
    }
    return self;
}

+ (BOOL) isValidWord: (NSString *) word
{
    [DRPDictionary sharedDictionary];
    
    NSString *prependingSelector = @"SELECT * FROM words WHERE word = '";
    NSString *postFix = @"';";
    NSString *query = [prependingSelector stringByAppendingString:word];
    query = [query stringByAppendingString:postFix];
    NSInteger count = [sharedDictionary.database intForQuery:query];
    if (count > 0){
        return YES;
    }else{
        return NO;
    }
}

+ (NSInteger) getIndexPosition: (NSString *) word
{
    [DRPDictionary sharedDictionary];
    
    NSString *prependingSelector = @"SELECT * FROM words WHERE word = '";
    NSString *postFix = @"';";
    NSString *query = [prependingSelector stringByAppendingString:word];
    query = [query stringByAppendingString:postFix];
    return [sharedDictionary.database intForQuery:query];
}

@end
