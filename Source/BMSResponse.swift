/*
*     Copyright 2015 IBM Corp.
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

import UIKit
import BMSCore

/**
 This is the extension of `Response` class in the `BMSCore`.
 
 It is used to handle the responses from the push REST API calls.
 */
public extension Response {
    
    // MARK: Methods (Only for using in BMSPushClient)
    
    /**
    This methode will convert the response that get while calling the `retrieveSubscriptionsWithCompletionHandler` in `BMSPushClient' class into an array of Tags and send to the Client app.
    
    This will use the public property `responseText` in the `Response` Class.
    */
    public func subscriptions() -> NSMutableArray {
        
        
        // let finalSubscription = NSMutableDictionary()
        
        let subscription = NSMutableArray()
        
        let  subscriptionDictionary = convertStringToDictionary(self.responseText!)! as NSDictionary
        
        let subscriptionArray:NSArray = subscriptionDictionary.objectForKey(IMFPUSH_SUBSCRIPTIONS) as! NSArray
        
        var subscriptionResponsDic:NSDictionary?
        
        for  i in 0..<subscriptionArray.count {
            
            subscriptionResponsDic = subscriptionArray.objectAtIndex(i) as? NSDictionary
            
            subscription.addObject((subscriptionResponsDic?.objectForKey(IMFPUSH_TAGNAME))!)
        }
        
        //finalSubscription.setObject(subscription, forKey: IMFPUSH_SUBSCRIPTIONS)
        
        return subscription;
        
    }
    
    /**
     This methode will convert the response that get while calling the `subscribeToTags` in `BMSPushClient' class into an Dictionary of details and send to the Client app.
     
     This will use the public property `responseText` in the `Response` Class.
     */
    public func subscribeStatus() -> NSMutableDictionary {
        
        let finalDict = NSMutableDictionary()
        
        
        let  subscriptions = convertStringToDictionary(self.responseText!)! as NSDictionary
        
        if self.statusCode == 201 {
            
            let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_SUBSCRIBED) as! NSArray
            
            var responseText:NSDictionary?
            
            let arry = NSMutableArray()
            
            for  i in 0..<arraySub.count {
                
                responseText = arraySub.objectAtIndex(i) as? NSDictionary
                
                arry.addObject((responseText?.objectForKey(IMFPUSH_TAGNAME))!)
            }
            
            finalDict.setObject(arry, forKey:IMFPUSH_SUBSCRIPTIONS)
        }
        else if self.statusCode == 207 {
            
            
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_SUBSCRIPTIONEXISTS) as? NSArray {
                
                var responseText:NSDictionary?
                
                let arry = NSMutableArray()
                
                for  i in 0..<arraySub.count {
                    
                    responseText = arraySub.objectAtIndex(i) as? NSDictionary
                    
                    arry.addObject((responseText?.objectForKey(IMFPUSH_TAGNAME))!)
                }
                
                finalDict.setObject(arry, forKey:IMFPUSH_SUBSCRIPTIONEXISTS)
                /*
                if arraySub.count != 0 {
                
                
                if let dictTags:NSDictionary = arraySub.objectAtIndex(3) as? NSDictionary{
                
                var str:String = dictTags.description
                str = str.stringByReplacingOccurrencesOfString("[", withString: "")
                str = str.stringByReplacingOccurrencesOfString("]", withString: "")
                
                let items:NSArray = str.componentsSeparatedByString(",")
                finalDict.setObject(items, forKey: IMFPUSH_SUBSCRIPTIONEXISTS)
                
                }
                }
                */
                
            }
            
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_TAGSNOTFOUND) as? NSArray {
                
                var responseText:NSDictionary?
                
                let arry = NSMutableArray()
                
                for  i in 0..<arraySub.count {
                    
                    responseText = arraySub.objectAtIndex(i) as? NSDictionary
                    
                    arry.addObject((responseText?.objectForKey(IMFPUSH_TAGNAME))!)
                }
                
                finalDict.setObject(arry, forKey:IMFPUSH_TAGSNOTFOUND)
                /*if arraySub.count != 0 {
                
                if let dictTags:NSDictionary = arraySub.objectAtIndex(3) as? NSDictionary{
                
                var str:String = dictTags.description
                str = str.stringByReplacingOccurrencesOfString("[", withString: "")
                str = str.stringByReplacingOccurrencesOfString("]", withString: "")
                
                let items:NSArray = str.componentsSeparatedByString(",")
                finalDict.setObject(items, forKey: IMFPUSH_TAGSNOTFOUND)
                
                }
                }
                */
            }
            
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_SUBSCRIBED) as? NSArray {
                
                var responseText:NSDictionary?
                
                let arry = NSMutableArray()
                
                for  i in 0..<arraySub.count {
                    
                    responseText = arraySub.objectAtIndex(i) as? NSDictionary
                    
                    arry.addObject((responseText?.objectForKey(IMFPUSH_TAGNAME))!)
                }
                
                finalDict.setObject(arry, forKey:IMFPUSH_SUBSCRIPTIONS)
            }
            
        }
        return finalDict;
    }
    
    /**
     This methode will convert the response that get while calling the `unsubscribeFromTags` in `BMSPushClient' class into an Dictionary of details and send to the Client app.
     
     This will use the public property `responseText` in the `Response` Class.
     */
    public func unsubscribeStatus() -> NSMutableDictionary {
        
        
        let finalDict = NSMutableDictionary()
        
        
        let  subscriptions = convertStringToDictionary(self.responseText!)! as NSDictionary
        
        if self.statusCode == 201 {
            
            let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_UNSUBSCRIBED) as! NSArray
            
            var responseText:NSDictionary?
            
            let arry = NSMutableArray()
            
            for  i in 0..<arraySub.count {
                
                responseText = arraySub.objectAtIndex(i) as? NSDictionary
                
                arry.addObject((responseText?.objectForKey(IMFPUSH_TAGNAME))!)
            }
            
            finalDict.setObject(arry, forKey:IMFPUSH_UNSUBSCRIPTIONS)
            
        }
        else if self.statusCode == 207 {
            
            
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_SUBSCRIPTIONNOTEXISTS) as? NSArray {
                
                
                var responseText:String?
                
                let arry = NSMutableArray()
                
                for  i in 0..<arraySub.count {
                    
                    responseText = arraySub.objectAtIndex(i) as? String
                    
                    arry.addObject(responseText!)
                }
                
                finalDict.setObject(arry, forKey:IMFPUSH_SUBSCRIPTIONNOTEXISTS)
                /* if arraySub.count != 0 {
                
                if let dictTags:NSDictionary = arraySub.objectAtIndex(3) as? NSDictionary{
                
                var str:String = dictTags.description
                str = str.stringByReplacingOccurrencesOfString("[", withString: "")
                str = str.stringByReplacingOccurrencesOfString("]", withString: "")
                
                let items:NSArray = str.componentsSeparatedByString(",")
                finalDict.setObject(items, forKey: IMFPUSH_SUBSCRIPTIONNOTEXISTS)
                
                }
                }
                */
                
            }
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_TAGSNOTFOUND) as? NSArray {
                
                var responseText:String?
                
                let arry = NSMutableArray()
                
                for  i in 0..<arraySub.count {
                    
                    responseText = arraySub.objectAtIndex(i) as? String
                    
                    arry.addObject(responseText!)
                }
                
                finalDict.setObject(arry, forKey:IMFPUSH_TAGSNOTFOUND)
                /*
                if arraySub.count != 0 {
                
                if let dictTags:NSDictionary = arraySub.objectAtIndex(3) as? NSDictionary{
                
                var str:String = dictTags.description
                str = str.stringByReplacingOccurrencesOfString("[", withString: "")
                str = str.stringByReplacingOccurrencesOfString("]", withString: "")
                
                let items:NSArray = str.componentsSeparatedByString(",")
                finalDict.setObject(items, forKey: IMFPUSH_TAGSNOTFOUND)
                
                }
                }
                */
                
            }
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_UNSUBSCRIBED) as? NSArray {
                
                var responseText:String?
                
                let arry = NSMutableArray()
                
                for  i in 0..<arraySub.count {
                    
                    responseText = arraySub.objectAtIndex(i) as? String
                    
                    arry.addObject(responseText!)
                }
                
                finalDict.setObject(arry, forKey:IMFPUSH_UNSUBSCRIPTIONS)
            }
        }
        return finalDict;
    }
    
    /**
     This methode will convert the response that get while calling the `retrieveAvailableTagsWithCompletionHandler` in `BMSPushClient' class into an array and send to the Client app.
     
     This will use the public property `responseText` in the `Response` Class.
     */
    public func availableTags() -> NSMutableArray {
        
        let tags = NSMutableArray()
        
        let  tagsDictionary = convertStringToDictionary(self.responseText!)! as NSDictionary
        
        let tag:NSArray = tagsDictionary.objectForKey(IMFPUSH_TAGS) as! NSArray
        
        var tagResponseDic:NSDictionary?
        
        // FIXME: additinal unknown tags
        // tags.addObject("HiTag")
        // tags.addObject("errorTag")
        
        for  i in 0..<tag.count {
            
            tagResponseDic = tag.objectAtIndex(i) as? NSDictionary
            
            tags.addObject((tagResponseDic?.objectForKey(IMFPUSH_NAME))!)
            
        }
        
        
        return tags;
    }
    
    
    private func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            
            return try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        }
        return nil
    }
}