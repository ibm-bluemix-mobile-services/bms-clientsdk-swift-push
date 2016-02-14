IBM Bluemix Mobile Services - Client SDK Swift Push
===================================================

This is the Push component of the Swift SDK for IBM Bluemix Mobile Services. 

https://console.ng.bluemix.net/solutions/mobilefirst


## Contents

This package contains the Push components of the Swift SDK.
* Push Registration
* Subscribing and Unsubcribing for Tags


## Requirements

* iOS 8.0+ 
* Xcode 7


## Installation

The Bluemix Mobile Services Swift SDK is available via [Cocoapods](http://cocoapods.org/). 
To install, add the `BMSPush` pod to your `Podfile`. You have to add `BMSCore` also in your `Podfile`.

##### iOS

```Swift
use_frameworks!

target 'MyApp' do
    platform :ios, '8.0'
    pod 'BMSCore'
    pod 'BMSPush'
end
```


###Learning More
* Visit the **[Bluemix Developers Community](https://developer.ibm.com/bluemix/)**.

* [Getting started with IBM MobileFirst Platfrom for iOS](https://www.ng.bluemix.net/docs/mobile/index.html)

###Connect with Bluemix

[Twitter](https://twitter.com/ibmbluemix) |
[YouTube](https://www.youtube.com/playlist?list=PLzpeuWUENMK2d3L5qCITo2GQEt-7r0oqm) |
[Blog](https://developer.ibm.com/bluemix/blog/) |
[Facebook](https://www.facebook.com/ibmbluemix) |
[Meetup](http://www.meetup.com/bluemix/)


=======================
Copyright 2015 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
