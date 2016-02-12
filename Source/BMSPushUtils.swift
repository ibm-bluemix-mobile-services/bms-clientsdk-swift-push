//
//  BMSPushUtils.swift
//  BMSPush
//
//  Created by Anantha Krishnan K G on 03/02/16.
//  Copyright © 2016 IBM Corp. All rights reserved.
//

import UIKit
import BMSCore

public class BMSPushUtils: NSObject {
    
    class func saveValueToNSUserDefaults (value:String, key:String){
        
        let loggerObject = Logger?()
        loggerObject?.info("Saving value to NSUserDefaults with Key: \(key) and Value: \(value)")
        
        Analytics.log([ IMFPUSH_UTILS: "Saving value to NSUserDefaults with Key: \(key) and Value: \(value)"])
        Analytics.send()

        let standardUserDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if standardUserDefaults.objectForKey(key) != nil  {
            
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
    }
    
    class func isSandbox (environment:String) -> Bool{
        
        var isSandBox = true
        
        if (environment.isEmpty || environment.caseInsensitiveCompare("sandbox") == NSComparisonResult.OrderedSame){
            
            isSandBox = true
        }
        else if (environment.caseInsensitiveCompare("production") == NSComparisonResult.OrderedSame){
            
            isSandBox = false
        }
        
        return isSandBox
    }
    
    class func getPushSettingValue() -> Bool {
        
        
        var pushEnabled = false
        
        if  ((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0) {
            
            if (UIApplication.sharedApplication().isRegisteredForRemoteNotifications()) {
                pushEnabled = true
            }
            else {
                pushEnabled = false
            }
        } else {
            
            let grantedSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
            
            if grantedSettings!.types.rawValue & UIUserNotificationType.Alert.rawValue != 0 {
                // Alert permission granted
                pushEnabled = true
            }
            else{
                pushEnabled = false
            }
        }
        
        return pushEnabled;
    }
    
    
    class func generateTimeStamp () -> String {
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US_POSIX")
        
        let timeInMilliSec  = NSDate().timeIntervalSince1970
        
        let isoDate:String = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeInMilliSec))
        
        
        let loggerObject = Logger?()
        loggerObject?.info("Current timestamp is: \(isoDate)")
        
        Analytics.log([ IMFPUSH_UTILS: "Current timestamp is: \(isoDate)"])
        Analytics.send()
        
        return isoDate;
    }
    
    class func generateMetricsEvents (action:String, messageId:String, timeStamp:String){
        
        var notificationMetaData = [String : AnyObject]()
        
        if messageId.isEmpty {
            
            notificationMetaData = ["$notificationAction" : action, "$timeStamp" : timeStamp]
        } else {
            
            notificationMetaData = ["$notificationId" : messageId,"$notificationAction" : action, "$timeStamp" : timeStamp]
        }
        
        let loggerObject = Logger?()
        
        loggerObject?.info("Currently logging analytics with NotificationMetaData: \(notificationMetaData)")
        
        Analytics.log([IMFPUSH_CLIENT : "Currently logging analytics with NotificationMetaData: \(notificationMetaData)"])
        Analytics.send()
        
        
        Analytics.log(["$imf_push":notificationMetaData])
        Analytics.send()
    }
}