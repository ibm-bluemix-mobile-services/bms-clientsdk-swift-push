Bluemix Push Notifications iOS SDK
===================================================

[![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-push.svg?branch=master)](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-push)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/08bd0c46c0ae4485a3abc0fd8dffa4cf)](https://www.codacy.com/app/ibm-bluemix-mobile-services/bms-clientsdk-swift-push?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ibm-bluemix-mobile-services/bms-clientsdk-swift-push&amp;utm_campaign=Badge_Grade)
[![Coverage Status](https://coveralls.io/repos/github/ibm-bluemix-mobile-services/bms-clientsdk-swift-push/badge.svg?branch=development)](https://coveralls.io/github/ibm-bluemix-mobile-services/bms-clientsdk-swift-push?branch=development)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/BMSPush.svg)](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-push.git)
[![](https://img.shields.io/badge/bluemix-powered-blue.svg)](https://bluemix.net)
[![CocoaPods](https://img.shields.io/cocoapods/dt/BMSPush.svg)](https://cocoapods.org/pods/BMSPush)


The [Bluemix Push Notifications service](https://console.ng.bluemix.net/catalog/services/push-notifications) provides a unified push service to send real-time notifications to mobile and web applications. The SDK enables iOS apps to receive push notifications sent from the service. Before starting to configure iOS SDK follow the [Bluemix Push service setup guide](https://console.ng.bluemix.net/docs/services/mobilepush/index.html#gettingstartedtemplate)

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [Cocoapods](#cocoapods)
  - [Carthage](#carthage)
- [Setup Client Application](#setup-client-application)
- [Register to Push Notifications Service](#register-to-push-notifications-ervice)
  - [Register Without UserId](#register-without-userid)
  - [Register With UserId](#register-with-userid)
  - [Unregistering the Device from Push Notifications](#unregistering-the-device-from-push-notifications)
- [Push Notification service tags](#push-notification-service-tags)
  - [Retrieve tags](#retrieve-tags)
  - [Subscribe to tags](#subscribe-to-tags)
  - [Retrieve Subscribed tags](#retrieve-subscribed-tags)
  - [Unsubscribing from tags](#unsubscribing-from-tags)
- [Receiving push notifications on iOS devices](#receiving-push-notifications-on-ios-devices)
- [Notification Options](#notification-options)
  - [Silent Notification](#silent-notification)
  - [Enable Interactive push notifications](#enable-interactive-push-notifications)
  - [Handling Interactive push notifications](#handling-interactive-push-notifications)
  - [Adding custom DeviceId for registration](#ddding-custom-deviceid-for-registration)
- [Enabling iOS 10 Rich Push notification](#enabling-ios-10-rich-push-notification)
- [Advanced options](#advanced-options)
  - [iOS Badge](#ios-badge)
  - [Custom Sound](#custom-sound)
- [Enable Monitoring](#enable-monitoring)
- [Open Url by clicking push notifications](#open-url-by-clicking-push-notifications)
- [Samples and Videos](#samples-and-videos)

## Requirements

* iOS 8.0+
* Xcode 7.3, 8.0+
* Swift 2.3 - 3.0+
* [Cocoapods](https://github.com/CocoaPods/CocoaPods-app/releases)(Ensure that you should use the latest version)
* Carthage

## Installation

The `Bluemix Push Notifications iOS SDK` is available via [Cocoapods](http://cocoapods.org/) and [Carthage](https://github.com/Carthage/Carthage).

### Cocoapods

If your project does not have a `Podfile` yet, use the `pod init` command to create one. To install `Bluemix Push Notifications iOS SDK` using Cocoapods, add the following to your Podfile,

```
use_frameworks!

target 'MyApp' do
    platform :ios, '8.0'
    pod 'BMSCore', '~> 2.0'
    pod 'BMSPush', '~> 3.0'
end
```
From the Terminal, go to your project folder and install the dependencies with the following command,

```
pod install
```

For apps built with Swift 3.0, you may receive a prompt saying "Convert to Current Swift Syntax?" when opening your project in Xcode 8 (following the installation of BMSCore) do not convert BMSPush, BMSCore or BMSAnalyticsAPI

This will installs your dependencies and creates a new Xcode workspace.

>**Note**: Ensure that you always open the new Xcode workspace, instead of the original Xcode project file: <strong>MyApp.xcworkspace</strong>.


### Carthage

To install BMSPush using Carthage, add it to your Cartfile,

```
github "ibm-bluemix-mobile-services/bms-clientsdk-swift-push"
```

Then run the `carthage update` command. Once the build is finished, add `BMSPush.framework`,`BMSCore.framework` and `BMSAnalyticsAPI.framework` into your Xcode project.

To complete the integration, follow the instructions [here](https://github.com/Carthage/Carthage#getting-started).

#### Xcode 8

For apps built with `Swift 2.3`, use the command `carthage update --toolchain com.apple.dt.toolchain.Swift_2_3.` Otherwise, for `Swift 3.0+` use `carthage update`.


## Setup Client Application

 Follow the steps to enable iOS applications to receive push notifications.

1. Add the `import` statements in your `.swift` file.

    ```
      import BMSCore
      import BMSPush
    ```
2. Initialize the Core SDK and Push SDK

```
BMSClient.sharedInstance.initialize(bluemixRegion: "Location where your app Hosted")

BMSPushClient.sharedInstance.initializeWithAppGUID(appGUID: "your push appGUID", clientSecret:"your push client secret")
```

##### bluemixRegion

- Specifies the location where the application is hosted. You can use following values
  * `BMSClient.Region.usSouth`
  * `BMSClient.Region.unitedKingdom`
  * `BMSClient.Region.sydney`

##### appGUID

- The Push service instance Id value.

##### clientSecret

- The Push service instance client secret value.

>**Note**: If you are using Xcode8 beta, add `yourApp.entitlements`. To do this, go to Targets -> Capabilities and enable Push Notifications capability.

## Register to Push Notifications Service

 Upon successful initialization, Apple Push Notification service(APNs) will give a token in `didRegisterForRemoteNotificationsWithDeviceToken` method. Pass this token to Push Notifications service register API.

### Register Without UserId

 To register without userId use the following pattern

```
 func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){

   BMSPushClient.sharedInstance.registerWithDeviceToken(deviceToken: deviceToken) { (response, statusCode, error) -> Void in
    if error.isEmpty {
      print( "Response during device registration: \(response) and status code is:\(statusCode)")
    } else{
      print( "Error during device registration: \(error) and status code is: \(statusCode)")
    }  
 }
```

### Register With UserId

The `userId` can be specified while registering the device with Push Notifications service. The register method will accept one more parameter - `userId`

```
func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){

   BMSPushClient.sharedInstance.registerWithDeviceToken(deviceToken: deviceToken, WithUserId: "your userId") { (response, statusCode, error) -> Void in
    if error.isEmpty {
      print( "Response during device registration : \(response) and status code is:\(statusCode)")
    } else{
      print( "Error during device registration \(error) and status code is:\(statusCode) ")
    }  
}
```

##### WithUserId

- The user identifier value you want to register the device in the push service instance.

>**Note**: If userId is provided the client secret value must be provided during initialization.


### Unregistering the Device from Push Notifications


Use the following code snippets to unregister the device from push notification service instance

```

//Swift3

BMSPushClient.sharedInstance.unregisterDevice(completionHandler: { (response, statusCode, error) -> Void in

  if error.isEmpty {                 
     print( "Response during unregistering device : \(response)  and status code is:\(statusCode)")
   }else{
     print( "Error during unregistering device \(error) and status code is:\(statusCode)")
   }
}

//Swift2.3 and Older

BMSPushClient.sharedInstance.unregisterDevice({ (response, statusCode, error) -> Void in

    if error.isEmpty {
        print( "Response during unregistering device : \(response) and status code is:\(statusCode)")
    }else{
        print( "Error during unregistering device \n  - status code: \(statusCode) \n Error :\(error) \n")
    }
}
```

>**Note**:To unregister from the `UserId` based registration you have to call the registration method [without userId](#register-without-userid).


## Push Notification service tags

### Retrieve tags

 The `retrieveAvailableTagsWithCompletionHandler` API returns the list of tags to which the device
can subscribe. After the device is subscribes to a particular tag, the device can receive notifications
that are sent for that tag.

Use the following code snippets into your Swift mobile application to get a list of tags to which the
device can subscribe.

```

//Swift3

BMSPushClient.sharedInstance.retrieveAvailableTagsWithCompletionHandler(completionHandler: { (response, statusCode, error) -> Void in

  if error.isEmpty {
    print( "Response during retrieve tags : \(response)  and status code is:\(statusCode)")
  }else{
    print( "Error during retrieve tags \n  - status code: \(statusCode) \n Error :\(error) \n")
  }
}

//Swift2.3 and Older

BMSPushClient.sharedInstance.retrieveAvailableTagsWithCompletionHandler({ (response, statusCode, error) -> Void in

    if error.isEmpty {
        print( "Response during retrieve tags : \(response)  and status code is:\(statusCode)")
    }else{
        print( "Error during retrieve tags \n  - status code: \(statusCode) \n Error :\(error) \n")
    }
}
```

### Subscribe to tags

The `subscribeToTags` API will subscribe the iOS device for the list of given tags. After the device is subscribed to a particular tag, the device can receive any push notifications
that are sent for that tag.

Use the following code snippets into your Swift mobile application to subscribe a list of tags.

```
//Swift3

 BMSPushClient.sharedInstance.subscribeToTags(tagsArray: response!, completionHandler: { (response, statusCode, error) -> Void in

   if error.isEmpty {
       print( "Response during Subscribing to tags : \(response?.description) and status code is:\(statusCode)")     
     }else{
       print( "Error during subscribing tags \n  - status code: \(statusCode) \n Error :\(error) \n")
     }
 }

//Swift2.3 and Older

BMSPushClient.sharedInstance.subscribeToTags(response, completionHandler: { (response, statusCode, error) -> Void in

    if error.isEmpty {
        print( "Response during Subscribing to tags : \(response?.description)  and status code is:\(statusCode)")
    } else {
        print( "Error during subscribing tags \n  - status code: \(statusCode) \n Error :\(error) \n")
    }
}
```

### Retrieve Subscribed tags

The `retrieveSubscriptionsWithCompletionHandler` API will return the list of tags to which the device is subscribed.

Use the following code snippets into your Swift mobile application to get the  subscription list.

```

//Swift3
 BMSPushClient.sharedInstance.retrieveSubscriptionsWithCompletionHandler(completionHandler: { (response, statusCode, error) -> Void in

   if error.isEmpty {                                     
     print( "Response during retrieving subscribed tags : \(response?.description) and status code is:\(statusCode)")
   } else{
     print( "Error during retrieving subscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
   }
 }

//Swift2.3 and Older
BMSPushClient.sharedInstance.retrieveSubscriptionsWithCompletionHandler { (response, statusCode, error) -> Void in

    if error.isEmpty {
        print( "Response during retrieving subscribed tags : \(response?.description) and status code is:\(statusCode))
    }else {
        print( "Error during retrieving subscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
    }
}
```
### Unsubscribing from tags

The `unsubscribeFromTags` API will remove the device subscription from the list tags.

Use the following code snippets to unsubsribe from tags

```

//Swift3
BMSPushClient.sharedInstance.unsubscribeFromTags(tagsArray: response!, completionHandler: { (response, statusCode, error) -> Void in

  if error.isEmpty {
    print( "Response during unsubscribed tags : \(response?.description) and status code is:\(statusCode)")
  }else{
    print( "Error during  unsubscribed tags \(error)and status code is:\(statusCode)")
  }
}

//Swift2.3 and Older

BMSPushClient.sharedInstance.unsubscribeFromTags(response, completionHandler: { (response, statusCode, error) -> Void in

    if error.isEmpty {

        print( "Response during unsubscribed tags : \(response?.description)and status code is:\(statusCode)")
    }
    else {
        print( "Error during unsubscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
    }
}
```

## Receiving push notifications on iOS devices

To receive push notifications on iOS devices, add the following Swift method to the `appDelegate.swift` of your application,

```
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

   //UserInfo dictionary will contain data sent from the server

}
```

## Notification Options

### Silent Notification

Silent notifications do not appear on the device screen. These notifications are received by the application in the background, which wakes up the application for up to 30 seconds to perform the specified background task. A user might not be aware of the notification arrival.

To handle the silent push notifications use the `didReceiveRemoteNotification_fetchCompletionHandler` method.

```
func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
   let contentAPS = userInfo["aps"] as [NSObject : AnyObject]
   if let contentAvailable = contentAPS["content-available"] as? Int {
       //silent or mixed push
       if contentAvailable == 1 {
           completionHandler(UIBackgroundFetchResult.NewData)
       } else {
           completionHandler(UIBackgroundFetchResult.NoData)
       }
   } else {
       //Default notification
       completionHandler(UIBackgroundFetchResult.NoData)
   }
}
```
#### Enable Interactive push notifications

To enable interactive push notifications, the notification action objects must be passed during initialization. The following is a sample code to enable interactive notifications.

```
let acceptButton = BMSPushNotificationAction(identifierName: "Accept", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)

let rejectButton = BMSPushNotificationAction(identifierName: "Reject", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)

let category = BMSPushNotificationActionCategory(identifierName: "category", buttonActions: [acceptButton, rejectButton])

let notificationOptions = BMSPushClientOptions()
notificationOptions.setInteractiveNotificationCategories(categoryName: [category])

BMSPushClient.sharedInstance.initializeWithAppGUID(appGUID: "your push appGUID",
 clientSecret:"your push client secret", options: notificationOptions)

```

#### Handling Interactive push notifications

Implement the callback method on `AppDelegate.swift`,

```
func userNotificationCenter(_ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
         switch response.actionIdentifier {
         case "Accept":
           print("Clicked Accept")
         case "Reject":
           print("Clicked Reject")  
         default:
         }
     completionHandler()
 }
```

This callback method is invoked when user clicks the action button. The implementation of this method must perform tasks associated with the specified identifier and execute the block in the completionHandler parameter.

#### Adding custom DeviceId for registration

To send `Device Identifier` use the `setDeviceId` method of `BMSPushClientOptions`.

```
let notificationOptions = BMSPushClientOptions()
notificationOptions.setDeviceId(deviceId: "YOUR_DEVICE_ID")
```
>**Note**: Remember to keep custom Device Identifier <strong>unique</strong> for each device.


### Enabling iOS 10 Rich Push notification

To receive rich push notifications with iOS 10, implement <strong>UNNotificationServiceExtension</strong>.  The extension will intercept and handle the rich push notification.

In the `didReceive()` method of your service extension, add the following code to retrieve the Rich push notification content.

```
override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
       self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        BMSPushRichPushNotificationOptions.didReceive(request, withContentHandler: contentHandler)
  }
```

## Advanced options

### iOS Badge

For iOS devices, the number to display as the badge of the app icon. If this property is absent, the badge is not changed. To remove the badge, set the value of this property to 0.

### Custom Sound

Add the sound file in your iOS application. Refer TODO

## Enable Monitoring

To see the push notification monitoring status for iOS you have to add the following code snippets,

<strong>Swift 3</strong>
```
// Send notification status when app is opened by clicking the notifications
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {

     let push =  BMSPushClient.sharedInstance
     let respJson = (userInfo as NSDictionary).value(forKey: "payload") as! String
     let data = respJson.data(using: String.Encoding.utf8)

     let jsonResponse:NSDictionary = try! JSONSerialization.jsonObject(with: data! , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

     let messageId:String = jsonResponse.value(forKey: "nid") as! String
     push.sendMessageDeliveryStatus(messageId: messageId) { (res, ss, ee) in
         print("Send message status to the Push server")
     }
}


// Send notification status when the app is in background mode.
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

   let payLoad = ((((userInfo as NSDictionary).value(forKey: "aps") as! NSDictionary).value(forKey: "alert") as! NSDictionary).value(forKey: "body") as! NSString)

   self.showAlert(title: "Recieved Push notifications", message: payLoad)

   let push =  BMSPushClient.sharedInstance

   let respJson = (userInfo as NSDictionary).value(forKey: "payload") as! String
   let data = respJson.data(using: String.Encoding.utf8)

   let jsonResponse:NSDictionary = try! JSONSerialization.jsonObject(with: data! , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

   let messageId:String = jsonResponse.value(forKey: "nid") as! String
   push.sendMessageDeliveryStatus(messageId: messageId) { (res, ss, ee) in
       completionHandler(UIBackgroundFetchResult.newData)
   }
}
```

<strong>Swift 2.3</strong>

```
func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {

  let respJson = (userInfo as NSDictionary).valueForKey("payload") as! String
  let data = respJson.dataUsingEncoding(NSUTF8StringEncoding)

  do {
      let responseObject:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
      let nid = responseObject.valueForKey("nid") as! String
      print(nid)

      let push =  BMSPushClient.sharedInstance

      push.sendMessageDeliveryStatus(nid, completionHandler: { (response, statusCode, error) in

          print("Send message status to the Push server")
      })

  } catch let error as NSError {
      print("error: \(error.localizedDescription)")
  }
}

func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

  let payLoad = ((((userInfo as NSDictionary).valueForKey("aps") as! NSDictionary).valueForKey("alert") as! NSDictionary).valueForKey("body") as! NSString)

  self.showAlert("Recieved Push notifications", message: payLoad)


  let respJson = (userInfo as NSDictionary).valueForKey("payload") as! String
  let data = respJson.dataUsingEncoding(NSUTF8StringEncoding)

  do {
      let responseObject:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
      let nid = responseObject.valueForKey("nid") as! String
      print(nid)

      let push =  BMSPushClient.sharedInstance

      push.sendMessageDeliveryStatus(nid, completionHandler: { (response, statusCode, error) in
          completionHandler(UIBackgroundFetchResult.NewData)
      })

  } catch let error as NSError {
      print("error: \(error.localizedDescription)")
  }
}
```

>**Note**: To get the message status when the app is in background you have to send either <strong>MIXED</strong> or <strong>SILENT</strong> push notifications. If the app is force quite you will not get any message delivery status.


## Open Url by clicking push notifications

To open a url by clicking the push notification you can send a `url` field inside the payload.

```
{
  "message": {
    "alert": "Notification alert message",
    "url":"https://console.ng.bliuemix.net"
  }
}
```

In your applications, go to `AppDelegate` file and inside `didFinishLaunchingWithOptions` check the value for `url`

```
let remoteNotif = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary

if remoteNotif != nil {
    let urlField = (remoteNotif?.value(forKey: "url") as! String)
    application.open(URL(string: urlField)!, options: [:], completionHandler: nil)
}
```

## Samples and Videos

* Please visit for samples - [Github Sample](https://github.com/ibm-bluemix-mobile-services/bms-samples-swift-hellopush)

* Video Tutorials Available here - [Bluemix Push Notifications](https://www.youtube.com/channel/UCRr2Wou-z91fD6QOYtZiHGA)

### Learning More

* Visit the **[Bluemix Developers Community](https://developer.ibm.com/bluemix/)**.

* [Getting started with IBM MobileFirst Platform for iOS](https://www.ng.bluemix.net/docs/mobile/index.html)

### Connect with Bluemix

[Twitter](https://twitter.com/ibmbluemix) |
[YouTube](https://www.youtube.com/playlist?list=PLzpeuWUENMK2d3L5qCITo2GQEt-7r0oqm) |
[Blog](https://developer.ibm.com/bluemix/blog/) |
[Facebook](https://www.facebook.com/ibmbluemix) |
[Meetup](http://www.meetup.com/bluemix/)


=======================
Copyright 2016 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
