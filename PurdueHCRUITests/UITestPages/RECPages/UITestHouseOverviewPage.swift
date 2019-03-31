//
//  UITestHouseOverviewPage.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/27/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation

import XCTest

class HouseOverviewPage: BasePage, UITestPageProtocol {

    @discardableResult func waitForLoadingToComplete() -> HouseOverviewPage {
        waitForLoading()
        return self
    }
    
}

