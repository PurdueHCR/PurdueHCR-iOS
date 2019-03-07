//
//  PointApprovalUITests.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 2/11/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class PointApprovalUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        UITestUtils.logout(app: app)
        UITestUtils.logIn(app: app,test: self ,type: .RESIDENT)
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        
        

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSwipePointApproval() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let testPointDescription = "Test Point Submission For Handling: "+UITestUtils.randomString(length: 10)
        
        //Points Remaining Label
        //Total Points Label
        let currentHousePoints = app.staticTexts.element(matching:.any, identifier: "Points Remaining Label").label
        print(app.debugDescription)
        
        //Get Current Users point, total house points, and value of base point type.
        UITestUtils.submitPoints(app: app, test: self, testPointDescription: testPointDescription)
        UITestUtils.waitForDropDownDismissal(app: app, test: self, message: "Submitted for approval!")
        app.tabBars.buttons["Profile"].tap()
        UITestUtils.logout(app: app)
        
        //Log in as RHP and approve
        UITestUtils.logIn(app: app,test:self, type: .RHP)
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        app.tabBars.buttons["Approve"].tap()
        app.tabBars.buttons["Approve"].tap()
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        
        let cells = app.tables.cells
        cells.staticTexts[testPointDescription].swipeLeft()
        cells.buttons["Approve"].tap()
        UITestUtils.waitForDropDownNotification(app: app, test: self, message: "Point approved")
        UITestUtils.waitForDropDownDismissal(app: app, test: self, message: "Point approved")
        UITestUtils.logout(app: app)
        
        //Log back in as Resident and compare points
        UITestUtils.logIn(app: app, test: self, type: .RESIDENT)
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        XCTAssertTrue(app.staticTexts["Points Remaining Label"].exists, "Points exist")
        
        
        
    }

}
