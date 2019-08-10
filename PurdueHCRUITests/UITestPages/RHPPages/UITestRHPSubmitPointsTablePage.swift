//
//  UITestRHPSubmitPointsTablePage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/28/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class RHPSubmitPointsTablePage: SubmitPointsTablePage {
    
    override init(app: XCUIApplication, test: XCTestCase) {
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    override func waitForLoadingToComplete() -> RHPSubmitPointsTablePage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    override func getTabBarContainer() -> RHPTabBarContainer {
        return RHPTabBarContainer(app: app, test: test)
    }
    
    @discardableResult
    override func selectPointType(pointTypeName:String = "") -> RHPPointSubmissionPage{
        super.selectPointType(pointTypeName: pointTypeName)
        return RHPPointSubmissionPage(app: app, test: test)
    }
    
    @discardableResult
    func submitRHPPointRoutine(testPointDescription:String,pointTypeName:String = "", waitForDismissal:Bool = true ) -> RHPSubmitPointsTablePage{
        
        selectPointType(pointTypeName: pointTypeName)
            .enterPointDescription(testPointDescription: testPointDescription)
            .tapSubmitButton(waitForDismissal: waitForDismissal)
        waitForDropDownNotification(message: "Congrats, 1 points submitted.")
        return self
    }
}
