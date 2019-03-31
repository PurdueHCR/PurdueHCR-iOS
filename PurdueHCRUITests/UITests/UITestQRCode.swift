//
//  UITestQRCode.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/31/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class UITestQRCode: UITestBase {

    private let INVALID_CODE_MESSAGE = "Could not submit points."
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
    }

    func testInvalidQRCode() {
        getStartingPage()
            .logInResident()
            .scanQRCodeForResident(qrCodeLink: "hcrpoint://addpoints/abcdefgh")
            .waitForDropDownNotification(message: INVALID_CODE_MESSAGE)
        XCTAssertTrue(app.staticTexts[INVALID_CODE_MESSAGE].exists, "Failure message was not found.")
    }

}
