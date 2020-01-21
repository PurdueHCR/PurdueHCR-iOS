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
    
    func testSingleUseCodeScans(){
        let message = "Testing " + randomString(length: 8)
        getStartingPage()
            .logInRHP()
            .getTabBarContainer()
            .tapQRTab()
            .tapCreateQRCodeButton()
            .createQRCode(type: "Worked on Purdue HCR", multiScan: false, description: message)
            .waitForLoadingToComplete()
            .tapEnableButton()
            .saveCodeLinkToClipboard(copyIOSCode: true)
            .scanQRCodeForRHP()
            .waitForDropDownDismissal(message: message)
        getCurrentTabBarContainer()
            .tapProfileTab()
            .logout()
            .logInResident()
            .scanQRCodeForResident()
            .waitForLoadingToComplete()
        XCTAssertTrue(!app.staticTexts[INVALID_CODE_MESSAGE].exists, "Code was unable to submit")
    }

}
