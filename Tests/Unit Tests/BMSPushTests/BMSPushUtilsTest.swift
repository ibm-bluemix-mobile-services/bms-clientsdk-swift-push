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

import XCTest
@testable import BMSPush

class BMSPushUtilsTest: XCTestCase {
    
    
    func testSaveValueToNSUserDefaults () {
        
        #if swift(>=3.0)
            BMSPushUtils.saveValueToNSUserDefaults(value: "some string", key: "somestring")
        
        XCTAssertEqual("some string", BMSPushUtils.getValueToNSUserDefaults(key: "somestring") as! String )
        #else
            BMSPushUtils.saveValueToNSUserDefaults("some string", key: "somestring")
            
        #endif
    }
    
    func testOptionsDefaults() {
        
        let variables = [
        "username":"testname",
        "accountNumber":"3564758697057869"
        ]
        
        BMSPushUtils.saveValueToNSUserDefaults(value:variables, key: IMFPUSH_VARIABLES)
        BMSPushUtils.saveValueToNSUserDefaults(value: true, key: HAS_IMFPUSH_VARIABLES)
        
        let newVariables = BMSPushUtils.getPushOptionsNSUserDefaults(key: IMFPUSH_VARIABLES)
        
        if let data = newVariables.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:String] {
                    XCTAssertEqual(variables["username"], json["username"])
                    XCTAssertEqual(variables["accountNumber"], json["accountNumber"])
                } else {
                    XCTFail("Failed in options check")
                }
                
            } catch {
                XCTFail("Failed in options check")
            }
        }
    }
    
    func testOptionsDefaultlFalse() {
        
        let variables = [
        "username":"testname",
        "accountNumber":"3564758697057869"
        ]
        
        BMSPushUtils.saveValueToNSUserDefaults(value:variables, key: IMFPUSH_VARIABLES)
        BMSPushUtils.saveValueToNSUserDefaults(value: false, key: HAS_IMFPUSH_VARIABLES)
        
        let newVariables = BMSPushUtils.getPushOptionsNSUserDefaults(key: IMFPUSH_VARIABLES)
        
        XCTAssertEqual(newVariables, "")
    }
    
    func testTemplateNotification() {
        
        let variables = [
        "username":"Johny",
        "accountNumber":"3564758697057869"
        ]
        
        BMSPushUtils.saveValueToNSUserDefaults(value:variables, key: IMFPUSH_VARIABLES)
        BMSPushUtils.saveValueToNSUserDefaults(value: true, key: HAS_IMFPUSH_VARIABLES)
        
        let data = "Hi! {{username}}, your {{accountNumber}} is activated"
        let expected = "Hi! Johny, your 3564758697057869 is activated"

        let message = BMSPushUtils.checkTemplateNotifications(data)
        
        XCTAssertEqual(message, expected)
        
    }
    func testGetPushSettingValue () {
        
        let pushSettingsValue = BMSPushUtils.getPushSettingValue()
        NSLog("\(pushSettingsValue)")
    }
    
    func test () {
           
           let pushSettingsValue = BMSPushUtils.getPushSettingValue()
           NSLog("\(pushSettingsValue)")
       }
    
    func testSendLoggerData () {
        
        BMSPushUtils.sendLoggerData()
    }
    
    func testGetNotifReg () {
        
        if (BMSPushUtils.getPushSettingValue()){
            print("Success")
        }
    }
    
}
