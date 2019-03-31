//
//  UITestForgotPasswordPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/27/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation

import XCTest

class ForgotPasswordPage: BasePage, UITestPageProtocol {
    
    let recoveryEmailField:XCUIElement
    let cancelButton:XCUIElement
    let okButton:XCUIElement
    
    override init(app: XCUIApplication, test: XCTestCase) {
        recoveryEmailField = app.textFields["Enter your login ID"]
        cancelButton = app.buttons["Cancel"]
        okButton = app.buttons["OK"]
        super.init(app: app, test: test)
    }
    
    @discardableResult func waitForLoadingToComplete() -> ForgotPasswordPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func typeRecoveryEmailField(email:String) -> ForgotPasswordPage {
        recoveryEmailField.tap()
        recoveryEmailField.typeText(email)
        return self
    }
    
    @discardableResult
    func tapCancelButton() -> SignInPage {
        cancelButton.tap()
        return SignInPage(app: app,test: test)
    }
    
    @discardableResult
    func tapOKButton() -> SignInPage {
        okButton.tap()
        return SignInPage(app: app,test: test)
    }
    
    
}
