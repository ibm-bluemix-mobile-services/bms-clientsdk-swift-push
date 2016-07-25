/*
*     Copyright 2015 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/

import UIKit
import BMSCore
import BMSPush

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let myBMSClient = BMSClient.sharedInstance
        
        myBMSClient.initializeWithBluemixAppRoute("", bluemixAppGUID: "", bluemixRegion: "")
       // BMSPushClient.overrideServerHost = "http://9.109.242.204:1337"
        
        myBMSClient.defaultRequestTimeout = 10.0 // seconds
        return true
    }
    
    func registerForPush () {
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
    }
    func unRegisterPush () {
        
        // MARK:  RETRIEVING AVAILABLE SUBSCRIPTIONS
        
        let push =  BMSPushClient.sharedInstance
        
        push.retrieveSubscriptionsWithCompletionHandler { (response, statusCode, error) -> Void in
            
            if error.isEmpty {
                
                print( "Response during retrieving subscribed tags : \(response?.description)")
                
                print( "status code during retrieving subscribed tags : \(statusCode)")
                
                self.sendNotifToDisplayResponse("Response during retrieving subscribed tags: \(response?.description)")
                
                // MARK:  UNSUBSCRIBING TO TAGS
                
                push.unsubscribeFromTags(response!, completionHandler: { (response, statusCode, error) -> Void in
                    
                    if error.isEmpty {
                        
                        print( "Response during unsubscribed tags : \(response?.description)")
                        
                        print( "status code during unsubscribed tags : \(statusCode)")
                        
                        self.sendNotifToDisplayResponse("Response during unsubscribed tags: \(response?.description)")
                        
                        // MARK:  UNSREGISTER DEVICE
                        push.unregisterDevice({ (response, statusCode, error) -> Void in
                            
                            if error.isEmpty {
                                
                                print( "Response during unregistering device : \(response)")
                                
                                print( "status code during unregistering device : \(statusCode)")
                                
                                self.sendNotifToDisplayResponse("Response during unregistering device: \(response)")
                                
                                UIApplication.sharedApplication().unregisterForRemoteNotifications()
                            }
                            else{
                                print( "Error during unregistering device \(error) ")
                                
                                self.sendNotifToDisplayResponse( "Error during unregistering device \n  - status code: \(statusCode) \n Error :\(error) \n")
                            }
                        })
                    }
                    else {
                        print( "Error during  unsubscribed tags \(error) ")
                        
                        self.sendNotifToDisplayResponse( "Error during unsubscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                    }
                })
            }
            else {
                
                print( "Error during retrieving subscribed tags \(error) ")
                
                self.sendNotifToDisplayResponse( "Error during retrieving subscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
            }
            
        }
        
    }
    
    func application (application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData){
        
        
        
        var devId = String()
        let authManager  = BMSClient.sharedInstance.authorizationManager
        devId = authManager.deviceIdentity.id!
        
        var token:String = deviceToken.description
        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        token = token.stringByReplacingOccurrencesOfString(">", withString: "")
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
        
        print(token);
        print(devId);
        
        let push =  BMSPushClient.sharedInstance
        push.initializeWithPushAppGUID("")
        //push.initializeWithPushAppGUID("", clientSecret:"")
       //push.registerWithDeviceToken(deviceToken, WithUserId: "") { (response, statusCode, error) -> Void in
        
        push.registerWithDeviceToken(deviceToken) { (response, statusCode, error) -> Void in
            
            if error.isEmpty {
                
                print( "Response during device registration : \(response)")
                
                print( "status code during device registration : \(statusCode)")
                
                self.sendNotifToDisplayResponse("Response during device registration json: \(response)")
                
                // MARK:    RETRIEVING AVAILABLE TAGS
                
                push.retrieveAvailableTagsWithCompletionHandler({ (response, statusCode, error) -> Void in
                    
                    if error.isEmpty {
                        
                        print( "Response during retrive tags : \(response)")
                        
                        print( "status code during retrieve tags : \(statusCode)")
                        
                        self.sendNotifToDisplayResponse("Response during retrive tags: \(response?.description)")
                        
                        // MARK:    SUBSCRIBING TO AVAILABLE TAGS
                        push.subscribeToTags(response!, completionHandler: { (response, statusCode, error) -> Void in
                            
                            if error.isEmpty {
                                
                                print( "Response during Subscribing to tags : \(response?.description)")
                                
                                print( "status code during Subscribing tags : \(statusCode)")
                                
                                self.sendNotifToDisplayResponse("Response during Subscribing tags: \(response?.description)")
                                
                                // MARK:  RETRIEVING AVAILABLE SUBSCRIPTIONS
                                push.retrieveSubscriptionsWithCompletionHandler({ (response, statusCode, error) -> Void in
                                    
                                    if error.isEmpty {
                                        
                                        print( "Response during retrieving subscribed tags : \(response?.description)")
                                        
                                        print( "status code during retrieving subscribed tags : \(statusCode)")
                                        
                                        self.sendNotifToDisplayResponse("Response during retrieving subscribed tags: \(response?.description)")
                                    }
                                    else {
                                        
                                        print( "Error during retrieving subscribed tags \(error) ")
                                        
                                        self.sendNotifToDisplayResponse( "Error during retrieving subscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                                    }
                                    
                                })
                                
                            }
                            else {
                                
                                print( "Error during subscribing tags \(error) ")
                                
                                self.sendNotifToDisplayResponse( "Error during subscribing tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                            }
                            
                        })
                    }
                    else {
                        print( "Error during retrieve tags \(error) ")
                        
                        self.sendNotifToDisplayResponse( "Error during retrieve tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                    }
                    
                    
                })
            }
            else{
                print( "Error during device registration \(error) ")
                
                self.sendNotifToDisplayResponse( "Error during device registration \n  - status code: \(statusCode) \n Error :\(error) \n")
            }
        }
    }
    
    //Called if unable to register for APNS.
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        let message:NSString = "Error registering for push notifications: "+error.description
        
        self.showAlert("Registering for notifications", message: message)
        
        
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        let payLoad = ((((userInfo as NSDictionary).valueForKey("aps") as! NSDictionary).valueForKey("alert") as! NSDictionary).valueForKey("body") as! NSString)
        
        self.showAlert("Recieved Push notifications", message: payLoad)
        
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
    
}
