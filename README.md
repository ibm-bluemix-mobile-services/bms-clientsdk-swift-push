IBM Cloud Mobile Services - Client SDK Swift Push
===================================================

[![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-push.svg?branch=master)](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-push)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/e77ce09404264d40991865b33b8cf0bf)](https://www.codacy.com/gh/ibm-bluemix-mobile-services/bms-clientsdk-swift-push?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ibm-bluemix-mobile-services/bms-clientsdk-swift-push&amp;utm_campaign=Badge_Grade)
[![Coverage Status](https://coveralls.io/repos/github/ibm-bluemix-mobile-services/bms-clientsdk-swift-push/badge.svg?branch=development)](https://coveralls.io/github/ibm-bluemix-mobile-services/bms-clientsdk-swift-push?branch=development)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/BMSPush.svg)](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-push.git)

The [IBM Cloud Push Notifications service](https://cloud.ibm.com/catalog/services/push-notifications) provides a unified push service to send real-time notifications to mobile and web applications. The SDK enables iOS apps to receive push notifications sent from the service. 

Ensure that you go through [IBM Cloud Push Notifications service documentation](https://cloud.ibm.com/docs/services/mobilepush?topic=mobile-pushnotification-gettingstartedtemplate#gettingstartedtemplate) before you start.

## Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Cocoapods](#cocoapods)
  - [Carthage](#carthage)
- [Initialize SDK](#initialize-sdk)
- [Register for notifications](#register-for-notifications)
- [Push Notification service tags](#push-notification-service-tags)
  - [Retrieve tags](#retrieve-tags)
  - [Subscribe to tags](#subscribe-to-tags)
  - [Retrieve subscribed tags](#retrieve-subscribed-tags)
  - [Unsubscribing from tags](#unsubscribing-from-tags)
- [Receiving push notifications on iOS devices](#receiving-push-notifications-on-ios-devices)
- [Notification options](#notification-options)
  - [Silent notification](#silent-notification)
  - [Interactive notifications](#interactive-notifications)
  - [Handling interactive push notifications](#handling-interactive-push-notifications)
  - [Adding custom DeviceId for registration](#adding-custom-deviceid-for-registration)
  - [Enabling rich media notifications](#enabling-rich-media-notifications)
- [Advanced options](#advanced-options)
  - [iOS badge](#ios-badge)
  - [Custom sound](#custom-sound)
- [Enable monitoring](#enable-monitoring)
- [Open URL by clicking push notifications](#open-url-by-clicking-push-notifications)
- [Parameterize Push Notifications](#parameterize-push-notifications)
- [API documentation](#api-documentation)
- [Samples and videos](#samples-and-videos)

## Prerequisites

* iOS 8.0 or later
* Xcode 8.0 or later
* Swift 3.0 or later
* [Cocoapods latest version](https://github.com/CocoaPods/CocoaPods-app/releases) 
* Carthage

## Installation

The `IBM Cloud Push Notifications iOS SDK` is available through [Cocoapods](http://cocoapods.org/) and [Carthage](https://github.com/Carthage/Carthage). 

### Cocoapods

If your project does not have a `Podfile` yet, use the `pod init` command to create one. To install `IBM Cloud Push Notifications iOS SDK` using Cocoapods, add the following to your Podfile:

```
use_frameworks!
target 'MyApp' do
    platform :ios, '8.0'
    pod 'BMSCore', '~> 2.0'
    pod 'BMSPush', '~> 3.0'
end
```

From the terminal, go to your project folder and install the dependencies with the `pod install` command.

For apps built with Swift 3.0, you may receive a prompt saying "Convert to Current Swift Syntax?" when opening your project in Xcode 8 (following the installation of BMSCore). Do not convert BMSPush, BMSCore or BMSAnalyticsAPI.

This will install the required dependencies and create a new Xcode workspace.

>**Note**: Ensure that you always open the new Xcode workspace, instead of the original Xcode project file: <strong>MyApp.xcworkspace</strong>.


### Carthage

To install BMSPush using Carthage, complete the following steps:

1. Add it to your Cartfile:
```
github "ibm-bluemix-mobile-services/bms-clientsdk-swift-push"
```
2. Run the `carthage update` command. 
3. Upon a successful build, add `BMSPush.framework`,`BMSCore.framework` and `BMSAnalyticsAPI.framework` into your Xcode project.

To complete the integration, follow the instructions [here](https://github.com/Carthage/Carthage#getting-started).

#### Xcode 8

Choose either of the following options:

- For `Swift 3.+` apps, use `carthage update`.


## Initialize SDK

Complete the following steps to enable iOS applications to receive notifications.

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

Where `bluemixRegion` specifies the location where the application is hosted. You can use following values:

- `BMSClient.Region.usSouth`
- `BMSClient.Region.unitedKingdom`
- `BMSClient.Region.sydney`
- `BMSClient.Region.germany`
- `BMSClient.Region.jpTok`
- `BMSClient.Region.usEast`

The `appGUID` is the Push service instance Id value, and `clientSecret` is the Push service instance client secret value.

>**Note**: If you are using Xcode8 beta, add `yourApp.entitlements`. To do this, go to Targets > Capabilities and enable Push Notifications capability.

## Register for notifications

Upon successful initialization, Apple Push Notification service (APNs) will give a token in `didRegisterForRemoteNotificationsWithDeviceToken` method. Pass the token to Push Notifications service register API.

The following options are supported:

- Register without UserId

	To register without userId use the following pattern:

	```swift
	func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
	  
	  BMSPushClient.sharedInstance.registerWithDeviceToken(deviceToken: deviceToken) { (response, statusCode, error) -> Void in
	   
	   if error.isEmpty {
		   print( "Response during device registration: \(response) and status code is:\(statusCode)")
	   } else {
		   print( "Error during device registration: \(error) and status code is: \(statusCode)")
	   }  
	 }
	```

- Register with UserId

	The `userId` can be specified while registering the device with Push Notifications service. The register method will accept one more parameter - `userId`

	```swift
	func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
	   
	   BMSPushClient.sharedInstance.registerWithDeviceToken(deviceToken: deviceToken, WithUserId: "your userId") { (response, statusCode, error) -> Void in
	   
	    if error.isEmpty {
			print( "Response during device registration : \(response) and status code is:\(statusCode)")
	    } else {
			print( "Error during device registration \(error) and status code is:\(statusCode) ")
	    }  
	}
	```

	Where `WithUserId` is the user identifier value you want to register the device in the push service instance.

	>**Note**: If userId is provided, the client secret value must be provided during initialization.


- Unregister device from notifications

	Use the following code snippets to unregister the device from Push Notification service instance:
		
	```swift
	BMSPushClient.sharedInstance.unregisterDevice(completionHandler: { (response, statusCode, error) -> Void in
	   if error.isEmpty {
		   print( "Response during unregistering device : \(response)  and status code is:\(statusCode)")
		} else {
			print( "Error during unregistering device \(error) and status code is:\(statusCode)")
		}
	}
	```

	>**Note**:To unregister from the `UserId` based registration, you have to call the registration method [without userId](#register-without-userid).


## Push Notification service tags

### Retrieve tags

The `retrieveAvailableTagsWithCompletionHandler` API returns the list of tags to which the device can subscribe. After the device is subscribed to a particular tag, the device can receive notifications that are sent for that tag.

Use the following code snippets into your Swift mobile application to get a list of tags to which the device can subscribe.

```swift
BMSPushClient.sharedInstance.retrieveAvailableTagsWithCompletionHandler(completionHandler: { (response, statusCode, error) -> Void in
	  
	if error.isEmpty {
		print( "Response during retrieve tags : \(response)  and status code is:\(statusCode)")
	} else {
		print( "Error during retrieve tags \n  - status code: \(statusCode) \n Error :\(error) \n")
	}
}
```

### Subscribe to tags

The `subscribeToTags` API will subscribe the iOS device for the list of given tags. After the device is subscribed to a particular tag, the device can receive any push notifications that are sent for that tag.

Add the following code snippets to your Swift mobile application to subscribe a list of tags.
	
```swift
BMSPushClient.sharedInstance.subscribeToTags(tagsArray: response!, completionHandler: { (response, statusCode, error) -> Void in
	
	if error.isEmpty {
		print( "Response during Subscribing to tags : \(response?.description) and status code is:\(statusCode)")     
	} else {
		print( "Error during subscribing tags \n  - status code: \(statusCode) \n Error :\(error) \n")
	}
}
```

### Retrieve subscribed tags

The `retrieveSubscriptionsWithCompletionHandler` API will return the list of tags to which the device is subscribed.

Add the following code snippets to your Swift mobile application to get the  subscription list.

```swift
BMSPushClient.sharedInstance.retrieveSubscriptionsWithCompletionHandler(completionHandler: { (response, statusCode, error) -> Void in
	   
	if error.isEmpty {                                     
	    print( "Response during retrieving subscribed tags : \(response?.description) and status code is:\(statusCode)")
	} else {
		print( "Error during retrieving subscribed tags \n  - status code: \(statusCode) \n Error :\(error) \n")
	}
}
```
### Unsubscribing from tags

The `unsubscribeFromTags` API will remove the device subscription from the list tags.

Use the following code snippets to unsubsribe from tags:

```swift
BMSPushClient.sharedInstance.unsubscribeFromTags(tagsArray: response!, completionHandler: { (response, statusCode, error) -> Void in
	 
	if error.isEmpty {
		print( "Response during unsubscribed tags : \(response?.description) and status code is:\(statusCode)")
	} else {
		print( "Error during  unsubscribed tags \(error)and status code is:\(statusCode)")
	}
}
```

## Receiving push notifications on iOS devices

To receive push notifications on iOS devices, add the following Swift method to the `appDelegate.swift` of your application:

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
	
	//UserInfo dictionary will contain data sent from the server
}
```

## Notification options

### Silent notification

Silent notifications do not appear on the device screen. These notifications are received by the application in the background, which wakes up the application for up to 30 seconds to perform the specified background task. A user might not be aware of the notification arrival.

To handle silent push notifications, use the `didReceiveRemoteNotification_fetchCompletionHandler` method.

```swift
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
### Interactive notifications

To enable interactive push notifications, the notification action objects must be passed during initialization. The following is a sample code to enable interactive notifications:
```
let acceptButton = BMSPushNotificationAction(identifierName: "Accept", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
let rejectButton = BMSPushNotificationAction(identifierName: "Reject", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.background)
let category = BMSPushNotificationActionCategory(identifierName: "category", buttonActions: [acceptButton, rejectButton])
let notificationOptions = BMSPushClientOptions()
notificationOptions.setInteractiveNotificationCategories(categoryName: [category])
BMSPushClient.sharedInstance.initializeWithAppGUID(appGUID: "your push appGUID", clientSecret:"your push client secret", options: notificationOptions)
```

#### Handling interactive push notifications

Implement the callback method on `AppDelegate.swift`:

```swift
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

To send `Device Identifier`, use the `setDeviceId` method of `BMSPushClientOptions`.

```swift
let notificationOptions = BMSPushClientOptions()
notificationOptions.setDeviceId(deviceId: "YOUR_DEVICE_ID")
```
>**Note**: Remember to keep custom Device Identifier <strong>unique</strong> for each device.


### Enabling rich media notifications

Rich media notifications are supported on iOS 10 or later. To receive rich media notifications, implement <strong>UNNotificationServiceExtension</strong>. The extension will intercept and handle the rich media notification.

In the `didReceive()` method of your service extension, add the following code to retrieve the rich push notification content.

```swift
override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
	self.contentHandler = contentHandler
	bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
	BMSPushRichPushNotificationOptions.didReceive(request, withContentHandler: contentHandler)
}
```

## Advanced options

### iOS badge

For iOS devices, the number to display as the badge of the app icon. If this property is absent, the badge is not changed. To remove the badge, set the value of this property to 0.

### Custom sound

Add a sound file to your iOS application. 

## Enable monitoring

To see the notification monitoring status for iOS, you have to add the following code snippets:

```swift
//Send notification status when app is opened by clicking notifications
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

// Send notification status when the app is in background mode
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

>**Note**: To get the message status when the app is in background, you have to send either **MIXED** or **SILENT** push notifications. No message delivery status would be received if the app was exited forcefully. 

## Open URL by clicking push notifications

To open a url by clicking the push notification, you can send a `url` field inside the payload.
	
```JSON
{
  "message": {
    "alert": "Notification alert message",
    "url":"https://console.ng.bliuemix.net"
  }
}
```

In your applications, go to `AppDelegate` file and inside `didFinishLaunchingWithOptions`. check the value for `url`.
	
```swift
let remoteNotif = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
if remoteNotif != nil {
	let urlField = (remoteNotif?.value(forKey: "url") as! String)
	application.open(URL(string: urlField)!, options: [:], completionHandler: nil)
}
```

## Parameterize Push Notifications

 To enable the Parameterize IBM Cloud Push Notifications, do the following ,

 1. Add the variables key vaue pair in the `BMSPushClientOptions`

   ```swift
    
    let variables = [
          "username":"testname",
          "accountNumber":"3564758697057869"
          ]
    let notifOptions = BMSPushClientOptions()
    notifOptions.setPushVariables(pushVaribales: variables)
   ```
2. Pass the `BMSPushClientOptions` in the `initializeWithAppGUID()` method. While registering the device IBM Cloud Push Notifications iOS SDK will pass these variables to IBM Cloud Push Notifications service. 

3. In the `application:didReceiveRemoteNotification:fetchCompletionHandler ()` add the following to handle the template based push notifications,

    ```Swift
        let push =  BMSPushClient.sharedInstance
        push.didReciveBMSPushNotification(userInfo: userInfo) { (res, error) in
            completionHandler(UIBackgroundFetchResult.newData)
        }
    ```

4. While sending push notification add the varibale key in `{{}}`

  ```JSON

    {
        "message": {
            "alert": "hello {{username}} , balance on your account {{accountNumber}} is $1200"
        }
    }

  ```
>**Note**: If the app is force killed , the Template based notifications may not appear in the device.

## API documentation
 Find the API documentation here - http://ibm-bluemix-mobile-services.github.io/API-docs/client-SDK/BMSPush/Swift/index.html

## Samples and videos

* For samples, visit - [Github Sample](https://github.com/ibm-bluemix-mobile-services/bms-samples-swift-hellopush)

* For video tutorials visit - [IBM Cloud Push Notifications](https://www.youtube.com/playlist?list=PLTroxxTPN9dIZYn9IU-IOcQePO-u5r0r4)

### Learning more

* Visit the **[IBM Cloud Developers Community](https://developer.ibm.com/depmodels/cloud/)**.

* [Getting started with IBM MobileFirst Platform for iOS](https://cloud.ibm.com/docs/mobile)

### Connect with IBM Cloud

[Twitter](https://twitter.com/IBMCloud) |
[YouTube](https://www.youtube.com/watch?v=AVPoBWScRQc) |
[Blog](https://developer.ibm.com/depmodels/cloud/) |
[Facebook](https://www.facebook.com/ibmcloud) |


=======================
Copyright 2020-21 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.