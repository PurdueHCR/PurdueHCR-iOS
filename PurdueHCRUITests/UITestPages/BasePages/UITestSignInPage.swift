//
//  UITestSignInPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/27/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class SignInPage: BasePage, UITestPageProtocol {
    
    let RESIDENT_EMAIL = "UITestHonorsResident@purdue.edu"
    let RHP_EMAIL = "UITestRHP@purdue.edu"
    let REC_EMAIL = "UITestREC@purdue.edu"
    let SHREVE_RESIDENT_EMAIL = "UITestShreveResident@purdue.edu"
    let ACCOUNT_PASSWORD = "Honors1"
    
    let emailField:XCUIElement
    let passwordField:XCUIElement
    let loginButton:XCUIElement
    let createAccountButton:XCUIElement
    let forgotPasswordButton:XCUIElement
    
    override init(app: XCUIApplication, test: XCTestCase) {
        emailField = app.textFields["Email"]
        passwordField = app.secureTextFields["Password"]
        loginButton = app.buttons["Login"]
        createAccountButton = app.buttons["Want to create an account?"]
        forgotPasswordButton = app.buttons["Forgot Password?"]
        super.init(app: app, test: test)

    }
    
    @discardableResult
    func typeEmail(email:String) -> SignInPage {
        emailField.tap()
        emailField.typeText(email)
        return self
    }
    
    @discardableResult
    func typePassword(password:String) -> SignInPage {
        passwordField.tap()
        passwordField.typeText(password)
        return self
    }
    
    @discardableResult
    func tapLoginButtonForResident() -> ProfilePage {
        loginButton.tap()
        return ProfilePage(app: app,test: test)
    }
    
    @discardableResult
    func tapLoginButtonForRHP() -> ProfilePage {
        loginButton.tap()
        return ProfilePage(app: app,test: test)
    }
    
    @discardableResult
    func tapLoginButtonForREC() -> HouseOverviewPage {
        loginButton.tap()
        return HouseOverviewPage(app: app,test: test)
    }
    
    @discardableResult
    func tapCreateAccountButton() -> SignUpPage {
        createAccountButton.tap()
        return SignUpPage(app:app, test:test)
    }
    
    @discardableResult
    func tapForgotPasswordButton() -> ForgotPasswordPage {
        forgotPasswordButton.tap()
        return ForgotPasswordPage(app:app, test:test)
    }
    
    @discardableResult
    func logInResident() -> ProfilePage{
        typeEmail(email: RESIDENT_EMAIL).typePassword(password: ACCOUNT_PASSWORD).tapLoginButtonForResident().waitForLoadingToComplete()
        return ProfilePage(app:app, test:test)
    }
    
    @discardableResult
    func logInShreveResident() -> ProfilePage{
        typeEmail(email: SHREVE_RESIDENT_EMAIL)
            .typePassword(password: ACCOUNT_PASSWORD)
            .tapLoginButtonForResident().waitForLoadingToComplete()
        return ProfilePage(app:app, test:test)
    }
    
    @discardableResult
    func logInRHP() -> RHPProfilePage{
        typeEmail(email: RHP_EMAIL).typePassword(password: ACCOUNT_PASSWORD).tapLoginButtonForRHP().waitForLoadingToComplete()
        return RHPProfilePage(app:app, test:test)
    }
    
    @discardableResult
    func logInREC() -> HouseOverviewPage{
        typeEmail(email: REC_EMAIL).typePassword(password: ACCOUNT_PASSWORD).tapLoginButtonForREC().waitForLoadingToComplete()
        return HouseOverviewPage(app:app, test:test)
    }
    
    @discardableResult
    func waitForLoadingToComplete() -> SignInPage {
        waitForLoading()
        sleep(3)
        return self
    }
    
}
