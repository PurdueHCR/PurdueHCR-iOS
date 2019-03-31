//
//  UITestRHPHistoryPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/30/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPHistoryPage: BasePage, UITestPageProtocol, UITestTabBarProtocol  {
    
    override init(app: XCUIApplication, test: XCTestCase) {
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func waitForLoadingToComplete() -> RHPHistoryPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
    }
    
}
