//
//  AppDelegate.swift
//  BMSPushHostApp
//
//  Created by Anantha Krishnan K G on 16/02/16.
//  Copyright © 2016 IBM Corp. All rights reserved.
//

import UIKit
import BMSCore
import BMSPush

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let myBMSClient = BMSClient.sharedInstance
        
        myBMSClient.initializeWithBluemixAppRoute("https://pushtestappananth.stage1.mybluemix.net", bluemixAppGUID: "05854d41-b1a8-449c-8949-ea59a85aaee7", bluemixRegionSuffix: REGION_US_SOUTH)
        
        myBMSClient.defaultRequestTimeout = 10.0 // seconds
        
        
        return true
    }
    
    func registerForPush () {
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
    }
    
    func application (application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData){
        
        let push =  BMSPushClient.sharedInstance
        
        // MARK:    REGISTERING DEVICE
        
        push.registerDeviceToken(deviceToken) { (response, error) -> Void in
            
            if let responseError = error {
                
                print( "Error during device registration \(responseError.localizedDescription) ")
                
                self.sendNotifToDisplayResponse( "Error during device registration \(responseError.localizedDescription) ")
                
            }
            else if response != nil {
                
                let status = response!.statusCode ?? 0
                let responseText = response!.responseText ?? ""
                
                print( "Response during device registration : \(responseText)")
                
                print( "status code during device registration : \(status)")
                
                self.sendNotifToDisplayResponse("Response during device registration json: \(responseText)")
                
                // MARK:    RETRIEVING AVAILABLE TAGS
                
                push.retrieveAvailableTagsWithCompletionHandler({ (response, error) -> Void in
                    
                    if let responseError = error {
                        
                        print( "Error during retrieve tags \(responseError.localizedDescription) ")
                        
                        self.sendNotifToDisplayResponse( "Error during retrieve tags \(responseError.localizedDescription) ")
                        
                    }
                    else{
                        
                        let status = response!.statusCode ?? 0
                        let responseText = response!.responseText ?? ""
                        
                        self.sendNotifToDisplayResponse("Response of retrieve tags : \(responseText)")
                        
                        print( "Response of retrieve tags : \(responseText)")
                        
                        print( "status code of retrieve tags: \(status)")
                        
                        
                        let tags: NSArray = response!.availableTags()
                        
                        
                        let tagsSize:Int = tags.count
                        
                        print("\n \n \n \n Available List of Tags : \(tags)")
                        
                        print("\n \n \n \n \n Number of Tags : \(tagsSize)")
                        
                        let myTags:NSArray = tags.subarrayWithRange(NSMakeRange(0, tagsSize/2))
                        
                        print("\n \n \n \n \n Now subscribe for half of the available tags :\n \(myTags)")
                        
                        self.sendNotifToDisplayResponse("Now subscribe for half of the available tags :\n \(myTags)")
                        
                        
                        // MARK:    SUBSCRIBING TO HALF OF AVAILABLE TAGS
                        
                        push.subscribeToTags(myTags, completionHandler: { (response, error) -> Void in
                            
                            if let responseError = error {
                                
                                print( "Error during subscribeing tags \(responseError.localizedDescription) ")
                                
                                self.sendNotifToDisplayResponse( "Error during subscribeing tags \(responseError.localizedDescription) ")
                                
                            }
                            else{
                                
                                let status = response!.statusCode ?? 0
                                //let headers = response!.headers ?? [:]
                                let responseText = response!.responseText ?? ""
                                
                                print( "Response of subscribe tags : \(responseText)")
                                
                                print( "status code of subscribe tags: \(status)")
                                
                                self.sendNotifToDisplayResponse("Response of subscribe tags: \(responseText)")
                                
                                let subStatus:NSDictionary = response!.subscribeStatus()
                                
                                print("\n \n \n \n subStatus is, \(subStatus.description)")
                                
                                self.sendNotifToDisplayResponse("subStatus is, \(subStatus.description)")
                                
                                
                                // MARK:  RETRIEVING AVAILABLE SUBSCRIPTIONS
                                
                                push.retrieveSubscriptionsWithCompletionHandler({ (response, error) -> Void in
                                    
                                    if let responseError = error {
                                        
                                        print( "Error during retrieve subscriptions \(responseError.localizedDescription) ")
                                        
                                        self.sendNotifToDisplayResponse( "Error during retrieve subscriptions \(responseError.localizedDescription) ")
                                        
                                    }
                                    else{
                                        
                                        let status = response!.statusCode ?? 0
                                        let responseText = response!.responseText ?? ""
                                        
                                        print( "Response of retrieve subscriptions : \(responseText)")
                                        
                                        print( "status code of retrieve subscriptions: \(status)")
                                        
                                        self.sendNotifToDisplayResponse("Response of retrieve subscriptions:  \(responseText)")
                                        
                                        
                                        let subscription: NSArray = response!.subscriptions()
                                        
                                        
                                        print("\n \n \n \n Subscribed tags are: \(subscription)")
                                        
                                        let subscriptionSize:Int = subscription.count
                                        
                                        print("\n \n \n \n \n Number of subscribed Tags : \(subscriptionSize)")
                                        
                                        self.sendNotifToDisplayResponse("subscribed tags details : \(subscription.description)")
                                        
                                    }
                                    
                                })
                                
                            }
                        })
                        
                    }
                })
                
            }
        }
    }
    
    //Called if unable to register for APNS.
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        let message:NSString = "Error registering for push notifications: "+error.description
        
        self.showAlert("Registering for notifications", message: message)
        
        
        
    }
    
    func unRegisterPush () {
        
        // MARK:  RETRIEVING AVAILABLE SUBSCRIPTIONS
        
        let push =  BMSPushClient.sharedInstance
        
        push.retrieveSubscriptionsWithCompletionHandler({ (response, error) -> Void in
            
            if let responseError = error {
                
                print( "Error during retrieve subscriptions \(responseError.localizedDescription) ")
                
                self.sendNotifToDisplayResponse( "Error during retrieve subscriptions \(responseError.localizedDescription) ")
                
            }
            else{
                
                let status = response!.statusCode ?? 0
                let responseText = response!.responseText ?? ""
                
                print( "Response of retrieve subscriptions : \(responseText)")
                
                print( "status code of retrieve subscriptions: \(status)")
                
                self.sendNotifToDisplayResponse("Response of retrieve subscriptions:  \(responseText)")
                
                
                let subscription: NSArray = response!.subscriptions()
                
                
                print("\n \n \n \n Subscribed tags are: \(subscription)")
                
                let subscriptionSize:Int = subscription.count
                
                print("\n \n \n \n \n Number of subscribed Tags : \(subscriptionSize)")
                
                self.sendNotifToDisplayResponse("subscribed tags details : \(subscription.description)")
                
                
                // MARK:  UNSUBSCRIBING TO TAGS
                
                push.unsubscribeFromTags(subscription, completionHandler: { (response, error) -> Void in
                    
                    
                    if let responseError = error {
                        
                        print( "Error during unsubscribing to tags \(responseError.localizedDescription) ")
                        
                        self.sendNotifToDisplayResponse( "Error during unsubscribing to tags \(responseError.localizedDescription) ")
                        
                    }
                    else{
                        
                        let status = response!.statusCode ?? 0
                        let responseText = response!.responseText ?? ""
                        
                        print( "Response of unsubscribe tags : \(responseText)")
                        
                        print( "status code of unsubscribe tags: \(status)")
                        
                        self.sendNotifToDisplayResponse( "Response of unsubscribe tags : \(responseText)")
                        
                        let unSubStatus:NSDictionary = response!.unsubscribeStatus()
                        
                        print("\n \n \n \n unSubscription is, \(unSubStatus.description)")
                        
                        self.sendNotifToDisplayResponse("unSubscription is, \(unSubStatus.description)")
                        
                        
                        // MARK:  UNSREGISTER DEVICE
                        
                        push.unregisterDevice({ (response, error) -> Void in
                            
                            if let responseError = error {
                                
                                print( "Error during unregistering device \(responseError.localizedDescription) ")
                                
                                self.sendNotifToDisplayResponse( "Error during unregistering device \(responseError.localizedDescription)")
                                
                            }
                            else{
                                
                                let status = response!.statusCode ?? 0
                                let responseText = response!.responseText ?? ""
                                
                                print( "Response of unregister device : \(responseText)")
                                
                                print( "status code of unregister device : \(status)")
                                
                                self.sendNotifToDisplayResponse( "Response of unregister device : \(responseText) \(status)")
                                
                                UIApplication.sharedApplication().unregisterForRemoteNotifications()
                            }
                        })
                    }
                })
                
            }
            
        })
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
    
    
    
    
    
    
    func sendNotifToDisplayResponse (responseValue:String){
        
        responseText = responseValue
        NSNotificationCenter.defaultCenter().postNotificationName("action", object: self)
    }
    
    
    func showAlert (title:NSString , message:NSString){
        
        // create the alert
        let alert = UIAlertController.init(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        // show the alert
        self.window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
}

