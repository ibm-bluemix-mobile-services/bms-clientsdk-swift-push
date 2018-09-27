/*
*     Copyright 2016 IBM Corp.
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


#if swift(>=3.0)
import UserNotifications
import UserNotificationsUI
#endif
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMSPushObserver {
    
    var window: UIWindow?
    
    #if swift(>=4.2)
    let alertStyle = UIAlertController.Style.alert
    let actionStyle = UIAlertAction.Style.default
    #else
    let alertStyle = UIAlertControllerStyle.alert
    let actionStyle = UIAlertActionStyle.default
    #endif
    
    #if swift(>=3.0)
    
        #if swift(>=4.2)
    
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
              return true
        }
        #else
    
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            
            return true
        }
    
        func onChangePermission(status: Bool) {
            
            print("Push Notification is enabled:  \(status)" as NSString)
            
        }
        
        func registerForPush () {
            
            let myBMSClient = BMSClient.sharedInstance
            myBMSClient.initialize(bluemixRegion: BMSClient.Region.usSouth)
            
            let push =  BMSPushClient.sharedInstance
            push.delegate = self
            
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionTwo = BMSPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionThree = BMSPushNotificationAction(identifierName: "Third", buttonTitle: "Delete", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionFour = BMSPushNotificationAction(identifierName: "Fourth", buttonTitle: "View", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionFive = BMSPushNotificationAction(identifierName: "Fifth", buttonTitle: "Later", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let category = BMSPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])
            let categorySecond = BMSPushNotificationActionCategory(identifierName: "category1", buttonActions: [actionOne, actionTwo])
            let categoryThird = BMSPushNotificationActionCategory(identifierName: "category2", buttonActions: [actionOne, actionTwo,actionThree,actionFour,actionFive])
            
            let notifOptions = BMSPushClientOptions()
            notifOptions.setDeviceId(deviceId: "YOUR_DEVICE_ID")
            let variables = ["username":"ananth","accountNumber":"3564758697057869"]
            notifOptions.setPushVariables(pushVariables: variables)
            notifOptions.setInteractiveNotificationCategories(categoryName: [category,categorySecond,categoryThird])
            push.initializeWithAppGUID(appGUID: "YOUR_APP_GUID", clientSecret:"YOUR_APP_CLIENT_SECRET", options: notifOptions)
            
        }
        func unRegisterPush () {
                
            // MARK:  RETRIEVING AVAILABLE SUBSCRIPTIONS
            
            let push =  BMSPushClient.sharedInstance
            
            push.retrieveSubscriptionsWithCompletionHandler { (response, statusCode, error) -> Void in
                
                if error.isEmpty {
                    
                    print( "Response during retrieving subscribed tags : \(response?.description)")
                    
                    print( "status code during retrieving subscribed tags : \(statusCode)")
                    
                    self.sendNotifToDisplayResponse(responseValue: "Response during retrieving subscribed tags: \(response?.description)")
                    
                    // MARK:  UNSUBSCRIBING TO TAGS
                    
                    push.unsubscribeFromTags(tagsArray: response!, completionHandler: { (response, statusCode, error) -> Void in
                        
                        if error.isEmpty {
                            
                            print( "Response during unsubscribed tags : \(response?.description)")
                            
                            print( "status code during unsubscribed tags : \(statusCode)")
                            
                            self.sendNotifToDisplayResponse(responseValue: "Response during unsubscribed tags: \(response?.description)")
                            
                            // MARK:  UNSREGISTER DEVICE
                            push.unregisterDevice(completionHandler: { (response, statusCode, error) -> Void in
                                
                                if error.isEmpty {
                                    
                                    print( "Response during unregistering device : \(response)")
                                    
                                    print( "status code during unregistering device : \(statusCode)")
                                    
                                    self.sendNotifToDisplayResponse(responseValue: "Response during unregistering device: \(response)")
                                    
                                    UIApplication.shared.unregisterForRemoteNotifications()
                                }
                                else{
                                    print( "Error during unregistering device \(error) ")
                                    
                                    self.sendNotifToDisplayResponse( responseValue: "Error during unregistering device \n  - status code: \(statusCode) \n Error :\(error) \n")
                                }
                            })
                        }
                        else {
                            print( "Error during  unsubscribed tags \(error) ")
                            
                            self.sendNotifToDisplayResponse( responseValue: "Error during unsubscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                        }
                    })
                }
                else {
                    
                    print( "Error during retrieving subscribed tags \(error) ")
                    
                    self.sendNotifToDisplayResponse( responseValue: "Error during retrieving subscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                }
                
            }
            
        }
        
        func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
            
            let push =  BMSPushClient.sharedInstance
            
            push.registerWithDeviceToken(deviceToken: deviceToken) { (response, statusCode, error) -> Void in
                
                if error.isEmpty {
                    
                    print( "Response during device registration : \(response)")
                    
                    print( "status code during device registration : \(statusCode)")
                    
                    self.sendNotifToDisplayResponse(responseValue: "Response during device registration json: \(response)")
                    
                    // MARK:    RETRIEVING AVAILABLE TAGS
                    
                    push.retrieveAvailableTagsWithCompletionHandler(completionHandler: { (response, statusCode, error) -> Void in
                        
                        if error.isEmpty {
                            
                            print( "Response during retrieve tags : \(response)")
                            
                            print( "status code during retrieve tags : \(statusCode)")
                            
                            self.sendNotifToDisplayResponse(responseValue: "Response during retrieve tags: \(response?.description)")
                            
                            // MARK:    SUBSCRIBING TO AVAILABLE TAGS
                            push.subscribeToTags(tagsArray: response!, completionHandler: { (response, statusCode, error) -> Void in
                                
                                if error.isEmpty {
                                    
                                    print( "Response during Subscribing to tags : \(response?.description)")
                                    
                                    print( "status code during Subscribing tags : \(statusCode)")
                                    
                                    self.sendNotifToDisplayResponse(responseValue: "Response during Subscribing tags: \(response?.description)")
                                    
                                    // MARK:  RETRIEVING AVAILABLE SUBSCRIPTIONS
                                    push.retrieveSubscriptionsWithCompletionHandler(completionHandler: { (response, statusCode, error) -> Void in
                                        
                                        if error.isEmpty {
                                            
                                            print( "Response during retrieving subscribed tags : \(response?.description)")
                                            
                                            print( "status code during retrieving subscribed tags : \(statusCode)")
                                            
                                            self.sendNotifToDisplayResponse(responseValue: "Response during retrieving subscribed tags: \(response?.description)")
                                        }
                                        else {
                                            
                                            print( "Error during retrieving subscribed tags \(error) ")
                                            
                                            self.sendNotifToDisplayResponse( responseValue: "Error during retrieving subscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                                        }
                                        
                                    })
                                    
                                }
                                else {
                                    
                                    print( "Error during subscribing tags \(error) ")
                                    
                                    self.sendNotifToDisplayResponse( responseValue: "Error during subscribing tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                                }
                                
                            })
                        }
                        else {
                            print( "Error during retrieve tags \(error) ")
                            
                            self.sendNotifToDisplayResponse( responseValue: "Error during retrieve tags \n  - status code: \(statusCode) \n Error :\(error) \n")
                        }
                        
                        
                    })
                }
                else{
                    print( "Error during device registration \(error) ")
                    
                    self.sendNotifToDisplayResponse( responseValue: "Error during device registration \n  - status code: \(statusCode) \n Error :\(error) \n")
                }
            }
        }
        
        //Called if unable to register for APNS.
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            
            let message:NSString = "Error registering for push notifications: \(error.localizedDescription)" as NSString
            
            self.showAlert(title: "Registering for notifications", message: message)
  
        }
    
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
            
            let push =  BMSPushClient.sharedInstance
            
            let respJson = (userInfo as NSDictionary).value(forKey: "payload") as! String
            let data = respJson.data(using: String.Encoding.utf8)
            
            let jsonResponse:NSDictionary = try! JSONSerialization.jsonObject(with: data! , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            let messageId:String = jsonResponse.value(forKey: "nid") as! String
            push.sendMessageDeliveryStatus(messageId: messageId) { (res, ss, ee) in
                print("Send message status to the Push server")
            }
            
        }

    
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            
            let payLoad = ((((userInfo as NSDictionary).value(forKey: "aps") as! NSDictionary).value(forKey: "alert") as! NSDictionary).value(forKey: "body") as! NSString)
            
            self.showAlert(title: "Recieved Push notifications", message: payLoad)
            
            let push =  BMSPushClient.sharedInstance
            
            let respJson = (userInfo as NSDictionary).value(forKey: "payload") as! String
            let data = respJson.data(using: String.Encoding.utf8)
            
            let jsonResponse:NSDictionary = try! JSONSerialization.jsonObject(with: data! , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            let messageId:String = jsonResponse.value(forKey: "nid") as! String
            push.sendMessageDeliveryStatus(messageId: messageId) { (res, ss, ee) in
                completionHandler(UIBackgroundFetchResult.newData)
            }
        }
    
        func sendNotifToDisplayResponse (responseValue:String){
            
            responseText = responseValue
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "action"), object: self)
        }
    
    
        func showAlert (title:NSString , message:NSString){
            
            // create the alert
            let alert = UIAlertController.init(title: title as String, message: message as String, preferredStyle: alertStyle)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: actionStyle, handler: nil))
            
            // show the alert
            self.window!.rootViewController!.present(alert, animated: true, completion: nil)
        }
    
    #else
    
        func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            // Override point for customization after application launch.
            return true
        }
        func onChangePermission(status: Bool) {
            print("Notification came : " + "this is enabled: \(status)" as NSString)
        }
    
        func registerForPush () {
            
            let myBMSClient = BMSClient.sharedInstance
            myBMSClient.initialize(bluemixRegion: BMSClient.Region.usSouth)
    
            let push =  BMSPushClient.sharedInstance
            push.delegate = self
    
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
    
            let actionTwo = BMSPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
    
            let category = BMSPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])
    
            let notifOptions = BMSPushClientOptions(categoryName: [category])
            push.initializeWithAppGUID("YOUR_APP_GUID", clientSecret:"YOUR_APP_CLIENT_SECRET", options: notifOptions)
    
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

            push.registerWithDeviceToken(deviceToken) { (response, statusCode, error) -> Void in
                
                if error.isEmpty {
                    
                    print( "Response during device registration : \(response)")
    
                    print( "status code during device registration : \(statusCode)")
                    
                    self.sendNotifToDisplayResponse("Response during device registration json: \(response)")
                    
                    // MARK:    RETRIEVING AVAILABLE TAGS
                    
                    push.retrieveAvailableTagsWithCompletionHandler({ (response, statusCode, error) -> Void in
                        
                        if error.isEmpty {
                            
                            print( "Response during retrieve tags : \(response)")
                            
                            print( "status code during retrieve tags : \(statusCode)")
                            
                            self.sendNotifToDisplayResponse("Response during retrieve tags: \(response?.description)")
                            
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
    
        func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            
            let respJson = (userInfo as NSDictionary).valueForKey("payload") as! String
            let data = respJson.dataUsingEncoding(NSUTF8StringEncoding)
            
            do {
                let responseObject:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                let nid = responseObject.valueForKey("nid") as! String
                print(nid)
                
                let push =  BMSPushClient.sharedInstance
                
                push.sendMessageDeliveryStatus(nid, completionHandler: { (response, statusCode, error) in
                    
                    print("Send message status to the Push server")
                })
                
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
            
        }
        func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
            
            let payLoad = ((((userInfo as NSDictionary).valueForKey("aps") as! NSDictionary).valueForKey("alert") as! NSDictionary).valueForKey("body") as! NSString)
            
            self.showAlert("Recieved Push notifications", message: payLoad)
            
            
            let respJson = (userInfo as NSDictionary).valueForKey("payload") as! String
            let data = respJson.dataUsingEncoding(NSUTF8StringEncoding)
            
            do {
                let responseObject:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                let nid = responseObject.valueForKey("nid") as! String
                print(nid)
                
                let push =  BMSPushClient.sharedInstance
                
                push.sendMessageDeliveryStatus(nid, completionHandler: { (response, statusCode, error) in
                    completionHandler(UIBackgroundFetchResult.NewData)
                })
                
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
            
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

    
    #endif
    
}
