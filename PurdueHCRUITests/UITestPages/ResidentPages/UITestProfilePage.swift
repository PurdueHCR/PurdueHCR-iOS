//
//  UITestProfilePage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/27/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class ProfilePage: BasePage, UITestPageProtocol, UITestTabBarProtocol {
    
    let totalUserPointsText:XCUIElement
    let housePointsText:XCUIElement
    let rewardPPRTotalText:XCUIElement
    
    override init(app: XCUIApplication, test: XCTestCase) {
        totalUserPointsText = app.staticTexts.element(matching:.any, identifier: "Total User Points Label")
        housePointsText = app.staticTexts.element(matching: .any, identifier: "House Points Per Resident Label")
        rewardPPRTotalText = app.staticTexts.element(matching: .any, identifier: "Reward Points Per Resident Total Label")
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func waitForLoadingToComplete() -> ProfilePage {
        waitForLoading()
        return self
    }
    
    
    @discardableResult
    func getTotalUserPointsText() -> Int {
        let number = totalUserPointsText.label.components(separatedBy: CharacterSet.letters).joined()
        print(number)
        return (number as NSString).integerValue
    }
    
    @discardableResult
    func getTabBarContainer() -> TabBarContainer {
        return TabBarContainer(app: app, test: test)
    }
    
    @discardableResult
    func getTotalHousePointsText() -> Int {
        print(app.debugDescription)
        let housePPRTotal = (housePointsText.label as NSString).integerValue
        let rewardPPRTotal = (rewardPPRTotalText.label as NSString).integerValue
        return rewardPPRTotal - housePPRTotal
    }
    
    
}

class TabBarContainer:BasePage {
    func tapProfileTab() -> ProfilePage {
        app.tabBars.buttons["Profile"].tap()
		waitForLoading()
        return ProfilePage(app: app, test: test)
        
    }
    
    func tapSubmitPointsTab() -> SubmitPointsTablePage {
        app.tabBars.buttons["Submit Points"].tap()
        app.tabBars.buttons["Submit Points"].tap()
		waitForLoading()
        return SubmitPointsTablePage(app: app, test: test)
        
    }
}
