//
//  UITestRHPQROverviewPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 8/29/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPQROverviewPage: BasePage, UITestPageProtocol, UITestTabBarProtocol  {
    
    
    
    override init(app: XCUIApplication, test: XCTestCase) {
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func waitForLoadingToComplete() -> RHPQROverviewPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
    }
    
    @discardableResult
    func tapEnableButton() -> RHPQROverviewPage {
        app.switches["Enable Code Switch"].tap();
        return self
    }
    
    @discardableResult
    func saveCodeLinkToClipboard(copyIOSCode:Bool)-> RHPQROverviewPage {
        app.buttons["Copy Link Button"].tap();
        app.buttons["Copy iOS Link"].tap()
        return self
    }
}
