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

class BMSPushUrlBuilderTest: XCTestCase {


    func testAddHeader() {
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let headers = urlBuilder.addHeader()
        if !(headers.isEmpty) {
            print("Success!!")
        }
    }
    
    func testAddHeader1() {
    
        BMSClient.sharedInstance.initialize(bluemixRegion: ".stage1.ng.bluemix.net")
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
        
        let headers = urlBuilder.addHeader()
        if !(headers.isEmpty) {
            print("Success!!")
        }
    }
    
    func testAddHeader2() {
        
        BMSClient.sharedInstance.initialize(bluemixRegion: ".stage1-dev.ng.bluemix.net")
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
        
        let headers = urlBuilder.addHeader()
        if !(headers.isEmpty) {
            print("Success!!")
        }
    }
    
    func testAddHeader3() {
        
        BMSClient.sharedInstance.initialize(bluemixRegion: ".stage1-test.ng.bluemix.net")
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
        
        let headers = urlBuilder.addHeader()
        if !(headers.isEmpty) {
            print("Success!!")
        }
    }
    
    func testAddHeader4() {
        
        BMSPushClient.overrideServerHost = "192.0.0.2:9080"
        
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
        
        let headers = urlBuilder.addHeader()
        if !(headers.isEmpty) {
            print("Success!!")
        }
    }
    
    func testGetSubscribedDevicesUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        #if swift(>=3.0)
            let subDeviceURL = urlBuilder.getSubscribedDevicesUrl(devID: "testDevice")
        #else
            let subDeviceURL = urlBuilder.getSubscribedDevicesUrl("testDevice")
        #endif
        if !(subDeviceURL.isEmpty) {
            print("Success!!")
        }
    }
    
    func testGetDevicesUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let getDeviceURL = urlBuilder.getDevicesUrl()
        if !(getDeviceURL.isEmpty) {
            print("Success!!")
        }
    }
    
    func testGetTagsUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let getTagsUrl = urlBuilder.getTagsUrl()
        if !(getTagsUrl.isEmpty) {
            print("Success!!")
        }
    }
    
    func testGetSubscriptionsUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let getSubscriptionsUrl = urlBuilder.getSubscriptionsUrl()
        if !(getSubscriptionsUrl.isEmpty) {
            print("Success!!")
        }
    }
    
    func testGetAvailableSubscriptionsUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
        #if swift(>=3.0)
            let getAvailableSubscriptionsUrl = urlBuilder.getAvailableSubscriptionsUrl(deviceId: "testDevice")
        #else
            let getAvailableSubscriptionsUrl = urlBuilder.getAvailableSubscriptionsUrl("testDevice")
        #endif
        if !(getAvailableSubscriptionsUrl.isEmpty) {
            print("Success!!")
        }
    }
    
    func testGetUnSubscribetagsUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let getUnSubscribetagsUrl = urlBuilder.getUnSubscribetagsUrl()
        if !(getUnSubscribetagsUrl.isEmpty) {
            print("Success!!")
        }
    }
    
    func testGetUnregisterUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
        #if swift(>=3.0)
            let getUnregisterUrl = urlBuilder.getUnregisterUrl(deviceId: "testDevice")
        #else
            let getUnregisterUrl = urlBuilder.getUnregisterUrl("testDevice")
        #endif
        if !(getUnregisterUrl.isEmpty) {
            print("Success!!")
        }
    }
    
    func testGetSendMessageDeliveryStatus(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
        #if swift(>=3.0)
            let getSendMessageDeliveryStatus = urlBuilder.getSendMessageDeliveryStatus(messageId: "testMessageId")
        #else
            let getSendMessageDeliveryStatus = urlBuilder.getSendMessageDeliveryStatus("testMessageId")
        #endif
        if !(getSendMessageDeliveryStatus.isEmpty) {
            print("Success!!")
        }
    }
}
