//
//  UITestHouseOverviewPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/27/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation

import XCTest

class HouseOverviewPage: BasePage, UITestPageProtocol {

	let competitionSwitch : XCUIElement
	
	override init(app: XCUIApplication, test: XCTestCase) {
		competitionSwitch = app.switches["House Competition Switch"]
		super.init(app: app, test: test)
	}
   
  @discardableResult func waitForLoadingToComplete() -> HouseOverviewPage {
      waitForLoading()
      return self
  }
	
	@discardableResult func flipHouseCompetitionEnabledSwitch(houseEnabledMessage: String = "") -> HouseOverviewPage {
		sleep(2)
		competitionSwitch.tap()
		if (app.alerts["Disable House Competition"].exists) {
			let messageTextField = app.alerts.element.textFields["Enter a message"]
			messageTextField.tap()
			messageTextField.typeText(houseEnabledMessage)
			app.alerts["Disable House Competition"].buttons["Confirm"].tap()
		}
		else if (app.alerts["Enable House Competition"].exists) {
			app.alerts["Enable House Competition"].buttons["Confirm"].tap()
		}
		return self
  }
}

