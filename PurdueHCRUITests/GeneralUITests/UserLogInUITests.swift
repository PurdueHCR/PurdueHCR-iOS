//
//  PurdueHCRUITests.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 2/9/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class UserLogInUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        UITestUtils.logout(app: app)

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test that a valid user can sucessful sign in
    func testSuccessfulLogin() {
        let app = XCUIApplication()
        UITestUtils.logIn(app: app, test:self, type: .RESIDENT)
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        XCTAssertTrue(UITestUtils.isSignedIn(app: app,test:self), "Sign in not progressing correctly.")
                
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
