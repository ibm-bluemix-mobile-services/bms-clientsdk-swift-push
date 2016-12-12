//
//  BMSPushRichPushNotificationOptions.swift
//  BMSPush
//
//  Created by Jim Dickens on 12/12/16.
//  Copyright © 2016 IBM Corp. All rights reserved.
//

import Foundation


#if swift(>=3.0)
    import UserNotifications
    import UserNotificationsUI
#endif

@available(iOS 10.0, *)
open class BMSRichPushNotificationOptions {
    
    
    public class func downloadRichPushContent(requestArray: Any, completionHandler: @escaping (_ response:String?, _ statusCode:Int?, _ error:String) -> Void){
        
        var contentHandler: ((UNNotificationContent) -> Void)?
        var bestAttemptContent: UNMutableNotificationContent?
        var request: UNNotificationRequest
        
        var arr: NSMutableArray
        
        arr = (requestArray as? ((NSMutableArray)))!
//        contentHandler = requestArray.object(at: 1) as? ((UNNotificationContent) -> Void)
//        request = (requestArray.object(at: 0) as? ((UNNotificationRequest)))!

                contentHandler = arr.object(at: 1) as? ((UNNotificationContent) -> Void)
                request = (arr.object(at: 0) as? ((UNNotificationRequest)))!

        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // Get the custom data from the notification payload
        if (request.content.userInfo["aps"] as? [String: AnyObject]) != nil {
            // Grab the attachment
            let url = request.content.userInfo["attachment-url"] as? String
            if let urlString = url, let fileUrl = URL(string: urlString ) {
                // Download the attachment
                URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
                    if let location = location {
                        // Move temporary file to remove .tmp extension
                        let tmpDirectory = NSTemporaryDirectory()
                        let tmpFile = "file://".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
                        let tmpUrl = URL(string: tmpFile)!
                        try! FileManager.default.moveItem(at: location, to: tmpUrl)
                        
                        // Add the attachment to the notification content
                        if let attachment = try? UNNotificationAttachment(identifier: "video", url: tmpUrl, options:nil) {
                            bestAttemptContent?.attachments = [attachment]
                        }
                    }
                    // Serve the notification content
                    contentHandler!(bestAttemptContent!)
                    completionHandler("Success", 1, "Job Well done")
                    }.resume()
            }
        }
    }
}
