//
//  UiTestUtils.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 2/9/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

enum UserType{
    case RESIDENT
    case RHP
    case REC
    case SHREVE
}


class UITestUtils{
    
    static let RESIDENT_EMAIL = "UITestHonorsResident@purdue.edu"
    static let RHP_EMAIL = "UITestRHP@purdue.edu"
    static let REC_EMAIL = "UITestREC@purdue.edu"
    static let SHREVE_RESIDENT_EMAIL = "UITestShreveResident@purdue.edu"
    static let ACCOUNT_PASSWORD = "Honors1"
    
    /// Log the user out if they are already logged in and are on a ViewController that displays the bottom bar
    ///
    /// - Parameter app: The current XCUIApplication
    static func logout(app:XCUIApplication){
        
        if(app.tabBars.element(boundBy: 0).exists){
            if(app.tabBars.buttons["Profile"].exists){
                app.tabBars.buttons["Profile"].tap()
                app.navigationBars["Profile"].buttons["Sign Out"].tap()
            }
            else{
                app.navigationBars["House Overview"].buttons["Item"].tap()
            }
            app.buttons["Logout"].tap()
            app.alerts["Log out?"].buttons["Yes"].tap()
        }
    }
    
    /// Given that the devices is currently displaying the SignIn ViewController, it will signin a user with the given UserType
    ///
    /// - Parameters:
    ///   - app: Current XCUIApplication
    ///   - test: Current XCTestCase (pass in 'self')
    ///   - type: UserType that needs to be signed in for this test
    static func logIn(app:XCUIApplication, test:XCTestCase, type:UserType){
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        if(type == UserType.RESIDENT){
            emailTextField.typeText(RESIDENT_EMAIL)
        }
        else if(type == UserType.RHP){
            emailTextField.typeText(RHP_EMAIL)
        }
        else if(type == UserType.REC){
            emailTextField.typeText(REC_EMAIL)
        }
        else if(type == UserType.SHREVE){
            emailTextField.typeText(SHREVE_RESIDENT_EMAIL)
        }
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText(ACCOUNT_PASSWORD)
        app.buttons["Login"].tap()
        sleep(2)
        UITestUtils.waitForLoadingToComplete(app: app, test: test)
    }
    
    
    /// Pause the XCTest until the Loading icon is dismissed.,
    /// Right now the loading icon is the activityIndicator
    ///
    /// - Parameters:
    ///   - app: Current XCUIApplication
    ///   - test: Current XCTEstCase (pass in 'self')
    static func waitForLoadingToComplete(app:XCUIApplication,test:XCTestCase){
        while(app.activityIndicators["In progress"].exists){
            //If this exists, wait for it not to exist
            let element = app.activityIndicators["In progress"]
            let expectation = test.expectation(for: NSPredicate(format: "exists == 0"), evaluatedWith: element, handler: nil)
            test.wait(for: [expectation], timeout: 10)
        }
    }
    
    /// Waits for loading to complete then checks to see if the HouseProfileView is visible. (Meaning they are logged in)
    ///
    /// - Parameters:
    ///   - app: Current XCUIApplication
    ///   - test: Current XCTestCase (pass in 'self')
    /// - Returns: Returns true if signed in
    static func isSignedIn(app:XCUIApplication,test:XCTestCase) -> Bool {
        waitForLoadingToComplete(app: app, test: test)
        let expectation = test.expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: app.navigationBars["Profile"], handler: nil)
        let result = XCTWaiter.wait(for: [expectation], timeout: 10)
        switch(result) {
        case .completed:
            return true
        default:
            return false
            //waiter was interrupted before completed or timedOut
        }
    }
    
    
    /// Pause the XCTestCase until the dropdown notification has appeared.
    ///
    /// - Parameters:
    ///   - app: Current XCUIApplicaiton
    ///   - test: Current XCTestCase (pass in 'self')
    ///   - message: Message that will be displayed on the drop down. Better results will be had if you pass in the message of the notification and not the title.
    static func waitForDropDownNotification(app:XCUIApplication,test:XCTestCase, message:String){
        let element = app.staticTexts[message]
        let expectation = test.expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: element, handler: nil)
        test.wait(for: [expectation], timeout: 10);
    }
    
    /// Pause the XCTestCase until the dropdown notification has dismissed.
    ///
    /// - Parameters:
    ///   - app: Current XCUIApplicaiton
    ///   - test: Current XCTestCase (pass in 'self')
    ///   - message: Message that will be displayed on the drop down. Better results will be had if you pass in the message of the notification and not the title.
    static func waitForDropDownDismissal(app:XCUIApplication,test:XCTestCase, message:String){
        let element = app.staticTexts[message]
        let expectation = test.expectation(for: NSPredicate(format: "exists == 0"), evaluatedWith: element, handler: nil)
        test.wait(for: [expectation], timeout: 10);
    }
    
    /// Generate a random String
    ///
    /// - Parameter length: Number of charaters
    /// - Returns: Generated String
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    /// This method will go to safari and post a link into the URL bar and go to that link.
    /// Use this method to test deeplinking. If you don't pass in any parameters, it will paste
    /// whatever is in the clipboard into the URL bar
    ///
    /// - Parameter link: (String, not String?) Optional String parameter that represents a DeepLink. If String is given it will paste that string into the URL bar.
    static func scanQRCodeWithSafari(qrCodeLink: String = "") {
        // Open iMessage app
        let safari = Safari.launch()
        if(qrCodeLink == ""){
            //If this line crashes, then there is no String saved into the clipboard
            Safari.open(URLString: UIPasteboard.general.string!, safariApp: safari)
        }
        else{
            Safari.open(URLString: qrCodeLink, safariApp: safari)
        }
        
        
    }
    
    
    /// Submit a point for a user
    /// Assumptions: User is logged in.
    /// Start: Call this from Viewcontroller that displays the bottom bar
    /// END: Method resturns as soon as a drop down notificaiton appears.
    ///
    /// - Parameters:
    ///   - app: XCUIApplication that is running
    ///   - test: The current testcase you are running. (Pass in 'self')
    ///   - testPointDescription: String that is the message you want to point in the point log
    ///   - pointTypeName: Optional String that is the name of the Point Type that you want to submit a point for
    static func submitPoints(app:XCUIApplication, test:XCTestCase, testPointDescription:String,pointTypeName:String = ""){
        
        UITestUtils.waitForLoadingToComplete(app: app, test: test) //Incase something is loading
        app.tabBars.buttons["Submit Points"].tap()
        app.tabBars.buttons["Submit Points"].tap()
        UITestUtils.waitForLoadingToComplete(app: app, test: test) //Incase the point types are loading
        if(pointTypeName == ""){
            app.tables.cells.element(boundBy: 0).tap()
        }
        else{
            app.tables.cells[pointTypeName].tap() // If the test fails here, it is because it could not find the PointType you chose.
        }
        let descriptionField = app.textViews["descriptionField"]
        descriptionField.tap()
        descriptionField.typeText(testPointDescription)
        app.navigationBars["Create Submission"].buttons["Submit"].tap()
        UITestUtils.waitForDropDownNotification(app: app, test: test, message: "Submitted for approval!")
    }
    
    
}


/// Enum that simplifies the processes for testing DeepLinks
enum Safari {
    
    /// Launch the app Safari on the test device
    ///
    /// - Returns: Returns XCUIApplication of Safari
    static func launch() -> XCUIApplication {
        
        // Open Safari app
        let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        
        // Launch iMessage app
        safariApp.launch()
        
        // Wait some seconds for launch
        sleep(2)
        
        // Return application handle
        return safariApp
    }
    
    /// Types the string into the URL bar
    ///
    /// - Parameters:
    ///   - urlString: String to be input into the URL  bar
    ///   - app: Current XCUIApplocation
    static func open(URLString urlString: String, safariApp app: XCUIApplication) {
        // Find Simulator Message
        let urlTextField = app.buttons["URL"]
        urlTextField.tap()
        print(app.debugDescription)
        app.textFields["URL"].typeText(urlString)
        app.buttons["Go"].tap()
        app/*@START_MENU_TOKEN@*/.otherElements["WebView"]/*[[".otherElements[\"BrowserWindow\"]",".scrollViews.otherElements[\"WebView\"]",".otherElements[\"WebView\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.buttons["Open"].tap()
    }
}
