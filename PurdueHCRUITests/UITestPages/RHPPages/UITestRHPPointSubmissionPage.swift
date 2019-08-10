//
//  UITestRHPPointSubmissionPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/30/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPPointSubmissionPage: PointSubmissionPage {
    

    override init(app: XCUIApplication, test: XCTestCase) {
        super.init(app: app, test: test)
    }
    
    @discardableResult
    override func waitForLoadingToComplete() -> RHPPointSubmissionPage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    override func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
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
    override func enterPointDescription(testPointDescription:String) -> RHPPointSubmissionPage{
        super.enterPointDescription(testPointDescription: testPointDescription)
        return self
    }
    
    @discardableResult
    override func tapSubmitButton(waitForDismissal:Bool = false) -> RHPSubmitPointsTablePage{
        submitButton.tap()
        waitForDropDownNotification(message: "Congrats, 1 points submitted.")
        if(waitForDismissal){
            waitForDropDownDismissal(message: "Congrats, 1 points submitted.")
        }
        return RHPSubmitPointsTablePage(app: app, test: test)
    }
    
}
