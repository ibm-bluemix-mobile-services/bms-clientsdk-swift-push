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
        if headers.isEmpty {
            XCTFail("Empty Header")
        } else{
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
        if subDeviceURL.isEmpty {
            XCTFail("Empty subDeviceURL")
        } else{
            print("Success!!")
        }
    }
    
    func testGetDevicesUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let getDeviceURL = urlBuilder.getDevicesUrl()
        if getDeviceURL.isEmpty {
            XCTFail("Empty DeviceURL")
        } else{
            print("Success!!")
        }
    }
    
    func testGetTagsUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let getTagsUrl = urlBuilder.getTagsUrl()
        if getTagsUrl.isEmpty {
            XCTFail("Empty TagsUrl")
        } else{
            print("Success!!")
        }
    }
    
    func testGetSubscriptionsUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let getSubscriptionsUrl = urlBuilder.getSubscriptionsUrl()
        if getSubscriptionsUrl.isEmpty {
            XCTFail("Empty SubscriptionsUrl")
        } else{
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
        if getAvailableSubscriptionsUrl.isEmpty {
            XCTFail("Empty AvailableSubscriptionsUrl")
        } else{
            print("Success!!")
        }
    }
    
    func testGetUnSubscribetagsUrl(){
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        let urlBuilder = BMSPushUrlBuilder(applicationID: "dabf5067-5553-48e2-ac96-6e2c03aab216",clientSecret:"6d0cfa42-cf69-4e72-8073-9ff2de3ddf77")
     
        let getUnSubscribetagsUrl = urlBuilder.getUnSubscribetagsUrl()
        if getUnSubscribetagsUrl.isEmpty {
            XCTFail("Empty UnSubscribetagsUrl")
        } else{
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
        if getUnregisterUrl.isEmpty {
            XCTFail("Empty UnregisterUrl")
        } else{
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
        if getSendMessageDeliveryStatus.isEmpty {
            XCTFail("Empty SendMessageDeliveryStatus")
        } else{
            print("Success!!")
        }
    }
}