//
//  UITestApprovalPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/28/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPApprovalPage: BasePage, UITestPageProtocol, UITestTabBarProtocol {
    
    override init(app: XCUIApplication, test: XCTestCase) {
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func tapHistoryButton() -> RHPHistoryPage {
        app.navigationBars["Approvals"].buttons["History"].tap()
        waitForLoading()
        return RHPHistoryPage(app: app, test: test)
    }
    
    @discardableResult
    func swipeApproveOnPoint(testPointDescription: String, waitForDismissal: Bool = true) -> RHPApprovalPage {
        let cells = app.tables.cells
        cells.staticTexts[testPointDescription].swipeLeft()
        cells.buttons["Approve"].tap()
        waitForDropDownNotification(message: "Point approved")
        if(waitForDismissal){
            waitForDropDownDismissal(message: "Point approved")
        }
        return self
    }
    
    
    @discardableResult
    func waitForLoadingToComplete() -> RHPApprovalPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
    }
    
}
