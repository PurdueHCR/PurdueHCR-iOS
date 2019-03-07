//
//  PointSubmissionUITests.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 2/9/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class ResidentPointSubmissionUITests: XCTestCase {

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

    /// Test that Honors residents can submit points
    func testHonorsResidentSubmitPoints() {
        
        let app = XCUIApplication()
        UITestUtils.logIn(app: app,test: self ,type: .RESIDENT)
        let testPointDescription = "This is a test point submission: "+UITestUtils.randomString(length: 10)
        
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        UITestUtils.submitPoints(app: app, test: self, testPointDescription: testPointDescription)
        UITestUtils.waitForDropDownDismissal(app: app, test: self, message: "Submitted for approval!")
        app.tabBars.buttons["Profile"].tap()
        UITestUtils.logout(app: app)
        
        
        UITestUtils.logIn(app: app,test:self, type: .RHP)
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        app.tabBars.buttons["Approve"].tap()
        app.tabBars.buttons["Approve"].tap()
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        XCTAssertTrue(app.tables.cells.staticTexts[testPointDescription].exists, "Point could not be found in the RHP's approval page.")
        
    }
    
    /// Test that a shreve resident can submit a point and it will show up on the RHP approval page with the shreve name style
    func testShreveResidentSubmitPoints() {
        
        let testPointDescription = "This is a test point submission: "+UITestUtils.randomString(length: 10)
        let shreveResidentName = "(Shreve) UITestShreve Resident"
        
        let app = XCUIApplication()
        
        UITestUtils.logIn(app: app,test: self ,type: .SHREVE)
        
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        UITestUtils.submitPoints(app: app, test: self, testPointDescription: testPointDescription)
        UITestUtils.waitForDropDownDismissal(app: app, test: self, message: "Submitted for approval!")
        app.tabBars.buttons["Profile"].tap()
        UITestUtils.logout(app: app)
        
        
        UITestUtils.logIn(app: app,test:self, type: .RHP)
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        app.tabBars.buttons["Approve"].tap()
        app.tabBars.buttons["Approve"].tap()
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        let finalAssertion = app.tables.cells.staticTexts[testPointDescription].exists && app.tables.cells.staticTexts[shreveResidentName].exists
        XCTAssertTrue( finalAssertion , "Point could not be found in the RHP's approval page.")
        
    }

}
