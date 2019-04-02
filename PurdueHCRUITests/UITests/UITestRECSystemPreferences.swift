//
//  UITestRECSystemPreferences.swift
//  PurdueHCRUITests
//
//  Created by Benjamin Hardin on 4/1/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class UITestRECSystemPreferences: UITestBase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEnableDisableHouseSystem() {
		let page = getStartingPage()
			.logInREC()
			.flipHouseCompetitionEnabledSwitch(houseEnabledMessage: "Test Disable")
			.logout()
			.logInResident()
			.getTabBarContainer()
			.tapSubmitPointsTab()
			.waitForLoadingToComplete()
		let message = page.getEmptyMessageFieldText()
		let messageExists = page.logout()
			.logInREC()
			.waitForLoadingToComplete()
			.flipHouseCompetitionEnabledSwitch()
			.logout()
			.logInResident()
			.getTabBarContainer()
			.tapSubmitPointsTab()
			.doesEmptyMessageFieldExist()
		XCTAssert(!messageExists && message == "Test Disable")				
		
    }

}
