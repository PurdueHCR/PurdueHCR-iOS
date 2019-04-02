//
//  UITestRHPProfilePage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/27/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPProfilePage: ProfilePage{
    
    override init(app: XCUIApplication, test: XCTestCase) {

        super.init(app: app, test: test)
    }
    
    @discardableResult
    override func waitForLoadingToComplete() -> RHPProfilePage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    override func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
    }
    
    
}

class RHPTabBarContainer: TabBarContainer{
    @discardableResult
    override func tapProfileTab() -> RHPProfilePage {
        app.tabBars.buttons["Profile"].tap()
        app.tabBars.buttons["Profile"].tap()
		waitForLoading()
        return RHPProfilePage(app: app, test: test)
    }
    
    @discardableResult
    func tapApproveTab() -> RHPApprovalPage {
        app.tabBars.buttons["Approve"].tap()
        app.tabBars.buttons["Approve"].tap()
		waitForLoading()
        return RHPApprovalPage(app: app, test: test)
    }
    @discardableResult
    func tapQRTab() -> RHPQRPage {
        app.tabBars.buttons["QR"].tap()
        app.tabBars.buttons["QR"].tap()
		waitForLoading()
        return RHPQRPage(app: app, test: test)
    }
    @discardableResult
    override func tapSubmitPointsTab() -> RHPSubmitPointsTablePage {
        app.tabBars.buttons["Submit Points"].tap()
        app.tabBars.buttons["Submit Points"].tap()
		waitForLoading()
        return RHPSubmitPointsTablePage(app: app, test: test)
        
    }
    
}
