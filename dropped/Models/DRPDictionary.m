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

@property (strong, atomic) NSURL *databaseURL;
@property (strong, atomic) FMDatabase *database;
@property (strong, atomic) NSMutableDictionary *uniqueAlphabetized;

@end

@implementation DRPDictionary

+ (DRPDictionary *)sharedDictionary
{
    static DRPDictionary *sharedDictionary = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        
        NSURL *dbDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                                     inDomains:NSUserDomainMask][0] URLByAppendingPathComponent:@"Database"];
        NSURL *databaseURL = [dbDirectory URLByAppendingPathComponent:@"en-us.db"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:databaseURL.path]) {
            // Library/Application Support/ directory isn't present by default, it has to be created
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtURL:dbDirectory
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
            
            // /Library/Application Support/ must be excluded from backup
            [dbDirectory setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
            
            // Copy the database from the app bundle to Application Support so it's writeable
            NSURL *databaseSourceURL = [[NSBundle mainBundle] URLForResource:@"en-us" withExtension:@"db" subdirectory:@"Database"];
            [[NSFileManager defaultManager] copyItemAtPath:databaseSourceURL.path toPath:databaseURL.path error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
        }
        
        sharedDictionary = [[DRPDictionary alloc] initWithDatabaseURL:databaseURL];
    });
    
    return sharedDictionary;
}

- (instancetype)initWithDatabaseURL:(NSURL *)databaseURL
{
    self = [super init];
    if (self){
        self.databaseURL = databaseURL;
        self.database = [[FMDatabase alloc] initWithPath:self.databaseURL.path];
        
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
    // TODO: this doesn't fail gracefully
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

+ (void)testing
{
    FMResultSet *wordSet = [[DRPDictionary sharedDictionary].database executeQuery:@"SELECT word FROM words;"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
 
        while ([wordSet next])
        {
            
            NSMutableSet *uniqueCharacters = [NSMutableSet set];
            NSMutableString *uniqueString = [NSMutableString string];
            [[wordSet stringForColumn:@"word"] enumerateSubstringsInRange:NSMakeRange(0, [wordSet stringForColumn:@"word"].length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                if (![uniqueCharacters containsObject:substring]) {
                    [uniqueCharacters addObject:substring];
                    [uniqueString appendString:substring];
                }
            }];
            
            NSUInteger length = [uniqueString length];
            unichar *chars = (unichar *)malloc(sizeof(unichar) * length);
            
            // extract
            [uniqueString getCharacters:chars range:NSMakeRange(0, length)];
            
            // sort (for western alphabets only)
            qsort_b(chars, length, sizeof(unichar), ^(const void *l, const void *r) {
                unichar left = *(unichar *)l;
                unichar right = *(unichar *)r;
                return (int)(left - right);
            });
            
            // recreate
            NSString *sorted = [NSString stringWithCharacters:chars length:length];
            
            // clean-up
            free(chars);
            
            //NSLog(@"%@", sorted);
        }
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"DONE!");
        });
    });
}

@end
