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
        while(!element.waitForExistence(timeout: 10)){
            print()
            continue
        }
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
            openSafariForLink(link: UIPasteboard.general.string!)
        }
        else{
			openSafariForLink(link: qrCodeLink)
        }
    }
    
    
    /// Open Safari with a link
    ///
    /// - Parameter link: link to open
    private func openSafariForLink(link: String){
        // Get the safari app using its bundle identifier
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        // Launch safari
        safari.launch()
        // Ensure that safari is running in foreground before we continue
        _ = safari.wait(for: .runningForeground, timeout: 30)
        
        // Access the address bar component and tap it
        safari.buttons["URL"].tap()
        // You will now have a cursor in the address field. So lets type in the text for our URL
        safari.typeText(link)
        // Make a new line character to simulate that the user taps the return key
        safari.typeText("\n")
        // An pop-up will open and ask you to launch the application. Tap it's "Open" button to confirm
        safari.buttons["Open"].tap()
        
        // Wait for your application to be the one in foreground
        _ = app.wait(for: .runningForeground, timeout: 5)
        
    }
	
	func clearTextField(textField: XCUIElement) {
		for _ in 1...(textField.value as! String).count {
			app.keys["delete"].tap()
		}
	}
    
}


