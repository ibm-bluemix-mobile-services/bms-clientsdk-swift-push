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

// MARK: - Swift 3 & Swift 4

#if swift(>=3.0)
    
/**
     Utils class for `BMSPush`
 */
open class BMSPushUtils: NSObject {
    
    static var loggerMessage:String = ""
    
    @objc dynamic open class func saveValueToNSUserDefaults (value:Any, key:String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        loggerMessage = ("Saving value to NSUserDefaults with Key: \(key) and Value: \(value)")
        self.sendLoggerData()
    }
    
    @objc dynamic open class func getValueToNSUserDefaults (key:String) -> Any {
        var value:Any = ""
        if(UserDefaults.standard.value(forKey: key) != nil){
            value = UserDefaults.standard.value(forKey: key) ?? ""
        }
        loggerMessage = ("Getting value for NSUserDefaults Key: \(key) and Value: \(value)")
        self.sendLoggerData()
        return value
    }
    
    @objc dynamic open class func getPushOptionsNSUserDefaults (key:String) -> String {
        var value = ""
        if key == IMFPUSH_VARIABLES {
            if let hasVariable = UserDefaults.standard.value(forKey: HAS_IMFPUSH_VARIABLES) as? Bool, hasVariable != true {
                return value
            }
        }
        if(UserDefaults.standard.value(forKey: key) != nil){
            let dataValue = UserDefaults.standard.value(forKey: key) as? [String: String]
            let jsonData = try! JSONSerialization.data(withJSONObject: dataValue!, options: .prettyPrinted)
            value = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        }
        loggerMessage = ("Getting value for NSUserDefaults Key: \(key) and Value: \(value)")
        self.sendLoggerData()
        return value
    }
    
    class func getPushSettingValue() -> Bool {
        
        
        var pushEnabled = false
        
        if  ((UIDevice.current.systemVersion as NSString).floatValue >= 8.0) {
            
            if (UIApplication.shared.isRegisteredForRemoteNotifications) {
                pushEnabled = true
            }
            else {
                pushEnabled = false
            }
        } else {
            
            let grantedSettings = UIApplication.shared.currentUserNotificationSettings
            
            if grantedSettings!.types.rawValue & UIUserNotificationType.alert.rawValue != 0 {
                // Alert permission granted
                pushEnabled = true
            }
            else{
                pushEnabled = false
            }
        }
        
        return pushEnabled;
    }
    
    class func sendLoggerData () {
        
        let devId = BMSPushClient.sharedInstance.getDeviceID()
        let testLogger = Logger.logger(name:devId)
        Logger.logLevelFilter = LogLevel.debug
        testLogger.debug(message: loggerMessage)
        Logger.logLevelFilter = LogLevel.info
        testLogger.info(message: loggerMessage)
        
    }
    
    class func checkTemplateNotifications(_ body:String) -> String {
        
        let regex = "\\{\\{.*?\\}\\}"
        var text = body
        
        guard let optionVariables = UserDefaults.standard.value(forKey: IMFPUSH_VARIABLES) as? [String: String] else { return text }
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            let resultMap = results.flatMap {
                Range($0.range, in: text).map {
                    String(text[$0])
                }
            }
            
            for val in resultMap {
                var temp = val
                temp = temp.replacingOccurrences(of: "{{", with: "", options: NSString.CompareOptions.literal, range: nil)
                temp = temp.replacingOccurrences(of: "}}", with: "", options: NSString.CompareOptions.literal, range: nil)
                temp = temp.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                if let templateValue = optionVariables[temp] {
                    text = text.replacingOccurrences(of: val, with: templateValue)
                }
            }
            return text
            
        } catch {
            return text
        }
    }
}
#endif
