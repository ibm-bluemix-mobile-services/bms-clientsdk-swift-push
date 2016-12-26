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
#if swift(>=3.0)
    import UserNotifications
    import UserNotificationsUI
#endif


class testBMSPushClient: XCTestCase {
    
    // MARK: Register device
    
    var expectation:XCTestExpectation?
    var responseHasArrived:Bool = false
    var timeoutDate = NSDate(timeIntervalSinceNow: 30.0)
    /*
    func testRegister () {
        
        
        #if swift(>=3.0)
            
            BMSClient.sharedInstance.initialize(bluemixRegion:BMSClient.Region.usSouth)
            let clientInstance = BMSPushClient.sharedInstance
            clientInstance.initializeWithAppGUID(appGUID: "fcaa8800-1b09-4ff2-85e1-8d7ea05211ec", clientSecret: "42cb3620-9f2e-4f72-a528-565dbbc55297")
            let string = "46f5b4fde98a7013ebeb189a3be65e585fc7eccd310af99359c7c6b67"
            
            let token = string.data(using: String.Encoding.utf8)
            clientInstance.registerWithDeviceToken(deviceToken: token!, completionHandler: { (response, statusCode, error) -> Void in
                
                
                NSLog("the status code for registartion is \(statusCode)");
                
                if error.isEmpty{
                    
                    print( "Response during device registration : \(response)")
                    
                    print( "status code during device registration : \(statusCode)")
                }
                else {
                    
                    print( "Error during device registration \(error) ")
                    // XCTFail("Failed to register")
                }
                
                self.responseHasArrived = true
            })
            
            
            while (responseHasArrived == false && (timeoutDate.timeIntervalSinceNow > 0)){
                CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
            }
            if responseHasArrived {
                
                NSLog("Success Execution")
            }
            else{
                XCTFail("Test timed out");
            }
        #else
            
            BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
            
            let clientInstance = BMSPushClient.sharedInstance
            clientInstance.initializeWithAppGUID(appGUID: "fcaa8800-1b09-4ff2-85e1-8d7ea05211ec", clientSecret: "42cb3620-9f2e-4f72-a528-565dbbc55297")
            let string = "46f5b4fde98a7013ebeb189a3be65e585fc7eccd310af99359c7c6b67"
            
            let token = string.dataUsingEncoding(NSUTF8StringEncoding)
            
            clientInstance.registerWithDeviceToken(token!,completionHandler:  { (response, statusCode, error) -> Void in
            
            
            NSLog("the status code for registartion is \(statusCode)");
            
            if error.isEmpty{
            
            print( "Response during device registration : \(response)")
            
            print( "status code during device registration : \(statusCode)")
            }
            else {
            
            print( "Error during device registration \(error) ")
            // XCTFail("Failed to register")
            }
            
            self.responseHasArrived = true
            })
            
            
            while (responseHasArrived == false && (timeoutDate.timeIntervalSinceNow > 0)){
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
            }
            if responseHasArrived {
            
            NSLog("Success Execution")
            }
            else{
            XCTFail("Test timed out");
            }
        #endif
        
    }
    
    func testSubscribeToTags () {
        
        
        let clientInstance = BMSPushClient.sharedInstance
        
        var tagsArray = NSMutableArray()
        
        // self.responseHasArrived = false
        
        clientInstance.retrieveAvailableTagsWithCompletionHandler { (response, statusCode, error) -> Void in
            
            NSLog("the status code for retrieving available tags is \(statusCode)");
            
            if error.isEmpty{
                
                print( "Response during retrieve tags : \(response)")
                
                print( "status code during retrieve tags : \(statusCode)")
                
                
                if let tags = response {
                    
                    tagsArray = tags
                    NSLog("\n\n\n\nTgas array \(tagsArray)\n\n\n")
                }
                
            }
            else {
                print( "Error during retrieve tags \(error) ")
                //XCTFail("Failed to get tags")
            }
            
            self.responseHasArrived = true
        }
        
        
        while (responseHasArrived == false && (timeoutDate.timeIntervalSinceNow > 0)){
            #if swift(>=3.0)
                CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
            #else
                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
            #endif
        }
        if responseHasArrived && (tagsArray.count > 0) {
            
            NSLog("Success Execution")
            
            self.responseHasArrived = false
            
            #if swift(>=3.0)
                clientInstance.subscribeToTags(tagsArray: tagsArray) { (response, statusCode, error) -> Void in
                    
                    if error.isEmpty {
                        
                        print( "Response during Subscribing to tags : \(response?.description)")
                        
                        print( "status code during Subscribing tags : \(statusCode)")
                    }
                    else {
                        print( "Error during subscribing tags \(error) ")
                        //XCTFail("Failed to subscribe tags")
                    }
                    
                    self.responseHasArrived = true
                }
            #else
                clientInstance.subscribeToTags(tagsArray) { (response, statusCode, error) -> Void in
                
                if error.isEmpty {
                
                print( "Response during Subscribing to tags : \(response?.description)")
                
                print( "status code during Subscribing tags : \(statusCode)")
                }
                else {
                print( "Error during subscribing tags \(error) ")
                //XCTFail("Failed to subscribe tags")
                }
                
                self.responseHasArrived = true
                }
            #endif
            
            
            
            while (responseHasArrived == false && (timeoutDate.timeIntervalSinceNow > 0)){
                #if swift(>=3.0)
                    CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
                #else
                    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
                #endif
            }
            if responseHasArrived {
                
                NSLog("Success Execution")
            }
            else{
                XCTFail("Test timed out");
            }
            
        }
        else{
            if tagsArray.count == 0 {
                print("Emty tag array");
                
            }
            else {
                XCTFail("Test timed out");
            }
        }
    }
    
    func testUnregisterDevice () {
        
        // MARK: retrieve subscibed tags
        #if swift(>=3.0)
            BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        #else
            BMSClient.sharedInstance.initialize(bluemixRegion:  BMSClient.Region.usSouth)
        #endif
        let clientInstance = BMSPushClient.sharedInstance
        
        var tagsArray = NSMutableArray()
        
        clientInstance.retrieveSubscriptionsWithCompletionHandler { (response, statusCode, error) -> Void in
            
            if error.isEmpty {
                
                print( "Response during retrieving subscribed tags : \(response)")
                
                print( "status code during retrieving subscribed tags : \(statusCode)")
                
                if let tags = response {
                    
                    tagsArray = tags
                }
                
            }
            else {
                print( "Error during retrieving subscribed tags \(error) ")
                //XCTFail("Failed to etrieving subscribed tags")
            }
            
            self.responseHasArrived = true
        }
        
        
        while (responseHasArrived == false && (timeoutDate.timeIntervalSinceNow > 0)){
            #if swift(>=3.0)
                CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
            #else
                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
            #endif
        }
        if responseHasArrived {
            
            NSLog("Success Execution")
            
            // MARK: Unsubscribe from tags
            
            self.responseHasArrived = false
            
            #if swift(>=3.0)
                clientInstance.unsubscribeFromTags(tagsArray: tagsArray) { (response, statusCode, error) -> Void in
                    
                    if error.isEmpty {
                        
                        print( "Response during unsubscribing tags : \(response?.description)")
                        
                        print( "status code during unsubscribing tags : \(statusCode)")
                    }
                    else {
                        print( "Error during  unsubscribing tags \(error) ")
                        //XCTFail("Failed to unsubscribing tags")
                    }
                    
                    self.responseHasArrived = true
                }
            #else
                clientInstance.unsubscribeFromTags(tagsArray) { (response, statusCode, error) -> Void in
                
                if error.isEmpty {
                
                print( "Response during unsubscribing tags : \(response?.description)")
                
                print( "status code during unsubscribing tags : \(statusCode)")
                }
                else {
                print( "Error during  unsubscribing tags \(error) ")
                //XCTFail("Failed to unsubscribing tags")
                }
                
                self.responseHasArrived = true
                }
            #endif
            
            
            
            while (responseHasArrived == false && (timeoutDate.timeIntervalSinceNow > 0)){
                #if swift(>=3.0)
                    CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
                #else
                    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
                #endif
            }
            if responseHasArrived {
                
                NSLog("Success Execution")
                
                // MARK: Unregister device
                self.responseHasArrived = false
                
                clientInstance.unregisterDevice { (response, statusCode, error) -> Void in
                    
                    if error.isEmpty {
                        
                        print( "Response during unregistering device : \(response)")
                        
                        print( "status code during unregistering device : \(statusCode)")
                    }
                    else {
                        print( "Error during unregistering device \(error) ")
                        //XCTFail("Failed to unregistering  device")
                    }
                    
                    self.responseHasArrived = true
                }
                
                
                while (responseHasArrived == false && (timeoutDate.timeIntervalSinceNow > 0)){
                    #if swift(>=3.0)
                        CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
                    #else
                        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
                    #endif
                }
                if responseHasArrived {
                    
                    NSLog("Success Execution")
                }
                else{
                    XCTFail("Test timed out");
                }
            }
            else{
                XCTFail("Test timed out");
            }
            
        }
        else{
            XCTFail("Test timed out");
        }
    }
    
    
    func testRegisterWithUserId(){
        #if swift(>=3.0)
            BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        #else
            BMSClient.sharedInstance.initialize(bluemixRegion:  BMSClient.Region.usSouth)
        #endif
        
        let clientInstance = BMSPushClient.sharedInstance
        
        #if swift(>=3.0)
            clientInstance.initializeWithAppGUID(appGUID: "fcaa8800-1b09-4ff2-85e1-8d7ea05211ec", clientSecret:"42cb3620-9f2e-4f72-a528-565dbbc55297")
            let string = "46f5b4fde98a7013ebeb189a3be65e585fc7eccd310a9c"
            
            let token = string.data(using: String.Encoding.utf8)
            
            clientInstance.registerWithDeviceToken(deviceToken: token!, WithUserId: "testUser", completionHandler:  { (response, statusCode, error) -> Void in
                
                
                NSLog("the status code for registartion is \(statusCode)");
                
                if error.isEmpty{
                    
                    print( "Response during device registration : \(response)")
                    
                    print( "status code during device registration : \(statusCode)")
                }
                else {
                    
                    print( "Error during device registration \(error) ")
                    // XCTFail("Failed to register")
                }
                
                self.responseHasArrived = true
            })
            
        #else
            clientInstance.initializeWithAppGUID(appGUID: "fcaa8800-1b09-4ff2-85e1-8d7ea05211ec", clientSecret:"42cb3620-9f2e-4f72-a528-565dbbc55297")
            let string = "46f5b4fde98a7013ebeb189a3be65e585fc7eccd310a9c"
            
            let token = string.dataUsingEncoding(NSUTF8StringEncoding)
            
            clientInstance.registerWithDeviceToken(token!, WithUserId: "testUser", completionHandler:  { (response, statusCode, error) -> Void in
            
            
            NSLog("the status code for registartion is \(statusCode)");
            
            if error.isEmpty{
            
            print( "Response during device registration : \(response)")
            
            print( "status code during device registration : \(statusCode)")
            }
            else {
            
            print( "Error during device registration \(error) ")
            // XCTFail("Failed to register")
            }
            
            self.responseHasArrived = true
            })
            
        #endif
        
        
        while (responseHasArrived == false && (timeoutDate.timeIntervalSinceNow > 0)){
            #if swift(>=3.0)
                CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
            #else
                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
            #endif
        }
        if responseHasArrived {
            
            NSLog("Success Execution")
        }
        else{
            XCTFail("Test timed out");
        }
    }
    */
    
}
