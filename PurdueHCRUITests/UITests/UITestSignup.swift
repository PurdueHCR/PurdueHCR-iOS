//
//  UITestSignup.swift
//  PurdueHCRUITests
//
//  Created by Benjamin Hardin on 4/9/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class UITestSignup: UITestBase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSignupInvalidEmail() {
		getStartingPage()
			.tapCreateAccountButton()
			.fillSignupPage(email: "InvalidEmail", name: "Example Name", password: "validpassword", code: "4N123")
			.waitForDropDownNotification(message: "Failed to Sign Up")
		XCTAssertTrue(app.staticTexts["Please enter a valid Purdue email address."].exists, "Could not find error message with that description")
    }

	func testSignupInvalidName() {
		getStartingPage()
			.tapCreateAccountButton()
			.fillSignupPage(email: "validemail@purdue.edu", name: "InvalidName", password: "validpassword", code: "4N123")
			.waitForDropDownNotification(message: "Failed to Sign Up")
		XCTAssertTrue(app.staticTexts["Please enter your preferred first and last name."].exists, "Could not find error message with that description")
	}
	
	func testSignupInvalidPassword() {
		getStartingPage()
			.tapCreateAccountButton()
			.fillSignupPage(email: "validemail@purdue.edu", name: "Valid Name", password: "invalid password", code: "4N123")
			.waitForDropDownNotification(message: "Failed to Sign Up")
		XCTAssertTrue(app.staticTexts["Password contains invalid characters."].exists, "Could not find error message with that description")
	}
	
	func testVerifyPassword() {
		getStartingPage()
			.tapCreateAccountButton()
			.fillSignupPage(email: "validemail@purdue.edu", name: "Valid Name", password: "firstpassword", verifyPassword: "secondpassword", code: "4N123")
			.waitForDropDownNotification(message: "Failed to Sign Up")
		XCTAssertTrue(app.staticTexts["Please verify your passwords are the same."].exists, "Could not find error message with that description")
	}
	
	func testSignupInvalidCode() {
		getStartingPage()
			.tapCreateAccountButton()
			.fillSignupPage(email: "validemail@purdue.edu", name: "Valid Name", password: "validpassword", code: "invalidcode")
			.waitForDropDownNotification(message: "Failed to Sign Up")
		XCTAssertTrue(app.staticTexts["Code is invalid."].exists, "Could not find error message with that description")
	}
	
	func testAlreadySignedUp() {
		getStartingPage()
			.tapCreateAccountButton()
			.fillSignupPage(email: "tester@purdue.edu", name: "Valid Name", password: "validpassword", code: "4N123")
			.waitForDropDownNotification(message: "Failed to Sign Up")
		XCTAssertTrue(app.staticTexts["The email address is already in use by another account."].exists, "Could not find error message with that description")
	}
	
}
