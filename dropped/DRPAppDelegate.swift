//
//  DRPAppDelegate.swift
//  Dropped
//
//  Created by Jared Jones on 7/22/14.
//  Copyright (c) 2014 Uvora LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class DRPAppDelegate: UIResponder, UIApplicationDelegate
{
    var window:UIWindow?
    
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        loadSwatches()
        srandomdev()
        
        //TestFlight.takeOff("e04eea5f-3c76-4cc7-a01d-79f12d9fa6ad")
        DRPDictionary.syncDictionary()
        
        // RootViewController
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = DRPMainViewController(nibName: nil, bundle: nil)
        
        UIApplication.sharedApplication().statusBarHidden = true
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//MARK: Push Notifications
    func application(application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        var APNSToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        APNSToken = APNSToken.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        DRPNetworking.sharedNetworking().setAPNSToken(APNSToken, withCompletion: nil)
        NSLog("APNS Setup Success: %@", APNSToken)
    }
    
    func application(application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: NSError)
    {
        NSLog("APNS Setup Failed:\n\nFailed to get APNS token, error: %@\n\n", error)
    }
    
    func application(application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void))
    {
        // TODO: respond to notification
    }

//MARK: Swatches
    func loadSwatches()
    {
        let swatches = ["animation", "board", "colors", "debug", "list", "page", "tileOffset", "tileScalingOffset"]
        for swatch in swatches
        {
            loadSwatchNamed(swatch)
        }
    }
    
    func loadSwatchNamed(name:String)
    {
        FRBSwatchist.loadSwatch(NSBundle.mainBundle().URLForResource(name, withExtension: "plist", subdirectory: "Swatches"), forName: name);
    }
}