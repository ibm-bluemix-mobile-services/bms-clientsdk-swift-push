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
import BMSCore

class BMSPushClientOptionsTest: XCTestCase {
    
    func testInit(){
        let notifOptions = BMSPushClientOptions()
        notifOptions.setInteractiveNotificationCategories(categoryName: [])
        let variables = ["username":"ananth","accountNumber":"3564758697057869"]
        #if swift(>=3.0)
           notifOptions.setDeviceId(deviceId: "testDeviceId")
            notifOptions.setPushVariables(pushVariables: variables)
           XCTAssertEqual(notifOptions.pushvariables, variables)
        #else
            notifOptions.setDeviceIdValue("testDeviceId")
        #endif
        XCTAssertEqual(notifOptions.category, [])
        XCTAssertEqual(notifOptions.deviceId, "testDeviceId")
        
        
        #if swift(>=3.0)
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionTwo = BMSPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
        #else
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
            
            let actionTwo = BMSPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
        #endif
       
        
        let category = BMSPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])
        
        let notifOptions2 = BMSPushClientOptions()
        #if swift(>=3.0)
            notifOptions2.setDeviceId(deviceId: "")
        #else
            notifOptions2.setDeviceIdValue("")
        #endif
        notifOptions2.setInteractiveNotificationCategories(categoryName: [category])
        XCTAssertEqual(notifOptions2.category, [category])
        XCTAssertEqual(notifOptions2.deviceId, "")
    }
    
    func testInit2(){
        let notifOptions = BMSPushClientOptions(categoryName: [])
        
        XCTAssertEqual(notifOptions.category, [])
        
        
        #if swift(>=3.0)
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionTwo = BMSPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
        #else
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
            
            let actionTwo = BMSPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
        #endif
        
        
        let category = BMSPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])
        
        let notifOptions2 = BMSPushClientOptions(categoryName: [category])
        XCTAssertEqual(notifOptions2.category, [category])
    }
    
}
