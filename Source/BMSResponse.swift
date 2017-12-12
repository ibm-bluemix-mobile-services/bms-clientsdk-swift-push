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

import UIKit
import BMSCore

// MARK: - Swift 3 & Swift 4

#if swift(>=3.0)

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
                
        let subscription = NSMutableArray()
        
        if  let  subscriptionDictionary = convertStringToDictionary(text: self.responseText!) as NSDictionary? {
            
            if let subscriptionArray:[[String:String]] = subscriptionDictionary.object(forKey: IMFPUSH_SUBSCRIPTIONS) as? [[String:String]] {
                
                let subscriptions = subscriptionArray.map {($0)[IMFPUSH_TAGNAME]!}
                subscription.addObjects(from: subscriptions)
            }
        }
        return subscription;
    }
    
    /**
     This methode will convert the response that get while calling the `subscribeToTags` in `BMSPushClient' class into an Dictionary of details and send to the Client app.
     
     This will use the public property `responseText` in the `Response` Class.
     */
    public func subscribeStatus() -> NSMutableDictionary {
        
        
        let finalDict = NSMutableDictionary()
        
        if let subscriptions:NSDictionary = convertStringToDictionary(text: self.responseText!) as NSDictionary? {
            
            if let arraySub:NSArray = subscriptions.object(forKey: IMFPUSH_SUBSCRIPTIONEXISTS) as? NSArray {
                
                finalDict.setObject(arraySub, forKey:IMFPUSH_SUBSCRIPTIONEXISTS as NSCopying)
                
            }
            if let dictionarySub:NSDictionary = subscriptions.object(forKey: IMFPUSH_TAGSNOTFOUND) as? NSDictionary {
                
                
                finalDict.setObject(dictionarySub, forKey:IMFPUSH_TAGSNOTFOUND as NSCopying)
                
            }
            if let arraySub:NSArray = subscriptions.object(forKey: IMFPUSH_SUBSCRIBED) as? NSArray {
                
                finalDict.setObject(arraySub, forKey:IMFPUSH_SUBSCRIPTIONS as NSCopying)
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
        
        if let subscriptions:NSDictionary = convertStringToDictionary(text: self.responseText!) as NSDictionary? {
            
            
            if let arraySub:NSArray = subscriptions.object(forKey: IMFPUSH_SUBSCRIPTIONEXISTS) as? NSArray {
                
                
                finalDict.setObject(arraySub, forKey:IMFPUSH_SUBSCRIPTIONEXISTS as NSCopying)
                
            }
            if let dictionarySub:NSDictionary = subscriptions.object(forKey: IMFPUSH_TAGSNOTFOUND) as? NSDictionary {
                
                
                finalDict.setObject(dictionarySub, forKey:IMFPUSH_TAGSNOTFOUND as NSCopying)
                
            }
            if let arraySub:NSArray = subscriptions.object(forKey: IMFPUSH_SUBSCRIBED) as? NSArray {
                
                finalDict.setObject(arraySub, forKey:IMFPUSH_SUBSCRIPTIONS as NSCopying)
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
        
        if let tagsDictionary:NSDictionary = convertStringToDictionary(text: self.responseText!) as NSDictionary? {
            
             if let tag:[[String:String]] = tagsDictionary.object(forKey: IMFPUSH_TAGS) as? [[String:String]] {
               let tagsArray = tag.map {($0)[IMFPUSH_NAME]!}
               tags.addObjects(from: tagsArray)
            }
        }
        return tags;
    }
    
    
    private func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] else {
                return [:]
            }
            return result
        }
        return [:]
    }
}






/**************************************************************************************************/





// MARK: - Swift 2

#else

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
        
        if  let  subscriptionDictionary:NSDictionary = convertStringToDictionary(self.responseText!)! as NSDictionary {
            
            if let subscriptionArray:NSArray = subscriptionDictionary.objectForKey(IMFPUSH_SUBSCRIPTIONS) as? NSArray {
                
                
                var subscriptionResponsDic:NSDictionary?
                
                for  i in 0..<subscriptionArray.count {
                    
                    subscriptionResponsDic = subscriptionArray.objectAtIndex(i) as? NSDictionary
                    
                    subscription.addObject((subscriptionResponsDic?.objectForKey(IMFPUSH_TAGNAME))!)
                }
            }
            
            
            //finalSubscription.setObject(subscription, forKey: IMFPUSH_SUBSCRIPTIONS)
        }
        
        
        
        return subscription;
        
    }
    
    /**
     This methode will convert the response that get while calling the `subscribeToTags` in `BMSPushClient' class into an Dictionary of details and send to the Client app.
     
     This will use the public property `responseText` in the `Response` Class.
     */
    public func subscribeStatus() -> NSMutableDictionary {
        
        
        let finalDict = NSMutableDictionary()
        
        if let subscriptions:NSDictionary = convertStringToDictionary(self.responseText!)! as NSDictionary {
            
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_SUBSCRIPTIONEXISTS) as? NSArray {
                
                finalDict.setObject(arraySub, forKey:IMFPUSH_SUBSCRIPTIONEXISTS)
                
            }
            if let dictionarySub:NSDictionary = subscriptions.objectForKey(IMFPUSH_TAGSNOTFOUND) as? NSDictionary {
                
                
                finalDict.setObject(dictionarySub, forKey:IMFPUSH_TAGSNOTFOUND)
                
            }
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_SUBSCRIBED) as? NSArray {
                
                finalDict.setObject(arraySub, forKey:IMFPUSH_SUBSCRIPTIONS)
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
        
        if let subscriptions:NSDictionary = convertStringToDictionary(self.responseText!)! as NSDictionary {
            
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_SUBSCRIPTIONEXISTS) as? NSArray {
                
                
                finalDict.setObject(arraySub, forKey:IMFPUSH_SUBSCRIPTIONEXISTS)
                
            }
            if let dictionarySub:NSDictionary = subscriptions.objectForKey(IMFPUSH_TAGSNOTFOUND) as? NSDictionary {
                
                
                finalDict.setObject(dictionarySub, forKey:IMFPUSH_TAGSNOTFOUND)
                
            }
            if let arraySub:NSArray = subscriptions.objectForKey(IMFPUSH_SUBSCRIBED) as? NSArray {
                
                finalDict.setObject(arraySub, forKey:IMFPUSH_SUBSCRIPTIONS)
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
        
        if let tagsDictionary:NSDictionary = convertStringToDictionary(self.responseText!)! as NSDictionary {
            
            if let tag:NSArray = tagsDictionary.objectForKey(IMFPUSH_TAGS) as? NSArray {
                
                var tagResponseDic:NSDictionary?
                
                for  i in 0..<tag.count {
                    
                    tagResponseDic = tag.objectAtIndex(i) as? NSDictionary
                    
                    tags.addObject((tagResponseDic?.objectForKey(IMFPUSH_NAME))!)
                    
                }
            }
        }
        
        return tags;
    }
    
    
    private func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            
            guard let result = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject] else {
                return [:]
            }
            return result!
        }
        return [:]
    }
}

#endif
