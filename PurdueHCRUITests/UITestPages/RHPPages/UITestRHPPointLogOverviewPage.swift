//
//  UITestApprovalPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/28/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPPointLogOverviewPage: BasePage, UITestPageProtocol, UITestTabBarProtocol {
    
    override init(app: XCUIApplication, test: XCTestCase) {
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func tapApprove(waitForDismissal: Bool = true) -> RHPApprovalPage {
        app.buttons["Approve Point"].tap()
        waitForDropDownNotification(message: "Point approved")
        if(waitForDismissal){
            waitForDropDownDismissal(message: "Point approved")
        }
        return RHPApprovalPage(app: app, test: test)
    }
    
    
    
    @discardableResult
    func waitForLoadingToComplete() -> RHPPointLogOverviewPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
    }
    
}
