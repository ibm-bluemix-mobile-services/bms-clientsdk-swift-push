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

class BMSPushNotificationActionTest: XCTestCase {
    
    func testInit(){
        
        #if swift(>=3.0)
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            let actionTwo = BMSPushNotificationAction(identifierName: "Second", buttonTitle: "decline", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
        #else
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
            let actionTwo = BMSPushNotificationAction(identifierName: "Second", buttonTitle: "decline", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
        #endif
       
        
        XCTAssertEqual(actionOne.identifier, "FIRST")
        XCTAssertEqual(actionOne.title, "Accept")
        
        XCTAssertEqual(actionTwo.identifier, "Second")
        XCTAssertEqual(actionTwo.title, "decline")
    }
}
