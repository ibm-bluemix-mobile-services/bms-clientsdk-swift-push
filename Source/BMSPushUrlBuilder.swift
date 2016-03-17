//
//  BMSPushUrlBuilder.swift
//  BMSPush
//
//  Created by Anantha Krishnan K G on 08/03/16.
//  Copyright © 2016 IBM Corp. All rights reserved.
//

import UIKit
import BMSCore

internal class BMSPushUrlBuilder: NSObject {
    
    internal  let FORWARDSLASH = "/";
    internal  let IMFPUSH = "imfpush";
    internal  let V1 = "v1";
    internal  let APPS = "apps";
    internal  let AMPERSAND = "&";
    internal  let QUESTIONMARK = "?";
    internal  let SUBZONE = "subzone";
    internal  let EQUALTO = "=";
    internal  let SUBSCRIPTIONS = "subscriptions";
    internal  let TAGS = "tags";
    internal  let DEVICES = "devices";
    internal  let TAGNAME = "tagName";
    internal  let DEVICEID = "deviceId";
    internal  let defaultProtocol = "https";
    
    internal final var pwUrl_ = String()
    
    init(applicationID:String) {
        
        if(!BMSPushClient.overrideServerHost.isEmpty){
            pwUrl_ += BMSPushClient.overrideServerHost
        }
        else {
            pwUrl_ += defaultProtocol
            pwUrl_ += "://"
            
            if BMSClient.sharedInstance.bluemixRegion?.containsString("stage1-test") == true || BMSClient.sharedInstance.bluemixRegion?.containsString("stage1-dev") == true {
                pwUrl_ += "mobile"
            }
            else{
                pwUrl_ += IMFPUSH
            }
            //pwUrl_ += "."
            pwUrl_ += BMSClient.sharedInstance.bluemixRegion!
        }
        
        pwUrl_ += FORWARDSLASH
        pwUrl_ += IMFPUSH
        pwUrl_ += FORWARDSLASH
        pwUrl_ += V1
        pwUrl_ += FORWARDSLASH
        pwUrl_ += APPS
        pwUrl_ += FORWARDSLASH
        pwUrl_ += applicationID
        pwUrl_ += FORWARDSLASH
    }
    
    func addHeader() -> [String: String] {
        
        return [IMFPUSH_CONTENT_TYPE_KEY:IMFPUSH_CONTENT_TYPE_JSON]
    }
    
    func getSubscribedDevicesUrl(devID:String) -> String {
        
        var deviceIdUrl:String = getDevicesUrl()
        deviceIdUrl += FORWARDSLASH
        deviceIdUrl += devID
        return deviceIdUrl
    }
    
    func getDevicesUrl() -> String {
        
        return getCollectionUrl(DEVICES)
    }
    
    func getTagsUrl() -> String {
        
        return getCollectionUrl(TAGS)
    }
    
    func getSubscriptionsUrl() -> String {
        
        return getCollectionUrl(SUBSCRIPTIONS)
    }
    
    func getAvailableSubscriptionsUrl(deviceId : String) -> String {
        
        var subscriptionURL = getCollectionUrl(SUBSCRIPTIONS)
        subscriptionURL += QUESTIONMARK
        subscriptionURL += "deviceId=\(deviceId)"
        
        return subscriptionURL;
    }
    
    func getUnSubscribetagsUrl() -> String {
        
        var unSubscriptionURL = getCollectionUrl(SUBSCRIPTIONS)
        unSubscriptionURL += QUESTIONMARK
        unSubscriptionURL += FORWARDSLASH
        unSubscriptionURL += IMFPUSH_ACTION_DELETE
        
        return unSubscriptionURL
    }
    
    func getUnregisterUrl (deviceId : String) -> String {
        
        var deviceUnregisterUrl:String = getDevicesUrl()
        deviceUnregisterUrl += FORWARDSLASH
        deviceUnregisterUrl += deviceId
        
        return deviceUnregisterUrl
    }
    
    internal func getCollectionUrl (collectionName:String) -> String {
        
        var collectionUrl:String = pwUrl_
        collectionUrl += collectionName
        
        return collectionUrl
    }
    
}
