//
//  BMSPushApplication.swift
//  BMSPush
//
//  Created by Jim Dickens on 11/10/16.
//  Copyright © 2016 IBM Corp. All rights reserved.
//

import Foundation

#if swift(>=3.0)
    import UserNotifications
    import UserNotificationsUI
#endif

    public class BMSPushApplication {
        
        #if swift(>=3.0)
    class public func setupPush ()  {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
                if(granted) {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    print("Error while registering with APNS server :  \(error?.localizedDescription)")
                }
            })
        } else {
            // Fallback on earlier versions
            
            let options :BMSPushClientOptions  = BMSPushClient.sharedInstance.notificationOptions!
            let category : [BMSPushNotificationActionCategory] = options.category
            
            let categoryFirst : BMSPushNotificationActionCategory = category.first!
            
            let pushNotificationAction : [BMSPushNotificationAction] = categoryFirst.actions
            let pushCategoryIdentifier : String = categoryFirst.identifier
            
            let firstActionButton : BMSPushNotificationAction = pushNotificationAction.first!
            let secondActionButton : BMSPushNotificationAction = pushNotificationAction[1]
            
            let replyActionButtonOne : UIMutableUserNotificationAction = UIMutableUserNotificationAction()
            replyActionButtonOne.identifier = firstActionButton.identifier
            replyActionButtonOne.title = firstActionButton.title
            replyActionButtonOne.activationMode = firstActionButton.activationMode
            replyActionButtonOne.isAuthenticationRequired = firstActionButton.authenticationRequired!
            
            let replyActionButtonTwo : UIMutableUserNotificationAction = UIMutableUserNotificationAction()
            replyActionButtonTwo.identifier = secondActionButton.identifier
            replyActionButtonTwo.title = secondActionButton.title
            replyActionButtonTwo.activationMode = secondActionButton.activationMode
            replyActionButtonTwo.isAuthenticationRequired = secondActionButton.authenticationRequired!
            
            let responseCategory : UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            responseCategory.identifier = pushCategoryIdentifier
            
            let replyActions: [UIUserNotificationAction] = [replyActionButtonOne, replyActionButtonTwo]
            
            responseCategory.setActions(replyActions, for:UIUserNotificationActionContext.default)
            responseCategory.setActions(replyActions, for:UIUserNotificationActionContext.minimal)
            
            let categories = NSSet(object: responseCategory)
            
            print ("JIM")
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories as! Set<UIUserNotificationCategory>)
            
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            
        }
    }


#else
    
    class public func setupPush() {
        
        let replyActionButtonOne : UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        replyActionButtonOne.identifier = "FIRST_BUTTON"
        replyActionButtonOne.title = "First"
        replyActionButtonOne.activationMode = UIUserNotificationActivationMode.background
        replyActionButtonOne.isAuthenticationRequired = false
        
        let replyActionButtonTwo : UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        replyActionButtonTwo.identifier = "SECOND_BUTTON"
        replyActionButtonTwo.title = "Second"
        replyActionButtonTwo.activationMode = UIUserNotificationActivationMode.background
        replyActionButtonTwo.isAuthenticationRequired = false
        
        let responseCategory : UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        responseCategory.identifier = "categoryOne"
        
        //let replyActions: NSArray = [replyActionButtonOne, replyActionButtonTwo]
        let replyActions: [UIUserNotificationAction] = [replyActionButtonOne, replyActionButtonTwo]
        
        responseCategory.setActions(replyActions, for:UIUserNotificationActionContext.default)
        responseCategory.setActions(replyActions, for:UIUserNotificationActionContext.minimal)
        
        let categories = NSSet(object: responseCategory)
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories as! Set<UIUserNotificationCategory>)
        
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
#endif

}

