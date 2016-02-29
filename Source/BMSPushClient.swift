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

public let IMFPushErrorDomain:String = "com.ibm.mobilefoundation.push"

public enum IMFPushErrorvalues: Int {
    case IMFPushErrorInternalError					= 1
    case IMFPushErrorInvalidToken					= 2
    case IMFPushErrorRemoteNotificationsNotSupported = 3
    case IMFPushErrorEmptyTagArray                   = 4
    case IMFPushRegistrationVerificationError        = 5
    case IMFPushRegistrationError                    = 6
    case IMFPushRegistrationUpdateError              = 7
    case IMFPushRetrieveSubscriptionError            = 8
    case IMFPushRetrieveTagsError                    = 9
    case IMFPushTagSubscriptionError                 = 10
    case IMFPushTagUnsubscriptionError               = 11
    case BMSPushUnregitrationError                   = 12
}

public class BMSPushClient: NSObject {
    
    public static let sharedInstance = BMSPushClient()
    
    var client = BMSClient.sharedInstance
    
    var loggerObject = Logger?()
    
    public func registerDeviceToken (deviceToken:NSData, completionHandler: (response:String, statusCode:Int, error:String) -> Void) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("appEnterActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("appEnterBackground"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("appOpenedFromNotificationClick"), name: UIApplicationDidFinishLaunchingNotification, object: nil)
        
        // Generate new ID
        // TODO: This need to be verified. The Device Id is not storing anywhere in BMSCore
        
        var devId = String()
        
        if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("deviceId") as? String {
            
            devId = returnValue
        }
        else{
            devId = NSUUID().UUIDString
            NSUserDefaults.standardUserDefaults().setObject(devId, forKey: "deviceId")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // TODO: This need to be verified. The Device Id is not storing anywhere in BMSCore
        
        //let authManager: AuthorizationManager = BMSClient.sharedInstance.sharedAuthorizationManager
        /*
        if devId.isEmpty {
        
        
        devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("id") as! String
        
        if devId.isEmpty {
        
        devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("deviceId") as! String
        }
        
        }*/
        
        
        var token:String = deviceToken.description
        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        token = token.stringByReplacingOccurrencesOfString(">", withString: "")
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
        
        let resourceURL:String = "\(client.bluemixAppRoute!)/\(IMFPUSH_PUSH_WORKS_SERVER_CONTEXT)/\(client.bluemixAppGUID!)/\(IMFPUSH_DEVICES)/\(devId)"
        
        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON, IMFPUSH_X_REWRITE_DOMAIN: self.buildRewriteDomain()]
        
        let method =  HttpMethod.GET
        
        
        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Verifying previous device registration.")
        
        let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
        
        // MARK: FIrst Action, checking for previuos registration
        
        getRequest.sendWithCompletionHandler ({ (response: Response?, error: NSError?) -> Void in
            
            if let responseError = error {
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error while verifying previous registration - Error is: \(responseError.localizedDescription)")
                
                completionHandler(response: "", statusCode: IMFPushErrorvalues.IMFPushRegistrationVerificationError.rawValue , error: "Error while verifying previous registration - Error is: \(responseError.localizedDescription)")
                
            }
            else if response != nil {
                
                let status = response!.statusCode ?? 0
                let responseText = response!.responseText ?? ""
                
                
                if (status == 404) {
                    
                    
                    self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Device is not registered before.  Registering for the first time.")
                    
                    let resourceURL:String = "\(self.client.bluemixAppRoute!)/\(IMFPUSH_PUSH_WORKS_SERVER_CONTEXT)/\(self.client.bluemixAppGUID!)/\(IMFPUSH_DEVICES)"
                    
                    let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON, IMFPUSH_X_REWRITE_DOMAIN: self.buildRewriteDomain()]
                    
                    let method =  HttpMethod.POST
                    
                    let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
                    
                    
                    let dict:NSMutableDictionary = NSMutableDictionary()
                    
                    dict.setValue(devId, forKey: IMFPUSH_DEVICE_ID)
                    dict.setValue(token, forKey: IMFPUSH_TOKEN)
                    dict.setValue("A", forKey: IMFPUSH_PLATFORM)
                    
                    // here "jsonData" is the dictionary encoded in JSON data
                    let jsonData = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
                    
                    // here "jsonData" is convereted to string
                    let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
                    
                    
                    // MARK: Registering for the First Time
                    
                    getRequest.sendString(jsonString , withCompletionHandler: { (response: Response?, error: NSError?) -> Void in
                        
                        
                        
                        if let responseError = error  {
                            
                            
                            self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error during device registration - Error is: \(responseError.localizedDescription)")
                            
                            completionHandler(response: "", statusCode: IMFPushErrorvalues.IMFPushRegistrationError.rawValue, error: "Error during device registration - Error is: \(responseError.localizedDescription)")
                            
                        } else {
                            
                            let status = response!.statusCode ?? 0
                            let responseText = response!.responseText ?? ""
                            
                            self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Response of device registration - Response is: \(responseText)")
                            
                            completionHandler(response: responseText, statusCode: status, error: "")
                        }
                        
                    })
                    
                }
                else if (status == 406) || (status == 500) {
                    
                    
                    self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error while verifying previous registration - Error is: \(error!.localizedDescription)")
                    
                    completionHandler(response: responseText, statusCode: status, error: "")
                }
                else {
                    
                    // MARK: device is already Registered
                    
                    print("\n \n Device is already registered. Return the device Id - Response is: \(response?.responseText)")
                    
                    
                    self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Device is already registered. Return the device Id - Response is: \(response?.responseText)")
                    
                    let respJson = response!.responseText
                    let data = respJson!.dataUsingEncoding(NSUTF8StringEncoding)
                    let jsonResponse:NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    
                    let rToken = jsonResponse.objectForKey(IMFPUSH_TOKEN) as! String
                    let devId = jsonResponse.objectForKey(IMFPUSH_DEVICE_ID) as! String
                    
                    
                    // TODO: Check for consumer or User Identity check. We need to figure this out
                    
                    let consumerId:String = ""
                    
                    
                    /*
                    if let consumerIdfromResponse = (authManager.getUserIdentity() as? NSDictionary)!.valueForKey(IMFPUSH_DISPLAYNAME) {
                    
                    consumerId = consumerIdfromResponse as! String
                    
                    }
                    */
                    
                    var shouldEnterLoop:Bool = false
                    
                    if (rToken.compare(token)) != NSComparisonResult.OrderedSame {
                        
                        shouldEnterLoop = true
                    }
                    /*
                    
                    else if (!consumerId.isEmpty){
                    
                    if ((consumerId.compare(jsonResponse.objectForKey(IMFPUSH_USER_ID) as! String))) != NSComparisonResult.OrderedSame {
                    shouldEnterLoop = true
                    }
                    }
                    */
                    // MARK: Only for testing
                    // shouldEnterLoop = true
                    
                    if shouldEnterLoop {
                        
                        // MARK: Updating the registered device , token or deviceId changed
                        
                        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Device token or DeviceId has changed. Sending update registration request.")
                        
                        
                        let resourceURL:String = "\(self.client.bluemixAppRoute!)/\(IMFPUSH_PUSH_WORKS_SERVER_CONTEXT)/\(self.client.bluemixAppGUID!)/\(IMFPUSH_DEVICES)/\(devId)"
                        
                        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON, IMFPUSH_X_REWRITE_DOMAIN: self.buildRewriteDomain()]
                        
                        let method =  HttpMethod.PUT
                        
                        let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
                        
                        
                        let dict:NSMutableDictionary = NSMutableDictionary()
                        
                        dict.setValue(token, forKey: IMFPUSH_TOKEN)
                        dict.setValue(consumerId, forKey: IMFPUSH_USER_ID)
                        dict.setValue(devId, forKey: IMFPUSH_DEVICE_ID)
                        
                        
                        let jsonData = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
                        
                        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
                        
                        getRequest.sendString(jsonString , withCompletionHandler: { (response: Response?, error: NSError?) -> Void in
                            
                            
                            
                            if let responseError = error {
                                
                                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error during device updatation - Error is : \(responseError.description)")
                                
                                completionHandler(response: "", statusCode: IMFPushErrorvalues.IMFPushRegistrationUpdateError.rawValue, error: "Error during device updatation - Error is : \(responseError.description)")
                            }
                            else {
                                
                                let status = response!.statusCode ?? 0
                                let responseText = response!.responseText ?? ""
                                
                                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Response of device updation - Response is: \(responseText)")
                                
                                completionHandler(response: responseText, statusCode: status, error: "")
                            }
                            
                        })
                        
                    } else {
                        // MARK: device already registered and parameteres not changed.
                        
                        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Device is already registered and device registration parameters not changed.")
                        
                        completionHandler(response: "Device is already registered and device registration parameters not changed", statusCode: status, error: "")
                    }
                }
                
            }
        })
    }
    
    public func retrieveSubscriptionsWithCompletionHandler (completionHandler: (response:NSMutableArray, statusCode:Int, error:String) -> Void) {
        
        
        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Entering retrieveSubscriptionsWithCompletitionHandler.")
        
        
        var devId = String()
        
        if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("deviceId") as? String {
            
            devId = returnValue
        }
        else{
            devId = NSUUID().UUIDString
            NSUserDefaults.standardUserDefaults().setObject(devId, forKey: "deviceId")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // TODO: This need to be verified. The Device Id is not storing anywhere in BMSCore
        
        //let authManager: AuthorizationManager = BMSClient.sharedInstance.sharedAuthorizationManager
        
        /* var devId = String()
        
        let authManager: AuthorizationManager = BMSClient.sharedInstance.sharedAuthorizationManager
        
        if devId.isEmpty {
        
        
        devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("id") as! String
        
        if devId.isEmpty {
        
        devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("deviceId") as! String
        }
        
        }
        */
        
        let resourceURL:String = "\(self.client.bluemixAppRoute!)/\(IMFPUSH_PUSH_WORKS_SERVER_CONTEXT)/\(self.client.bluemixAppGUID!)/\(IMFPUSH_SUBSCRIPTIONS)?deviceId=\(devId)"
        
        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON, IMFPUSH_X_REWRITE_DOMAIN: self.buildRewriteDomain()]
        
        let method =  HttpMethod.GET
        
        let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
        
        
        getRequest.sendWithCompletionHandler({ (response: Response?, error: NSError?) -> Void in
            
            var subscriptionArray = NSMutableArray()
            
            if let responseError = error {
                
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error while retrieving subscriptions - Error is: \(responseError.localizedDescription)")
                
                completionHandler(response: subscriptionArray, statusCode: IMFPushErrorvalues.IMFPushRetrieveSubscriptionError.rawValue,error: "Error while retrieving subscriptions - Error is: \(responseError.localizedDescription)")
                
            } else{
                
                let status = response!.statusCode ?? 0
                let responseText = response!.responseText ?? ""
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Subscription retrieved successfully - Response is: \(responseText)")
                
                subscriptionArray = response!.subscriptions()
                
                completionHandler(response: subscriptionArray, statusCode: status, error: "")
            }
        })
    }
    
    
    public func retrieveAvailableTagsWithCompletionHandler (completionHandler: (response:NSMutableArray, statusCode:Int, error:String) -> Void){
        
        
        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Entering retrieveAvailableTagsWithCompletitionHandler.")
        
        
        let resourceURL:String = "\(self.client.bluemixAppRoute!)/\(IMFPUSH_PUSH_WORKS_SERVER_CONTEXT)/\(self.client.bluemixAppGUID!)/\(IMFPUSH_TAGS)"
        
        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON, IMFPUSH_X_REWRITE_DOMAIN: self.buildRewriteDomain()]
        
        let method =  HttpMethod.GET
        
        let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
        
        
        getRequest.sendWithCompletionHandler ({ (response, error) -> Void in
            
            var availableTagsArray = NSMutableArray()
            
            if let responseError = error  {
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error while retrieving available tags - Error is: \(responseError.description)")
                
                completionHandler(response: availableTagsArray, statusCode: IMFPushErrorvalues.IMFPushRetrieveTagsError.rawValue,error: "Error while retrieving available tags - Error is: \(responseError.description)")
                
            } else {
                
                let status = response!.statusCode ?? 0
                let responseText = response!.responseText ?? ""
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Successfully retrieved available tags - Response is: \(responseText)")
                
                availableTagsArray = response!.availableTags()
                
                completionHandler(response: availableTagsArray, statusCode: status, error: "")
            }
        })
    }
    
    public func subscribeToTags (tagsArray:NSArray, completionHandler: (response:NSMutableDictionary, statusCode:Int, error:String) -> Void) {
        
        
        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Entering: subscribeToTags.")
        
        var subscriptionResponse = NSMutableDictionary()
        
        if tagsArray.count != 0 {
            
            var devId = String()
            
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("deviceId") as? String {
                
                devId = returnValue
            }
            else{
                devId = NSUUID().UUIDString
                NSUserDefaults.standardUserDefaults().setObject(devId, forKey: "deviceId")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            
            // TODO: This need to be verified. The Device Id is not storing anywhere in BMSCore
            
            /*
            var devId = String()
            
            let authManager: AuthorizationManager = BMSClient.sharedInstance.sharedAuthorizationManager
            
            if devId.isEmpty {
            
            
            devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("id") as! String
            
            if devId.isEmpty {
            
            devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("deviceId") as! String
            }
            
            }
            */
            
            let resourceURL:String = "\(self.client.bluemixAppRoute!)/\(IMFPUSH_PUSH_WORKS_SERVER_CONTEXT)/\(self.client.bluemixAppGUID!)/\(IMFPUSH_SUBSCRIPTIONS)"
            
            let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON, IMFPUSH_X_REWRITE_DOMAIN: self.buildRewriteDomain()]
            
            let method =  HttpMethod.POST
            
            let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
            
            
            let dict:NSMutableDictionary = NSMutableDictionary()
            
            dict.setValue(tagsArray, forKey: IMFPUSH_TAGNAMES)
            dict.setValue(devId, forKey: IMFPUSH_DEVICE_ID)
            
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
            
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
            
            getRequest.sendString(jsonString, withCompletionHandler: { (response, error) -> Void in
                
                if let responseError = error {
                    
                    self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error while subscribing to tags - Error is: \(responseError.description)")
                    
                    completionHandler(response: subscriptionResponse, statusCode: IMFPushErrorvalues.IMFPushTagSubscriptionError.rawValue,error: "Error while retrieving available tags - Error is: \(responseError.description)")
                    
                } else {
                    
                    let status = response!.statusCode ?? 0
                    let responseText = response!.responseText ?? ""
                    self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Successfully subscribed to tags - Response is: \(responseText)")
                    
                    subscriptionResponse = response!.subscribeStatus()
                    
                    completionHandler(response: subscriptionResponse, statusCode: status, error: "")
                }
            })
            
        } else {
            
            self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error.  Tag array cannot be null. Create tags in your Bluemix App")
            
            completionHandler(response: subscriptionResponse, statusCode: IMFPushErrorvalues.IMFPushErrorEmptyTagArray.rawValue, error: "Error.  Tag array cannot be null. Create tags in your Bluemix App")
        }
    }
    
    
    public func unsubscribeFromTags (tagsArray:NSArray, completionHandler: (response:NSMutableDictionary, statusCode:Int, error:String) -> Void) {
        
        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Entering: unsubscribeFromTags")
        
        var unSubscriptionResponse = NSMutableDictionary()
        
        if tagsArray.count != 0 {
            
            
            var devId = String()
            
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("deviceId") as? String {
                
                devId = returnValue
            }
            else{
                devId = NSUUID().UUIDString
                NSUserDefaults.standardUserDefaults().setObject(devId, forKey: "deviceId")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            
            /*
            var devId = String()
            
            let authManager: AuthorizationManager = BMSClient.sharedInstance.sharedAuthorizationManager
            
            if devId.isEmpty {
            
            
            devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("id") as! String
            
            if devId.isEmpty {
            
            devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("deviceId") as! String
            }
            }
            */
            
            
            let resourceURL:String = "\(self.client.bluemixAppRoute!)/\(IMFPUSH_PUSH_WORKS_SERVER_CONTEXT)/\(self.client.bluemixAppGUID!)/\(IMFPUSH_SUBSCRIPTIONS)?\(IMFPUSH_ACTION_DELETE)"
            
            let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON, IMFPUSH_X_REWRITE_DOMAIN: self.buildRewriteDomain()]
            
            let method =  HttpMethod.POST
            
            let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
            
            
            let dict:NSMutableDictionary = NSMutableDictionary()
            
            dict.setValue(tagsArray, forKey: IMFPUSH_TAGNAMES)
            dict.setValue(devId, forKey: IMFPUSH_DEVICE_ID)
            
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
            
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
            
            getRequest.sendString(jsonString, withCompletionHandler: { (response, error) -> Void in
                
                if let responseError = error {
                    
                    self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error while unsubscribing from tags - Error is: \(responseError.description)")
                    
                    completionHandler(response: unSubscriptionResponse, statusCode: IMFPushErrorvalues.IMFPushTagUnsubscriptionError.rawValue,error: "Error while retrieving available tags - Error is: \(responseError.description)")
                } else {
                    
                    let status = response!.statusCode ?? 0
                    let responseText = response!.responseText ?? ""
                    
                    self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Successfully unsubscribed from tags - Response is: \(responseText)")
                    
                    unSubscriptionResponse = response!.unsubscribeStatus()
                    
                    completionHandler(response: unSubscriptionResponse, statusCode: status, error: "")
                }
                
            })
            
        } else {
            
            self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error.  Tag array cannot be null.")
            
            completionHandler(response: unSubscriptionResponse, statusCode: IMFPushErrorvalues.IMFPushErrorEmptyTagArray.rawValue, error: "Error.  Tag array cannot be null.")
        }
    }
    
    public func unregisterDevice (completionHandler: (response:String, statusCode:Int) -> Void) {
        
        
        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Entering unregisterDevice.")
        
        var devId = String()
        
        if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("deviceId") as? String {
            
            devId = returnValue
        }
        else{
            devId = NSUUID().UUIDString
            NSUserDefaults.standardUserDefaults().setObject(devId, forKey: "deviceId")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        /*
        var devId = String()
        
        let authManager: AuthorizationManager = BMSClient.sharedInstance.sharedAuthorizationManager
        
        if devId.isEmpty {
        
        
        devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("id") as! String
        
        if devId.isEmpty {
        
        devId = (authManager.getDeviceIdentity() as! NSDictionary).valueForKey("deviceId") as! String
        }
        }
        */
        let resourceURL:String = "\(self.client.bluemixAppRoute!)/\(IMFPUSH_PUSH_WORKS_SERVER_CONTEXT)/\(self.client.bluemixAppGUID!)/\(IMFPUSH_DEVICES)/\(devId)"
        
        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON, IMFPUSH_X_REWRITE_DOMAIN: self.buildRewriteDomain()]
        
        let method =  HttpMethod.DELETE
        
        let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
        
        
        getRequest.sendWithCompletionHandler ({ (response, error) -> Void in
            
            if let responseError = error {
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error while unregistering device - Error is: \(responseError.description)")
                
                completionHandler(response:"Error while unregistering device - Error is: \(responseError.description)", statusCode: IMFPushErrorvalues.BMSPushUnregitrationError.rawValue)
                
                
            } else {
                
                let status = response!.statusCode ?? 0
                let responseText = response!.responseText ?? ""
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Successfully unregistered the device. - Response is: \(response?.responseText)")
                completionHandler(response: responseText, statusCode: status)
                
            }
        })
    }
    
    //Begin Analytics API implementation
    
    func appEnterActive () {
        
        self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "Application Enter Active.")
        
        let messageID:String = ""
        
        BMSPushUtils.generateMetricsEvents(IMFPUSH_OPEN, messageId: messageID, timeStamp: BMSPushUtils.generateTimeStamp())
        
    }
    
    func appEnterBackground () {
        
        
        self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "Application Enter Background. Sending analytics information to server.")
        
        
    }
    
    
    func applicationRecievedPush (application:UIApplication, userInfo: [NSObject : AnyObject] ){
        
        let messageId = (userInfo as NSDictionary).objectForKey("nid") as! String
        BMSPushUtils.generateMetricsEvents(IMFPUSH_RECEIVED, messageId: messageId, timeStamp: BMSPushUtils.generateTimeStamp())
        
        if (application.applicationState == UIApplicationState.Active){
            
            
            self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "Push notification received when application is in active state.")
            
            
            BMSPushUtils.generateMetricsEvents(IMFPUSH_SEEN, messageId: messageId, timeStamp: BMSPushUtils.generateTimeStamp())
        }
        
        let pushStatus:Bool = BMSPushUtils.getPushSettingValue()
        
        if pushStatus {
            
            self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "Push notification is enabled on device")
            
            BMSPushUtils.generateMetricsEvents(IMFPUSH_ACKNOWLEDGED, messageId: messageId, timeStamp: BMSPushUtils.generateTimeStamp())
        }
    }
    
    /*
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    
    print("got it")
    }
    func application (application:UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject] ){
    
    let messageId = (userInfo as NSDictionary).objectForKey("nid") as! String
    BMSPushUtils.generateMetricsEvents(IMFPUSH_RECEIVED, messageId: messageId, timeStamp: BMSPushUtils.generateTimeStamp())
    
    if (application.applicationState == UIApplicationState.Active){
    
    
    self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "Push notification received when application is in active state.")
    
    
    BMSPushUtils.generateMetricsEvents(IMFPUSH_SEEN, messageId: messageId, timeStamp: BMSPushUtils.generateTimeStamp())
    }
    
    let pushStatus:Bool = BMSPushUtils.getPushSettingValue()
    
    if pushStatus {
    
    self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "Push notification is enabled on device")
    
    BMSPushUtils.generateMetricsEvents(IMFPUSH_ACKNOWLEDGED, messageId: messageId, timeStamp: BMSPushUtils.generateTimeStamp())
    }
    }
    */
    
    
    func appOpenedFromNotificationClick (notification:NSNotification){
        
        let launchOptions: NSDictionary = notification.userInfo!
        if launchOptions.allKeys.count > 0  {
            
            let pushNotificationPayload:NSDictionary = launchOptions.valueForKey(UIApplicationLaunchOptionsRemoteNotificationKey) as! NSDictionary
            
            if pushNotificationPayload.allKeys.count > 0 {
                
                self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "App opened by clicking on push notification.")
                
                let messageId:NSString = pushNotificationPayload.objectForKey("nid") as! String
                BMSPushUtils.generateMetricsEvents(IMFPUSH_SEEN, messageId: messageId as String, timeStamp: BMSPushUtils.generateTimeStamp())
            }
        }
    }
    
    
    func buildRewriteDomain() -> String {
        
        let applicationRoute = client.bluemixAppRoute!
        var newRewriteDomain = ""
        
        if applicationRoute.isEmpty {
            return newRewriteDomain
        }
        
        // applicationRoute was not nil
        var actualApplicationRoute = applicationRoute
        
        if actualApplicationRoute.hasPrefix("http") == false {
            
            // Add https
            actualApplicationRoute = "https://\(actualApplicationRoute)"
        }
        else if ((actualApplicationRoute.hasPrefix("https") == false) && (actualApplicationRoute.rangeOfString("bluemix") != nil)){
            
            // Replace http with https
            
            let indexValue = actualApplicationRoute.startIndex.advancedBy(4)
            actualApplicationRoute = actualApplicationRoute.substringFromIndex(indexValue)
            
            actualApplicationRoute = "https\(actualApplicationRoute)"
        }
        
        let url = NSURL(string: actualApplicationRoute)
        
        if((url == nil)){
            
            let error = NSError!()
            
            NSException.raise("InvalidURLException", format: "Invalid applicationRoute: \(applicationRoute)", arguments: getVaList([error]))
        }
        
        var newBaasUrl:String = ""
        var regionInDomain:String = ".ng"
        
        // Determine whether a port should be added.
        
        //let port:NSNumber = url!.port!
        
        if let port:NSNumber = url!.port {
            
            newBaasUrl = "\(url!.scheme)://\(url!.host!):\(port)"
            
        }
        else{
            newBaasUrl = "\(url!.scheme)://\(url!.host!)"
        }
        
        // This is a subzone
        
        var subZone :String = ""
        
        if let subZoneIndex = actualApplicationRoute.characters.indexOf("=")?.successor() {
            
            subZone = actualApplicationRoute.substringFromIndex(subZoneIndex)
            
        }
        
        
        
        
        let hostElements:NSArray = url!.host!.componentsSeparatedByString(".")
        
        if newBaasUrl.rangeOfString(STAGE1) == nil {
            
            // Multi-region: myApp.eu-gb.mybluemix.net
            // US: myApp.mybluemix.net
            
            // this is production
            //  Multi-Region Eg: eu-gb.bluemix.net
            //  US Eg: ng.bluemix.net
            
            if hostElements.count == 4 {
                regionInDomain = (hostElements.objectAtIndex(hostElements.count - 3) as! String)+"."
            }
            else{
                regionInDomain = "ng."
            }
            newRewriteDomain = "\(regionInDomain)\(BLUEMIX_DOMAIN)"
            
            
        }
        else {
            
            // Multi-region: myApp.stage1.eu-gb.mybluemix.net
            // US: myApp.stage1.mybluemix.net
            
            if hostElements.count == 5 {
                regionInDomain = "."+(hostElements.objectAtIndex(hostElements.count - 3) as! String)
            }
            
            // this is internal to IBM
            
            if subZone.isEmpty == false {
                
                //  Multi-region Dev subzone Eg: stage1-Dev.eu-gb.bluemix.net
                //  US Dev subzone Eg: stage1-Dev.ng.bluemix.net
                
                newRewriteDomain = "\(STAGE1)-\(subZone)\(regionInDomain).\(BLUEMIX_DOMAIN)"
                
            }
            else {
                
                //  Multi-region Eg: stage1.eu-gb.bluemix.net
                //  US  Eg: stage1.ng.bluemix.net
                
                newRewriteDomain = "\(STAGE1)\(regionInDomain).\(BLUEMIX_DOMAIN)"
            }
        }
        
        return newRewriteDomain;
    }
    
    
    
    // TODO: This should be changed
    internal func sendAnalyticsdata (firstData:String, stringData:AnyObject?){
        
        loggerObject?.info(stringData as! String)
        
        print("\n \(stringData)")
        
    }
    
}
