//
//  UpdatePointTypeUITests.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/25/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class UpdatePointTypeUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()
        UITestUtils.waitForLoadingToComplete(app: app, test: self)
        UITestUtils.logout(app: app)
        UITestUtils.logIn(app: app,test: self ,type: .REC)
        UITestUtils.waitForLoadingToComplete(app: app, test: self)

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChangeEnabledStatusSuccessDropDownMessage() {
        let app = XCUIApplication()
        
        app.tabBars.buttons["RECPointOptions"].tap()
        
        app.tables.cells.element(boundBy: 0).tap()
        
        let enabledSwitch = app.switches["enabledButton"]
        enabledSwitch.tap()
        
        app.navigationBars["PurdueHCR.RECPointCreationTableView"].buttons["Update"].tap()
        UITestUtils.waitForDropDownNotification(app: app, test: self, message: "Point Type Updated")
        XCTAssertTrue(app.staticTexts["Point Type Updated"].exists, "Failure message was not found.")
        
    }
    
    func testPointTypeQRCodePermissionChange() {
        

        
    }

}
