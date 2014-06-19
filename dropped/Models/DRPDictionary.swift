//
//  DRPDictionary.swift
//  Dropped
//
//  Created by Jared Jones on 6/17/14.
//  Copyright (c) 2014 Brad Zeis. All rights reserved.
//

import Foundation

let _HTTPSuccessCode:NSInteger = 200

class DRPDictionary : NSObject
{
    let databaseURL:NSURL
    let database:FMDatabase
    
    class var sharedDictionary : DRPDictionary
    {
        var pred : dispatch_once_t = 0
            
        struct Static {
            static var pred : dispatch_once_t = 0
            static var instance : DRPDictionary? = nil
        }
            
        dispatch_once(&Static.pred, {
            
            let dbDirectory = (NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory,
                                                                                inDomains: .UserDomainMask)[0]
                                                            as NSURL).URLByAppendingPathComponent("Database")
            
            let databaseURL = dbDirectory.URLByAppendingPathComponent("en-us.db")
            if !NSFileManager.defaultManager().fileExistsAtPath(databaseURL.path)
            {
                // Library/Application Support/ directory isn't present by default, it has to be created
                var error:NSError?
                NSFileManager.defaultManager().createDirectoryAtURL(dbDirectory,
                                                                    withIntermediateDirectories: true,
                                                                    attributes: nil,
                                                                    error:&error)
                if (error)
                {
                    NSLog("%@", error!.localizedDescription)
                }
                
                // /Library/Application Support/ must be excluded from backup
                dbDirectory.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey, error: &error)
                if (error)
                {
                    NSLog("%@", error!.localizedDescription)
                }
                
                let databaseSourceURL:NSURL = NSBundle.mainBundle().URLForResource("en-us", withExtension: "db",
                                                                                            subdirectory: "Database")
                NSFileManager.defaultManager().copyItemAtPath(databaseSourceURL.path, toPath: databaseURL.path, error: &error)
                if (error)
                {
                    NSLog("%@", error!.localizedDescription)
                }

            }
            Static.instance = DRPDictionary(databaseURL: databaseURL)
        })
        return Static.instance!
    }

    init(databaseURL:NSURL)
    {
        self.databaseURL = databaseURL
        self.database = FMDatabase(path: self.databaseURL.path)
        
        super.init()
        
        if !self.database.openWithFlags(SQLITE_OPEN_READWRITE)
        {
            // FMDatabase doesn't throw exceptions when it can't
            // open the database, it just returns a BOOL
            NSLog("%@", "ERROR: Database failed to open!!!")
        }
    }
    
    deinit
    {
        database.close()
    }

    class func syncDictionary()
    {
        //TODO
        //NO Syncing till I rewrite how this is done. Shouldn't take long.
        //I'm super tired, I'll finish this tomorrow most likely.
    }
    
    class func getDictionaryVersion() -> NSInteger
    {
        let rs:FMResultSet = DRPDictionary.sharedDictionary.database.executeQuery("SELECT version FROM settings;",
                                                                        withArgumentsInArray: [])
        rs.next()
        return Int(rs.intForColumnIndex(0))
    }
    
    class func isValidWord(word: NSString)->Bool
    {
        return DRPDictionary.indexPositionForWord(word.lowercaseString) > 0
    }
    
    class func indexPositionForWord(word: NSString)->NSInteger
    {
        let rs:FMResultSet = DRPDictionary.sharedDictionary.database.executeQuery("SELECT * FROM words WHERE word = ?;",
            withArgumentsInArray: [word])
        rs.next()
        
        return Int(rs.intForColumnIndex(0))
    }
}