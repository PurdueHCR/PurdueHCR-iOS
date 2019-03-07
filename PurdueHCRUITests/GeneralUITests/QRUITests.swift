//
//  UITestQRUtils.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 2/10/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class QRUITests: XCTestCase {
    
    private let INVALID_CODE_MESSAGE = "Could not submit points."

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test handling of invalid deeplink/qrcode
    func testInvalidDeepLink() {
        UITestUtils.scanQRCodeWithSafari(qrCodeLink: "hcrpoint://addpoints/abcdefgh")
        let app = XCUIApplication()
        UITestUtils.waitForDropDownNotification(app: app, test: self, message: INVALID_CODE_MESSAGE)
        XCTAssertTrue(app.staticTexts[INVALID_CODE_MESSAGE].exists, "Failure message was not found.")
    }

}
