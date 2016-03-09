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

/**
 Used in the `BMSPushClient` class, the `IMFPushErrorvalues` denotes error in the requests.
 */
public enum IMFPushErrorvalues: Int {
    
    /// - IMFPushErrorInternalError: Denotes the Internal Server Error occured.
    case IMFPushErrorInternalError = 1
    
    /// - IMFPushErrorEmptyTagArray: Denotes the Empty Tag Array Error.
    case IMFPushErrorEmptyTagArray = 2
    
    /// - IMFPushRegistrationVerificationError: Denotes the Previous Push registration Error.
    case IMFPushRegistrationVerificationError = 3
    
    /// - IMFPushRegistrationError: Denotes the First Time Push registration Error.
    case IMFPushRegistrationError = 4
    
    /// - IMFPushRegistrationUpdateError: Denotes the Device updation Error.
    case IMFPushRegistrationUpdateError = 5
    
    /// - IMFPushRetrieveSubscriptionError: Denotes the Subscribed tags retrieval error.
    case IMFPushRetrieveSubscriptionError = 6
    
    /// - IMFPushRetrieveSubscriptionError: Denotes the Available tags retrieval error.
    case IMFPushRetrieveTagsError = 7
    
    /// - IMFPushTagSubscriptionError: Denotes the Tag Subscription error.
    case IMFPushTagSubscriptionError = 8
    
    /// - IMFPushTagUnsubscriptionError: Denotes the tag Unsubscription error.
    case IMFPushTagUnsubscriptionError = 9
    
    /// - BMSPushUnregitrationError: Denotes the Push Unregistration error.
    case BMSPushUnregitrationError = 10
}


/**
 A singleton that serves as an entry point to Bluemix client- Push service communication.
 */
public class BMSPushClient: NSObject {
    
    // MARK: Properties (Public)
    
    /// This singleton should be used for all `BMSPushClient` activity.
    public static let sharedInstance = BMSPushClient()
    
    
    public static var overrideServerHost = "";
    
    // MARK: Properties (private)
    
    /// `BMSClient` object.
    private var bmsClient = BMSClient.sharedInstance
    
    /// `Logger` object.
    private var loggerObject = Logger?()
    
    
    // MARK: Methods (Public)
    
    /**
    
    This Methode used to register the client device to the Bluemix Push service.
    
    Call this methode after successfully registering for remote push notification in the Apple Push
    Notification Service .
    
    - Parameter deviceToken: This is the response we get from the push registartion in APNS.
    - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
    */
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
        
        
        let urlBuilder = BMSPushUrlBuilder(applicationID: bmsClient.bluemixAppGUID!)
        
        let resourceURL:String = urlBuilder.getSubscribedDevicesUrl(devId)
        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
        
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
                    
                    let resourceURL:String = urlBuilder.getDevicesUrl()

                    let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
                    
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
                        
                        let resourceURL:String = urlBuilder.getSubscribedDevicesUrl(devId)
                        
                        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
                        
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
    
    /**
     
     This Method used to Retrieve all the available Tags in the Bluemix Push Service.
     
     This methode will return the list of available Tags in an Array.
     
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableArray), StatusCode (Int) and error (string).
     */
    public func retrieveAvailableTagsWithCompletionHandler (completionHandler: (response:NSMutableArray, statusCode:Int, error:String) -> Void){
        
        
        self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Entering retrieveAvailableTagsWithCompletitionHandler.")
        
        let urlBuilder = BMSPushUrlBuilder(applicationID: bmsClient.bluemixAppGUID!)
        
        let resourceURL:String = urlBuilder.getTagsUrl()
        
        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
        
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
    
    /**
     
     This Methode used to Subscribe to the Tags in the Bluemix Push srvice.
     
     
     This methode will return the list of subscribed tags. If you pass the tags that are not present in the Bluemix App it will be classified under the TAGS NOT FOUND section in the response.
     
     - parameter tagsArray: the array that contains name tags.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableDictionary), StatusCode (Int) and error (string).
     */
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
            
            let urlBuilder = BMSPushUrlBuilder(applicationID: bmsClient.bluemixAppGUID!)
            let resourceURL:String = urlBuilder.getSubscriptionsUrl()
            
            let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
            
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
    
    
    /**
     
     This Methode used to Retrieve the Subscribed Tags in the Bluemix Push srvice.
     
     
     This methode will return the list of subscribed tags.
     
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableArray), StatusCode (Int) and error (string).
     */
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
        
        let urlBuilder = BMSPushUrlBuilder(applicationID: bmsClient.bluemixAppGUID!)
        let resourceURL:String = urlBuilder.getAvailableSubscriptionsUrl(devId)
        
        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
        
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
    
    /**
     
     This Methode used to Unsubscribe from the Subscribed Tags in the Bluemix Push srvice.
     
     
     This methode will return the details of Unsubscription status.
     
     - Parameter tagsArray: The list of tags that need to be unsubscribed.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableDictionary), StatusCode (Int) and error (string).
     */
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
            
            let urlBuilder = BMSPushUrlBuilder(applicationID: bmsClient.bluemixAppGUID!)
            let resourceURL:String = urlBuilder.getUnSubscribetagsUrl()
            
            let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
            
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
    
    /**
     
     This Methode used to UnRegister the client App from the Bluemix Push srvice.
     
     
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
     */
    public func unregisterDevice (completionHandler: (response:String, statusCode:Int, error:String) -> Void) {
        
        
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
        
        let urlBuilder = BMSPushUrlBuilder(applicationID: bmsClient.bluemixAppGUID!)
        let resourceURL:String = urlBuilder.getUnregisterUrl(devId)
        
        let headers = [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
        
        let method =  HttpMethod.DELETE
        
        let getRequest = MFPRequest(url: resourceURL, headers: headers, queryParameters: nil, method: method, timeout: 60)
        
        
        getRequest.sendWithCompletionHandler ({ (response, error) -> Void in
            
            if let responseError = error {
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Error while unregistering device - Error is: \(responseError.description)")
                
                completionHandler(response:"", statusCode: IMFPushErrorvalues.BMSPushUnregitrationError.rawValue,error: "Error while unregistering device - Error is: \(responseError.description)")
                
                
            } else {
                
                let status = response!.statusCode ?? 0
                let responseText = response!.responseText ?? ""
                
                self.sendAnalyticsdata(IMFPUSH_CLIENT, stringData: "Successfully unregistered the device. - Response is: \(response?.responseText)")
                completionHandler(response: responseText, statusCode: status, error: "")
                
            }
        })
    }
    
    
    // MARK: Methods (Internal)
    
    //Begin Logger implementation
    
    /**
    Send the Logger info when the client app come from Background state to Active state.
    */
    internal func appEnterActive () {
        
        self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "Application Enter Active.")
        
        let messageID:String = ""
        
        BMSPushUtils.generateMetricsEvents(IMFPUSH_OPEN, messageId: messageID, timeStamp: BMSPushUtils.generateTimeStamp())
        
    }
    
    /**
     Send the Logger info when the client app goes Background state from Active state.
     */
    internal func appEnterBackground () {
        
        
        self.sendAnalyticsdata(IMFPUSH_APP_MANAGER, stringData: "Application Enter Background. Sending analytics information to server.")
        
    }
    
    /**
     Send the Logger info while the app is opened by clicking the notification.
     */
    internal func appOpenedFromNotificationClick (notification:NSNotification){
        
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
    
    /**
     Assigning Re-Write Domain.
     */
    internal func buildRewriteDomain() -> String {
        return BMSClient.sharedInstance.bluemixRegion!
    }
    
    // TODO: This should be changed
    internal func sendAnalyticsdata (firstData:String, stringData:AnyObject?){
        
        loggerObject?.info(stringData as! String)
    }
    
}
