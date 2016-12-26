//
//  NotificationService.swift
//  NotificationInterceptor
//
//  Created by Jim Dickens on 12/13/16.
//  Copyright © 2016 IBM Corp. All rights reserved.
//

#if swift(>=3.0)
import UserNotifications
import BMSPush
class NotificationService:BMSPushRichPushNotificationOptions {

    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
   
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        BMSPushRichPushNotificationOptions.didReceive(request, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
#endif
