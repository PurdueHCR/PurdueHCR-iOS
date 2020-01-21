//
//  UITestQRPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/28/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPQRPage: BasePage, UITestPageProtocol, UITestTabBarProtocol  {
    
    
    
    override init(app: XCUIApplication, test: XCTestCase) {
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func waitForLoadingToComplete() -> RHPQRPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
    }
    
    @discardableResult
    func selectQRCode(pointTypeName:String = "") -> PointSubmissionPage{
        if(pointTypeName == ""){
            app.tables.cells.element(boundBy: 0).tap()
        }
        else{
            app.tables.cells[pointTypeName].tap() // If the test fails here, it is because it could not find the PointType you chose.
        }
        return PointSubmissionPage(app: app, test: test)
    }
    
    @discardableResult
    func tapCreateQRCodeButton() -> RHPQRCodeCreationPage{
        app.buttons["Add"].tap()
        return RHPQRCodeCreationPage(app: app, test: test)
    }
}
