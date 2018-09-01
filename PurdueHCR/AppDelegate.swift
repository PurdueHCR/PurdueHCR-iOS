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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
                    UIViewController().notify(title: "Failure", subtitle: "Could not find data with account.", style: .danger) //Create drop down message
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
    
    // This method will handle the case where a URI is sent to the app from a link or a QR code
    // the format is hcrpoint://addpoints/<linkId>
    // Returns true if this app can handle this link
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        guard let urlPath = url.path as String? , let urlHost  = url.host as String? else {
            // Displays message when there is an issue with the uri link
            let banner = NotificationBanner(title: "Failure", subtitle: "Link is not formatted correctly.", style: .danger)
            banner.duration = 2
            banner.show()
            return false
        }
        
        // handles the link
        if(urlHost == "addpoints"){
            //this makes sure it has the format /<linkId>
            let pathParts = urlPath.split(separator: "/")
            if(pathParts.count == 1){
                let linkID = pathParts[0].description.replacingOccurrences(of: "/", with: "")
                DataManager.sharedManager.handlePointLink(id: linkID)
                return true
            }
            else{
                // Issue with the link, so cause error
                let banner = NotificationBanner(title: "Failure", subtitle: "Illegal Link.", style: .danger)
                banner.duration = 2
                banner.show()
                return false
            }
        }
        return false
    }

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

