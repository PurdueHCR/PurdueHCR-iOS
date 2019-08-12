//
//  UITestPageBase.swift
//  PurdueHCRUITests
//
//  Created by Brian Johncox on 3/27/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import Foundation
import XCTest

protocol UITestPageProtocol {
    associatedtype Page: BasePage
    @discardableResult func waitForLoadingToComplete() -> Page
}

protocol UITestTabBarProtocol {
    associatedtype TabBar: TabBarContainer
    @discardableResult func getTabBarContainer() -> TabBar
}


class BasePage{
    
    let app: XCUIApplication
    let test: XCTestCase
    
    init(app:XCUIApplication, test:XCTestCase) {
        self.app = app
        self.test = test
        waitForLoading() //Incase anything is loading
    }
    
    static func startApp(app:XCUIApplication, test:XCTestCase) -> SignInPage{
        return SignInPage(app: app,test: test)
    }
    
    /// Pause the XCTest until the Loading icon is dismissed.,
    /// Right now the loading icon is the activityIndicator
    ///
    /// - Parameters:
    ///   - app: Current XCUIApplication
    ///   - test: Current XCTEstCase (pass in 'self')
    func waitForLoading(){
        while(app.activityIndicators["In progress"].exists){
        //If this exists, wait for it not to exist
        let element = app.activityIndicators["In progress"]
        let expectation = test.expectation(for: NSPredicate(format: "exists == 0"), evaluatedWith: element, handler: nil)
        test.wait(for: [expectation], timeout: 10)
        }
    }
    
    /// Pause the XCTestCase until the dropdown notification has appeared.
    ///
    /// - Parameters:
    ///   - app: Current XCUIApplicaiton
    ///   - test: Current XCTestCase (pass in 'self')
    ///   - message: Message that will be displayed on the drop down. Better results will be had if you pass in the message of the notification and not the title.
    func waitForDropDownNotification(message:String){
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
    func waitForDropDownDismissal(message:String){
        let element = app.staticTexts[message]
        let expectation = test.expectation(for: NSPredicate(format: "exists == 0"), evaluatedWith: element, handler: nil)
        test.wait(for: [expectation], timeout: 10);
    }
    
    /// Log the user out if they are already logged in and are on a ViewController that displays the bottom bar
    ///
    /// - Parameter app: The current XCUIApplication
	@discardableResult
    func logout() -> SignInPage{
        if(app.tabBars.buttons["Profile"].exists){
            app.tabBars.buttons["Profile"].tap()
            app.navigationBars["Profile"].buttons["Sign Out"].tap()
        }
		else if(app.tabBars.buttons["Houses"].exists){
			app.tabBars.buttons["Houses"].tap()
			app.navigationBars["House Overview"].buttons["Item"].tap()
		}
		app.buttons["Logout"].tap()
		app.alerts["Log out?"].buttons["Yes"].tap()
        return SignInPage(app: app, test: test)
    }
    
    @discardableResult
    func scanQRCodeForResident(qrCodeLink: String = "") -> ProfilePage{
        scanQRCodeWithSafari(qrCodeLink: qrCodeLink)
        return ProfilePage(app: app, test: test)
    }
    
    @discardableResult
    func scanQRCodeForRHP(qrCodeLink: String = "") -> RHPProfilePage{
        scanQRCodeWithSafari(qrCodeLink: qrCodeLink)
        return RHPProfilePage(app: app, test: test)
    }
    
    @discardableResult
    func scanQRCodeForREC(qrCodeLink: String = "") -> HouseOverviewPage{
        scanQRCodeWithSafari(qrCodeLink: qrCodeLink)
        return HouseOverviewPage(app: app, test: test)
    }
    
    /// This method will go to safari and post a link into the URL bar and go to that link.
    /// Use this method to test deeplinking. If you don't pass in any parameters, it will paste
    /// whatever is in the clipboard into the URL bar
    ///
    /// - Parameter link: (String, not String?) Optional String parameter that represents a DeepLink. If String is given it will paste that string into the URL bar.
    private func scanQRCodeWithSafari(qrCodeLink: String = ""){
        // Open iMessage app
        if (qrCodeLink == ""){
            //If this line crashes, then there is no String saved into the clipboard
			
			if let url = URL(string: UIPasteboard.general.string!) {
				UIApplication.shared.open(url)
			}
        }
        else{
			if let url = URL(string: qrCodeLink) {
				UIApplication.shared.open(url)
			}
        }
    }
	
	func clearTextField(textField: XCUIElement) {
		for _ in 1...(textField.value as! String).count {
			app.keys["delete"].tap()
		}
	}
    
}


