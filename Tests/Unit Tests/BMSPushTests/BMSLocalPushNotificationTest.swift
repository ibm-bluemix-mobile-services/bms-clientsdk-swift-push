//
//  BMSLocalPushNotificationTest.swift
//  BMSPushTests
//
//  Created by Anantha Krishnan K G on 01/03/18.
//  Copyright © 2018 IBM Corp. All rights reserved.
//

import XCTest
@testable import BMSPush

class BMSLocalPushNotificationTest: XCTestCase {

    #if swift(>=3.0)

    func testInit() {

        if #available(iOS 10.0, *) {
            let localPush = BMSLocalPushNotification(body: "test message", title: "test Title", subtitle: "test subTitle", sound: "soundName", badge: 3, categoryIdentifier: "identifier", attachments: "https://attchment.png", userInfo: [:])
            XCTAssertEqual(localPush.attachments!, "https://attchment.png")
            XCTAssertEqual(localPush.body, "test message")
            XCTAssertEqual(localPush.title!, "test Title")
            XCTAssertEqual(localPush.subtitle!, "test subTitle")
            XCTAssertEqual(localPush.sound!, "soundName")
            XCTAssertEqual(localPush.badge!, 3)
            XCTAssertEqual(localPush.categoryIdentifier!, "identifier")
        } else {
            // Fallback on earlier versions
        }
    }

    func testFail() {

        if #available(iOS 10.0, *) {
            let localPush = BMSLocalPushNotification(body: "test message", title: "test Title", subtitle: "test subTitle", sound: "soundName", badge: 3, categoryIdentifier: "identifier", attachments: "https://attchment.png", userInfo: [:])
            XCTAssertNotEqual(localPush.attachments!, "https://attcewhment.png")
            XCTAssertNotEqual(localPush.body, "test message 3")
            XCTAssertNotEqual(localPush.title!, "test Title testFail")
            XCTAssertNotEqual(localPush.subtitle!, "test subTitle testFail")
            XCTAssertNotEqual(localPush.sound!, "soundName testFail")
            XCTAssertNotEqual(localPush.badge!, 4)
            XCTAssertNotEqual(localPush.categoryIdentifier!, "identifier testFail")
        } else {
            // Fallback on earlier versions
        }
    }

#endif

}
