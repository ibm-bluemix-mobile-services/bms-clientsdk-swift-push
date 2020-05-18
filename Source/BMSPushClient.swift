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

public protocol BMSPushObserver{
    func onChangePermission(status:Bool);
}
// MARK: - Swift 3 & Swift 4

#if swift(>=3.0)

import UserNotifications

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
 A singleton that serves as an entry point to IBM Cloud client-Push service communication.
 */
public class BMSPushClient: NSObject {
    
    // MARK: Properties (Public)
    
    #if swift(>=4.2)
    let bmsNotificationName = UIApplication.didBecomeActiveNotification
    let applicationBGstate =  UIApplication.State.background
    #else
    let bmsNotificationName = NSNotification.Name.UIApplicationDidBecomeActive
    let applicationBGstate =  UIApplicationState.background
    #endif
    
    /// This singleton should be used for all `BMSPushClient` activity.
    public static let sharedInstance = BMSPushClient()
    
    // Specifies the IBM Cloud push clientSecret value
    public private(set) var clientSecret: String?
    public private(set) var applicationId: String?
    public private(set) var bluemixDeviceId: String?
    
    // used to test in test zone and dev zone
    public static var overrideServerHost = "";
    
    private var _notificationOptions : BMSPushClientOptions?
    
    private var notificationOptions:BMSPushClientOptions? {
        get{
            return _notificationOptions
        }
        set(value){
            _notificationOptions = value
        }
    }
    
    // MARK: Properties (private)
    
    /// `BMSClient` object.
    private var bmsClient = BMSClient.sharedInstance
    
    // Notification Count
    private var notificationcount:Int = 0
    
    private var isInitialized = false;
    
    public var delegate:BMSPushObserver?
    
    // MARK: Initializers
    
    /**
     The required intializer for the `BMSPushClient` class.
     
     This method will intialize the BMSPushClient with clientSecret based registration.
     
     - parameter clientSecret:    The clientSecret of the Push Service
     - parameter appGUID:    The pushAppGUID of the Push Service
     */
    public func initializeWithAppGUID (appGUID: String, clientSecret: String) {
        
        if validateString(object: clientSecret) {
            
            self.clientSecret = clientSecret
            self.applicationId = appGUID
            BMSPushUtils.saveValueToNSUserDefaults(value: appGUID, key: BMSPUSH_APP_GUID)
            BMSPushUtils.saveValueToNSUserDefaults(value: clientSecret, key: BMSPUSH_CLIENT_SECRET)
            isInitialized = true;
            self.bluemixDeviceId = ""
            
            
            if #available(iOS 10.0, *) {
                initPushCenter(UNUserNotificationCenter.current())
            } else {
                // Fallback on earlier versions
                initLowerPlatformPush()
            }
        }
        else{
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while registration - Client secret is not valid")
            print("Error while registration - Client secret is not valid")
            self.delegate?.onChangePermission(status: false)
        }
    }
    
    /**
     The required intializer for the `BMSPushClient` class.
     
     This method will intialize the BMSPushClient with clientSecret based registration and take in notificationOptions.
     
     - parameter clientSecret:    The clientSecret of the Push Service
     - parameter appGUID:    The pushAppGUID of the Push Service
     - parameter options: The push notification options
     */
    public func initializeWithAppGUID (appGUID: String, clientSecret: String, options: BMSPushClientOptions) {
        
        if validateString(object: clientSecret) {
            
            self.clientSecret = clientSecret
            self.applicationId = appGUID
            BMSPushUtils.saveValueToNSUserDefaults(value: appGUID, key: BMSPUSH_APP_GUID)
            BMSPushUtils.saveValueToNSUserDefaults(value: clientSecret, key: BMSPUSH_CLIENT_SECRET)
            isInitialized = true;
            let category : [BMSPushNotificationActionCategory] = options.category
            self.bluemixDeviceId = options.deviceId
            self.notificationOptions = options
            if !options.pushvariables.isEmpty && options.pushvariables.count > 0 {
                BMSPushUtils.saveValueToNSUserDefaults(value: options.pushvariables, key: IMFPUSH_VARIABLES)
                BMSPushUtils.saveValueToNSUserDefaults(value: true, key: HAS_IMFPUSH_VARIABLES)
            } else {
                BMSPushUtils.saveValueToNSUserDefaults(value: false, key: HAS_IMFPUSH_VARIABLES)
            }
            
            if #available(iOS 10.0, *) {
                
                let center = UNUserNotificationCenter.current()
                
                var notifCategory = Set<UNNotificationCategory>();
                
                for singleCategory in category {
                    
                    let categoryFirst : BMSPushNotificationActionCategory = singleCategory
                    let pushCategoryIdentifier : String = categoryFirst.identifier
                    let pushNotificationAction : [BMSPushNotificationAction] = categoryFirst.actions
                    var pushActionsArray = [UNNotificationAction]()
                    
                    for actionButton in pushNotificationAction {
                        
                        let newActionButton : BMSPushNotificationAction = actionButton
                        var options:UNNotificationActionOptions = .foreground
                        switch actionButton.activationMode {
                        case UIUserNotificationActivationMode.background:
                            options = .destructive
                        case UIUserNotificationActivationMode.foreground:
                            options = .foreground
                        }
                        let addButton = UNNotificationAction(identifier: newActionButton.identifier, title: newActionButton.title, options: [options])
                        pushActionsArray.append(addButton)
                    }
                    
                    let responseCategory = UNNotificationCategory(identifier: pushCategoryIdentifier, actions: pushActionsArray, intentIdentifiers: [])
                    notifCategory.insert(responseCategory)
                }
                
                if !notifCategory.isEmpty {
                    center.setNotificationCategories(notifCategory)
                }
                self.initPushCenter(center)
            } else {
                // Fallback on earlier versions
                
                var notifCategory = Set<UIUserNotificationCategory>();
                
                for singleCategory in category {
                    
                    let categoryFirst : BMSPushNotificationActionCategory = singleCategory
                    let pushNotificationAction : [BMSPushNotificationAction] = categoryFirst.actions
                    let pushCategoryIdentifier : String = categoryFirst.identifier
                    
                    var pushActionsArray = [UIUserNotificationAction]()
                    
                    for actionButton in pushNotificationAction {
                        
                        let newActionButton : BMSPushNotificationAction = actionButton
                        let addButton : UIMutableUserNotificationAction = UIMutableUserNotificationAction()
                        addButton.identifier = newActionButton.identifier
                        addButton.title = newActionButton.title
                        addButton.activationMode = newActionButton.activationMode
                        addButton.isAuthenticationRequired = newActionButton.authenticationRequired!
                        pushActionsArray.append(addButton)
                    }
                    
                    let responseCategory : UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
                    responseCategory.identifier = pushCategoryIdentifier
                    responseCategory.setActions(pushActionsArray, for:UIUserNotificationActionContext.default)
                    responseCategory.setActions(pushActionsArray, for:UIUserNotificationActionContext.minimal)
                    notifCategory.insert(responseCategory)
                }
                
                if notifCategory.isEmpty {
                    initLowerPlatformPush()
                    
                } else {
                    initLowerPlatformPush(notifCategory)
                }
                self.checkStatusChange()
            }
        }
        else{
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while registration - Client secret is not valid")
            print("Error while registration - Client secret is not valid")
            self.delegate?.onChangePermission(status: false)
        }
    }
    
    // MARK: Methods (Public)
    
    /**
     
     This Methode used to register the client device to the IBM Cloud Push service. This is the normal registration, without userId.
     
     Call this methode after successfully registering for remote push notification in the Apple Push
     Notification Service .
     
     - Parameter deviceToken: This is the response we get from the push registartion in APNS.
     - Parameter WithUserId: This is the userId value.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
     */
    public func registerWithDeviceToken(deviceToken:Data , WithUserId:String?, completionHandler: @escaping(_ response:String?, _ statusCode:Int?, _ error:String) -> Void) {
        
        if (isInitialized){
            
            if (validateString(object: WithUserId!)){
                
                let devId = self.getDeviceID()
                BMSPushUtils.saveValueToNSUserDefaults(value: devId, key: "deviceId")
                var token = ""
                for i in 0..<deviceToken.count {
                    token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
                }
                
                if !checkForCredentials() {
                    
                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while registration - Error is: push is not initialized")
                    completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue , "Error while registration - Error is: push is not initialized")
                    return
                    
                }
                let urlBuilder = BMSPushUrlBuilder(applicationID: self.applicationId!,clientSecret:self.clientSecret!)
                
                let resourceURL:String = urlBuilder.getSubscribedDevicesUrl(devID: devId)
                let headers = urlBuilder.addHeader()
                
                let method =  HttpMethod.GET
                
                self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Verifying previous device registration.")
                let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60)
                
                // MARK: FIrst Action, checking for previuos registration
                
                getRequest.send(completionHandler: { (response, error)  -> Void in
                    
                    if response?.statusCode != nil {
                        
                        let status = response?.statusCode ?? 0
                        let responseText = response?.responseText ?? ""
                        
                        
                        if (status == 404) {
                            
                            self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Device is not registered before.  Registering for the first time.")
                            let resourceURL:String = urlBuilder.getDevicesUrl()
                            
                            let headers = urlBuilder.addHeader()
                            
                            let method =  HttpMethod.POST
                            
                            let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60, cachePolicy: .useProtocolCachePolicy)
                            
                            var data:Data?
                            let variables = BMSPushUtils.getPushOptionsNSUserDefaults(key: IMFPUSH_VARIABLES)
                            if(variables.isEmpty) {
                                data =  "{\"\(IMFPUSH_DEVICE_ID)\": \"\(devId)\", \"\(IMFPUSH_TOKEN)\": \"\(token)\", \"\(IMFPUSH_PLATFORM)\": \"A\", \"\(IMFPUSH_USERID)\": \"\(WithUserId!)\"}".data(using: .utf8)
                            } else {
                                data =  "{\"\(IMFPUSH_DEVICE_ID)\": \"\(devId)\", \"\(IMFPUSH_TOKEN)\": \"\(token)\", \"\(IMFPUSH_PLATFORM)\": \"A\", \"\(IMFPUSH_USERID)\": \"\(WithUserId!)\", \"\(IMFPUSH_VARIABLES)\": \(variables)}".data(using: .utf8)
                            }
                            
                            // MARK: Registering for the First Time
                            
                            getRequest.send(requestBody: data!, completionHandler: { (response, error) -> Void in
                                
                                if response?.statusCode != nil {
                                    
                                    let status = response?.statusCode ?? 0
                                    
                                    if (status == 201){
                                        let responseText = response?.responseText ?? ""
                                        self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Response of device registration - Response is: \(responseText)")
                                        completionHandler(responseText, status, "")
                                    }else{
                                        self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error during device registration - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                                        completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue, "Error during device registration - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                                    }
                                }
                                else if let responseError = error {
                                    
                                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error during device registration - Error is: \(responseError.localizedDescription)")
                                    completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue, "Error during device registration - Error is: \(responseError.localizedDescription)")
                                }
                            })
                            
                        }else if (status == 200){
                            
                            // MARK: device is already Registered
                            
                            self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Device is already registered. Return the device Id - Response is: \(String(describing: response?.responseText))")
                            let respJson = response?.responseText
                            let data = respJson!.data(using: String.Encoding.utf8)
                            let jsonResponse:NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                            
                            let rToken = jsonResponse.object(forKey: IMFPUSH_TOKEN) as! String
                            let rDevId = jsonResponse.object(forKey: IMFPUSH_DEVICE_ID) as! String
                            let userId = jsonResponse.object(forKey: IMFPUSH_USERID) as! String
                            
                            if ((rToken.compare(token)) != ComparisonResult.orderedSame) ||
                                (!(WithUserId!.isEmpty) && (WithUserId!.compare(userId) != ComparisonResult.orderedSame)) || (devId.compare(rDevId) != ComparisonResult.orderedSame){
                                
                                // MARK: Updating the registered device ,userID, token or deviceId changed
                                
                                self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Device token or DeviceId has changed. Sending update registration request.")
                                let resourceURL:String = urlBuilder.getSubscribedDevicesUrl(devID: devId)
                                
                                let headers = urlBuilder.addHeader()
                                
                                let method =  HttpMethod.PUT
                                
                                let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60, cachePolicy: .useProtocolCachePolicy)
                                
                                var data:Data?
                                let variables = BMSPushUtils.getPushOptionsNSUserDefaults(key: IMFPUSH_VARIABLES)
                                if(variables.isEmpty) {
                                    data =   "{\"\(IMFPUSH_DEVICE_ID)\": \"\(devId)\", \"\(IMFPUSH_TOKEN)\": \"\(token)\", \"\(IMFPUSH_USERID)\": \"\(WithUserId!)\"}".data(using: .utf8)
                                } else {
                                    data =  "{\"\(IMFPUSH_DEVICE_ID)\": \"\(devId)\", \"\(IMFPUSH_TOKEN)\": \"\(token)\", \"\(IMFPUSH_USERID)\": \"\(WithUserId!)\", \"\(IMFPUSH_VARIABLES)\": \(variables)}".data(using: .utf8)
                                }
                                
                                
                                getRequest.send(requestBody: data!, completionHandler: { (response, error) -> Void in
                                    
                                    if response?.statusCode != nil  {
                                        
                                        let status = response?.statusCode ?? 0
                                        if (status == 200){
                                            let responseText = response?.responseText ?? ""
                                            self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Response of device registration - Response is: \(responseText)")
                                            completionHandler(responseText, status, "")
                                        }else{
                                            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error during device registration - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                                            completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue, "Error during device registration - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                                        }
                                    }
                                    else if let responseError = error {
                                        
                                        self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error during device updatation - Error is : \(responseError.localizedDescription)")
                                        completionHandler("", IMFPushErrorvalues.IMFPushRegistrationUpdateError.rawValue, "Error during device updatation - Error is : \(responseError.localizedDescription)")
                                    }
                                })
                            }
                            else {
                                // MARK: device already registered and parameteres not changed.
                                
                                self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Device is already registered and device registration parameters not changed.")
                                completionHandler(response?.responseText, status, "")
                            }
                        }
                        else{
                            
                            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while verifying previous registration - Error is: \(error!.localizedDescription)")
                            completionHandler("", status, responseText)
                        }
                    }
                    else if let responseError = error {
                        
                        self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while verifying previous registration - Error is: \(responseError.localizedDescription)")
                        completionHandler("", IMFPushErrorvalues.IMFPushRegistrationVerificationError.rawValue , "Error while verifying previous registration - Error is: \(responseError.localizedDescription)")
                    }
                })
            }else{
                
                self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while registration - Provide a valid userId value")
                completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue , "Error while registration - Provide a valid userId value")
            }
        }else{
            
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while registration - BMSPush is not initialized")
            completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue , "Error while registration - BMSPush is not initialized")
        }
        
    }
    
    
    /**
     This Methode used to register the client device to the IBM Cloud Push service. This is the normal registration, without userId.
     
     Call this methode after successfully registering for remote push notification in the Apple Push
     Notification Service .
     
     - Parameter deviceToken: This is the response we get from the push registartion in APNS.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
     */
    public func registerWithDeviceToken (deviceToken:Data, completionHandler: @escaping(_ response:String?, _ statusCode:Int?, _ error:String) -> Void) {
        
        if (isInitialized){
            let devId = self.getDeviceID()
            BMSPushUtils.saveValueToNSUserDefaults(value: devId, key: "deviceId")
            
            var token = ""
            for i in 0..<deviceToken.count {
                token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
            }
            
            if !checkForCredentials() {
                
                self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while  registration - Error is: push is not initialized")
                completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue , "Error while registration - Error is: push is not initialized")
                return
                
            }
            
            let urlBuilder = BMSPushUrlBuilder(applicationID: self.applicationId!,clientSecret:self.clientSecret!)
            
            let resourceURL:String = urlBuilder.getSubscribedDevicesUrl(devID: devId)
            let headers = urlBuilder.addHeader()
            
            let method =  HttpMethod.GET
            
            self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Verifying previous device registration.")
            let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60)
            
            // MARK: FIrst Action, checking for previuos registration
            getRequest.send(completionHandler: { (response, error)  -> Void in
                
                if response?.statusCode != nil {
                    
                    let status = response?.statusCode ?? 0
                    let responseText = response?.responseText ?? ""
                    
                    if (status == 404) {
                        
                        self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Device is not registered before.  Registering for the first time.")
                        let resourceURL:String = urlBuilder.getDevicesUrl()
                        
                        let headers = urlBuilder.addHeader()
                        
                        let method =  HttpMethod.POST
                        
                        let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60, cachePolicy: .useProtocolCachePolicy)
                        
                        let variables = BMSPushUtils.getPushOptionsNSUserDefaults(key: IMFPUSH_VARIABLES)
                        var data:Data?
                        if(variables.isEmpty) {
                            data =   "{\"\(IMFPUSH_DEVICE_ID)\": \"\(devId)\", \"\(IMFPUSH_TOKEN)\": \"\(token)\", \"\(IMFPUSH_PLATFORM)\": \"A\"}".data(using: .utf8)
                        } else {
                            data =  "{\"\(IMFPUSH_DEVICE_ID)\": \"\(devId)\", \"\(IMFPUSH_TOKEN)\": \"\(token)\", \"\(IMFPUSH_PLATFORM)\": \"A\", \"\(IMFPUSH_VARIABLES)\": \(variables)}".data(using: .utf8)
                        }
                        
                        
                        // MARK: Registering for the First Time
                        
                        getRequest.send(requestBody: data!, completionHandler: { (response, error)  -> Void in
                            
                            if response?.statusCode != nil {
                                
                                let status = response?.statusCode ?? 0
                                if (status == 201){
                                    let responseText = response?.responseText ?? ""
                                    self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Response of device registration - Response is: \(responseText)")
                                    completionHandler(responseText, status, "")
                                }else{
                                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error during device registration - Error code is: \(status) and error is: \(String(describing: response?.responseText)) ")
                                    completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue, "Error during device registration - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                                }
                                
                            }
                            else if let responseError = error {
                                
                                self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error during device registration - Error is: \(responseError.localizedDescription)")
                                completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue, "Error during device registration - Error is: \(responseError.localizedDescription)")
                            }
                        })
                        
                    }else if (status == 200){
                        
                        // MARK: device is already Registered
                        
                        self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Device is already registered. Return the device Id - Response is: \(String(describing: response?.responseText))")
                        let respJson = response?.responseText
                        let data = respJson!.data(using: String.Encoding.utf8)
                        let jsonResponse:NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                        
                        let rToken = jsonResponse.object(forKey: IMFPUSH_TOKEN) as! String
                        let rDevId = jsonResponse.object(forKey: IMFPUSH_DEVICE_ID) as! String
                        let userId = jsonResponse.object(forKey: IMFPUSH_USERID) as! String
                        
                        if ((rToken.compare(token)) != ComparisonResult.orderedSame) || (devId.compare(rDevId) != ComparisonResult.orderedSame) || (userId != "anonymous") {
                            
                            // MARK: Updating the registered userID , token or deviceId changed
                            
                            self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Device token or DeviceId has changed. Sending update registration request.")
                            let resourceURL:String = urlBuilder.getSubscribedDevicesUrl(devID: devId)
                            
                            let headers = urlBuilder.addHeader()
                            
                            let method =  HttpMethod.PUT
                            
                            let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60, cachePolicy: .useProtocolCachePolicy)
                            
                            var data:Data?
                            let variables = BMSPushUtils.getPushOptionsNSUserDefaults(key: IMFPUSH_VARIABLES)
                            if(variables.isEmpty) {
                                data =  "{\"\(IMFPUSH_DEVICE_ID)\": \"\(devId)\", \"\(IMFPUSH_TOKEN)\": \"\(token)\"}".data(using: .utf8)
                            } else {
                                data =  "{\"\(IMFPUSH_DEVICE_ID)\": \"\(devId)\", \"\(IMFPUSH_TOKEN)\": \"\(token)\", \"\(IMFPUSH_VARIABLES)\": \(variables)}".data(using: .utf8)
                            }
                            
                            getRequest.send(requestBody: data!, completionHandler: { (response, error)  -> Void in
                                
                                if response?.statusCode != nil  {
                                    
                                    let status = response?.statusCode ?? 0
                                    if (status == 200){
                                        let responseText = response?.responseText ?? ""
                                        self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Response of device registration - Response is: \(responseText)")
                                        completionHandler(responseText, status, "")
                                    }else{
                                        self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error during device registration - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                                        completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue, "Error during device registration - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                                    }
                                }
                                else if let responseError = error {
                                    
                                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error during device updatation - Error is : \(responseError.localizedDescription)")
                                    completionHandler("", IMFPushErrorvalues.IMFPushRegistrationUpdateError.rawValue, "Error during device updatation - Error is : \(responseError.localizedDescription)")
                                }
                            })
                        }
                        else {
                            // MARK: device already registered and parameteres not changed.
                            
                            self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Device is already registered and device registration parameters not changed.")
                            completionHandler(response?.responseText, status, "")
                        }
                    }else{
                        
                        self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while verifying previous registration - Error is: \(error!.localizedDescription)")
                        completionHandler("", status, responseText)
                    }
                }
                else if let responseError = error {
                    
                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while verifying previous registration - Error is: \(responseError.localizedDescription)")
                    completionHandler("", IMFPushErrorvalues.IMFPushRegistrationVerificationError.rawValue , "Error while verifying previous registration - Error is: \(responseError.localizedDescription)")
                }
            })
        }else{
            
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while registration - BMSPush is not initialized")
            completionHandler("", IMFPushErrorvalues.IMFPushRegistrationError.rawValue , "Error while registration - BMSPush is not initialized")
        }
    }
    
    /**
     This Method used to Retrieve all the available Tags in the IBM Cloud Push Service.
     
     This methode will return the list of available Tags in an Array.
     
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableArray), StatusCode (Int) and error (string).
     */
    public func retrieveAvailableTagsWithCompletionHandler (completionHandler: @escaping(_ response:NSMutableArray?, _ statusCode:Int?, _ error:String) -> Void){
        
        self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Entering retrieveAvailableTagsWithCompletitionHandler.")
        
       if !checkForCredentials() {
            
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while retrieving available tags - Error is: push is not initialized")
            completionHandler([], IMFPushErrorvalues.IMFPushRetrieveTagsError.rawValue , "Error while retrieving available tags - Error is: push is not initialized")
            return
            
        }
        let urlBuilder = BMSPushUrlBuilder(applicationID: self.applicationId!,clientSecret:self.clientSecret!)
        
        let resourceURL:String = urlBuilder.getTagsUrl()
        
        let headers = urlBuilder.addHeader()
        
        let method =  HttpMethod.GET
        
        let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60)
        
        getRequest.send(completionHandler:{ (response, error) -> Void in
            
            if response?.statusCode != nil {
                
                let status = response?.statusCode ?? 0
                if (status == 200){
                    let responseText = response?.responseText ?? ""
                    
                    self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Successfully retrieved available tags - Response is: \(responseText)")
                    let availableTagsArray = response?.availableTags()
                    completionHandler(availableTagsArray, status, "")
                    
                }else{
                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while retrieving available tags - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                    completionHandler([], IMFPushErrorvalues.IMFPushRetrieveTagsError.rawValue,"Error while retrieving available tags - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                }
                
            } else if let responseError = error {
                
                self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while retrieving available tags - Error is: \(responseError.localizedDescription)")
                completionHandler([], IMFPushErrorvalues.IMFPushRetrieveTagsError.rawValue,"Error while retrieving available tags - Error is: \(responseError.localizedDescription)")
                
            }
        })
    }
    
    /**
     This Methode used to Subscribe to the Tags in the IBM Cloud Push srvice.
     
     This methode will return the list of subscribed tags. If you pass the tags that are not present in the IBM Cloud App it will be classified under the TAGS NOT FOUND section in the response.
     
     - parameter tagsArray: the array that contains name tags.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableDictionary), StatusCode (Int) and error (string).
     */
    public func subscribeToTags (tagsArray:NSArray, completionHandler: @escaping (_ response:NSMutableDictionary?, _ statusCode:Int?, _ error:String) -> Void) {
        
        self.sendAnalyticsData(logType: LogLevel.debug, logStringData:"Entering: subscribeToTags." )
        
        if tagsArray.count != 0 {
            
            let devId = self.getDeviceID()
            
            if !checkForCredentials() {
                
                self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while subscribing to tags - Error is: push is not initialized")
                completionHandler([:], IMFPushErrorvalues.IMFPushTagSubscriptionError.rawValue , "Error while subscribing to tags - Error is: push is not initialized")
                return
                
            }
            
            let urlBuilder = BMSPushUrlBuilder(applicationID: self.applicationId!,clientSecret:self.clientSecret!)
            let resourceURL:String = urlBuilder.getSubscriptionsUrl()
            
            let headers = urlBuilder.addHeader()
            
            let method =  HttpMethod.POST
            
            let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60, cachePolicy: .useProtocolCachePolicy)
            
            let mappedArray = tagsArray.map{"\($0)"}.description;
            
            let data =  "{\"\(IMFPUSH_TAGNAMES)\":\(mappedArray), \"\(IMFPUSH_DEVICE_ID)\":\"\(devId)\"}".data(using: .utf8)
            
            getRequest.send(requestBody: data!, completionHandler: { (response, error) -> Void in
                
                if response?.statusCode != nil {
                    
                    let status = response?.statusCode ?? 0
                    if (status == 207){
                        let responseText = response?.responseText ?? ""
                        
                        self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Successfully subscribed to tags - Response is: \(responseText)")
                        let subscriptionResponse = response?.subscribeStatus()
                        
                        completionHandler(subscriptionResponse, status, "")
                        
                    }else{
                        self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while subscribing to tags - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                        completionHandler([:], IMFPushErrorvalues.IMFPushTagSubscriptionError.rawValue,"Error while subscribing to tags - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                    }
                    
                } else if let responseError = error {
                    
                    
                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while subscribing to tags - Error is: \(responseError.localizedDescription)")
                    completionHandler([:], IMFPushErrorvalues.IMFPushTagSubscriptionError.rawValue,"Error while subscribing to tags - Error is: \(responseError.localizedDescription)")
                }
            })
            
        } else {
            
            let subscriptionResponse = NSMutableDictionary()
            
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error.  Tag array cannot be null. Create tags in your IBM Cloud App")
            completionHandler(subscriptionResponse, IMFPushErrorvalues.IMFPushErrorEmptyTagArray.rawValue, "Error.  Tag array cannot be null. Create tags in your IBM Cloud App")
        }
    }
    
    
    /**
     
     This Methode used to Retrieve the Subscribed Tags in the IBM Cloud Push srvice.
     
     This methode will return the list of subscribed tags.
     
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableArray), StatusCode (Int) and error (string).
     */
    public func retrieveSubscriptionsWithCompletionHandler  (completionHandler: @escaping (_ response:NSMutableArray?, _ statusCode:Int?, _ error:String) -> Void) {
        
        self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Entering retrieveSubscriptionsWithCompletitionHandler.")
        
        let devId = self.getDeviceID()
        
        if !checkForCredentials() {
            
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while retrieving subscriptions - Error is: push is not initialized")
            completionHandler([], IMFPushErrorvalues.IMFPushTagSubscriptionError.rawValue , "Error while retrieving subscriptions - Error is: push is not initialized")
            return
            
        }
        
        let urlBuilder = BMSPushUrlBuilder(applicationID: self.applicationId!,clientSecret:self.clientSecret!)
        let resourceURL:String = urlBuilder.getAvailableSubscriptionsUrl(deviceId: devId)
        
        let headers = urlBuilder.addHeader()
        
        let method =  HttpMethod.GET
        
        let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60)
        
        getRequest.send(completionHandler: { (response, error) -> Void in
            
            if response?.statusCode != nil {
                let status = response?.statusCode ?? 0
                
                if (status == 200){
                    let responseText = response?.responseText ?? ""
                    
                    self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Subscription retrieved successfully - Response is: \(responseText)")
                    let subscriptionArray = response?.subscriptions()
                    
                    completionHandler(subscriptionArray, status, "")
                }else{
                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while retrieving subscriptions - Error codeis: \(status) and error is: \(String(describing: response?.responseText))")
                    completionHandler([], IMFPushErrorvalues.IMFPushRetrieveSubscriptionError.rawValue,"Error while retrieving subscriptions - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                }
                
            } else if let responseError = error {
                
                self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while retrieving subscriptions - Error is: \(responseError.localizedDescription)")
                
                completionHandler([], IMFPushErrorvalues.IMFPushRetrieveSubscriptionError.rawValue,"Error while retrieving subscriptions - Error is: \(responseError.localizedDescription)")
                
            }
        })
    }
    
    /**
     This Methode used to Unsubscribe from the Subscribed Tags in the IBM Cloud Push srvice.
     
     This methode will return the details of Unsubscription status.
     
     - Parameter tagsArray: The list of tags that need to be unsubscribed.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableDictionary), StatusCode (Int) and error (string).
     */
    public func unsubscribeFromTags (tagsArray:NSArray, completionHandler: @escaping (_ response:NSMutableDictionary?, _ statusCode:Int?, _ error:String) -> Void) {
        
        self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Entering: unsubscribeFromTags")
        
        if tagsArray.count != 0 {
            
            let devId = self.getDeviceID()
            
            if !checkForCredentials() {
                
                self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while unsubscribing from tags - Error is: push is not initialized")
                completionHandler([:], IMFPushErrorvalues.IMFPushTagUnsubscriptionError.rawValue , "Error while unsubscribing from tags - Error is: push is not initialized")
                return
                
            }
            
            let urlBuilder = BMSPushUrlBuilder(applicationID: self.applicationId!,clientSecret:self.clientSecret!)
            let resourceURL:String = urlBuilder.getUnSubscribetagsUrl()
            
            let headers = urlBuilder.addHeader()
            
            let method =  HttpMethod.POST
            
            let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60, cachePolicy: .useProtocolCachePolicy)
            
            let mappedArray = tagsArray.map{"\($0)"}.description;
            
            let data =  "{\"\(IMFPUSH_TAGNAMES)\":\(mappedArray), \"\(IMFPUSH_DEVICE_ID)\":\"\(devId)\"}".data(using: .utf8)
            
            getRequest.send(requestBody: data!, completionHandler: { (response, error)  -> Void in
                
                if response?.statusCode != nil {
                    
                    let status = response?.statusCode ?? 0
                    let responseText = response?.responseText ?? ""
                    
                    self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Successfully unsubscribed from tags - Response is: \(responseText)")
                    let unSubscriptionResponse = response?.unsubscribeStatus()
                    
                    completionHandler(unSubscriptionResponse, status, "")
                    
                } else if let responseError = error{
                    
                    let unSubscriptionResponse = NSMutableDictionary()
                    
                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while unsubscribing from tags - Error is: \(responseError.localizedDescription)")
                    completionHandler(unSubscriptionResponse, IMFPushErrorvalues.IMFPushTagUnsubscriptionError.rawValue,"Error while unsubscribing from tags - Error is: \(responseError.localizedDescription)")
                }
            })
        } else {
            
            let unSubscriptionResponse = NSMutableDictionary()
            
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error.  Tag array cannot be null.")
            completionHandler(unSubscriptionResponse, IMFPushErrorvalues.IMFPushErrorEmptyTagArray.rawValue, "Error.  Tag array cannot be null.")
        }
    }
    
    /**
     
     This Methode used to UnRegister the client App from the IBM Cloud Push srvice.
     
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
     */
    public func unregisterDevice  (completionHandler: @escaping (_ response:String?, _ statusCode:Int?, _ error:String) -> Void) {
        
        self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Entering unregisterDevice.")
        let devId = self.getDeviceID()
        
        if !checkForCredentials() {
            
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while unregistering device - Error is: push is not initialized")
            completionHandler("", IMFPushErrorvalues.IMFPushTagUnsubscriptionError.rawValue , "Error while unregistering device - Error is: push is not initialized")
            return
            
        }
        
        let urlBuilder = BMSPushUrlBuilder(applicationID: self.applicationId!,clientSecret:self.clientSecret!)
        let resourceURL:String = urlBuilder.getUnregisterUrl(deviceId: devId)
        
        let headers = urlBuilder.addHeader()
        
        let method =  HttpMethod.DELETE
        
        let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60)
        
        getRequest.send(completionHandler: { (response, error) -> Void in
            
            if response?.statusCode != nil {
                
                let status = response?.statusCode ?? 0
                
                if (status == 204){
                    let responseText = response?.responseText ?? ""
                    
                    self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Successfully unregistered the device. - Response is: \(String(describing: response?.responseText))")
                    
                    completionHandler(responseText, status, "")
                }else{
                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while unregistering device - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                    completionHandler("", IMFPushErrorvalues.BMSPushUnregitrationError.rawValue,"Error while unregistering device - Error code is: \(status) and error is: \(String(describing: response?.responseText))")
                }
            } else if let responseError = error  {
                
                self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Error while unregistering device - Error is: \(responseError.localizedDescription)")
                completionHandler("", IMFPushErrorvalues.BMSPushUnregitrationError.rawValue,"Error while unregistering device - Error is: \(responseError.localizedDescription)")
            }
        })
    }
    
    public func sendMessageDeliveryStatus (messageId:String, completionHandler: @escaping (_ response:String?, _ statusCode:Int?, _ error:String) -> Void) {
        
        self.sendAnalyticsData(logType: LogLevel.debug, logStringData: "Entering sendMessageDeliveryStatus.")
        let devId = self.getDeviceID()
        
       if !checkForCredentials() {
            
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Failed to update the message status - Error is: push is not initialized")
            completionHandler("", IMFPushErrorvalues.IMFPushTagUnsubscriptionError.rawValue , "Failed to update the message status - Error is: push is not initialized")
            return
            
        }
        
        let urlBuilder = BMSPushUrlBuilder(applicationID: self.applicationId!,clientSecret:self.clientSecret!)
        let resourceURL:String = urlBuilder.getSendMessageDeliveryStatus(messageId: messageId)
        
        let headers = urlBuilder.addHeader()
        
        let method =  HttpMethod.PUT
        
        var status = "";
        
        if (UIApplication.shared.applicationState == applicationBGstate){
            status = "SEEN";
        } else {
            status = "OPEN"
        }
        
        if !(status.isEmpty){
            let json = [
                IMFPUSH_DEVICE_ID : devId,
                IMFPUSH_STATUS : status
            ]
            
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            
            let getRequest = Request(url: resourceURL, method: method, headers: headers, queryParameters: nil, timeout: 60)
            
            getRequest.send(requestBody: data!, completionHandler: { (response, error)  -> Void in
                
                if response?.statusCode != nil {
                    
                    let responseText = response?.responseText ?? ""
                    
                    self.sendAnalyticsData(logType: LogLevel.info, logStringData: "Successfully updated the message status.  The response is: \(responseText)")
                    print("Successfully updated the message status.  The response is: "+responseText)
                    completionHandler(responseText,200,"")
                    
                } else if let responseError = error {
                    
                    self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Failed to update the message status.  The response is:  \(responseError.localizedDescription)")
                    print("Failed to update the message status.  The response is: "+responseError.localizedDescription)
                    completionHandler("",400,responseError.localizedDescription)
                }
            })
        } else{
            self.sendAnalyticsData(logType: LogLevel.error, logStringData: "Failed to update the message status.  The response is:  Status should be either SEEN or OPEN")
            print("Failed to update the message status.  The response is: Status should be either SEEN or OPEN")
        }
    }
    
    public func didReciveBMSPushNotification (userInfo: [AnyHashable : Any], completionHandler: @escaping (_ response:String?, _ error:String) -> Void) {
        
        
        //let payload = userInfo as NSDictionary
        
        
        guard let hasTemplate = userInfo["has-template"] as? Int  else {
            completionHandler("", "Not a template based push Notification")
            return  }
        
        if hasTemplate == 1 {
            
            let payload = userInfo as NSDictionary
            var additionalPaylaod: [AnyHashable : Any] = [:]
            var alertBody: String = ""
            var title: String = ""
            var subTitle: String = ""
            var categoryIdentifier: String = ""
            var sound: String = ""
            var attachmentURL:String = ""
            var badge:NSNumber = 0
            
            if let additionalJson = payload.value(forKey: "payload") as? [AnyHashable : Any], additionalJson.count != 0 {
                additionalPaylaod = additionalJson
            }
            
            guard let templateAps = payload.value(forKey: "template") as? NSDictionary, templateAps.count > 0 else {
                completionHandler("", "Get Template Json - Failed to get template based push notification")
                return
            }
            
            guard  let alertJson = templateAps.value(forKey: "alert") as? NSDictionary else {
                completionHandler("", "Get Alert Body - Failed to get template based push notification")
                return
            }
            
            if let message = alertJson.value(forKey: "body") as? String {
                alertBody = BMSPushUtils.checkTemplateNotifications(message);
            }
            
            if let titleValue = alertJson.value(forKey: "title") as? String {
                title = titleValue
            }
            
            if let subTitleValue = alertJson.value(forKey: "subTitle") as? String {
                subTitle = subTitleValue
            }
            
            if let soundValue = alertJson.value(forKey: "sound") as? String {
                sound = soundValue
            }
            
            if let attachmentUrlValue = payload.value(forKey: "attachment-url") as? String {
                attachmentURL = attachmentUrlValue
            }
            if let badgeValue = templateAps.value(forKey: "badge") as? NSNumber {
                badge = badgeValue
            }
            if let categoryValue = templateAps.value(forKey: "category") as? String {
                categoryIdentifier = categoryValue
            }
            
            if #available(iOS 10.0, *) {
                let localPush = BMSLocalPushNotification(body: alertBody, title: title, subtitle: subTitle, sound: sound, badge: badge, categoryIdentifier: categoryIdentifier, attachments: attachmentURL, userInfo: additionalPaylaod)
                localPush.showBMSPushNotification()
                completionHandler("", "Template push success")
            } else {
                completionHandler("", "Template based push is not supporte dbelow iOS10")
            }
        } else {
            completionHandler("", "Not a template based push Notification")
            return
        }
    }
    
    // MARK: Methods (Internal)
    
    //Begin Logger implementation
    
    // Setting Log info
    internal func sendAnalyticsData (logType:LogLevel, logStringData:String){
        let devId = self.getDeviceID()
        let testLogger = Logger.logger(name:devId)
        if (logType == LogLevel.debug){
            Logger.logLevelFilter = LogLevel.debug
            testLogger.debug(message: logStringData)
        } else if (logType == LogLevel.error){
            Logger.logLevelFilter = LogLevel.error
            testLogger.error(message: logStringData)
        } else if (logType == LogLevel.analytics){
            Logger.logLevelFilter = LogLevel.analytics
            testLogger.debug(message: logStringData)
        } else if (logType == LogLevel.fatal){
            Logger.logLevelFilter = LogLevel.fatal
            testLogger.fatal(message: logStringData)
        } else if (logType == LogLevel.warn){
            Logger.logLevelFilter = LogLevel.warn
            testLogger.warn(message: logStringData)
        } else if (logType == LogLevel.info){
            Logger.logLevelFilter = LogLevel.info
            testLogger.info(message: logStringData)
        }
        else {
            Logger.logLevelFilter = LogLevel.none
            testLogger.debug(message: logStringData)
        }
    }
    
    internal func validateString(object:String) -> Bool{
        if (object.isEmpty || object == "") {
            return false;
        }
        return true
    }
    
    internal func getDeviceID() -> String{
        var devId = String()
        if ((self.bluemixDeviceId == nil) || (self.bluemixDeviceId?.isEmpty)!) {
            // Generate new ID
            let authManager  = BMSClient.sharedInstance.authorizationManager
            devId = authManager.deviceIdentity.ID!
        }else{
            devId = self.bluemixDeviceId!
        }
        return devId
    }
    
    internal func checkStatusChange() {
        
        if(UserDefaults.standard.object(forKey: BMSPUSH_APP_INSTALL) != nil) {
            statusChangeHeloper()
        } else {
            BMSPushUtils.saveValueToNSUserDefaults(value: true, key: BMSPUSH_APP_INSTALL)
            NotificationCenter.default.addObserver(forName: bmsNotificationName, object: nil, queue: OperationQueue.main) { (notifiction) in
                
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
                    self?.statusChangeHeloper()
                }
                
            }
            
        }
    }
    
    internal func statusChangeHeloper() {
        let notificationType = UIApplication.shared.currentUserNotificationSettings?.types
        if notificationType?.rawValue == 0 {
            print("Push Disabled")
            self.delegate?.onChangePermission(status: false)
        } else {
            print("Push Enabled")
            self.delegate?.onChangePermission(status: true)
            #if swift(>=4.0)
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            #else
            UIApplication.shared.registerForRemoteNotifications()
            #endif
        }
        
    }
    
    @available(iOS 10.0, *)
    internal func initPushCenter(_ center: UNUserNotificationCenter ) {
        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if(granted) {
                #if swift(>=4.0)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                #else
                UIApplication.shared.registerForRemoteNotifications()
                #endif
                self.delegate?.onChangePermission(status: true)
            } else {
                print("Error while registering with APNS server :  \(String(describing: error))")
                self.delegate?.onChangePermission(status: false)
            }
        })
        self.checkStatusChange()
    }
    
    internal func initLowerPlatformPush(_ categories: Set<UIUserNotificationCategory>? = nil) {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
        UIApplication.shared.registerUserNotificationSettings(settings)
        self.checkStatusChange()
    }
    
    internal func checkForCredentials() -> Bool {
        self.applicationId = BMSPushUtils.getValueToNSUserDefaults(key: BMSPUSH_APP_GUID) as? String
        self.clientSecret = BMSPushUtils.getValueToNSUserDefaults(key: BMSPUSH_CLIENT_SECRET) as? String
        
        if(self.applicationId == "" || self.clientSecret == "") {
            return false
        }
        return true
    }
}
#endif

