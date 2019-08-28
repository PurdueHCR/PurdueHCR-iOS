//
//  UITestPointSubmissionPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/30/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class PointSubmissionPage: BasePage, UITestTabBarProtocol, UITestPageProtocol {
    
    let submitButton:XCUIElement
    let submissionField:XCUIElement
    
    override init(app: XCUIApplication, test: XCTestCase) {
        submitButton = app.buttons["Submit"]
        submissionField = app.textViews["descriptionField"]
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func waitForLoadingToComplete() -> PointSubmissionPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func getTabBarContainer() -> TabBarContainer {
        return TabBarContainer(app: app, test: test)
    }
    
    /// Submit a point for a user
    /// Assumptions: User is logged in.
    /// Start: Call this from Viewcontroller that displays the bottom bar
    /// END: Method resturns as soon as a drop down notificaiton appears.
    ///
    /// - Parameters:
    ///   - testPointDescription: String that is the message you want to point in the point log
    ///   - pointTypeName: Optional String that is the name of the Point Type that you want to submit a point for
    @discardableResult
    func enterPointDescription(testPointDescription:String) -> PointSubmissionPage{
        submissionField.tap()
        submissionField.typeText(testPointDescription)
        return self
    }
    
    @discardableResult
    func tapSubmitButton(waitForDismissal:Bool = true) -> SubmitPointsTablePage{
        submitButton.tap()
        waitForDropDownNotification(message: "Submitted for approval!")
        if(waitForDismissal){
            waitForDropDownDismissal(message: "Submitted for approval!")
        }
        return SubmitPointsTablePage(app: app, test: test)
    }
    
}
