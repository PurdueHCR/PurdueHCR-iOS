//
//  AppDelegate.swift
//  Purdue HCR
//
//  Created by Brian Johncox on 6/23/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import Cely
import Firebase
import NotificationBannerSwift
import FirebaseDynamicLinks

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Cely handles the creation of the log in/ sign up page. If the user is not logged in, it will create a new page and handle the login
        
        //set up the project to connect with firebase and fetch the information on the houses so the login page has the information availible.
        FirebaseApp.configure()
        DataManager.sharedManager.refreshHouses(onDone: {(house:[House]) in return})
        
        //Handle the user being logged in or not.
        if Auth.auth().currentUser != nil {
            Cely.changeStatus(to: .loggedIn)
            DataManager.sharedManager.getUserWhenLogginIn(id: (Auth.auth().currentUser?.uid)!, onDone: { (success:Bool) in
                if(success){
                    User.save(Auth.auth().currentUser?.uid as Any, as: .id)
                }
                else{
                    try! Auth.auth().signOut() // Sign out from firebase
                    Cely.logout()
                    UIViewController().notify(title: "Could Not Find User Data", subtitle: "Please try signing in again.", style: .danger) //Create drop down message
                }
            })
            Cely.setup(with: window!, forModel: User(), requiredProperties: [.id], withOptions: [
                .loginStoryboard: UIStoryboard(name: "LoginStoryboard", bundle: nil)
                ])
        }
        else{
            Cely.setup(with: window!, forModel: User(), requiredProperties: [.id], withOptions: [
                .loginStoryboard: UIStoryboard(name: "LoginStoryboard", bundle: nil)
                ])
        }
        return true
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let testExist = dynamicLink.url else {
            print("Dynamic link object has no url.")
            return
        }
        // Flutter adds /# in URL. This needs to be removed.
        let modifiedURL = URL(string: (dynamicLink.url!.absoluteString.replacingOccurrences(of: "/#", with: "")))
        guard let url = modifiedURL else {
            print("Dynamic link object has no url.")
            return
        }
        print("Your modified incoming link parameter is \(url.absoluteString)")

        print("path", url.path)
        print("path extension", url.pathExtension)
        let components = url.pathComponents
        if (components.count == 3) {
            if (components[1] == "addpoints") {
                DataManager.sharedManager.handlePointLink(id: components[2])
            }
            else if (components[1] == "createaccount") {
                // Check that user is not already logged in
                if (Cely.currentLoginStatus() == CelyStatus.loggedIn) {
                    let banner = NotificationBanner(title: "Failure", subtitle: "Another user is already logged in.", style: .danger)
                    banner.duration = 2
                    banner.show()
                    return
                }
                // Get usertype from code
                guard let houseCodes = DataManager.sharedManager.getHouseCodes() else {
                    let banner = NotificationBanner(title: "Failure", subtitle: "Unabled to confirm valid house code.", style: .danger)
                    banner.duration = 2
                    banner.show()
                    return
                }
                for code in houseCodes {
                    if (components[2] == code.code) {
                        // Check that permission level is able to be created in app
                        if (code.permissionLevel == PointType.PermissionLevel.rec.rawValue) {
                            let banner = NotificationBanner(title: "Failure", subtitle: "REC account creation is not available in the app at this time.", style: .danger)
                            banner.duration = 2
                            banner.show()
                        }
                        else if (code.permissionLevel == PointType.PermissionLevel.faculty.rawValue) {
                            let banner = NotificationBanner(title: "Failure", subtitle: "Faculty account creation is not available in the app at this time.", style: .danger)
                            banner.duration = 2
                            banner.show()
                        }
                        else if (code.permissionLevel == PointType.PermissionLevel.ea.rawValue) {
                            let banner = NotificationBanner(title: "Failure", subtitle: "External Advisor account creation is not available in the app at this time.", style: .danger)
                            banner.duration = 2
                            banner.show()
                        } else {
                            let signUpStoryboard:UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                            let signUpPage = signUpStoryboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                            self.window?.setCurrentViewController(to: signUpPage)
                            signUpPage.backButton.addTarget(signUpPage, action: #selector(signUpPage.goToLogin), for: .touchUpInside)
                            SignUpViewController.houseCode = code.code
                        }
                    }
                }
                // Check that usertype can be created
                // Take to page to create account with that code
            }
        } else {
            let banner = NotificationBanner(title: "Failure", subtitle: "Illegal Link.", style: .danger)
            banner.duration = 2
            banner.show()
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.referrerURL {
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, err) in
                guard err == nil else {
                    print("Found an error! \(err!.localizedDescription)")
                    return
                }
            
                if let dynamicLink = dynamicLink {
                    DataManager.sharedManager.refreshHouses { (houses) in
                        self.handleIncomingDynamicLink(dynamicLink)
                   }
                }
            }
            if (linkHandled) {
                return true
            } else {
                // Displays message when there is an issue with the uri link
                let banner = NotificationBanner(title: "Failure", subtitle: "Link is not formatted correctly.", style: .danger)
                banner.duration = 2
                banner.show()
                return false
            }
        }
        return false
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//      return application(app, open: url,
//                         sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//                         annotation: "")
//    }
//
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//      if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
//        // Handle the deep link. For example, show the deep-linked content or
//        // apply a promotional offer to the user's account.
//        // ...
//        print("In the source application open url function")
//        handleIncomingDynamicLink(dynamicLink)
//        return true
//      }
//      return false
//    }
    
    
    // This method will handle the case where a URI is sent to the app from a link or a QR code
    // the format is hcrpoint://addpoints/<linkId>
    // Returns true if this app can handle this link
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//
//        guard let urlPath = url.path as String? , let urlHost  = url.host as String? else {
//            // Displays message when there is an issue with the uri link
//            let banner = NotificationBanner(title: "Failure", subtitle: "Link is not formatted correctly.", style: .danger)
//            banner.duration = 2
//            banner.show()
//            return false
//        }
//
//        // handles the link
//        if(urlHost == "addpoints"){
//            //this makes sure it has the format /<linkId>
//            let pathParts = urlPath.split(separator: "/")
//            if(pathParts.count == 1){
//                let linkID = pathParts[0].description.replacingOccurrences(of: "/", with: "")
//                DataManager.sharedManager.handlePointLink(id: linkID)
//                return true
//            }
//            else{
//                // Issue with the link, so cause error
//                let banner = NotificationBanner(title: "Failure", subtitle: "Illegal Link.", style: .danger)
//                banner.duration = 2
//                banner.show()
//                return false
//            }
//        }
//        return false
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }


}

