//
//  UITestRHPQRCodeCreationPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 8/29/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPQRCodeCreationPage: BasePage, UITestPageProtocol, UITestTabBarProtocol  {
    
    
    
    override init(app: XCUIApplication, test: XCTestCase) {
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func waitForLoadingToComplete() -> RHPQRCodeCreationPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
    }
    
    @discardableResult
    func createQRCode(type:String, multiScan:Bool, description:String) -> RHPQROverviewPage{
        app.pickerWheels.element.adjust(toPickerWheelValue: type)
        if(multiScan){
            app.switches.element.tap()
            app.buttons["OK"].tap()
        }
        app.textViews.element.tap()
        app.textViews.element.typeText(description)
        app.buttons["Generate"].tap()
        return RHPQROverviewPage(app: app, test: test)
    }
}
