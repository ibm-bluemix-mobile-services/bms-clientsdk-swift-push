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
            
        #else
            BMSPushUtils.saveValueToNSUserDefaults("some string", key: "somestring")
            
        #endif
    }
    
    func testgetPushSettingValue () {
        
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
