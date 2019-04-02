//
//  UITestSubmitPointsTablePage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/28/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

class SubmitPointsTablePage: BasePage, UITestTabBarProtocol {
    
    override init(app: XCUIApplication, test: XCTestCase) {
        
        super.init(app: app, test: test)
    }
    
    @discardableResult
    func waitForLoadingToComplete() -> SubmitPointsTablePage {
        waitForLoading()
        return self
    }
    
    @discardableResult
    func getTabBarContainer() -> TabBarContainer {
        return TabBarContainer(app: app, test: test)
    }
    

    @discardableResult
    func selectPointType(pointTypeName:String = "") -> PointSubmissionPage{
        if(pointTypeName == ""){
            app.tables.cells.element(boundBy: 0).tap()
        }
        else{
            app.tables.cells[pointTypeName].tap() // If the test fails here, it is because it could not find the PointType you chose.
        }
        return PointSubmissionPage(app: app, test: test)
    }
    

    @discardableResult
    func submitPointRoutine(testPointDescription:String,pointTypeName:String = "", waitForDismissal:Bool = true) -> SubmitPointsTablePage{
        
        selectPointType(pointTypeName: pointTypeName)
            .enterPointDescription(testPointDescription: testPointDescription)
            .tapSubmitButton(waitForDismissal: waitForDismissal)
        return self
    }
	
	func getEmptyMessageFieldText() -> String {
		return app.staticTexts["Empty Message"].label
	}
	func doesEmptyMessageFieldExist() -> Bool {
		return app.staticTexts["Empty Message"].exists
	}
}
