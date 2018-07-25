//
//  AppDelegate.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/23/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import Cely
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Cely.setup(with: window!, forModel: User(), requiredProperties: [.id], withOptions: [
            .loginStoryboard: UIStoryboard(name: "LoginStoryboard", bundle: nil)
            ])
        
        FirebaseApp.configure()
        DataManager.sharedManager.refreshHouses(onDone: {(house:[House]) in return})
        // Override point for customization after application launch.
        if Auth.auth().currentUser != nil {
            DataManager.sharedManager.getUserWhenLogginIn(id: (Auth.auth().currentUser?.uid)!, onDone: { (success:Bool) in
                if(success){
                    User.save(Auth.auth().currentUser?.uid as Any, as: .id)
                    Cely.changeStatus(to: .loggedIn)
                }
                else{
                    fatalError("Something bad happend that should not have happend. Somehow you have an account without a corresponding entry in user table.")
                }
            })
        }
        else{
            Cely.logout()
        }
        return true
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

