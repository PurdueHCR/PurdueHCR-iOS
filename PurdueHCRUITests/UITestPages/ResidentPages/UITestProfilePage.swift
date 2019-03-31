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
    
    override init(app: XCUIApplication, test: XCTestCase) {
        totalUserPointsText = app.staticTexts.element(matching:.any, identifier: "Resident Points")
        housePointsText = app.staticTexts.element(matching: .any, identifier: "TotalHousePoints")
        
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
        let label = housePointsText.label
        var stringParts = label.split(separator: "\n")
        
        let houseRemaining = String(stringParts[0][...stringParts[0].firstIndex(of: " ")!])
        let rewardTotal = String(stringParts[1][stringParts[1].index(stringParts[1].firstIndex(of: "(")!, offsetBy: 1) ... stringParts[1].firstIndex(of: " ")!])
        let remaining = (rewardTotal as NSString).integerValue - (houseRemaining as NSString).integerValue
        return remaining
    }
    
    
}

class TabBarContainer:BasePage {
    func tapProfileTab() -> ProfilePage {
        app.tabBars.buttons["Profile"].tap()
        return ProfilePage(app: app, test: test)
        
    }
    
    func tapSubmitPointsTab() -> SubmitPointsTablePage {
        app.tabBars.buttons["Submit Points"].tap()
        return SubmitPointsTablePage(app: app, test: test)
        
    }
}
