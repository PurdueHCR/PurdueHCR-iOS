//
//  UITestResidentPointSubmission.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/30/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import XCTest

class UITestPointSubmission: UITestBase {
    
    override func setUp() {
        super.setUp()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Test that Honors residents can submit points and get notified
    func testHonorsResidentSubmitPointsNotification() {
        
        let testPointDescription = "This is a test point submission: " + randomString(length: 10)
        getStartingPage().logInResident()
            .getTabBarContainer()
            .tapSubmitPointsTab()
            .submitPointRoutine(testPointDescription: testPointDescription, waitForDismissal: false)
        XCTAssertTrue(app.staticTexts["Submitted for approval!"].exists, "Problem With Point Submission Notification")
    }
    
    /// Test that Honors residents can submit points and get notified
    func testHonorsResidentSubmitPointsWithRHPApproval() {
        
        let testPointDescription = "This is a test point submission: "+randomString(length: 10)
        let page = getStartingPage().logInResident()
        print(app.debugDescription)
        let userScore = page.getTotalUserPointsText()
        let houseScore = page.getTotalHousePointsText()
        page.getTabBarContainer()
            .tapSubmitPointsTab()
            .submitPointRoutine(testPointDescription: testPointDescription, pointTypeName: "Cool Point")
            .logout()
            .logInRHP()
            .getTabBarContainer()
            .tapApproveTab()
            .waitForLoadingToComplete()
            .swipeApproveOnPoint(testPointDescription: testPointDescription)
            .getTabBarContainer().tapProfileTab()
        
        let residentPage = page.logout().logInResident()
        
        
        let residentScoreCorrect = (residentPage.getTotalUserPointsText() - userScore) == 1
        let houseScoreCorrect = (residentPage.getTotalHousePointsText() - houseScore) == 1
        
        XCTAssertTrue(residentScoreCorrect && houseScoreCorrect, "Problem With House Point additions")
    }
    
    
    /// Test that RHP can submit points and get notified
    func testRHPSubmitPointsNotification() {
        
        let testPointDescription = "This is a test point submission: "+randomString(length: 10)
        getStartingPage()
            .logInRHP()
            .getTabBarContainer()
            .tapSubmitPointsTab()
            .submitRHPPointRoutine(testPointDescription: testPointDescription, waitForDismissal: false)
        XCTAssertTrue(app.staticTexts["Congrats, 1 points submitted."].exists, "Problem With Point Submission Notification")
    }
    
    /// Test that a shreve resident can submit a point and get notified
    func testShreveResidentSubmitPointsNotification() {
        
        let testPointDescription = "This is a Shreve test point submission: "+randomString(length: 10)
        getStartingPage()
            .logInShreveResident()
            .getTabBarContainer()
            .tapSubmitPointsTab()
            .submitPointRoutine(testPointDescription: testPointDescription, waitForDismissal: false)
        XCTAssertTrue(app.staticTexts["Submitted for approval!"].exists, "Problem With Point Submission Notification")
        
    }
    
    
}
