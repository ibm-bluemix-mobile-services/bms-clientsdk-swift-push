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

class BMSPushNotificationActionCategoryTest: XCTestCase {
    
    func testInit(){
        #if swift(>=3.0)
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionTwo = BMSPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionThree = BMSPushNotificationAction(identifierName: "Third", buttonTitle: "Delete", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionFour = BMSPushNotificationAction(identifierName: "Fourth", buttonTitle: "View", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
            
            let actionFive = BMSPushNotificationAction(identifierName: "Fifth", buttonTitle: "Later", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)

        #else
            let actionOne = BMSPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
            
            let actionTwo = BMSPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
            
            let actionThree = BMSPushNotificationAction(identifierName: "Third", buttonTitle: "Delete", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
            
            let actionFour = BMSPushNotificationAction(identifierName: "Fourth", buttonTitle: "View", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)
            
            let actionFive = BMSPushNotificationAction(identifierName: "Fifth", buttonTitle: "Later", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.Background)

        #endif
        
        let category = BMSPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])
        let categorySecond = BMSPushNotificationActionCategory(identifierName: "category1", buttonActions: [actionOne, actionTwo])
        let categoryThird = BMSPushNotificationActionCategory(identifierName: "category2", buttonActions: [actionOne, actionTwo,actionThree,actionFour,actionFive])
        
        XCTAssertEqual(category.identifier, "category")
        XCTAssertEqual(category.actions, [actionOne, actionTwo])
        
        XCTAssertEqual(categorySecond.identifier, "category1")
        XCTAssertEqual(categorySecond.actions, [actionOne, actionTwo])
        
        XCTAssertEqual(categoryThird.identifier, "category2")
        XCTAssertEqual(categoryThird.actions, [actionOne, actionTwo,actionThree,actionFour,actionFive])

    }
    
}
