//
//  DRPDictionary.m
//  dropped
//
//  Created by Jared Jones on 11/15/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPDictionary.h"
#import <FRBSwatchist/FRBSwatchist.h>
#import <FMDatabase.h>
#import <FMResultSet.h>
#import <FMDatabaseAdditions.h>

static const NSInteger _HTTPSuccessCode = 200;

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
        // TODO: use a writeable path here
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
        self.databasePath = [[NSBundle mainBundle] pathForResource:filePath ofType:ext inDirectory:dirPath];
        self.database = [[FMDatabase alloc]initWithPath:self.databasePath];
        
        if (![self.database openWithFlags:SQLITE_OPEN_READWRITE]) {
            // FMDatabase doesn't throw exceptions when it can't
            // open the database, it just returns a BOOL
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [self.database close];
}

+ (void)syncDictionary
{
    NSInteger versionNumber = [[[DRPDictionary sharedDictionary] database] intForQuery:@"SELECT version FROM settings"];
    NSString *URLString = [NSString stringWithFormat:@"%@grabdicsql.php?i=%ld",
                                            [FRBSwatchist stringForKey:@"debug.dictionaryDownloadURL"],
                                            (long)versionNumber];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]init];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setURL:[NSURL URLWithString:URLString]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               if ([httpResponse statusCode] != _HTTPSuccessCode ||
                                                            connectionError != nil) {
                                   NSLog(@"Dictionary Downloaded Failed with HTTP Status-Code:%ld\nURLPath:%@",
                                         (long)[httpResponse statusCode],
                                         URLString);
                               } else if([data length] == 0) {
                                   //Either your version is too old for updating or your version is current
                                   
                               } else {
                                   NSString *queryData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //Keep this till we can verify that it's working
                                   NSLog(@":%@", queryData);
                                   NSArray * commands = [queryData componentsSeparatedByString:@";"];
                                   for(NSString * cmd in commands){
                                       NSString * trimmedCmd = [cmd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                       if ([trimmedCmd length] == 0){
                                           // The last line of the schema will trigger this case.
                                           continue;
                                       }
                                       [[DRPDictionary sharedDictionary].database executeUpdate:trimmedCmd];
                                   }
                               }
                           }];
}

+ (NSInteger)getDictionaryVersion
{
    return [[DRPDictionary sharedDictionary].database intForQuery:@"SELECT version FROM settings;"];
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
