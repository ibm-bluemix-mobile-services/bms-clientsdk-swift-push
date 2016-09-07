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

class BMSResponseTests: XCTestCase {
    
    
    var responseArray = NSMutableArray()
    var responseDictionary = NSMutableDictionary()
    
    func testSubscriptions () {
        
        
        let response = "{\"subscriptions\":[{\"tagName\":\"some tag name\",\"subscriptionId\":\"some subscription ID\",\"deviceId\":\"some device ID\",\"href\":\" https:// mybluemix.net\"},{\"tagName\":\"Push.ALL\",\"userId\":\"\",\"subscriptionId\":\"some subscription ID\",\"deviceId\":\"some device ID\",\"href\":\"https:// mybluemix.net\"}]}"
        
        #if swift(>=3.0)
            let responseData = response.data(using: String.Encoding.utf8)
            let httpURLResponse = HTTPURLResponse(url: NSURL(string: "http://example.com")! as URL, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["key": "value"])
        #else
            let responseData = response.dataUsingEncoding(NSUTF8StringEncoding)
            let httpURLResponse = NSHTTPURLResponse(URL: NSURL(string: "http://example.com")!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: ["key": "value"])
        #endif
        
        let testResponse = Response(responseData: responseData!, httpResponse: httpURLResponse, isRedirect: true)
        
        responseArray = testResponse.subscriptions()
        
        NSLog("\(responseArray)")
        
    }
    
    func testSubscribeStatus () {
        
        
        let response = "{\"tagsNotFound\":{\"tags\":[],\"message\":\"Not Found - Targeted resource 'tagNames' does not exist. Check the 'tags' parameter\",\"code\":\"FPWSE0001E\"},\"subscriptionExists\":[],\"subscribed\":[{\"tagName\":\"some tag name\",\"subscriptionId\":\"some subscription ID\",\"deviceId\":\"some device ID\",\"href\":\"https://mybluemix.net\"}]}"
        
        #if swift(>=3.0)
            let responseData = response.data(using: String.Encoding.utf8)
            let httpURLResponse = HTTPURLResponse(url: NSURL(string: "http://example.com")! as URL, statusCode: 207, httpVersion: "HTTP/1.1", headerFields: ["key": "value"])
        #else
            let responseData = response.dataUsingEncoding(NSUTF8StringEncoding)
            let httpURLResponse = NSHTTPURLResponse(URL: NSURL(string: "http://example.com")!, statusCode: 207, HTTPVersion: "HTTP/1.1", headerFields: ["key": "value"])
        #endif
        
        let testResponse = Response(responseData: responseData!, httpResponse: httpURLResponse, isRedirect: true)
        
        responseDictionary = testResponse.subscribeStatus()
        
        NSLog("\(responseDictionary)")
        
    }
    
    func testUnsubscribeStatus () {
        
        
        let response = "{\"tagsNotFound\":{\"tags\":[\"Push.ALL\"],\"message\":\"Not Found - Targeted resource 'tagNames' does not exist. Check the 'tags' parameter\",\"code\":\"FPWSE0001E\"},\"subscriptionExists\":[{\"tagName\":\"Some Tag Name\",\"subscriptionId\":\"some subscription ID\",\"deviceId\":\"some device ID\",\"href\":\"https://mybluemix.net\"}],\"subscribed\":[]}"
        
        #if swift(>=3.0)
            let responseData = response.data(using: String.Encoding.utf8)
            let httpURLResponse = HTTPURLResponse(url: NSURL(string: "http://example.com")! as URL, statusCode: 207, httpVersion: "HTTP/1.1", headerFields: ["key": "value"])
        #else
            let responseData = response.dataUsingEncoding(NSUTF8StringEncoding)
            let httpURLResponse = NSHTTPURLResponse(URL: NSURL(string: "http://example.com")!, statusCode: 207, HTTPVersion: "HTTP/1.1", headerFields: ["key": "value"])
        #endif
        
        let testResponse = Response(responseData: responseData!, httpResponse: httpURLResponse, isRedirect: true)
        
        responseDictionary = testResponse.unsubscribeStatus()
        
        NSLog("\(responseDictionary)")
        
    }
    
    
    func testAvailableTags () {
        
        let response = "{\"tags\":[{\"uri\":\"https://mybluemix.net/tags/tagname\",\"name\":\"tagname\",\"createdTime\":\"2016-03-21T10:32:27Z\",\"lastUpdatedTime\":\"2016-03-21T10:32:27Z\",\"createdMode\":\"API\",\"href\":\"https://mybluemix.net\"}]}"
        
        #if swift(>=3.0)
            let responseData = response.data(using: String.Encoding.utf8)
            let httpURLResponse = HTTPURLResponse(url: NSURL(string: "http://example.com")! as URL, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["key": "value"])
        #else
            let responseData = response.dataUsingEncoding(NSUTF8StringEncoding)
            let httpURLResponse = NSHTTPURLResponse(URL: NSURL(string: "http://example.com")!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: ["key": "value"])
        #endif
        
        let testResponse = Response(responseData: responseData!, httpResponse: httpURLResponse, isRedirect: true)
        
        responseArray = testResponse.availableTags()
        
        NSLog("\(responseArray)")
    }
    
}
